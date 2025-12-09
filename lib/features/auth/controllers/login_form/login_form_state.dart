import 'package:formz/formz.dart';

import '../../../../../../models/form_models.dart';

class LoginFormState {
  final bool hasSubmitted;

  // form fields
  final RequiredEmailFormField email;
  final RequiredStringFormField password;

  const LoginFormState({
    this.hasSubmitted = false,
    this.email = const RequiredEmailFormField.dirty(),
    this.password = const RequiredStringFormField.dirty(),
  });

  LoginFormState copyWith({
    bool? hasSubmitted,
    RequiredEmailFormField? email,
    RequiredStringFormField? password,
  }) {
    return LoginFormState(
      hasSubmitted: hasSubmitted ?? this.hasSubmitted,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  List<FormzInput> get validationFields => [
    email,
    password,
  ];

  bool get isValid => Formz.validate(validationFields);

  @override
  String toString() {
    return 'LoginFormState{hasSubmitted: $hasSubmitted, email: $email, password: $password}';
  }
}
