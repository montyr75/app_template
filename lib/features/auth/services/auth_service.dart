import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app_config.dart';
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
    if (user != null && !state.isLoggedIn) {
      state = state.copyWith(user: user);
      log.info("USER LOGGED IN --> $user");
    } else {
      state = state.logout();
      log.info("USER LOGGED OUT");
    }
  }

  Future<void> register({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);

    // await ref.read(authRepoProvider).register(email: email, password: password);

    // Simulate API call.
    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(isLoading: false);
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true);

    // await ref.read(authRepoProvider).loginWithEmailAndPassword(email: email, password: password);

    // Simulate API call.
    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(isLoading: false);
  }

  Future<void> logout() => ref.read(authRepoProvider).logout();
}
