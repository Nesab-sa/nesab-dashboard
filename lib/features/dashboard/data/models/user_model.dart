import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    this.authProvider,
    this.lastLogin,
    this.updatedAt,
    this.displayName,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;
  final String? authProvider;
  final DateTime? lastLogin;
  final DateTime? updatedAt;
  final String? displayName;
  final String? imageUrl;

/// Creates [UserModel] from a Firestore document.
  /// Supports common field names: name/displayName, email, role, createdAt.
  factory UserModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final name = (data['name'] ?? data['displayName'] ?? doc.id).toString();
    final email = (data['email'] ?? '').toString();
    final role = (data['role'] ?? 'User').toString();
    final createdAtRaw = data['createdAt'];
    final lastLoginRaw = data['lastLogin'];
    final updatedAtRaw = data['updatedAt'];

    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : createdAtRaw != null
            ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now()
            : DateTime.now();

    final lastLogin = lastLoginRaw is Timestamp
        ? lastLoginRaw.toDate()
        : lastLoginRaw != null
            ? DateTime.tryParse(lastLoginRaw.toString())
            : null;

    final updatedAt = updatedAtRaw is Timestamp
        ? updatedAtRaw.toDate()
        : updatedAtRaw != null
            ? DateTime.tryParse(updatedAtRaw.toString())
            : null;

    return UserModel(
      id: doc.id,
      name: name,
      email: email,
      role: role,
      createdAt: createdAt,
      authProvider: data['authProvider']?.toString(),
      lastLogin: lastLogin,
      updatedAt: updatedAt,
      displayName: data['displayName']?.toString(),
      imageUrl: data['imageUrl']?.toString(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      authProvider: json['authProvider'] as String?,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      displayName: json['displayName'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
