// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_form_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginFormCtrl)
final loginFormCtrlProvider = LoginFormCtrlProvider._();

final class LoginFormCtrlProvider
    extends $NotifierProvider<LoginFormCtrl, LoginFormState> {
  LoginFormCtrlProvider._()
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

String _$loginFormCtrlHash() => r'742824f84e6eec96b07767f27de63aef6eba8f72';

abstract class _$LoginFormCtrl extends $Notifier<LoginFormState> {
  LoginFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LoginFormState, LoginFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginFormState, LoginFormState>,
              LoginFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
