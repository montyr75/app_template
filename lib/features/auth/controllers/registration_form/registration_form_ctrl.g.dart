// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_form_ctrl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RegistrationFormCtrl)
const registrationFormCtrlProvider = RegistrationFormCtrlProvider._();

final class RegistrationFormCtrlProvider
    extends $NotifierProvider<RegistrationFormCtrl, RegistrationFormState> {
  const RegistrationFormCtrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registrationFormCtrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registrationFormCtrlHash();

  @$internal
  @override
  RegistrationFormCtrl create() => RegistrationFormCtrl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegistrationFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegistrationFormState>(value),
    );
  }
}

String _$registrationFormCtrlHash() =>
    r'4b7a928d5f928902714410f3f5818ee7babfce12';

abstract class _$RegistrationFormCtrl extends $Notifier<RegistrationFormState> {
  RegistrationFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RegistrationFormState, RegistrationFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RegistrationFormState, RegistrationFormState>,
              RegistrationFormState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
