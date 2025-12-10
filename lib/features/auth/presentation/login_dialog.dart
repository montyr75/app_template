import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../../../utils/screen_utils.dart';
import '../services/auth_service.dart';
import '../services/auth_state.dart';
import 'login_form.dart';
import 'registration_form.dart';

class LoginDialog extends ConsumerStatefulWidget {
  static Future<bool> show() async {
    final result = await SmartDialog.show<bool>(
      builder: (_) => const LoginDialog(),
      clickMaskDismiss: false,
    );

    return result ?? false;
  }

  const LoginDialog({super.key});

  @override
  ConsumerState<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends ConsumerState<LoginDialog> {
  bool _loginMode = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authServiceProvider);

    // Listen for a successful login to automatically dismiss the dialog.
    ref.listen<AuthState>(authServiceProvider, (previous, next) {
      if (next.isLoggedIn && (previous?.isLoggedIn == false)) {
        SmartDialog.dismiss(result: true);
      }
    });

    return AlertDialog(
      title: Text(_loginMode ? "Sign In" : "Register"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _loginMode ? const LoginForm() : const RegistrationForm(),
            boxXXL,
            boxXXL,
            Text(_loginMode ? "Don't have an account? " : "Already have an account? "),
            boxS,
            TextButton(
              onPressed: !authState.isLoading
                  ? () {
                      setState(() {
                        _loginMode = !_loginMode;
                      });
                    }
                  : null,
              child: _loginMode ? const Text("Register") : const Text("Sign In"),
            ),
          ],
        ),
      ),
      actions: [
        const TextButton(
          onPressed: SmartDialog.dismiss,
          child: Text("Close"),
        ),
      ],
    );
  }
}
