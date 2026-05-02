import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/create_admin_repository.dart';
import 'create_admins_state.dart';

class CreateAdminsCubit extends Cubit<CreateAdminsState> {
  CreateAdminsCubit([CreateAdminRepository? repository])
      : _repo = repository ?? CreateAdminRepository(),
        super(const CreateAdminsState.initial());

  final CreateAdminRepository _repo;

  Future<void> createAdmin({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    if (isClosed) return;
    emit(const CreateAdminsState.loading());
    final result = await _repo.createAdmin(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );
    if (isClosed) return;
    switch (result) {
      case Left(value: final failure):
        emit(CreateAdminsState.error(failure.message));
      case Right():
        emit(const CreateAdminsState.success());
    }
  }

  void reset() => emit(const CreateAdminsState.initial());
}
