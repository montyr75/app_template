import 'package:material_ui/material_ui.dart';

/// The kernel's placeholder theme, hand-built in the shape every app keeps (ARCHITECTURE.md §9): one [ColorScheme],
/// one [TextTheme] mapped to the app's display, body, and label faces, component themes, and the two
/// [ThemeExtension]s reached through [AppColorsContext] and [AppStylesContext]. A real app replaces the values below
/// with its design system's tokens (its `DESIGN.md` or approved UI spec), never invents them here, and names its
/// bundled font families in [fontDisplay], [fontBody], and [fontLabel].

/// The seed the placeholder schemes derive from. A real app lists its full [ColorScheme] instead.
const seedColor = Color(0xFF3F51B5);

/// Font families, as `pubspec.yaml` names them. Roboto is Flutter's bundled default, so the kernel ships no font files.
const fontDisplay = 'Roboto';
const fontBody = 'Roboto';
const fontLabel = 'Roboto';

/// The widest a page's content grows on a wide screen.
const pageMaxWidth = 640.0;

ThemeData buildAppTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: brightness);
  final textTheme = _buildTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarTheme(centerTitle: true, titleTextStyle: textTheme.titleLarge),
    inputDecorationTheme: const InputDecorationTheme(isDense: true, border: OutlineInputBorder()),
    extensions: [
      AppColors.of(brightness),
      AppStyles.of(textTheme, scheme),
    ],
  );
}

/// Maps the Material type scale onto the three faces: display and headline styles to [fontDisplay], title and body
/// styles to [fontBody], and label styles to [fontLabel].
TextTheme _buildTextTheme(TextTheme base) {
  TextStyle? face(TextStyle? style, String family) => style?.copyWith(fontFamily: family);

  return base.copyWith(
    displayLarge: face(base.displayLarge, fontDisplay),
    displayMedium: face(base.displayMedium, fontDisplay),
    displaySmall: face(base.displaySmall, fontDisplay),
    headlineLarge: face(base.headlineLarge, fontDisplay),
    headlineMedium: face(base.headlineMedium, fontDisplay),
    headlineSmall: face(base.headlineSmall, fontDisplay),
    titleLarge: face(base.titleLarge, fontBody),
    titleMedium: face(base.titleMedium, fontBody),
    titleSmall: face(base.titleSmall, fontBody),
    bodyLarge: face(base.bodyLarge, fontBody),
    bodyMedium: face(base.bodyMedium, fontBody),
    bodySmall: face(base.bodySmall, fontBody),
    labelLarge: face(base.labelLarge, fontLabel),
    labelMedium: face(base.labelMedium, fontLabel),
    labelSmall: face(base.labelSmall, fontLabel),
  );
}

/// Brand colors the [ColorScheme] has no role for. Add a field per token; keep [copyWith] and [lerp] in step.
class AppColors extends ThemeExtension<AppColors> {
  final Color success;
  final Color warning;

  const AppColors({required this.success, required this.warning});

  static const light = AppColors(success: Color(0xFF2E7D32), warning: Color(0xFFF9A825));
  static const dark = AppColors(success: Color(0xFF81C784), warning: Color(0xFFFFD54F));

  static AppColors of(Brightness brightness) => brightness == Brightness.dark ? dark : light;

  @override
  AppColors copyWith({Color? success, Color? warning}) =>
      AppColors(success: success ?? this.success, warning: warning ?? this.warning);

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

/// Named text styles outside the Material type scale. Add a field per style; keep [copyWith] and [lerp] in step.
class AppStyles extends ThemeExtension<AppStyles> {
  /// The app's name as a wordmark, on the login page and the like.
  final TextStyle wordmark;

  const AppStyles({required this.wordmark});

  static AppStyles of(TextTheme textTheme, ColorScheme scheme) => AppStyles(
    wordmark: textTheme.headlineMedium!.copyWith(fontFamily: fontDisplay, color: scheme.primary, letterSpacing: 1.5),
  );

  @override
  AppStyles copyWith({TextStyle? wordmark}) => AppStyles(wordmark: wordmark ?? this.wordmark);

  @override
  AppStyles lerp(AppStyles? other, double t) {
    if (other == null) return this;
    return AppStyles(wordmark: TextStyle.lerp(wordmark, other.wordmark, t)!);
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

extension AppStylesContext on BuildContext {
  AppStyles get appStyles => Theme.of(this).extension<AppStyles>()!;
}
