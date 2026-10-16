import 'package:app_template/features/auth/models/app_user.dart';
import 'package:app_template/features/auth/services/auth_service.dart';
import 'package:app_template/features/auth/services/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const monty = AppUser(id: 'u1', email: 'monty@example.test', displayName: 'Monty');

  test('a sign-in adopts the user', () {
    final next = reduceUserChange(const AuthState(), monty);

    expect(next.user, monty);
    expect(next.isLoggedIn, isTrue);
  });

  test('a profile update for the signed-in user is adopted', () {
    const renamed = AppUser(id: 'u1', email: 'monty@example.test', displayName: 'Monty R.');
    final next = reduceUserChange(const AuthState(user: monty), renamed);

    expect(next.user, renamed);
  });

  test('an identical emission returns the same state', () {
    const current = AuthState(user: monty);

    expect(identical(reduceUserChange(current, monty), current), isTrue);
  });

  test('a null emission signs out, once', () {
    final signedOut = reduceUserChange(const AuthState(user: monty), null);
    expect(signedOut.isLoggedIn, isFalse);

    expect(identical(reduceUserChange(signedOut, null), signedOut), isTrue);
  });
}
