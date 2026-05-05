import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nesab/core/errors/exceptions.dart';
import 'package:nesab/features/auth/data/data_sources/user_remote_data_source.dart';
import 'package:nesab/features/auth/data/models/user_model.dart';

class FirestoreUserRemoteDataSource implements UserRemoteDataSource {
  FirestoreUserRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toFirestoreCreate());
    } catch (e) {
      throw ServerException(message: 'Failed to create user profile: $e');
    }
  }

  @override
  Future<void> updateLastLogin(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toFirestoreLoginUpdate());
    } catch (e) {
      throw ServerException(message: 'Failed to update last login: $e');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch user profile: $e');
    }
  }

  @override
  Future<void> saveOrUpdateUserProfile(UserModel user) async {
    try {
      final doc = await _usersCollection.doc(user.uid).get();
      if (doc.exists) {
        await _usersCollection
            .doc(user.uid)
            .update(user.toFirestoreLoginUpdate());
      } else {
        await _usersCollection.doc(user.uid).set(user.toFirestoreCreate());
      }
    } catch (e) {
      throw ServerException(message: 'Failed to save user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    required String displayName,
  }) async {
    try {
      await _usersCollection.doc(uid).update({
        'displayName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to update user profile: $e');
    }
  }

  @override
  Future<String> uploadSignature({
    required String uid,
    required String filePath,
  }) async {
    try {
      final ref = _storage.ref().child('signatures/$uid/signature.png');
      await ref.putFile(File(filePath));
      final downloadUrl = await ref.getDownloadURL();

      // Save the URL in the user's Firestore document
      await _usersCollection.doc(uid).update({
        'signatureUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      throw ServerException(message: 'Failed to upload signature: $e');
    }
  }
  
  @override
  Future<void> deleteUserProfile(String uid) {
    try {
      return _usersCollection.doc(uid).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete user profile: $e');
    }
  }
}
