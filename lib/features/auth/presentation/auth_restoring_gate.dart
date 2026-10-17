import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../services/auth_service.dart';

/// Covers the app with the theme's scaffold background until FirebaseAuth has reported for the first time, so a
/// restored user never sees the login page flash before the home route. Non-interactive, so it carries no key and no
/// Marionette registration; the router waits too (see `authRedirect`).
class AuthRestoringGate extends ConsumerWidget {
  final Widget? child;

  const AuthRestoringGate({super.key, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRestoring = ref.watch(authServiceProvider.select((auth) => auth.isRestoring));
    if (isRestoring) {
      return ColoredBox(color: Theme.of(context).scaffoldBackgroundColor, child: const SizedBox.expand());
    }
    return child ?? const SizedBox.shrink();
  }
}
