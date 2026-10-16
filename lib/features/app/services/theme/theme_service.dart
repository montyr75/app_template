import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_theme.dart';
import 'theme_state.dart';

part 'theme_service.g.dart';

/// Holds the light and dark [ThemeData] and the mode. The themes themselves are built in `app_theme.dart`; this
/// plumbing never changes between apps. An app that is dark-only passes its dark theme to both slots and fixes the mode.
@riverpod
class ThemeService extends _$ThemeService {
  @override
  ThemeState build() {
    return ThemeState(
      light: buildAppTheme(Brightness.light),
      dark: buildAppTheme(Brightness.dark),
    );
  }

  void onModeChange(ThemeMode value) {
    state = state.copyWith(mode: value);
  }
}
