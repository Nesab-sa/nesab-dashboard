import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nesab/core/errors/exceptions.dart';
import 'package:nesab/core/errors/failures.dart';
import 'package:nesab/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:nesab/features/auth/data/data_sources/user_remote_data_source.dart';
import 'package:nesab/features/auth/data/models/user_model.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';
import 'package:nesab/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._userRemoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final UserRemoteDataSource _userRemoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _remoteDataSource.signInWithEmail(
        email,
        password,
      );
      final user = credential.user;
      if (user == null) {
        return const Left(
          AuthFailure(
            code: AuthFailureCode.unknown,
            message: 'Sign in failed: no user returned',
          ),
        );
      }
      final userModel = UserModel.fromFirebaseUser(user);
      await _syncUserProfileOnLogin(userModel);
      return Right(userModel);
    } on AuthCancelledException catch (e) {
      return Left(
        AuthFailure(code: AuthFailureCode.cancelled, message: e.message),
      );
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _remoteDataSource.registerWithEmail(
        email,
        password,
        displayName,
      );
      final user = credential.user;
      if (user == null) {
        return const Left(
          AuthFailure(
            code: AuthFailureCode.unknown,
            message: 'Registration failed: no user returned',
          ),
        );
      }
      final userModel = UserModel.fromFirebaseUser(user);
      await _createUserProfile(userModel);
      return Right(userModel);
    } on AuthCancelledException catch (e) {
      return Left(
        AuthFailure(code: AuthFailureCode.cancelled, message: e.message),
      );
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final credential = await _remoteDataSource.signInWithGoogle();
      final user = credential.user;
      if (user == null) {
        return const Left(
          AuthFailure(
            code: AuthFailureCode.unknown,
            message: 'Google sign in failed: no user returned',
          ),
        );
      }
      final userModel = UserModel.fromFirebaseUser(user);
      await _syncUserProfileOnLogin(userModel);
      return Right(userModel);
    } on AuthCancelledException catch (e) {
      return Left(
        AuthFailure(code: AuthFailureCode.cancelled, message: e.message),
      );
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      final credential = await _remoteDataSource.signInWithApple();
      final user = credential.user;
      if (user == null) {
        return const Left(
          AuthFailure(
            code: AuthFailureCode.unknown,
            message: 'Apple sign in failed: no user returned',
          ),
        );
      }
      final userModel = UserModel.fromFirebaseUser(user);
      await _syncUserProfileOnLogin(userModel);
      return Right(userModel);
    } on AuthCancelledException catch (e) {
      return Left(
        AuthFailure(code: AuthFailureCode.cancelled, message: e.message),
      );
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final userId = _remoteDataSource.currentUser!.uid;
      await _userRemoteDataSource.deleteUserProfile(userId);
      await _remoteDataSource.deleteAccount();

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await _remoteDataSource.resetPassword(email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  @override
  UserEntity? get currentUser {
    final user = _remoteDataSource.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String displayName,
  }) async {
    try {
      final currentFirebaseUser = _remoteDataSource.currentUser;
      if (currentFirebaseUser == null) {
        return const Left(
          AuthFailure(
            code: AuthFailureCode.unknown,
            message: 'No authenticated user',
          ),
        );
      }

      // Update Firebase Auth display name
      await _remoteDataSource.updateDisplayName(displayName);

      // Update Firestore profile
      await _userRemoteDataSource.updateUserProfile(
        uid: currentFirebaseUser.uid,
        displayName: displayName,
      );

      // Return updated user entity
      final updatedUser = _remoteDataSource.currentUser;
      if (updatedUser == null) {
        return const Left(
          AuthFailure(
            code: AuthFailureCode.unknown,
            message: 'Failed to retrieve updated user',
          ),
        );
      }
      return Right(UserModel.fromFirebaseUser(updatedUser));
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadSignature({
    required String filePath,
  }) async {
    try {
      final currentFirebaseUser = _remoteDataSource.currentUser;
      if (currentFirebaseUser == null) {
        return const Left(
          AuthFailure(
            code: AuthFailureCode.unknown,
            message: 'No authenticated user',
          ),
        );
      }
      final url = await _userRemoteDataSource.uploadSignature(
        uid: currentFirebaseUser.uid,
        filePath: filePath,
      );
      return Right(url);
    } catch (e) {
      return Left(GeneralFailure(message: e.toString()));
    }
  }

  /// Called on login: creates Firestore doc if missing, updates lastLogin if exists.
  Future<void> _syncUserProfileOnLogin(UserModel user) async {
    try {
      await _userRemoteDataSource.saveOrUpdateUserProfile(user);
    } catch (e) {
      throw GeneralException(message: 'Failed to sync user profile: ${e.toString()}');
    }
  }

  /// Called on explicit registration: always creates a new Firestore doc.
  Future<void> _createUserProfile(UserModel user) async {
    try {
      await _userRemoteDataSource.createUserProfile(user);
    } catch (e) {
throw GeneralException(message: 'Failed to create user profile: ${e.toString()}');
    }
  }

  AuthFailure _mapFirebaseException(FirebaseAuthException e) {
    final code = e.code;
    final AuthFailureCode failureCode;

    switch (code) {
      case 'invalid-email':
        failureCode = AuthFailureCode.invalidEmail;
      case 'wrong-password':
        failureCode = AuthFailureCode.wrongPassword;
      case 'user-not-found':
        failureCode = AuthFailureCode.userNotFound;
      case 'user-disabled':
        failureCode = AuthFailureCode.userDisabled;
      case 'email-already-in-use':
        failureCode = AuthFailureCode.emailAlreadyInUse;
      case 'weak-password':
        failureCode = AuthFailureCode.weakPassword;
      case 'too-many-requests':
        failureCode = AuthFailureCode.tooManyRequests;
      case 'operation-not-allowed':
        failureCode = AuthFailureCode.operationNotAllowed;
      case 'invalid-credential':
        failureCode = AuthFailureCode.invalidCredential;
      case 'account-exists-with-different-credential':
        failureCode = AuthFailureCode.accountExistsWithDifferentCredential;
      case 'network-request-failed':
        failureCode = AuthFailureCode.networkError;
      default:
        failureCode = AuthFailureCode.unknown;
    }

    return AuthFailure(
      code: failureCode,
      message: e.message ?? 'An authentication error occurred',
    );
  }
}
