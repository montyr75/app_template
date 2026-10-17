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
    ref.listen(authStateChangesProvider, (prev, next) {
      // A bare loading event carries no user yet; the first real emission ends the restoring wait.
      if (next.isLoading && !next.hasValue) return;
      _onUserChanged(next.value);
    });

    // The listener hears only emissions that come after it, so a service first read once the stream has emitted is
    // seeded with what the stream already holds, or it would miss a user who signed in before then. Restoring until
    // the stream has emitted once (a null emission is "signed out" and ends the wait).
    final first = ref.read(authStateChangesProvider);
    if (!first.hasValue && !first.hasError) return const AuthState(isRestoring: true);
    return reduceUserChange(const AuthState(isRestoring: true), first.value);
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

  Future<void> register({required String email, required String password}) =>
      _whileLoading(() => ref.read(authRepoProvider).register(email: email, password: password));

  Future<void> login({required String email, required String password}) =>
      _whileLoading(() => ref.read(authRepoProvider).loginWithEmailAndPassword(email: email, password: password));

  Future<void> logout() => ref.read(authRepoProvider).logout();

  Future<void> sendPasswordResetEmail({required String email}) =>
      ref.read(authRepoProvider).sendPasswordResetEmail(email: email);

  /// Runs [action] with `isLoading` set, and clears it afterward, whatever happens.
  Future<T> _whileLoading<T>(Future<T> Function() action) async {
    state = state.copyWith(isLoading: true);
    try {
      return await action();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

/// The pure reducer for an auth emission, factored out of [AuthService] so it is tested without Firebase. It adopts
/// profile updates for an already signed-in user, not only the sign-in transition (a fresh registration is emitted
/// first with an empty display name, then again with the real one), and returns [current] itself when nothing
/// material differs, so token refreshes never churn state. Any emission ends the restoring wait.
AuthState reduceUserChange(AuthState current, AppUser? user) {
  if (user == null) {
    if (current.isLoggedIn) return current.logout().copyWith(isRestoring: false);
    return current.isRestoring ? current.copyWith(isRestoring: false) : current;
  }
  if (!current.isLoggedIn || current.user != user || current.isRestoring) {
    return current.copyWith(user: user, isRestoring: false);
  }
  return current;
}
