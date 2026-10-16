// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_repo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The only source of the Firestore client. Firestore `Settings` are applied in `main.dart` before anything touches
/// the instance; applying them here would race that on Web, where the SDK silently ignores settings after first use.

@ProviderFor(firestore)
final firestoreProvider = FirestoreProvider._();

/// The only source of the Firestore client. Firestore `Settings` are applied in `main.dart` before anything touches
/// the instance; applying them here would race that on Web, where the SDK silently ignores settings after first use.

final class FirestoreProvider
    extends
        $FunctionalProvider<
          FirebaseFirestore,
          FirebaseFirestore,
          FirebaseFirestore
        >
    with $Provider<FirebaseFirestore> {
  /// The only source of the Firestore client. Firestore `Settings` are applied in `main.dart` before anything touches
  /// the instance; applying them here would race that on Web, where the SDK silently ignores settings after first use.
  FirestoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firestoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firestoreHash();

  @$internal
  @override
  $ProviderElement<FirebaseFirestore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseFirestore create(Ref ref) {
    return firestore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseFirestore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseFirestore>(value),
    );
  }
}

String _$firestoreHash() => r'864285def6284159b44f9598dcde96347e0c1dce';

@ProviderFor(dbRepo)
final dbRepoProvider = DbRepoProvider._();

final class DbRepoProvider extends $FunctionalProvider<DbRepo, DbRepo, DbRepo>
    with $Provider<DbRepo> {
  DbRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dbRepoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dbRepoHash();

  @$internal
  @override
  $ProviderElement<DbRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DbRepo create(Ref ref) {
    return dbRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DbRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DbRepo>(value),
    );
  }
}

String _$dbRepoHash() => r'9de0cb7a4caf24bce2912b3b07485d617abac37e';
