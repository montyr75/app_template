// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ErrorService)
final errorServiceProvider = ErrorServiceProvider._();

final class ErrorServiceProvider
    extends $NotifierProvider<ErrorService, AppError?> {
  ErrorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorServiceHash();

  @$internal
  @override
  ErrorService create() => ErrorService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppError? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppError?>(value),
    );
  }
}

String _$errorServiceHash() => r'2b2c082378ab12c425f533cc9deb01e42ddad24a';

abstract class _$ErrorService extends $Notifier<AppError?> {
  AppError? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppError?, AppError?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppError?, AppError?>,
              AppError?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
