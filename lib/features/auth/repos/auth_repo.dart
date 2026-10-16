import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/services/error/error_service.dart';
import '../models/app_user.dart';

part 'auth_repo.g.dart';

/// The only source of the Auth client (the test harness overrides it per seat).
@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@Riverpod(keepAlive: true)
AuthRepo authRepo(Ref ref) => AuthRepo(ref: ref, firebaseAuth: ref.watch(firebaseAuthProvider));

@Riverpod(keepAlive: true)
Stream<AppUser?> authStateChanges(Ref ref) =>
    ref.watch(authRepoProvider).authStateChanges.map((user) => user != null ? AppUser.fromFBUser(user) : null);

/// Email and password sign-in. Google sign-in (`signInWithPopup` on web, `google_sign_in` on Android, iOS, and macOS)
/// is added per app; Windows stays email and password (ARCHITECTURE.md §8.3).
class AuthRepo {
  final Ref ref;
  final FirebaseAuth _firebaseAuth;

  AuthRepo({required this.ref, required this._firebaseAuth});

  Future<void> register({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e, st) {
      _handleError(error: e, stackTrace: st, message: "Failed to register.");
    }
  }

  Future<void> loginWithEmailAndPassword({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e, st) {
      _handleError(error: e, stackTrace: st, message: "Failed to sign in.");
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e, st) {
      _handleError(error: e, stackTrace: st, message: "Failed to send the password reset email.");
    }
  }

  Future<void> logout() => _firebaseAuth.signOut();

  /// `userChanges` rather than `authStateChanges`, so a display-name edit re-emits the user.
  Stream<User?> get authStateChanges => _firebaseAuth.userChanges();

  AppUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? AppUser.fromFBUser(user) : null;
  }

  void _handleError({Object? error, StackTrace? stackTrace, String? message}) {
    String? msg;

    // Firebase's messages arrive as "[firebase_auth/code] The message."; the user sees the message alone.
    if (error is FirebaseAuthException && error.message != null) {
      msg = error.message!.replaceAll(RegExp(r'\[.*?\]'), '').trim();
    } else if (message != null) {
      msg = message;
    }

    ref
        .read(errorServiceProvider.notifier)
        .onError(
          provider: authRepoProvider,
          error: AppError(error: error, message: msg ?? "Unknown server error.", showAlert: true),
          st: stackTrace,
        );
  }
}
