import 'dart:async';

import 'package:app_template/db/repos/db_repo.dart';
import 'package:app_template/features/app/presentation/home_page.dart';
import 'package:app_template/features/app/services/app/app_service.dart';
import 'package:app_template/features/auth/models/app_user.dart';
import 'package:app_template/features/auth/presentation/auth_restoring_gate.dart';
import 'package:app_template/features/auth/presentation/login_page.dart';
import 'package:app_template/features/auth/repos/auth_repo.dart';
import 'package:app_template/features/auth/services/auth_service.dart';
import 'package:app_template/features/auth/services/auth_state.dart';
import 'package:app_template/main.dart';
import 'package:app_template/routes.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

const _monty = AppUser(id: 'u1', email: 'monty@example.test', displayName: 'Monty');

void main() {
  test('the redirect waits while restoring, wherever the request is', () {
    for (final location in [AppRoute.home.path, AppRoute.settings.path, AppRoute.login.path]) {
      expect(authRedirect(isLoggedIn: false, isRestoring: true, location: location), isNull);
    }
  });

  group('the service', () {
    ProviderContainer containerOver(Stream<AppUser?> stream) {
      final container = ProviderContainer(overrides: [authStateChangesProvider.overrideWith((ref) => stream)]);
      addTearDown(container.dispose);
      container.listen(authServiceProvider, (_, _) {});
      return container;
    }

    test('restores until the stream emits, then follows the user', () async {
      final controller = StreamController<AppUser?>();
      addTearDown(controller.close);
      final container = containerOver(controller.stream);

      expect(container.read(authServiceProvider).isRestoring, isTrue);

      controller.add(_monty);
      await Future<void>.delayed(Duration.zero);
      var state = container.read(authServiceProvider);
      expect(state.isRestoring, isFalse);
      expect(state.isLoggedIn, isTrue);

      controller.add(null);
      await Future<void>.delayed(Duration.zero);
      state = container.read(authServiceProvider);
      expect(state.isRestoring, isFalse);
      expect(state.isLoggedIn, isFalse);
    });

    test('a first emission of null ends the wait signed out', () async {
      final controller = StreamController<AppUser?>();
      addTearDown(controller.close);
      final container = containerOver(controller.stream);

      controller.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(authServiceProvider), const AuthState());
    });

    test('a service first read after the stream has emitted is seeded with its user', () async {
      final container = ProviderContainer(
        overrides: [authStateChangesProvider.overrideWith((ref) => Stream.value(_monty))],
      );
      addTearDown(container.dispose);
      // Let the stream provider emit before anything reads the service.
      container.listen(authStateChangesProvider, (_, _) {});
      await Future<void>.delayed(Duration.zero);

      final state = container.read(authServiceProvider);
      expect(state.isRestoring, isFalse);
      expect(state.user, _monty);
    });
  });

  group('the app', () {
    late StreamController<AppUser?> controller;

    setUp(() => controller = StreamController<AppUser?>());
    tearDown(() => controller.close());

    Future<void> pumpRestoring(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
            authStateChangesProvider.overrideWith((ref) => controller.stream),
            packageInfoProvider.overrideWith(
              (ref) async =>
                  PackageInfo(appName: 'app_template', packageName: 'app_template', version: '0.1.0', buildNumber: '1'),
            ),
          ],
          child: const App(),
        ),
      );
      await tester.pump();
    }

    testWidgets('the gate wraps the app', (tester) async {
      await pumpRestoring(tester);
      expect(find.byType(AuthRestoringGate), findsOneWidget);
    });

    testWidgets('a restored user goes straight home, with no login frame', (tester) async {
      await pumpRestoring(tester);
      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(HomePage), findsNothing);

      controller.add(_monty);
      await tester.pump();
      expect(find.byType(LoginPage), findsNothing);
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('a cold start with no user reaches the login screen', (tester) async {
      await pumpRestoring(tester);
      expect(find.byType(LoginPage), findsNothing);

      controller.add(null);
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('a sign-out still redirects to the login screen', (tester) async {
      await pumpRestoring(tester);
      controller.add(_monty);
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      controller.add(null);
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}
