import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app_config.dart';
import '../../features/app/services/error/error_service.dart';

part 'db_repo.g.dart';

/// The only source of the Firestore client. Firestore `Settings` are applied in `main.dart` before anything touches
/// the instance; applying them here would race that on Web, where the SDK silently ignores settings after first use.
@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
DbRepo dbRepo(Ref ref) => DbRepo(ref: ref, firestore: ref.watch(firestoreProvider));

/// The only Firestore-aware layer in the app (ARCHITECTURE.md §8.1). Everything takes collection paths and document
/// ids as strings and moves `Map<String, dynamic>`; models are decoded by the stream providers and services that call
/// it. Collection path constants live in the feature service that owns them.
class DbRepo {
  final Ref ref;
  final FirebaseFirestore _firestore;

  DbRepo({required this.ref, required this._firestore});

  /// Sets (creates or overwrites) a document.
  Future<bool> setDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).set(data);
      return true;
    } catch (e, st) {
      _handleError(error: e, stackTrace: st, message: 'Failed to set document in $collectionPath/$docId.');
      return false;
    }
  }

  /// Partially updates an existing document.
  Future<bool> updateDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).update(data);
      return true;
    } catch (e, st) {
      _handleError(error: e, stackTrace: st, message: 'Failed to update document in $collectionPath/$docId.');
      return false;
    }
  }

  /// Deletes a document.
  Future<bool> deleteDocument({
    required String collectionPath,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).delete();
      return true;
    } catch (e, st) {
      _handleError(error: e, stackTrace: st, message: 'Failed to delete document from $collectionPath/$docId.');
      return false;
    }
  }

  /// Deletes a document and every document in the named subcollections. Client SDKs cannot discover subcollection
  /// names, so they are passed in, and the deletion is not recursive below them.
  Future<bool> deleteDocumentAndSubcollections({
    required String collectionPath,
    required String docId,
    required List<String> subcollectionNames,
  }) async {
    try {
      final docRef = _firestore.collection(collectionPath).doc(docId);

      for (final subcollectionName in subcollectionNames) {
        await _deleteCollectionInBatches('$collectionPath/$docId/$subcollectionName');
      }

      await docRef.delete();
      return true;
    } catch (e, st) {
      _handleError(
        error: e,
        stackTrace: st,
        message: 'Failed to delete document and subcollections for $collectionPath/$docId.',
      );
      return false;
    }
  }

  /// Reads a single document; null when the read fails.
  Future<DocumentSnapshot<Map<String, dynamic>>?> getDocument({
    required String collectionPath,
    required String docId,
  }) async {
    try {
      return await _firestore.collection(collectionPath).doc(docId).get();
    } catch (e, st) {
      _handleError(error: e, stackTrace: st, message: 'Failed to get document from $collectionPath/$docId.');
      return null;
    }
  }

  /// Reads every document in a collection; null when the read fails.
  Future<QuerySnapshot<Map<String, dynamic>>?> getCollection({required String collectionPath}) async {
    try {
      return await _firestore.collection(collectionPath).get();
    } catch (e, st) {
      _handleError(error: e, stackTrace: st, message: 'Failed to get collection from $collectionPath.');
      return null;
    }
  }

  /// Whether a document exists; false when the read fails.
  Future<bool> documentExists({
    required String collectionPath,
    required String docId,
  }) async {
    final doc = await getDocument(collectionPath: collectionPath, docId: docId);
    return doc?.exists ?? false;
  }

  /// Streams a document. An error is reported through [_handleError] and rethrown onto the stream, so a Riverpod
  /// stream provider yields `AsyncError` rather than a graceful close.
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument({
    required String collectionPath,
    required String docId,
  }) {
    return _firestore.collection(collectionPath).doc(docId).snapshots().handleError(
      (Object e, StackTrace st) {
        _handleError(error: e, stackTrace: st, message: 'Error streaming document from $collectionPath/$docId.');
        throw e;
      },
    );
  }

  /// Streams a collection. See [streamDocument] for the error contract.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({required String collectionPath}) {
    return _firestore.collection(collectionPath).snapshots().handleError(
      (Object e, StackTrace st) {
        _handleError(error: e, stackTrace: st, message: 'Error streaming collection from $collectionPath.');
        throw e;
      },
    );
  }

  /// Runs an atomic transaction. [action] receives a [TxContext], the only way to read and write inside it; reads
  /// must precede writes.
  ///
  /// Two error paths, so the user only sees toasts for failures they could act on: a [FirebaseException] (server,
  /// permission, network) is reported with a toast and rethrown; any other exception is one the caller threw on
  /// purpose (an expected race such as a lost room-code claim), so it is logged as a warning and rethrown silently for
  /// the caller to handle.
  Future<T> runTransaction<T>(Future<T> Function(TxContext tx) action) async {
    try {
      return await _firestore.runTransaction((tx) => action(_RealTxContext(tx, _firestore)));
    } on FirebaseException catch (e, st) {
      _handleError(error: e, stackTrace: st, message: 'Firestore transaction failed.');
      rethrow;
    } catch (e, st) {
      log.warning('Transaction aborted by caller: $e', e, st);
      rethrow;
    }
  }

  /// A document reference, with a fresh id when [docId] is null (`docRef(collectionPath: ...).id` mints ids).
  DocumentReference<Map<String, dynamic>> docRef({
    required String collectionPath,
    String? docId,
  }) {
    final col = _firestore.collection(collectionPath);
    return docId == null ? col.doc() : col.doc(docId);
  }

  /// A write batch, so multi-document writes compose without holding a Firestore handle.
  WriteBatch batch() => _firestore.batch();

  /// Deletes a document inside an external batch.
  void batchDelete(WriteBatch batch, {required String collectionPath, required String docId}) {
    batch.delete(_firestore.collection(collectionPath).doc(docId));
  }

  /// Deletes every document in a collection, 100 per batch (Firestore allows 500 per batch; 100 keeps memory low).
  Future<void> _deleteCollectionInBatches(String collectionPath) async {
    final collectionRef = _firestore.collection(collectionPath);
    const batchSize = 100;
    var query = collectionRef.orderBy(FieldPath.documentId).limit(batchSize);

    while (true) {
      final snapshot = await query.get();
      if (snapshot.docs.isEmpty) break;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      query = collectionRef.orderBy(FieldPath.documentId).startAfterDocument(snapshot.docs.last).limit(batchSize);
    }
  }

  void _handleError({Object? error, StackTrace? stackTrace, String? message}) {
    ref
        .read(errorServiceProvider.notifier)
        .onError(
          provider: dbRepoProvider,
          error: AppError(error: error, message: message ?? "Unknown server error.", showAlert: true),
          st: stackTrace,
        );
  }
}

