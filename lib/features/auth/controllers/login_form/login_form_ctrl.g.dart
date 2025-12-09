// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_form_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginFormCtrl)
const loginFormCtrlProvider = LoginFormCtrlProvider._();

final class LoginFormCtrlProvider
    extends $NotifierProvider<LoginFormCtrl, LoginFormState> {
  const LoginFormCtrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginFormCtrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginFormCtrlHash();

  @$internal
  @override
  LoginFormCtrl create() => LoginFormCtrl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginFormState>(value),
    );
  }
}

String _$loginFormCtrlHash() => r'5af9a6c5b466ff5db9ccaf1dd84ae2db68da5b06';

abstract class _$LoginFormCtrl extends $Notifier<LoginFormState> {
  LoginFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LoginFormState, LoginFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginFormState, LoginFormState>,
              LoginFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
