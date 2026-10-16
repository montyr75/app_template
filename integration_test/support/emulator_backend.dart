// The table harness's emulator backend: every seat is its own named FirebaseApp on the Local Emulator Suite, so
// transactions contend for real and the Firestore rules apply. Run through `tool\emulators\test.cmd`.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../test/support/table/table.dart';
import 'emulator_apps.dart';

class EmulatorTableBackend implements TableBackend {
  /// A fresh app signed in as `<account>@app-template.test`, where the account is [sameAccountAs] or else [seat]; a
  /// second device of the same account therefore gets the same uid.
  @override
  Future<SeatWiring> wire(String seat, {String? sameAccountAs}) async {
    final app = await emulatorApp(seat);
    final user = await signInSeat(app, sameAccountAs ?? seat);
    return (
      uid: user.uid,
      firestore: FirebaseFirestore.instanceFor(app: app),
      auth: FirebaseAuth.instanceFor(app: app),
    );
  }

  /// Wipes every document and account in the emulators.
  @override
  Future<void> reset() => clearEmulators();
}
