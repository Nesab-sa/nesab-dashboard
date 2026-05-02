import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nesab_dashboard/features/dashboard/data/models/user_model.dart';

/// Firestore collection for dashboard managers (admins/users with dashboard access).
const String managersCollection = 'managers';

/// Remote datasource for auth: Firebase Auth + Firestore [managers] collection.
class AuthRemoteDatasource {
  AuthRemoteDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<DocumentSnapshot<Map<String, dynamic>>> getManagerDoc(String uid) {
    return _firestore.collection(managersCollection).doc(uid).get();
  }

  /// Parses a Firestore document into [UserModel].
  UserModel parseManagerDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final name = (data['name'] ?? data['displayName'] ?? '').toString();
    final email = (data['email'] ?? '').toString();
    final role = (data['role'] ?? 'user').toString().toLowerCase();
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : createdAtRaw != null
            ? (DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now())
            : DateTime.now();
    return UserModel(
      id: doc.id,
      name: name.isNotEmpty ? name : email,
      email: email,
      role: role,
      createdAt: createdAt,
    );
  }
}
