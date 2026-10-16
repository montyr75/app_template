import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support/emulator_apps.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(initTestFirebase);

  testWidgets('two seats sign in with distinct uids and the rules refuse a write', (tester) async {
    await clearEmulators();
    final p1App = await emulatorApp('p1');
    final p2App = await emulatorApp('p2');
    final p1 = await signInSeat(p1App, 'p1');
    final p2 = await signInSeat(p2App, 'p2');

    expect(p1.uid, isNot(p2.uid));
    expect(p1.displayName, 'p1');
    expect(p2.displayName, 'p2');
    // The Auth emulator issues unsigned ID tokens; a live project's are RS256-signed.
    expect(_tokenAlgorithm(await p1.getIdToken()), 'none');

    // p1 writing a document hosted by p2: refused by the deny-all baseline rules.
    await expectLater(
      FirebaseFirestore.instanceFor(app: p1App).doc('games/smoke').set({'hostUid': p2.uid}),
      throwsA(isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied')),
    );
  });
}

/// The `alg` field of a JWT's header.
String? _tokenAlgorithm(String? token) {
  final header = token!.split('.').first;
  final json = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(header)))) as Map<String, dynamic>;
  return json['alg'] as String?;
}
