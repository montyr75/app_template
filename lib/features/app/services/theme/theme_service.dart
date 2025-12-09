import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'theme_state.dart';

part 'theme_service.g.dart';

@riverpod
class ThemeService extends _$ThemeService {
  @override
  ThemeState build() {
    final light = FlexThemeData.light(scheme: FlexScheme.greyLaw);
    final dark = FlexThemeData.dark(scheme: FlexScheme.greyLaw);

    return ThemeState(
      light: _modTheme(light),
      dark: _modTheme(dark),
    );
  }

  /// Use this to customize the color scheme.
  ThemeData _modTheme(ThemeData data) {
    final textTheme = _buildTextTheme(data.textTheme);
  
    return data.copyWith(
      // filledButtonTheme: FilledButtonThemeData(
      //   style: FilledButton.styleFrom(
      //     backgroundColor: Colors.cyanAccent,
      //     foregroundColor: Colors.black,
      //     shape: const BeveledRectangleBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(sm)),
      //     ),
      //     textStyle: textTheme.titleSmall,
      //   ),
      // ),
      // outlinedButtonTheme: OutlinedButtonThemeData(
      //   style: OutlinedButton.styleFrom(
      //     foregroundColor: Colors.white,
      //     shape: const BeveledRectangleBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(sm)),
      //     ),
      //     textStyle: textTheme.titleSmall,
      //   ),
      // ),
      // inputDecorationTheme: data.inputDecorationTheme.copyWith(
      //   filled: false,
      // ),
      // popupMenuTheme: data.popupMenuTheme.copyWith(
      //   color: Colors.black87,
      // ),
      // dialogTheme: data.dialogTheme.copyWith(
      //   backgroundColor: Colors.black87,
      //   shape: const BeveledRectangleBorder(
      //     side: BorderSide(width: 2, color: Colors.white30),
      //     borderRadius: BorderRadius.all(Radius.circular(med)),
      //   ),
      // ),
      textTheme: textTheme,
    );
  }

  /// Use this to customize the text theme.
  TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge!.copyWith(
        fontSize: 57,
        fontFamily: 'Roboto',
      ),
      displayMedium: base.displayMedium!.copyWith(
        fontSize: 45,
        fontFamily: 'Roboto',
      ),
      displaySmall: base.displaySmall!.copyWith(
        fontSize: 36,
        fontFamily: 'Roboto',
      ),
      headlineLarge: base.headlineLarge!.copyWith(
        fontSize: 32,
        fontFamily: 'Roboto',
      ),
      headlineMedium: base.headlineMedium!.copyWith(
        fontSize: 28,
        fontFamily: 'Roboto',
      ),
      headlineSmall: base.headlineSmall!.copyWith(
        fontSize: 24,
        fontFamily: 'Roboto',
      ),
      titleLarge: base.titleLarge!.copyWith(
        fontSize: 22,
        fontFamily: 'Roboto',
      ),
      // TextField default
      titleMedium: base.titleMedium!.copyWith(
        fontSize: 16,
        fontFamily: 'Roboto',
      ),
      titleSmall: base.titleSmall!.copyWith(
        fontSize: 14,
        fontFamily: 'Roboto',
      ),
      bodyLarge: base.bodyLarge!.copyWith(
        fontSize: 16,
        fontFamily: 'Roboto',
      ),
      // Text default
      bodyMedium: base.bodyMedium!.copyWith(
        fontSize: 14,
        fontFamily: 'Roboto',
      ),
      bodySmall: base.bodySmall!.copyWith(
        fontSize: 12,
        fontFamily: 'Roboto',
      ),
      labelLarge: base.labelLarge!.copyWith(
        fontSize: 14,
        fontFamily: 'Roboto',
      ),
      labelMedium: base.labelMedium!.copyWith(
        fontSize: 12,
        fontFamily: 'Roboto',
      ),
      labelSmall: base.labelSmall!.copyWith(
        fontSize: 10,
        fontFamily: 'Roboto',
      ),
    );
  }

  void onModeChange(ThemeMode value) {
    state = state.copyWith(mode: value);
  }
}
