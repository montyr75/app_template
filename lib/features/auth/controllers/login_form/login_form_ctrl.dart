import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../models/form_models.dart';
import '../../services/auth_service.dart';
import 'login_form_state.dart';

part 'login_form_ctrl.g.dart';

@riverpod
class LoginFormCtrl extends _$LoginFormCtrl {
  @override
  LoginFormState build() => const LoginFormState();

  void emailChanged(String value) {
    state = state.copyWith(
      email: RequiredEmailFormField.dirty(value),
    );
  }

  void passwordChanged(String value) {
    state = state.copyWith(
      password: RequiredStringFormField.dirty(value),
    );
  }

  Future<void> submit() async {
    if (!state.hasSubmitted) {
      state = state.copyWith(hasSubmitted: true);
    }

    if (state.isValid) {
      ref
          .read(authServiceProvider.notifier)
          .login(
            email: state.email.value.trim(),
            password: state.password.value.trim(),
          );
    }
  }
}
