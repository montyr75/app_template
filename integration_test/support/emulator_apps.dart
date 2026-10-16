// Firebase plumbing for the emulator-backed integration tests: one named FirebaseApp per seat, each with its own Auth
// session, all pointed at the Local Emulator Suite (Auth 9099, Firestore 8080, the project `emulatorProjectId`).
//
// Run through `tool\emulators\test.cmd`, never against a live project.

import 'package:app_template/dev/dev_config.dart';
import 'package:app_template/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// The password of every emulator test account (`<account>@app-template.test`).
const testPassword = 'app-template-test-1';

int _appCounter = 0;

/// Initializes the default app once with the platform options and points it at the emulators too, so nothing in a
/// test process can reach a live project through the default app.
Future<void> initTestFirebase() async {
  if (Firebase.apps.any((app) => app.name == defaultFirebaseAppName)) return;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await connectEmulators();
}

/// A new named app `'<seat>-<n>'` wired to the emulators. The name is unique per call, so no Auth session survives
/// from one test into the next.
Future<FirebaseApp> emulatorApp(String seat) async {
  await initTestFirebase();
  final app = await Firebase.initializeApp(
    name: '$seat-${_appCounter++}',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await connectEmulators(app: app);
  return app;
}

/// Signs [app] in as `'<account>@app-template.test'`, creating the account when it does not exist yet, and sets the
/// display name to [account].
Future<User> signInSeat(FirebaseApp app, String account) async {
  final auth = FirebaseAuth.instanceFor(app: app);
  final email = '$account@app-template.test';
  try {
    await auth.createUserWithEmailAndPassword(email: email, password: testPassword);
  } on FirebaseAuthException catch (e) {
    if (e.code != 'email-already-in-use') rethrow;
    await auth.signInWithEmailAndPassword(email: email, password: testPassword);
  }
  final user = auth.currentUser!;
  await user.updateDisplayName(account);
  await user.reload();
  return auth.currentUser!;
}

/// Wipes every Firestore document and every Auth account in the emulators' project.
Future<void> clearEmulators() async {
  final host = resolveEmulatorHost(override: emulatorHostOverride, platform: defaultTargetPlatform, isWeb: kIsWeb);
  final urls = [
    'http://$host:$firestoreEmulatorPort/emulator/v1/projects/$emulatorProjectId/databases/(default)/documents',
    'http://$host:$authEmulatorPort/emulator/v1/projects/$emulatorProjectId/accounts',
  ];
  for (final url in urls) {
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw StateError('clearEmulators: DELETE $url returned ${response.statusCode}: ${response.body}');
    }
  }
}
