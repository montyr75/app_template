import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../routes.dart';
import '../../../utils/screen_utils.dart';
import '../../app/services/theme/app_theme.dart';
import 'registration_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: paddingAllXL,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('App Template', textAlign: TextAlign.center, style: context.appStyles.wordmark),
                  boxXXL,
                  const RegistrationForm(),
                  boxXXL,
                  TextButton(
                    key: const ValueKey('register_signInLink'),
                    onPressed: () => context.goNamed(AppRoute.login.name),
                    child: const Text('Already have an account? Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
