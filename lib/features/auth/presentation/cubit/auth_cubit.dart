import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nesab_dashboard/core/routing/auth_redirect_notifier.dart';
import 'package:nesab_dashboard/features/auth/data/repositories/auth_repository.dart';
import 'package:nesab_dashboard/features/auth/presentation/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    AuthRepository? repository,
    AuthRedirectNotifier? redirectNotifier,
  }) : _repo = repository ?? AuthRepository(),
       _redirectNotifier = redirectNotifier ?? AuthRedirectNotifier(),
       super(const AuthState.initial());

  final AuthRepository _repo;
  final AuthRedirectNotifier _redirectNotifier;
  StreamSubscription<User?>? _authSubscription;

  /// Starts listening to auth state and checks current session.
  void checkAuth() {
    _authSubscription?.cancel();
    _authSubscription = _repo.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    emit(const AuthState.loading());

    if (user == null) {
      _redirectNotifier.setAuthenticated(false);
      if (!isClosed) emit(const AuthState.unauthenticated());
      return;
    }
    try {
      final profile = await _repo.getManagerProfile(user.uid);
      if (profile == null) {
        await _repo.logout();
        _redirectNotifier.setAuthenticated(false);
        if (!isClosed) emit(const AuthState.unauthenticated());
        return;
      }
      _redirectNotifier.setAuthenticated(true);
      if (!isClosed) emit(AuthState.authenticated(profile));
    } catch (e) {
      await _repo.logout();
      _redirectNotifier.setAuthenticated(false);
      if (!isClosed) emit(const AuthState.unauthenticated());
    }
  }

  /// Signs in with email and password, fetches manager profile from Firestore.
  Future<void> login({required String email, required String password}) async {
    emit(const AuthState.loading());
    final result = await _repo.login(email: email, password: password);
    switch (result) {
      case Left(value: final v):
        _redirectNotifier.setAuthenticated(false);
        if (!isClosed) emit(AuthState.error(v.message));
      case Right(value: final v):
        _redirectNotifier.setAuthenticated(true);
        if (!isClosed) emit(AuthState.authenticated(v));
    }
  }

  /// Signs out and clears auth state.
  Future<void> logout() async {
    await _repo.logout();
    _redirectNotifier.setAuthenticated(false);
    if (!isClosed) emit(const AuthState.unauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
