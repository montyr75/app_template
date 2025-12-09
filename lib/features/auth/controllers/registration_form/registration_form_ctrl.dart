import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../models/form_models.dart';
import '../../services/auth_service.dart';
import 'registration_form_state.dart';

part 'registration_form_ctrl.g.dart';

@riverpod
class RegistrationFormCtrl extends _$RegistrationFormCtrl {
  @override
  RegistrationFormState build() => const RegistrationFormState();

  void emailChanged(String value) {
    state = state.copyWith(
      email: RequiredEmailFormField.dirty(value),
    );
  }

  void passwordChanged(String value) {
    state = state.copyWith(
      password: RequiredFirebaseNewPasswordFormField.dirty(value),
    );
  }

  void confirmPasswordChanged(String value) {
    state = state.copyWith(
      confirmPassword: RequiredConfirmPasswordFormField.dirty(match: state.password.value, value: value),
    );
  }

  void submit() {
    if (!state.hasSubmitted) {
      state = state.copyWith(hasSubmitted: true);
    }

    if (state.isValid) {
      ref
          .read(authServiceProvider.notifier)
          .register(
            email: state.email.value.trim(),
            password: state.password.value.trim(),
          );
    }
  }
}
