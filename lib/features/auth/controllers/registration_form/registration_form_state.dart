import 'package:formz/formz.dart';

import '../../../../../../../models/form_models.dart';

class RegistrationFormState {
  final bool hasSubmitted;

  // form fields
  final RequiredEmailFormField email;
  final RequiredFirebaseNewPasswordFormField password;
  final RequiredConfirmPasswordFormField confirmPassword;

  const RegistrationFormState({
    this.hasSubmitted = false,
    this.email = const RequiredEmailFormField.pure(),
    this.password = const RequiredFirebaseNewPasswordFormField.pure(),
    this.confirmPassword = const RequiredConfirmPasswordFormField.pure(),
  });

  RegistrationFormState copyWith({
    bool? hasSubmitted,
    RequiredEmailFormField? email,
    RequiredFirebaseNewPasswordFormField? password,
    RequiredConfirmPasswordFormField? confirmPassword,
  }) {
    return RegistrationFormState(
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  List<FormzInput> get validationFields => [
    email,
    password,
    confirmPassword,
  ];

  bool get isValid => Formz.validate(validationFields);
}
