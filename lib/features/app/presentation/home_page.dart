import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../routes.dart';
import '../../../utils/screen_utils.dart';
import '../../auth/services/auth_service.dart';
import '../services/app/app_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appServiceProvider.select((state) => state.appVersion));
    final user = ref.watch(authServiceProvider.select((state) => state.user));

    final styles = context.textStyles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Template'),
        actions: [
          IconButton(
            key: const ValueKey('home_settingsButton'),
            tooltip: 'Settings',
            onPressed: () => context.pushNamed(AppRoute.settings.name),
            icon: const Icon(Icons.settings),
          ),
          IconButton(
            key: const ValueKey('home_signOutButton'),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authServiceProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: paddingAllM,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Signed in as ${user?.displayName.isNotEmpty == true ? user!.displayName : user?.email ?? ''}',
                    style: styles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Text(
                appVersion,
                style: styles.labelSmall.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
