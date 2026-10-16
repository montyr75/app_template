import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// `--dart-define=USE_EMULATOR=true` points the app at the local Firebase emulators. `main` honors it only under
/// `kDebugMode`.
const bool useEmulator = bool.fromEnvironment('USE_EMULATOR');

/// `--dart-define=EMULATOR_HOST=<ip>` overrides the emulator host (a physical device needs the PC's LAN address).
const String emulatorHostOverride = String.fromEnvironment('EMULATOR_HOST');

const int authEmulatorPort = 9099;
const int firestoreEmulatorPort = 8080;

/// The project the emulators run as. It matches `firebase_options.dart`, `.firebaserc`, and the `--project` flag in
/// `tool/emulators/*.cmd`; `flutterfire configure` and `firebase use` change the first two, so change the rest with them.
const String emulatorProjectId = 'demo-app-template';

/// The override when non-empty, else `10.0.2.2` for the Android emulator (outside the web), else loopback.
String resolveEmulatorHost({required String override, required TargetPlatform platform, required bool isWeb}) {
  if (override.isNotEmpty) return override;
  if (!isWeb && platform == TargetPlatform.android) return '10.0.2.2';
  return '127.0.0.1';
}

/// Points Auth and Firestore of [app] (default: the default app) at the emulators. Firestore persistence is off so a
/// wiped emulator never meets a stale local cache. Returns the host used.
Future<String> connectEmulators({FirebaseApp? app}) async {
  final host = resolveEmulatorHost(
    override: emulatorHostOverride,
    platform: defaultTargetPlatform,
    isWeb: kIsWeb,
  );
  final target = app ?? Firebase.app();
  await FirebaseAuth.instanceFor(app: target).useAuthEmulator(host, authEmulatorPort);
  FirebaseFirestore.instanceFor(app: target)
    ..settings = const Settings(persistenceEnabled: false)
    ..useFirestoreEmulator(host, firestoreEmulatorPort);
  return host;
}
