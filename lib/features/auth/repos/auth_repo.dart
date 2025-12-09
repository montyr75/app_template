import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/services/error/error_service.dart';
import '../models/app_user.dart';

part 'auth_repo.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
AuthRepo authRepo(Ref ref) => AuthRepo(ref: ref, firebaseAuth: ref.watch(firebaseAuthProvider));

@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) =>
    ref.watch(authRepoProvider).authStateChanges.map((user) => user != null ? AppUser.fromFBUser(user) : null);

class AuthRepo {
  final Ref ref;
  final FirebaseAuth _firebaseAuth;

  AuthRepo({required this.ref, required FirebaseAuth firebaseAuth}) : _firebaseAuth = firebaseAuth;

  Future<void> register({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _handleError(error: e);
    }
  }

  Future<void> loginWithEmailAndPassword({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      _handleError(error: e);
    }
  }

  void _handleError({Object? error, StackTrace? stackTrace, String? message}) {
    final errorService = ref.read(errorServiceProvider.notifier);
    String? msg;

    if (error is FirebaseAuthException) {
      msg = error.message?.replaceAll(RegExp(r'\[.*?\]'), '').trim();
    } else if (message != null) {
      msg = message;
    }

    errorService.onError(
      provider: authRepoProvider,
      error: AppError(
        error: error,
        message: msg ?? "Unknown server error.",
        showAlert: true,
      ),
      st: stackTrace,
    );
  }

  Future<void> logout() => _firebaseAuth.signOut();

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  AppUser? get currentUser => _firebaseAuth.currentUser != null ? AppUser.fromFBUser(_firebaseAuth.currentUser!) : null;
}
