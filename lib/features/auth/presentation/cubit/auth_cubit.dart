import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/core/services/analytics_service.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';
import 'package:nesab/features/auth/domain/usecases/get_current_user.dart';
import 'package:nesab/features/auth/domain/usecases/register_with_email.dart';
import 'package:nesab/features/auth/domain/usecases/reset_password.dart';
import 'package:nesab/features/auth/domain/usecases/sign_in_with_apple.dart';
import 'package:nesab/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:nesab/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:nesab/features/auth/domain/usecases/sign_out.dart';
import 'package:nesab/features/auth/domain/usecases/delete_account.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required RegisterWithEmailUseCase registerWithEmailUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
    required SignOutUseCase signOutUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required AnalyticsService analyticsService,
  })  : _signInWithEmailUseCase = signInWithEmailUseCase,
        _registerWithEmailUseCase = registerWithEmailUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signInWithAppleUseCase = signInWithAppleUseCase,
        _signOutUseCase = signOutUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _resetPasswordUseCase = resetPasswordUseCase,
        _analyticsService = analyticsService,
        super(const AuthState.initial()) {
    // Subscribe to auth state changes for session persistence
    _authStateSubscription =
        _getCurrentUserUseCase.authStateChanges.listen((user) {
      if (user != null) {
        _analyticsService.setUserId(user.uid);
        emit(AuthState.authenticated(user));
      } else {
        _analyticsService.setUserId(null);
        emit(const AuthState.unauthenticated());
      }
    });
  }

  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final RegisterWithEmailUseCase _registerWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignOutUseCase _signOutUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final AnalyticsService _analyticsService;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const AuthState.loading());
    final result = await _signInWithEmailUseCase(
      email: email,
      password: password,
    );
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(const AuthState.loading());
    final result = await _registerWithEmailUseCase(
      email: email,
      password: password,
      displayName: displayName,
    );
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthState.loading());
    final result = await _signInWithGoogleUseCase();
    result.fold(
      (failure) {
        // Don't emit error for cancellation, just return to unauthenticated
        if (failure.message.contains('cancel')) {
          emit(const AuthState.unauthenticated());
        } else {
          emit(AuthState.error(failure.message));
        }
      },
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> signInWithApple() async {
    emit(const AuthState.loading());
    final result = await _signInWithAppleUseCase();
    result.fold(
      (failure) {
        // Don't emit error for cancellation, just return to unauthenticated
        if (failure.message.contains('cancel')) {
          emit(const AuthState.unauthenticated());
        } else {
          emit(AuthState.error(failure.message));
        }
      },
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> signOut() async {
    emit(const AuthState.loading());
    final result = await _signOutUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  Future<void> deleteAccount() async {
    emit(const AuthState.loading());
    final result = await _deleteAccountUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  void checkAuth() {
    final user = _getCurrentUserUseCase();
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> resetPassword({required String email}) async {
    emit(const AuthState.loading());
    final result = await _resetPasswordUseCase(email: email);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(const AuthState.resetLinkSent()),
    );
  }

  void browseAsGuest() {
    // Create a guest user without calling Firebase
    const guestUser = UserEntity(
      uid: 'guest',
      authProvider: AppAuthProvider.guest,
    );
    emit(const AuthState.authenticated(guestUser));
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
