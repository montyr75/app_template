import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utils/screen_utils.dart';
import '../controllers/registration_form/registration_form_ctrl.dart';
import '../services/auth_service.dart';

const formName = 'reg_form';

class RegistrationForm extends StatelessWidget {
  const RegistrationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoginSection(context),
        boxXXL,
        const _SubmitButton(),
      ],
    );
  }

  Widget _buildLoginSection(BuildContext context) {
    return const AutofillGroup(
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
    );
  }
}

class _EmailInput extends ConsumerStatefulWidget {
  static const inputName = "Email";

  const _EmailInput();

  @override
  ConsumerState<_EmailInput> createState() => _EmailInputState();
}

class _EmailInputState extends ConsumerState<_EmailInput> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Programmatically request focus after the first frame is built.
    // This is more reliable than `autofocus: true` in dialogs.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
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
      key: const Key('${formName}_${_EmailInput.inputName}_textField'),
      focusNode: _focusNode,
      initialValue: field.value,
      onChanged: (value) => ref.read(registrationFormCtrlProvider.notifier).emailChanged(value),
      onFieldSubmitted: (_) => ref.read(registrationFormCtrlProvider.notifier).submit(),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enableSuggestions: false,
      autocorrect: false,
      autofillHints: const [AutofillHints.email],
      decoration: InputDecoration(
        labelText: _EmailInput.inputName,
        errorText: showError ? field.displayError?.errorMsg : null,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _PasswordInput extends ConsumerWidget {
  static const inputName = "Password";

  const _PasswordInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = ref.watch(registrationFormCtrlProvider.select((state) => state.password));
    final showError = ref.watch(registrationFormCtrlProvider.select((state) => state.hasSubmitted));

    return TextFormField(
      key: const Key('${formName}_${inputName}_textField'),
      initialValue: field.value,
      obscureText: true,
      onChanged: (value) => ref.read(registrationFormCtrlProvider.notifier).passwordChanged(value),
      onFieldSubmitted: (_) => ref.read(registrationFormCtrlProvider.notifier).submit(),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      autofillHints: const [AutofillHints.newPassword],
      decoration: InputDecoration(
        labelText: inputName,
        errorText: showError ? field.displayError?.errorMsg : null,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _ConfirmPasswordInput extends ConsumerWidget {
  static const inputName = "Confirm Password";

  const _ConfirmPasswordInput();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = ref.watch(registrationFormCtrlProvider.select((state) => state.confirmPassword));
    final showError = ref.watch(registrationFormCtrlProvider.select((state) => state.hasSubmitted));

    return TextFormField(
      key: const Key('${formName}_${inputName}_textField'),
      initialValue: field.value,
      obscureText: true,
      onChanged: (value) => ref.read(registrationFormCtrlProvider.notifier).confirmPasswordChanged(value),
      onFieldSubmitted: (_) => ref.read(registrationFormCtrlProvider.notifier).submit(),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.go,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      autofillHints: const [AutofillHints.newPassword],
      decoration: InputDecoration(
        labelText: inputName,
        errorText: showError ? field.displayError?.errorMsg : null,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _SubmitButton extends ConsumerWidget {
  static const inputName = "Register";

  const _SubmitButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authServiceProvider.select((state) => state.isLoading));

    return !isLoading
        ? FilledButton(
            key: const Key('${formName}_${inputName}_button'),
            onPressed: () => ref.read(registrationFormCtrlProvider.notifier).submit(),
            child: const Text(inputName),
          )
        : const CircularProgressIndicator();
  }
}
