// The harness's own scenarios: seats sign in and each sees its own account. They prove the per-seat provider overrides
// on both backends before any service depends on them.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'table.dart';

final signInScenarios = <TableScenario>[
  TableScenario('three seats sign in as three accounts', (table) async {
    final seats = [await table.seat('p1'), await table.seat('p2'), await table.seat('p3')];

    expect({for (final seat in seats) seat.uid}, hasLength(3));
    for (final seat in seats) {
      expect(seat.user!.id, seat.uid, reason: '${seat.name} sees its own account');
    }
  }),
  TableScenario('a second device of one account shares its uid', (table) async {
    final first = await table.seat('p1');
    final second = await table.seat('p1-second', sameAccountAs: 'p1');

    expect(second.uid, first.uid);
  }),
  TableScenario("the rules refuse a seat's write", emulatorOnly: true, (table) async {
    final p1 = await table.seat('p1');

    // A plain write, not a transaction: on Windows desktop a transaction the rules refuse never completes.
    await expectLater(
      p1.firestore.doc('games/harness').set({'hostUid': p1.uid}),
      throwsA(isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied')),
    );
  }),
];
