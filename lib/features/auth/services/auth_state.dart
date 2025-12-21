import 'package:dart_mappable/dart_mappable.dart';

import '../models/app_user.dart';

part 'auth_state.mapper.dart';

@MappableClass()
class AuthState with AuthStateMappable {
  final bool isLoading;
  final AppUser? user;

  const AuthState({
    this.isLoading = false,
    this.user,
  });

  AuthState logout() => copyWith(user: null);

  bool get isLoggedIn => user != null;
}