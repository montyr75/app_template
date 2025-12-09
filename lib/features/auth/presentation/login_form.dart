import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utils/screen_utils.dart';
import '../controllers/login_form/login_form_ctrl.dart';
import '../services/auth_service.dart';

const formName = 'login_form';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

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
    final field = ref.watch(loginFormCtrlProvider.select((state) => state.email));
    final showError = ref.watch(loginFormCtrlProvider.select((state) => state.hasSubmitted));

    return TextFormField(
      key: const Key('${formName}_${_EmailInput.inputName}_textField'),
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
        labelText: _EmailInput.inputName,
        errorText: showError ? field.displayError?.errorMsg : null,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _PasswordInput extends ConsumerStatefulWidget {
  const _PasswordInput();

  @override
  ConsumerState createState() => _PasswordInputState();
}

class _PasswordInputState extends ConsumerState<_PasswordInput> {
  static const inputName = "Password";

  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final field = ref.watch(loginFormCtrlProvider.select((state) => state.password));
    final showError = ref.watch(loginFormCtrlProvider.select((state) => state.hasSubmitted));

    return TextFormField(
      key: const Key('${formName}_${inputName}_textField'),
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
        labelText: inputName,
        errorText: showError ? field.displayError?.errorMsg : null,
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscure = !_obscure;
            });
          },
          icon: _obscure ? const Icon(Icons.visibility) : const Icon(Icons.visibility_off),
        ),
      ),
    );
  }
}

class _SubmitButton extends ConsumerWidget {
  static const inputName = "Sign In";

  const _SubmitButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authServiceProvider.select((state) => state.isLoading));

    return !isLoading
        ? FilledButton(
            key: const Key('${formName}_${inputName}_button'),
            onPressed: () => ref.read(loginFormCtrlProvider.notifier).submit(),
            child: const Text(inputName),
          )
        : const CircularProgressIndicator();
  }
}
