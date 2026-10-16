import 'package:app_template/widgets/tap_target.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/interaction_checks.dart';

const _mouseId = 1; // TestGesture uses the pointer id as the device id
const _key = ValueKey<String>('target');

Future<TestGesture> _pump(
  WidgetTester tester, {
  VoidCallback? onTap,
  String? tooltip,
  Widget Function(BuildContext, TapTargetStates)? builder,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: TapTarget(
            key: _key,
            onTap: onTap,
            tooltip: tooltip,
            builder: builder,
            child: builder == null ? const SizedBox(width: 60, height: 40, child: Icon(Icons.close)) : null,
          ),
        ),
      ),
    ),
  );
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse, pointer: _mouseId);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await tester.pump();
  return mouse;
}

MouseCursor _cursorAtTarget(WidgetTester tester) => tester.binding.mouseTracker.debugDeviceActiveCursor(_mouseId)!;

void main() {
  testWidgets('shows the click cursor on hover when enabled', (tester) async {
    final mouse = await _pump(tester, onTap: () {}, tooltip: 'Close');
    await mouse.moveTo(tester.getCenter(find.byKey(_key)));
    await tester.pump();

    expect(_cursorAtTarget(tester), SystemMouseCursors.click);
  });

  testWidgets('shows the basic cursor on hover when disabled, with no tooltip and no focus', (tester) async {
    final mouse = await _pump(tester, tooltip: 'Close');
    await mouse.moveTo(tester.getCenter(find.byKey(_key)));
    await tester.pump();

    expect(_cursorAtTarget(tester), SystemMouseCursors.basic);
    expect(find.byType(Tooltip), findsNothing);
    expect(tester.widget<FocusableActionDetector>(find.byType(FocusableActionDetector)).enabled, isFalse);
  });

  testWidgets('taps through, exposes a tooltip on hover, and passes the desktop guard', (tester) async {
    var taps = 0;
    final mouse = await _pump(tester, onTap: () => taps++, tooltip: 'Close');
    await mouse.moveTo(tester.getCenter(find.byKey(_key)));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Close'), findsOneWidget);
    await tester.tap(find.byKey(_key));
    expect(taps, 1);
    await expectDesktopReady(tester);
  });

  testWidgets('takes focus and activates on Enter and Space', (tester) async {
    var taps = 0;
    await _pump(tester, onTap: () => taps++, tooltip: 'Close');

    final node = tester.widget<FocusableActionDetector>(find.byType(FocusableActionDetector));
    expect(node.enabled, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(Focus.of(tester.element(find.byIcon(Icons.close))).hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(taps, 2);
  });

  testWidgets('has button semantics carrying the tap', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, onTap: () {}, tooltip: 'Close');

    expect(
      tester.getSemantics(find.byType(GestureDetector)),
      isSemantics(isButton: true, isEnabled: true, hasTapAction: true, isFocusable: true),
    );
    handle.dispose();
  });

  testWidgets('hands hovered, focused, and pressed states to the builder', (tester) async {
    TapTargetStates? last;
    final mouse = await _pump(
      tester,
      onTap: () {},
      tooltip: 'Close',
      builder: (context, states) {
        last = states;
        return const SizedBox(width: 60, height: 40, child: Icon(Icons.close));
      },
    );
    expect(last!.hovered, isFalse);

    await mouse.moveTo(tester.getCenter(find.byKey(_key)));
    await tester.pump();
    expect(last!.hovered, isTrue);

    final gesture = await tester.startGesture(tester.getCenter(find.byKey(_key)));
    // The tap recognizer reports the down after the press timeout while the tooltip's recognizer shares the arena.
    await tester.pump(kPressTimeout);
    expect(last!.pressed, isTrue);
    await gesture.up();
    await tester.pump();
    expect(last!.pressed, isFalse);
  });

  testWidgets('the guard flags an icon-only target without a tooltip', (tester) async {
    await _pump(tester, onTap: () {});

    Object? failure;
    try {
      await expectDesktopReady(tester);
    } on TestFailure catch (e) {
      failure = e;
    }
    expect(failure, isNotNull);
    expect('$failure', contains('no tooltip: TapTarget'));
  });

  testWidgets('the guard flags a bare GestureDetector', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(onTap: () {}, child: const Text('Bare')),
        ),
      ),
    );

    Object? failure;
    try {
      await expectDesktopReady(tester);
    } on TestFailure catch (e) {
      failure = e;
    }
    expect(failure, isNotNull);
    expect('$failure', contains('no click cursor: GestureDetector'));
  });
}
