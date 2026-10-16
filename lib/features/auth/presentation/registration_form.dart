import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../utils/screen_utils.dart';
import '../controllers/registration_form/registration_form_ctrl.dart';
import '../services/auth_service.dart';

class RegistrationForm extends StatelessWidget {
  const RegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EmailInput(),
              boxXL,
              _PasswordInput(),
              boxXL,
              _ConfirmPasswordInput(),
            ],
          ),
        ),
        boxXXL,
        _SubmitButton(),
      ],
    );
  }
}

class _EmailInput extends ConsumerStatefulWidget {
  const _EmailInput();

  @override
  ConsumerState<_EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends ConsumerState<_EmailInput> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = ref.watch(registrationFormCtrlProvider.select((state) => state.email));
    final showError = ref.watch(registrationFormCtrlProvider.select((state) => state.hasSubmitted));

    return TextFormField(
      key: const ValueKey('register_emailField'),
      focusNode: _focusNode,
      initialValue: field.value,
      onChanged: ref.read(registrationFormCtrlProvider.notifier).emailChanged,
      onFieldSubmitted: (_) => ref.read(registrationFormCtrlProvider.notifier).submit(),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enableSuggestions: false,
      autocorrect: false,
      autofillHints: const [AutofillHints.email],
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: showError ? field.displayError?.errorMsg : null,
      ),
    );
  }
}

class _PasswordInput extends ConsumerWidget {
  const _PasswordInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = ref.watch(registrationFormCtrlProvider.select((state) => state.password));
    final showError = ref.watch(registrationFormCtrlProvider.select((state) => state.hasSubmitted));

    return TextFormField(
      key: const ValueKey('register_passwordField'),
      initialValue: field.value,
      obscureText: true,
      onChanged: ref.read(registrationFormCtrlProvider.notifier).passwordChanged,
      onFieldSubmitted: (_) => ref.read(registrationFormCtrlProvider.notifier).submit(),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      autofillHints: const [AutofillHints.newPassword],
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: showError ? field.displayError?.errorMsg : null,
      ),
    );
  }
}

class _ConfirmPasswordInput extends ConsumerWidget {
  const _ConfirmPasswordInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = ref.watch(registrationFormCtrlProvider.select((state) => state.confirmPassword));
    final showError = ref.watch(registrationFormCtrlProvider.select((state) => state.hasSubmitted));

    return TextFormField(
      key: const ValueKey('register_confirmPasswordField'),
      initialValue: field.value,
      obscureText: true,
      onChanged: ref.read(registrationFormCtrlProvider.notifier).confirmPasswordChanged,
      onFieldSubmitted: (_) => ref.read(registrationFormCtrlProvider.notifier).submit(),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.go,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      autofillHints: const [AutofillHints.newPassword],
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        errorText: showError ? field.displayError?.errorMsg : null,
      ),
    );
  }
}

class _SubmitButton extends ConsumerWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authServiceProvider.select((state) => state.isLoading));

    return !isLoading
        ? FilledButton(
            key: const ValueKey('register_registerButton'),
            onPressed: () => ref.read(registrationFormCtrlProvider.notifier).submit(),
            child: const Text('Register'),
          )
        : const CircularProgressIndicator();
  }
}
