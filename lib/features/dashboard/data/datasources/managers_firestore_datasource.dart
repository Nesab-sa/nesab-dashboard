import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nesab_dashboard/features/dashboard/data/models/user_model.dart';

const String _managersCollection = 'managers';

/// Fetches managers from Firestore [managers] collection.
class ManagersFirestoreDatasource {
  ManagersFirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<UserModel>> getManagers({int limit = 500}) async {
    try {
      final snapshot = await _firestore
          .collection(_managersCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      return _mapDocs(snapshot);
    } catch (e) {
      try {
        final snapshot = await _firestore
            .collection(_managersCollection)
            .limit(limit)
            .get();
        return _mapDocs(snapshot);
      } catch (e2) {
        rethrow;
      }
    }
  }

  List<UserModel> _mapDocs(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
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
    }).toList();
  }
}
