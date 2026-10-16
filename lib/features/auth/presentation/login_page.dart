import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../routes.dart';
import '../../../utils/screen_utils.dart';
import '../../app/services/theme/app_theme.dart';
import 'login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                  const LoginForm(),
                  boxXXL,
                  TextButton(
                    key: const ValueKey('login_registerLink'),
                    onPressed: () => context.goNamed(AppRoute.register.name),
                    child: const Text("Don't have an account? Register"),
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
