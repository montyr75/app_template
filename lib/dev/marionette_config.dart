import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:marionette_logging/marionette_logging.dart';
import 'package:material_ui/material_ui.dart';

import '../widgets/tap_target.dart';

/// Marionette's configuration for debug builds (docs/testing.md).
///
/// [TapTarget] (ARCHITECTURE.md §9.1) is registered as interactive by type; its label is its semantic label or its
/// tooltip. Register every control built on it the same way.
///
/// Marionette 0.7 recognizes its built-in controls as `package:flutter/material.dart` types, which the app's
/// `material_ui` widgets are not, so the `material_ui` copies of those built-ins are registered here: interactive
/// ([_isMaterialInteractive]), stopping the traversal as the built-ins do ([_isMaterialStop]), and a text field's text.
/// Drop them once marionette_flutter moves to `material_ui`. Register each custom interactive widget the app adds by
/// type in [buildMarionetteConfig] and return its label from `extractText`, so `tap --text` works and
/// `get-interactive-elements` shows it, and extend `test/dev/marionette_config_test.dart`.
MarionetteConfiguration buildMarionetteConfig() => MarionetteConfiguration(
  isInteractiveElement: (element) => switch (element.widget) {
    TapTarget() => true,
    final widget => _isMaterialInteractive(widget),
  },
  shouldStopTraversalAtElement: (element) => _isMaterialStop(element.widget),
  extractText: (element) => switch (element.widget) {
    final TapTarget target => target.semanticLabel ?? target.tooltip,
    final TextField field => field.controller?.text,
    final TextFormField field => field.controller?.text,
    _ => null,
  },
  // The app logs through package:logging, so get_logs sees every log.* line.
  logCollector: LoggingLogCollector(),
);

/// Marionette's built-in interactive Material widgets, as `material_ui` types (`GestureDetector` is the widgets
/// layer's, so Marionette still finds it itself).
bool _isMaterialInteractive(Widget widget) => switch (widget) {
  Checkbox() ||
  CheckboxListTile() ||
  DropdownButton() ||
  DropdownButtonFormField() ||
  FloatingActionButton() ||
  IconButton() ||
  InkWell() ||
  PopupMenuButton() ||
  Radio() ||
  RadioListTile() ||
  SegmentedButton() ||
  Slider() ||
  Switch() ||
  SwitchListTile() ||
  TextField() ||
  TextFormField() ||
  ButtonStyleButton() => true,
  _ => false,
};

/// Marionette stops at its built-in interactive widgets except those that wrap content or show their value in a child.
bool _isMaterialStop(Widget widget) => switch (widget) {
  InkWell() || DropdownButton() || DropdownButtonFormField() || PopupMenuButton() || RadioListTile() => false,
  _ => _isMaterialInteractive(widget),
};
