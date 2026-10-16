// Desktop and web interaction guard for widget tests (ARCHITECTURE.md §9.1): every tappable custom target shows the
// click cursor and every icon-only control carries a tooltip. Call [expectDesktopReady] at the end of every screen
// test. Copied from Kingpin Clash's test/support/interaction_checks.dart.

import 'package:app_template/widgets/tap_target.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

// The nearest MouseRegion above a tap detector: Material ink sits 4 levels up, TapTarget 1.
const _cursorSearchDepth = 6;

/// Fails, listing every offender, when the pumped tree has (a) a tappable `GestureDetector` with no click-cursor
/// `MouseRegion` just above it, or (b) an `IconButton` or [TapTarget] with no text label and no tooltip.
Future<void> expectDesktopReady(WidgetTester tester) async {
  final offenders = <String>[];
  await _rebuildAsDesktop(tester, () {
    for (final element in tester.allElements.toList()) {
      final widget = element.widget;

      if (widget is GestureDetector &&
          (widget.onTap != null || widget.onTapDown != null || widget.onLongPress != null)) {
        if (_insideTextInput(element) || _isModalBarrier(element)) continue;
        if (!_hasClickCursorAbove(element)) {
          offenders.add('no click cursor: GestureDetector ${_describe(element)}');
        }
      }

      if (widget is IconButton && (widget.tooltip ?? '').isEmpty) {
        offenders.add('no tooltip: IconButton ${_describe(element)}');
      }

      if (widget is TapTarget && widget.enabled && (widget.tooltip ?? '').isEmpty && !_hasText(element)) {
        offenders.add('no tooltip: TapTarget ${_describe(element)}');
      }
    }
  });
  expect(offenders, isEmpty, reason: 'Desktop/web interaction offenders:\n${offenders.join('\n')}');
}

/// The effective cursor is the nearest MouseRegion above the detector, unless the detector's own child is wrapped in
/// one (a region deeper in the tree wins the hit test). It must be the click cursor.
bool _hasClickCursorAbove(Element element) {
  var below = false;
  var belowClick = false;
  var node = element;
  for (var i = 0; i < 4 && !below; i++) {
    Element? next;
    node.visitChildren((c) => next = c);
    if (next == null) break;
    node = next!;
    if (node.widget is MouseRegion) {
      below = true;
      belowClick = (node.widget as MouseRegion).cursor == SystemMouseCursors.click;
    }
  }
  if (below) return belowClick;

  var depth = 0;
  var click = false;
  element.visitAncestorElements((ancestor) {
    final w = ancestor.widget;
    if (w is MouseRegion) {
      click = w.cursor == SystemMouseCursors.click;
      return false;
    }
    return ++depth < _cursorSearchDepth;
  });
  return click;
}

/// Material resolves its default cursor at build time (click only on web), so the tree is rebuilt under a desktop
/// platform before [check] inspects it, then rebuilt again under the original platform so the test carries on with
/// the screen it started with.
Future<void> _rebuildAsDesktop(WidgetTester tester, void Function() check) async {
  Future<void> rebuild() async {
    void dirty(Element e) {
      e.markNeedsBuild();
      e.visitChildren(dirty);
    }

    tester.binding.rootElement!.visitChildren(dirty);
    await tester.pump();
  }

  final original = debugDefaultTargetPlatformOverride;
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  try {
    await rebuild();
    check();
  } finally {
    debugDefaultTargetPlatformOverride = original;
    await rebuild();
  }
}

/// A modal barrier's dismiss tap is framework chrome, not an app tap target.
bool _isModalBarrier(Element element) {
  var depth = 0;
  var found = false;
  element.visitAncestorElements((ancestor) {
    if (ancestor.widget is ModalBarrier) {
      found = true;
      return false;
    }
    return ++depth < _cursorSearchDepth;
  });
  return found;
}

bool _insideTextInput(Element element) {
  var inside = false;
  element.visitAncestorElements((ancestor) {
    if (ancestor.widget is EditableText || ancestor.widget is TextFieldTapRegion) {
      inside = true;
      return false;
    }
    return true;
  });
  return inside;
}

bool _hasText(Element element) {
  var found = false;
  void visit(Element e) {
    if (found) return;
    if (e.widget is Text) {
      found = true;
      return;
    }
    e.visitChildren(visit);
  }

  element.visitChildren(visit);
  return found;
}

String _describe(Element element) {
  final own = element.widget.key;
  if (own != null) return '$own';
  var owner = '(unknown)';
  var depth = 0;
  element.visitAncestorElements((a) {
    final w = a.widget;
    final type = switch (w) {
      IconButton() => 'IconButton',
      ButtonStyleButton() => w.runtimeType.toString(),
      PopupMenuButton() => 'PopupMenuButton',
      PopupMenuItem() => 'PopupMenuItem',
      TapTarget() => 'TapTarget',
      _ => null,
    };
    if (type != null) {
      final key = w.key;
      owner = key == null ? type : '$type $key';
      return false;
    }
    if (w is InkResponse && owner == '(unknown)') owner = 'InkWell';
    return ++depth < 60;
  });
  return owner;
}
