// The table harness's in-process backend: one FakeFirebaseFirestore shared by every seat, and a MockFirebaseAuth per
// seat. No rules and no real contention (the emulator backend covers both), but transactions run one at a time, so two
// in flight together behave like Firestore's after its contention retries: the second reads what the first wrote.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'table.dart';

/// A [FakeFirebaseFirestore] whose transactions run one after another. The fake's own transaction applies each write
/// as it is made and checks nothing at commit, so two interleaved handlers would both read the same doc and the later
/// write would silently drop the earlier one, which real Firestore never commits.
class SerialFakeFirestore extends FakeFirebaseFirestore {
  Future<void> _last = Future<void>.value();

  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) {
    final previous = _last;
    final done = Completer<void>();
    _last = done.future;
    return previous.then((_) async {
      try {
        return await super.runTransaction(transactionHandler, timeout: timeout, maxAttempts: maxAttempts);
      } finally {
        done.complete();
      }
    });
  }
}

/// One backend per test, so [reset] does nothing.
class FakeTableBackend implements TableBackend {
  final FakeFirebaseFirestore firestore = SerialFakeFirestore();

  /// Signs the seat in as `uid-<account>`, `<account>@app-template.test`, where the account is [sameAccountAs] or
  /// else [seat].
  @override
  Future<SeatWiring> wire(String seat, {String? sameAccountAs}) async {
    final account = sameAccountAs ?? seat;
    final uid = 'uid-$account';
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: uid, email: '$account@app-template.test', displayName: account),
    );
    return (uid: uid, firestore: firestore, auth: auth);
  }

  @override
  Future<void> reset() async {}
}
