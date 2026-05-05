import 'package:dartz/dartz.dart';
import 'package:nesab/core/errors/failures.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Signs in a user with email and password.
  /// Returns [UserEntity] on success, [AuthFailure] on error.
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Creates a new account with email, password, and display name.
  /// Returns [UserEntity] on success, [AuthFailure] on error.
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs in a user with their Google account.
  /// Returns [UserEntity] on success, [AuthFailure] on error.
  /// Returns [Left(AuthFailure(code: cancelled))] if user cancels.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Signs in a user with their Apple ID.
  /// Returns [UserEntity] on success, [AuthFailure] on error.
  /// Returns [Left(AuthFailure(code: cancelled))] if user cancels.
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Signs out the current user, clearing all session data.
  Future<Either<Failure, void>> signOut();

  /// Permanently deletes the current user's account from Firebase Auth.
  /// May return [AuthFailure(code: requiresRecentLogin)] if re-auth is needed.
  Future<Either<Failure, void>> deleteAccount();

  /// Sends a password reset email to the given address.
  /// Returns [Right(void)] on success, [Left(Failure)] on error.
  Future<Either<Failure, void>> resetPassword({required String email});

  /// Stream of auth state changes. Emits [UserEntity] when signed in,
  /// null when signed out. Fires initial event on subscription.
  Stream<UserEntity?> get authStateChanges;

  /// Returns the currently signed-in user, or null if not authenticated.
  UserEntity? get currentUser;

  /// Updates the current user's display name in Firebase Auth and Firestore.
  Future<Either<Failure, UserEntity>> updateProfile({
    required String displayName,
  });

  /// Changes the password for an email-authenticated user.
  /// Requires the current password for re-authentication.
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Uploads a signature image and returns the download URL.
  Future<Either<Failure, String>> uploadSignature({
    required String filePath,
  });
}
