import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'app_config.dart';
import 'features/app/services/app/app_service.dart';
import 'features/app/services/theme/theme_service.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget with WidgetsBindingObserver {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(appServiceProvider);

    final themeState = ref.watch(themeServiceProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'App Template',
      theme: themeState.light,
      darkTheme: themeState.dark,
      themeMode: themeState.mode,
      restorationScopeId: 'app',
      routerConfig: ref.watch(goRouterProvider),
      builder: FlutterSmartDialog.init(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        log.info('App in foreground - User can interact');
        break;

      case AppLifecycleState.inactive:
        log.info('App inactive - Transitional state');
        break;

      case AppLifecycleState.paused:
        log.info('App in background - Not visible');
        break;

      case AppLifecycleState.detached:
        log.info('App detached - About to be terminated');
        break;

      case AppLifecycleState.hidden:
        log.info('App hidden - All views obscured');
        break;
    }
  }
}
