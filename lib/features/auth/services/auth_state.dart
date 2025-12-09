import '../models/app_user.dart';

class AuthState {
  final bool isLoading;
  final AppUser? user;

  const AuthState({
    this.isLoading = false,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    AppUser? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }

  AuthState logout() => AuthState(isLoading: isLoading);

  bool get isLoggedIn => user != null;
}