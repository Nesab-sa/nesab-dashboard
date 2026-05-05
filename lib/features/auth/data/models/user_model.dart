import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:nesab/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    required super.authProvider,
    super.lastLogin,
    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromFirebaseUser(firebase_auth.User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      authProvider: _mapProvider(user.providerData),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['imageUrl'] as String?,
      authProvider: _mapAuthProviderString(data['authProvider'] as String?),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestoreCreate() {
    final now = FieldValue.serverTimestamp();
    return {
      'displayName': displayName,
      'email': email,
      'imageUrl': photoUrl,
      'authProvider': authProvider.name,
      'lastLogin': now,
      'createdAt': now,
      'updatedAt': now,
    };
  }

  Map<String, dynamic> toFirestoreLoginUpdate() {
    final now = FieldValue.serverTimestamp();
    return {
      'displayName': displayName,
      'email': email,
      'imageUrl': photoUrl,
      'lastLogin': now,
      'updatedAt': now,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    AppAuthProvider? authProvider,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      authProvider: authProvider ?? this.authProvider,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static AppAuthProvider _mapProvider(
    List<firebase_auth.UserInfo> providerData,
  ) {
    if (providerData.any((info) => info.providerId == 'apple.com')) {
      return AppAuthProvider.apple;
    }
    if (providerData.any((info) => info.providerId == 'google.com')) {
      return AppAuthProvider.google;
    }
    if (providerData.any((info) => info.providerId == 'password')) {
      return AppAuthProvider.email;
    }
    return AppAuthProvider.guest;
  }

  static AppAuthProvider _mapAuthProviderString(String? provider) {
    return switch (provider) {
      'google' => AppAuthProvider.google,
      'apple' => AppAuthProvider.apple,
      'email' => AppAuthProvider.email,
      'guest' => AppAuthProvider.guest,
      _ => AppAuthProvider.email,
    };
  }
}
