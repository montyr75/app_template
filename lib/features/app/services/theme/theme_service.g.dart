// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the light and dark [ThemeData] and the mode. The themes themselves are built in `app_theme.dart`; this
/// plumbing never changes between apps. An app that is dark-only passes its dark theme to both slots and fixes the mode.

@ProviderFor(ThemeService)
final themeServiceProvider = ThemeServiceProvider._();

/// Holds the light and dark [ThemeData] and the mode. The themes themselves are built in `app_theme.dart`; this
/// plumbing never changes between apps. An app that is dark-only passes its dark theme to both slots and fixes the mode.
final class ThemeServiceProvider
    extends $NotifierProvider<ThemeService, ThemeState> {
  /// Holds the light and dark [ThemeData] and the mode. The themes themselves are built in `app_theme.dart`; this
  /// plumbing never changes between apps. An app that is dark-only passes its dark theme to both slots and fixes the mode.
  ThemeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeServiceHash();

  @$internal
  @override
  ThemeService create() => ThemeService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeState>(value),
    );
  }
}

String _$themeServiceHash() => r'583dd21e08bb3c93e33aac0382ea1fb146fc70db';

/// Holds the light and dark [ThemeData] and the mode. The themes themselves are built in `app_theme.dart`; this
/// plumbing never changes between apps. An app that is dark-only passes its dark theme to both slots and fixes the mode.

abstract class _$ThemeService extends $Notifier<ThemeState> {
  ThemeState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ThemeState, ThemeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeState, ThemeState>,
              ThemeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
