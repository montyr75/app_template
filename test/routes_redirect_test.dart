import 'package:app_template/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a logged-out user is sent to the login page', () {
    expect(authRedirect(isLoggedIn: false, location: AppRoute.home.path), AppRoute.login.path);
    expect(authRedirect(isLoggedIn: false, location: AppRoute.settings.path), AppRoute.login.path);
  });

  test('a logged-out user may stay on the auth routes', () {
    expect(authRedirect(isLoggedIn: false, location: AppRoute.login.path), isNull);
    expect(authRedirect(isLoggedIn: false, location: AppRoute.register.path), isNull);
  });

  test('a logged-in user is sent home from the auth routes', () {
    expect(authRedirect(isLoggedIn: true, location: AppRoute.login.path), AppRoute.home.path);
    expect(authRedirect(isLoggedIn: true, location: AppRoute.register.path), AppRoute.home.path);
  });

  test('a logged-in user goes where they asked', () {
    expect(authRedirect(isLoggedIn: true, location: AppRoute.home.path), isNull);
    expect(authRedirect(isLoggedIn: true, location: AppRoute.settings.path), isNull);
  });
}