/// A transaction handle: reads and writes by (collection path, document id) inside [DbRepo.runTransaction]. Test
/// fakes implement this interface; the real implementation stays private to this file.
abstract class TxContext {
  /// Reads the document inside the transaction. Callers branch on `.exists` and decode `data()` themselves.
  Future<DocumentSnapshot<Map<String, dynamic>>> get({
    required String collectionPath,
    required String docId,
  });

  /// Writes [data], replacing the document.
  void set({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  });

  /// Partially updates an existing document; fails if it does not exist.
  void update({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  });

  /// Deletes the document.
  void delete({required String collectionPath, required String docId});
}

class _RealTxContext implements TxContext {
  final Transaction _tx;
  final FirebaseFirestore _firestore;

  _RealTxContext(this._tx, this._firestore);

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get({
    required String collectionPath,
    required String docId,
  }) {
    return _tx.get(_firestore.collection(collectionPath).doc(docId));
  }

  @override
  void set({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    _tx.set(_firestore.collection(collectionPath).doc(docId), data);
  }

  @override
  void update({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    _tx.update(_firestore.collection(collectionPath).doc(docId), data);
  }

  @override
  void delete({required String collectionPath, required String docId}) {
    _tx.delete(_firestore.collection(collectionPath).doc(docId));
  }
}
