import 'package:app_template/widgets/tap_target.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/interaction_checks.dart';

const _mouseId = 1; // TestGesture uses the pointer id as the device id
const _key = ValueKey<String>('target');

Widget _app({
  VoidCallback? onTap,
  String? tooltip,
  String? semanticLabel,
  bool excludeChildSemantics = false,
  Widget Function(BuildContext, TapTargetStates)? builder,
  Widget? child,
  Map<ShortcutActivator, Intent>? shortcuts,
  Map<Type, Action<Intent>>? actions,
  Widget Function(BuildContext, String, Widget)? tooltipBuilder,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: TapTarget(
          key: _key,
          onTap: onTap,
          tooltip: tooltip,
          tooltipBuilder: tooltipBuilder,
          semanticLabel: semanticLabel,
          excludeChildSemantics: excludeChildSemantics,
          shortcuts: shortcuts,
          actions: actions,
          builder: builder,
          child: builder == null ? (child ?? const SizedBox(width: 60, height: 40, child: Icon(Icons.close))) : null,
        ),
      ),
    ),
  );
}

Future<TestGesture> _pump(
  WidgetTester tester, {
  VoidCallback? onTap,
  String? tooltip,
  Widget Function(BuildContext, TapTargetStates)? builder,
}) async {
  await tester.pumpWidget(_app(onTap: onTap, tooltip: tooltip, builder: builder));
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse, pointer: _mouseId);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await tester.pump();
  return mouse;
}

MouseCursor _cursorAtTarget(WidgetTester tester) => tester.binding.mouseTracker.debugDeviceActiveCursor(_mouseId)!;

Future<Object?> _guardFailure(WidgetTester tester) async {
  try {
    await expectDesktopReady(tester);
  } on TestFailure catch (e) {
    return e;
  }
  return null;
}

class _ExplainIntent extends Intent {
  const _ExplainIntent();
}

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

  testWidgets('is one semantics node: a focusable button carrying the tap, with no child nodes', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, onTap: () {}, tooltip: 'Close');

    final node = tester.getSemantics(find.byType(GestureDetector));
    expect(node, isSemantics(isButton: true, isEnabled: true, hasTapAction: true, isFocusable: true));
    expect(node.childrenCount, 0);
    handle.dispose();
  });

  testWidgets('excludeChildSemantics drops the face but keeps the focus and the tap', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        onTap: () {},
        semanticLabel: 'Save',
        excludeChildSemantics: true,
        child: const SizedBox(width: 60, height: 40, child: Text('S')),
      ),
    );

    final node = tester.getSemantics(find.byType(GestureDetector));
    expect(node, isSemantics(isButton: true, isFocusable: true, hasTapAction: true, label: 'Save'));
    expect(node.childrenCount, 0);
    handle.dispose();
  });

  testWidgets('hands hovered, focused, focus-ring, and pressed states to the builder', (tester) async {
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
    expect(last!.focused, isFalse);

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

    // Focus by keyboard shows the ring; the ring follows Flutter's highlight mode, the focus flag does not.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(last!.focused, isTrue);
    expect(last!.showsFocusRing, isTrue);
  });

  testWidgets('a target disabled mid-press forgets the press', (tester) async {
    TapTargetStates? last;
    Widget face(BuildContext context, TapTargetStates states) {
      last = states;
      return const SizedBox(width: 60, height: 40, child: Icon(Icons.close));
    }

    await tester.pumpWidget(_app(onTap: () {}, builder: face));
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(_key)));
    await tester.pump(kPressTimeout);
    expect(last!.pressed, isTrue);

    await tester.pumpWidget(_app(onTap: null, builder: face));
    expect(last!.pressed, isFalse);
    await gesture.cancel();

    await tester.pumpWidget(_app(onTap: () {}, builder: face));
    expect(last!.pressed, isFalse, reason: 're-enabled with no press in progress');
  });

  testWidgets('extra shortcuts and actions fire while focused, with the node still the button', (tester) async {
    final handle = tester.ensureSemantics();
    var explained = 0;
    await tester.pumpWidget(
      _app(
        onTap: () {},
        semanticLabel: 'Close',
        shortcuts: {const SingleActivator(LogicalKeyboardKey.f10, shift: true): const _ExplainIntent()},
        actions: {_ExplainIntent: CallbackAction<_ExplainIntent>(onInvoke: (_) => explained++)},
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.f10);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(explained, 1);

    expect(tester.getSemantics(find.byKey(_key)), isSemantics(isButton: true, label: 'Close'));
    handle.dispose();
  });

  testWidgets('tooltipBuilder replaces the Material tooltip and satisfies the guard', (tester) async {
    await tester.pumpWidget(
      _app(
        onTap: () {},
        tooltip: 'Close',
        tooltipBuilder: (context, message, child) => Semantics(tooltip: message, child: child),
      ),
    );

    expect(find.byType(Tooltip), findsNothing);
    expect(find.byWidgetPredicate((w) => w is Semantics && w.properties.tooltip == 'Close'), findsOneWidget);
    await expectDesktopReady(tester);
  });

  testWidgets('the guard flags an icon-only target without a tooltip', (tester) async {
    await _pump(tester, onTap: () {});

    final failure = await _guardFailure(tester);
    expect(failure, isNotNull);
    expect('$failure', contains('no tooltip: TapTarget'));
  });

  testWidgets('the guard treats a lone glyph as no name, and a word as one', (tester) async {
    await tester.pumpWidget(_app(onTap: () {}, child: const Text('←')));
    expect('${await _guardFailure(tester)}', contains('no tooltip: TapTarget'));

    await tester.pumpWidget(_app(onTap: () {}, child: const Text('Back')));
    expect(await _guardFailure(tester), isNull);
  });

  testWidgets('the guard flags a bare GestureDetector', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GestureDetector(onTap: () {}, child: const Text('Bare')),
        ),
      ),
    );

    final failure = await _guardFailure(tester);
    expect(failure, isNotNull);
    expect('$failure', contains('no click cursor: GestureDetector'));
  });
}
