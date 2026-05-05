enum AppAuthProvider {
  email,
  google,
  apple,
  guest,
}

class UserEntity {
  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.authProvider,
    this.lastLogin,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final AppAuthProvider authProvider;
  final DateTime? lastLogin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
