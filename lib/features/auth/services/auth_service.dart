import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_config.dart';
import '../models/app_user.dart';
import '../repos/auth_repo.dart';
import 'auth_state.dart';

part 'auth_service.g.dart';

@Riverpod(keepAlive: true)
class AuthService extends _$AuthService {
  @override
  AuthState build() {
    ref.listen(
      authStateChangesProvider,
      (prev, next) => _onUserChanged(next.value),
    );

    return const AuthState();
  }

  void _onUserChanged(AppUser? user) {
    final wasLoggedIn = state.isLoggedIn;
    final next = reduceUserChange(state, user);
    if (identical(next, state)) return;

    state = next;
    if (next.isLoggedIn && !wasLoggedIn) {
      log.info("USER LOGGED IN --> ${next.user}");
    } else if (!next.isLoggedIn && wasLoggedIn) {
      log.info("USER LOGGED OUT");
    }
  }

  Future<void> register({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepoProvider).register(email: email, password: password);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepoProvider).loginWithEmailAndPassword(email: email, password: password);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() => ref.read(authRepoProvider).logout();

  Future<void> sendPasswordResetEmail({required String email}) =>
      ref.read(authRepoProvider).sendPasswordResetEmail(email: email);
}

/// The pure reducer for an auth emission, factored out of [AuthService] so it is tested without Firebase. It adopts
/// profile updates for an already signed-in user, not only the sign-in transition (a fresh registration is emitted
/// first with an empty display name, then again with the real one), and returns [current] itself when nothing
/// material differs, so token refreshes never churn state.
AuthState reduceUserChange(AuthState current, AppUser? user) {
  if (user == null) {
    return current.isLoggedIn ? current.logout() : current;
  }
  if (!current.isLoggedIn || current.user != user) {
    return current.copyWith(user: user);
  }
  return current;
}
