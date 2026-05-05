import 'package:nesab/features/auth/data/models/user_model.dart';

abstract class UserRemoteDataSource {
  /// Creates a new user document in Firestore at `users/{uid}`.
  Future<void> createUserProfile(UserModel user);

  /// Updates `lastLogin` and `updatedAt` for an existing user.
  Future<void> updateLastLogin(UserModel user);

  /// Fetches the user profile from Firestore.
  /// Returns null if the document does not exist.
  Future<UserModel?> getUserProfile(String uid);

  /// Creates the profile if it does not exist, or updates lastLogin if it does.
  Future<void> saveOrUpdateUserProfile(UserModel user);
Future<void>deleteUserProfile(String uid);
  /// Updates user profile fields in Firestore.
  Future<void> updateUserProfile({
    required String uid,
    required String displayName,
  });

  /// Uploads a signature image to Firebase Storage and saves the URL in Firestore.
  /// Returns the download URL of the uploaded signature.
  Future<String> uploadSignature({
    required String uid,
    required String filePath,
  });
}
