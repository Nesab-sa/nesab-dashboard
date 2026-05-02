import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:nesab_dashboard/core/errors/failures.dart';
import 'package:nesab_dashboard/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/user_model.dart';

/// Handles authentication using [AuthRemoteDatasource].
/// Coordinates login, profile fetch, logout and error mapping.
class AuthRepository {
  AuthRepository({AuthRemoteDatasource? datasource})
      : _datasource = datasource ?? AuthRemoteDatasource();

  final AuthRemoteDatasource _datasource;

  Stream<User?> get authStateChanges => _datasource.authStateChanges;

  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _datasource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        return left(const AuthFailure(
          message: 'Invalid email or password.',
          code: AuthFailureCode.invalidCredential,
        ));
      }
      final profile = await getManagerProfile(user.uid);
      if (profile == null) {
        await _datasource.signOut();
        return left(const AuthFailure(
          message: 'You are not registered as a manager.',
          code: AuthFailureCode.operationNotAllowed,
        ));
      }
      return right(profile);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }

  Future<UserModel?> getManagerProfile(String uid) async {
    final doc = await _datasource.getManagerDoc(uid);
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return _datasource.parseManagerDoc(doc);
  }

  Future<void> logout() => _datasource.signOut();

  AuthFailure _mapFirebaseAuthException(FirebaseAuthException e) {
    final code = switch (e.code) {
      'user-not-found' || 'invalid-credential' || 'invalid-email' || 'wrong-password' =>
        AuthFailureCode.invalidCredential,
      'user-disabled' => AuthFailureCode.userDisabled,
      'too-many-requests' => AuthFailureCode.tooManyRequests,
      'network-request-failed' => AuthFailureCode.networkError,
      _ => AuthFailureCode.unknown,
    };
    return AuthFailure(message: e.message ?? 'Sign in failed', code: code);
  }
}
