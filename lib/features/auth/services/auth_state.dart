import 'package:dart_mappable/dart_mappable.dart';

import '../models/app_user.dart';

part 'auth_state.mapper.dart';

@MappableClass()
class AuthState with AuthStateMappable {
  final bool isLoading;
  final AppUser? user;

  /// True until FirebaseAuth has reported for the first time (a persisted user is restored asynchronously), so the
  /// router can wait instead of treating the missing user as signed out. Defaults to false for a state built by hand.
  final bool isRestoring;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.isRestoring = false,
  });

  AuthState logout() => copyWith(user: null);

  bool get isLoggedIn => user != null;
}
