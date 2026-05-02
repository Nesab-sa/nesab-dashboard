import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

/// Firestore collection name for users.
const String usersCollection = 'users';

/// Fetches users from Firestore.
class UsersFirestoreDatasource {
  UsersFirestoreDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Fetches all users from the [users] collection.
  /// Tries orderBy(createdAt) first; falls back to unordered if index is missing.
  /// Capped at [limit] documents for performance.
  Future<List<UserModel>> getUsers({int limit = 1000}) async {
    try {
      final snapshot = await _firestore
          .collection(usersCollection)
          .orderBy(_createdAtField, descending: true)
          .limit(limit)
          .get();
      return _mapDocs(snapshot);
    } catch (_) {
      final snapshot = await _firestore
          .collection(usersCollection)
          .limit(limit)
          .get();
      return _mapDocs(snapshot);
    }
  }

  List<UserModel> _mapDocs(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }
}

/// Firestore field names (adjust if your schema differs).
const String _createdAtField = 'createdAt';
