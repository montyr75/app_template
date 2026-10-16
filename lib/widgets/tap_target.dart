import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// The one way to make a custom (non-Material) control a real control (ARCHITECTURE.md §9.1): keyboard focus with
/// Enter and Space activating it, the click cursor when enabled and the basic cursor when not, button semantics
/// carrying the tap, an optional tooltip (required when the child shows no text), and the hovered, focused, pressed,
/// and enabled flags handed to [builder] so the control can draw its states.
///
/// Material's own buttons already are real controls; use this for shapes, tiles, chips, and branded buttons.
class TapTarget extends StatefulWidget {
  /// Null disables the target: basic cursor, no focus, no tap, no tooltip.
  final VoidCallback? onTap;

  /// Shown on hover and long-press; required when the child shows no text.
  final String? tooltip;

  /// The button's semantic label; null leaves the label to the child's text.
  final String? semanticLabel;

  /// Drop the child's own semantics so only [semanticLabel] is read (the tap action stays).
  final bool excludeChildSemantics;
  final bool? selected;
  final bool autofocus;
  final FocusNode? focusNode;

  /// The control's face when it has no states to draw; one of [child] and [builder] is given.
  final Widget? child;

  /// The control's face given its states, for drawing hover, focus, pressed, and disabled looks.
  final Widget Function(BuildContext context, TapTargetStates states)? builder;

  const TapTarget({
    super.key,
    required this.onTap,
    this.child,
    this.builder,
    this.tooltip,
    this.semanticLabel,
    this.excludeChildSemantics = false,
    this.selected,
    this.autofocus = false,
    this.focusNode,
  }) : assert((child == null) != (builder == null), 'Give TapTarget either a child or a builder.');

  bool get enabled => onTap != null;

  @override
  State<TapTarget> createState() => _TapTargetState();
}

/// What a [TapTarget] knows about itself when it draws.
class TapTargetStates {
  final bool enabled;
  final bool hovered;
  final bool focused;
  final bool pressed;

  const TapTargetStates({required this.enabled, required this.hovered, required this.focused, required this.pressed});
}

class _TapTargetState extends State<TapTarget> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  static final _shortcuts = <ShortcutActivator, Intent>{
    const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
    const SingleActivator(LogicalKeyboardKey.numpadEnter): const ActivateIntent(),
    const SingleActivator(LogicalKeyboardKey.space): const ActivateIntent(),
  };

  void _set(void Function() change) => setState(change);

  void _activate() {
    final handler = widget.onTap;
    if (handler == null) return;
    handler();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final states = TapTargetStates(
      enabled: enabled,
      hovered: enabled && _hovered,
      focused: enabled && _focused,
      pressed: enabled && _pressed,
    );
    final face = widget.builder?.call(context, states) ?? widget.child!;

    // One semantics node for the whole control: the focus node's focusable flag and focus action, the button flags
    // and label, and the tap action merge, so a screen reader meets one button.
    Widget target = MergeSemantics(
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: widget.selected,
        label: widget.semanticLabel,
        onTap: enabled ? _activate : null,
        excludeSemantics: widget.excludeChildSemantics,
        // Hover is tracked here rather than through onShowHoverHighlight, which Flutter gates behind its highlight
        // mode. The cursor is the detector's, below, which is also the one the desktop guard looks for.
        child: MouseRegion(
          cursor: MouseCursor.defer,
          onEnter: (_) => _set(() => _hovered = true),
          onExit: (_) => _set(() => _hovered = false),
          child: FocusableActionDetector(
            enabled: enabled,
            autofocus: widget.autofocus,
            focusNode: widget.focusNode,
            mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            shortcuts: _shortcuts,
            actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate())},
            onFocusChange: (value) => _set(() => _focused = value),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? _activate : null,
              onTapDown: enabled ? (_) => _set(() => _pressed = true) : null,
              onTapUp: enabled ? (_) => _set(() => _pressed = false) : null,
              onTapCancel: enabled ? () => _set(() => _pressed = false) : null,
              child: face,
            ),
          ),
        ),
      ),
    );

    final tip = widget.tooltip;
    if (enabled && tip != null && tip.isNotEmpty) {
      target = Tooltip(message: tip, excludeFromSemantics: true, child: target);
    }
    return target;
  }
}
