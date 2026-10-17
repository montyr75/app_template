import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'app_config.dart';
import 'dev/dev_config.dart';
import 'dev/marionette_config.dart';
import 'features/app/services/app/app_service.dart';
import 'features/app/services/theme/theme_service.dart';
import 'features/auth/presentation/auth_restoring_gate.dart';
import 'firebase_options.dart';
import 'routes.dart';

Future<void> main() async {
  // The Marionette binding must be the first binding; nothing may call WidgetsFlutterBinding.ensureInitialized()
  // before it. Release builds never carry it.
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(buildMarionetteConfig());
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Firestore settings must be applied BEFORE anything else touches FirebaseFirestore.instance: on Web the SDK
  // silently ignores them once the instance has been used. The emulator switch sets its own (persistence off).
  if (kDebugMode && useEmulator) {
    final host = await connectEmulators();
    log.info('Using the Firebase emulators at $host');
  } else {
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  }
  log.info('Firebase initialized');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      // Bridges theme and localizations to packages still on package:flutter/material.dart (flutter_smart_dialog,
      // awesome_flutter_extensions). The gate hides the first frames until FirebaseAuth has restored any persisted
      // user, so a signed-in user never sees the login page flash.
      // ignore: deprecated_member_use
      builder: (context, child) => MaterialUiCompatibilityBridge(
        child: FlutterSmartDialog.init()(context, AuthRestoringGate(child: child)),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        log.info('App in foreground - User can interact');
      case AppLifecycleState.inactive:
        log.info('App inactive - Transitional state');
      case AppLifecycleState.paused:
        log.info('App in background - Not visible');
      case AppLifecycleState.detached:
        log.info('App detached - About to be terminated');
      case AppLifecycleState.hidden:
        log.info('App hidden - All views obscured');
    }
  }
}
