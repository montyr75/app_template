// The table harness: seats several users in one process, each a ProviderContainer with its own Auth, all driving the
// REAL services over one backend. Backend-agnostic: `FakeTableBackend` (flutter test) shares one FakeFirebaseFirestore;
// `EmulatorTableBackend` (integration_test, through tool\emulators\test.cmd) gives every seat its own named FirebaseApp
// on the emulators, so transactions contend for real and the rules apply. docs/testing.md has the whole story.
//
// A skeleton: seats sign in and nothing else exists to drive. As services arrive, give TestSeat a getter per service
// (`container.read(fooServiceProvider.notifier)`), give TestTable reads of the stored models, and end every scenario
// with an invariant check over them.

import 'package:app_template/db/repos/db_repo.dart';
import 'package:app_template/features/auth/models/app_user.dart';
import 'package:app_template/features/auth/repos/auth_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// What a backend hands one seat: the signed-in uid and the Firestore and Auth instances the seat's container uses.
typedef SeatWiring = ({String uid, FirebaseFirestore firestore, FirebaseAuth auth});

/// Where a table's seats live.
abstract interface class TableBackend {
  /// Wires seat [seat], signed in as the account [sameAccountAs] (a second device of that account) or, by default, as
  /// [seat] itself.
  Future<SeatWiring> wire(String seat, {String? sameAccountAs});

  /// Wipes whatever the backend holds between tables.
  Future<void> reset();
}

/// One scenario, written once and run on both backends. [emulatorOnly] scenarios need real contention or the security
/// rules (simultaneous writes, a refused write), so the fake backend skips them.
class TableScenario {
  const TableScenario(this.name, this.run, {this.emulatorOnly = false});

  final String name;
  final Future<void> Function(TestTable table) run;
  final bool emulatorOnly;
}

/// One user at the table.
class TestSeat {
  TestSeat._({required this.name, required this.uid, required this.container});

  final String name;
  final String uid;
  final ProviderContainer container;

  /// The signed-in user as this seat's app sees it.
  AppUser? get user => container.read(authStateChangesProvider).value;

  /// The Firestore this seat's services write through.
  FirebaseFirestore get firestore => container.read(firestoreProvider);

  /// Polls [read] every 50 ms until [until] accepts its value, which it returns; fails once [timeout] passes.
  Future<T> eventually<T>(
    T Function() read,
    bool Function(T) until, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (true) {
      final value = read();
      if (until(value)) return value;
      if (DateTime.now().isAfter(deadline)) {
        fail('$name: condition not reached within $timeout (last value: $value)');
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  @override
  String toString() => 'TestSeat($name, $uid)';
}

/// A table of seats over one [backend].
class TestTable {
  TestTable(this.backend);

  final TableBackend backend;
  final List<TestSeat> _seats = [];

  List<TestSeat> get seats => List.unmodifiable(_seats);

  /// Seats [name] (signed in as [sameAccountAs] when given) and returns once its app reports the sign-in.
  Future<TestSeat> seat(String name, {String? sameAccountAs}) async {
    final wiring = await backend.wire(name, sameAccountAs: sameAccountAs);
    final container = ProviderContainer(
      overrides: [
        firestoreProvider.overrideWithValue(wiring.firestore),
        firebaseAuthProvider.overrideWithValue(wiring.auth),
      ],
    );
    final seat = TestSeat._(name: name, uid: wiring.uid, container: container);
    _seats.add(seat);

    container.listen(authStateChangesProvider, (_, _) {}, fireImmediately: true);
    await seat.eventually(() => seat.user, (user) => user != null);
    expect(seat.user!.id, wiring.uid, reason: '$name signed in as the wired uid');
    return seat;
  }

  /// Disposes every seat's container and resets the backend.
  Future<void> dispose() async {
    for (final seat in _seats) {
      seat.container.dispose();
    }
    _seats.clear();
    await backend.reset();
  }
}

/// Runs [scenario] on a fresh table over [backend], disposing the table afterwards.
Future<void> runOnTable(TableScenario scenario, TableBackend backend) async {
  final table = TestTable(backend);
  try {
    await scenario.run(table);
  } finally {
    await table.dispose();
  }
}
