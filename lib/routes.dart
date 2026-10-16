import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'features/app/presentation/home_page.dart';
import 'features/app/presentation/not_found_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/auth/services/auth_service.dart';
import 'features/settings/presentation/settings_page.dart';

part 'routes.g.dart';

enum AppRoute {
  home('/'),
  login('/login'),
  register('/register'),
  settings('/settings');

  final String? _path;

  String get path => _path ?? name;

  const AppRoute([this._path]);
}

/// Where the router sends a request for [location]: logged-out users to the login page, logged-in users away from the
/// auth routes, everyone else where they asked.
@visibleForTesting
String? authRedirect({required bool isLoggedIn, required String location}) {
  final isOnAuthRoute = location == AppRoute.login.path || location == AppRoute.register.path;

  if (!isLoggedIn && !isOnAuthRoute) return AppRoute.login.path;
  if (isLoggedIn && isOnAuthRoute) return AppRoute.home.path;
  return null;
}

@riverpod
GoRouter goRouter(Ref ref) {
  // Bridges the auth service's isLoggedIn into a Listenable, so go_router re-evaluates `redirect` whenever it flips.
  final authNotifier = ValueNotifier<bool>(ref.read(authServiceProvider).isLoggedIn);
  ref.listen(authServiceProvider, (prev, next) {
    if (prev?.isLoggedIn != next.isLoggedIn) {
      authNotifier.value = next.isLoggedIn;
    }
  });
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    debugLogDiagnostics: false,
    routerNeglect: true,
    initialLocation: AppRoute.home.path,
    refreshListenable: authNotifier,
    redirect: (context, state) =>
        authRedirect(isLoggedIn: ref.read(authServiceProvider).isLoggedIn, location: state.matchedLocation),
    observers: [FlutterSmartDialog.observer],
    routes: [
      GoRoute(
        name: AppRoute.home.name,
        path: AppRoute.home.path,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: AppRoute.login.name,
        path: AppRoute.login.path,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: AppRoute.register.name,
        path: AppRoute.register.path,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        name: AppRoute.settings.name,
        path: AppRoute.settings.path,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}
