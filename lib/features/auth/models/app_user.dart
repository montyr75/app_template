import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
  });

  factory AppUser.fromFBUser(User user) {
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, displayName: $displayName}';
  }
}
