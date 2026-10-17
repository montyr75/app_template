import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// The one way to make a custom (non-Material) control a real control (ARCHITECTURE.md §9.1): keyboard focus with
/// Enter and Space activating it, the click cursor when enabled and the basic cursor when not, one button semantics
/// node carrying the tap, an optional tooltip (required when the child shows no text), and the enabled, hovered,
/// focused, pressed, and focus-ring flags handed to [builder] so the control can draw its states.
///
/// Material's own buttons already are real controls; use this for shapes, tiles, chips, and branded buttons. A branded
/// skin passes [builder] for its look, [shortcuts] and [actions] for extra keys, and [tooltipBuilder] for its own
/// tooltip widget (BT Buddy's `HudTapTarget` and Kingpin Clash's `KcTapTarget` are such skins).
class TapTarget extends StatefulWidget {
  /// Null disables the target: basic cursor, no focus, no tap, no tooltip.
  final VoidCallback? onTap;

  /// Shown on hover and long-press; required when the child shows no text. Shown by Material's [Tooltip], or by
  /// [tooltipBuilder] when given.
  final String? tooltip;

  /// Builds the tooltip around the target for a skin with its own tooltip widget: called with [tooltip] and the
  /// target when the target is enabled and has a tooltip.
  final Widget Function(BuildContext context, String message, Widget child)? tooltipBuilder;

  /// The button's semantic label; null leaves the label to the child's text.
  final String? semanticLabel;

  /// Drop the face's own semantics so only [semanticLabel] is read. The node keeps its button flags, its focus, and
  /// its tap action.
  final bool excludeChildSemantics;
  final bool? selected;
  final bool autofocus;
  final FocusNode? focusNode;

  /// Keys beyond Enter and Space, bound while the target has the focus; an entry for Enter or Space replaces the
  /// default binding.
  final Map<ShortcutActivator, Intent>? shortcuts;

  /// Actions for [shortcuts]' intents; an entry for [ActivateIntent] replaces the tap.
  final Map<Type, Action<Intent>>? actions;

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
    this.tooltipBuilder,
    this.semanticLabel,
    this.excludeChildSemantics = false,
    this.selected,
    this.autofocus = false,
    this.focusNode,
    this.shortcuts,
    this.actions,
  }) : assert((child == null) != (builder == null), 'Give TapTarget either a child or a builder.');

  bool get enabled => onTap != null;

  @override
  State<TapTarget> createState() => _TapTargetState();
}

/// What a [TapTarget] knows about itself when it draws.
class TapTargetStates {
  final bool enabled;
  final bool hovered;

  /// The target has the focus, however it got it.
  final bool focused;

  /// The target has the focus and the keyboard is in use (Flutter's traditional highlight mode), so a focus ring
  /// should show; false while the user is tapping or clicking.
  final bool showsFocusRing;
  final bool pressed;

  const TapTargetStates({
    required this.enabled,
    required this.hovered,
    required this.focused,
    required this.pressed,
    this.showsFocusRing = false,
  });
}

class _TapTargetState extends State<TapTarget> {
  bool _hovered = false;
  bool _focused = false;
  bool _showsFocusRing = false;
  bool _pressed = false;

  static const _defaultShortcuts = <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
    SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
  };

  void _set(void Function() change) => setState(change);

  /// The press flag, changed only while enabled and only when it differs, so a recognizer callback that fires during a
  /// rebuild (a press cancelled as the target is disabled) never calls setState mid-build.
  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    _set(() => _pressed = value);
  }

  void _activate() {
    final handler = widget.onTap;
    if (handler == null) return;
    handler();
  }

  @override
  void didUpdateWidget(TapTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A target disabled mid-press never gets its tap-up, so the press ends here.
    if (!widget.enabled && _pressed) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final states = TapTargetStates(
      enabled: enabled,
      hovered: enabled && _hovered,
      focused: enabled && _focused,
      showsFocusRing: enabled && _focused && _showsFocusRing,
      pressed: enabled && _pressed,
    );
    Widget face = widget.builder?.call(context, states) ?? widget.child!;
    // Only the face is left out, so the node keeps its focus flags, its focus action, and its tap.
    if (widget.excludeChildSemantics) face = ExcludeSemantics(child: face);

    // One semantics node for the whole control: the focus node's focusable flag and focus action, the button flags
    // and label, and the detector's tap action merge, so a screen reader meets one button. The tap action is the
    // detector's alone: a second one on the Semantics would be an incompatible configuration, which forks the detector
    // into a second node under the merge.
    Widget target = MergeSemantics(
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: widget.selected,
        label: widget.semanticLabel,
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
            shortcuts: {..._defaultShortcuts, ...?widget.shortcuts},
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate()),
              ...?widget.actions,
            },
            onFocusChange: (value) => _set(() => _focused = value),
            onShowFocusHighlight: (value) => _set(() => _showsFocusRing = value),
            // The press callbacks stay in place while disabled (gated inside), so the recognizer survives a rebuild
            // that disables the target mid-press; the detector's semantics are left out then, so no tap action shows.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: !enabled,
              onTap: enabled ? _activate : null,
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              child: face,
            ),
          ),
        ),
      ),
    );

    final tip = widget.tooltip;
    if (enabled && tip != null && tip.isNotEmpty) {
      final build = widget.tooltipBuilder;
      target = build != null
          ? build(context, tip, target)
          : Tooltip(message: tip, excludeFromSemantics: true, child: target);
    }
    return target;
  }
}
