import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/create_admin_repository.dart';
import '../../data/repositories/managers_repository.dart';
import 'managers_state.dart';

class ManagersCubit extends Cubit<ManagersState> {
  ManagersCubit({
    required ManagersRepository repository,
    required CreateAdminRepository createAdminRepository,
  })  : _repo = repository,
        _createAdminRepo = createAdminRepository,
        super(const ManagersState.initial());

  final ManagersRepository _repo;
  final CreateAdminRepository _createAdminRepo;

  Future<void> loadManagers() async {
    if (isClosed) return;
    emit(const ManagersState.loading());
    final result = await _repo.getManagers();
    if (isClosed) return;
    switch (result) {
      case Left(value: final failure):
        emit(ManagersState.error(failure.message));
      case Right(value: final managers):
        emit(ManagersState.loaded(managers));
    }
  }

  Future<bool> deleteManager(String id) async {
    if (isClosed) return false;
    final result = await _createAdminRepo.deleteManager(id);
    return result.fold((l) => false, (r) => true);
  }
}
