import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../utils/screen_utils.dart';
import '../controllers/login_form/login_form_ctrl.dart';
import '../services/auth_service.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

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
    // Focus after the first frame; more reliable than `autofocus: true` inside a route transition.
    SchedulerBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = ref.watch(loginFormCtrlProvider.select((state) => state.email));
    final showError = ref.watch(loginFormCtrlProvider.select((state) => state.hasSubmitted));

    return TextFormField(
      key: const ValueKey('login_emailField'),
      initialValue: field.value,
      focusNode: _focusNode,
      onChanged: ref.read(loginFormCtrlProvider.notifier).emailChanged,
      onFieldSubmitted: (_) => ref.read(loginFormCtrlProvider.notifier).submit(),
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

class _PasswordInput extends ConsumerStatefulWidget {
  const _PasswordInput();

  @override
  ConsumerState<_PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends ConsumerState<_PasswordInput> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final field = ref.watch(loginFormCtrlProvider.select((state) => state.password));
    final showError = ref.watch(loginFormCtrlProvider.select((state) => state.hasSubmitted));

    return TextFormField(
      key: const ValueKey('login_passwordField'),
      initialValue: field.value,
      obscureText: _obscure,
      onChanged: ref.read(loginFormCtrlProvider.notifier).passwordChanged,
      onFieldSubmitted: (_) => ref.read(loginFormCtrlProvider.notifier).submit(),
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.go,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: showError ? field.displayError?.errorMsg : null,
        suffixIcon: IconButton(
          key: const ValueKey('login_passwordVisibilityButton'),
          tooltip: _obscure ? 'Show password' : 'Hide password',
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
        ),
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
            key: const ValueKey('login_signInButton'),
            onPressed: () => ref.read(loginFormCtrlProvider.notifier).submit(),
            child: const Text('Sign In'),
          )
        : const CircularProgressIndicator();
  }
}
