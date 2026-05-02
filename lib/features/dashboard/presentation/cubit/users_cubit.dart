import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/users_repository.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  UsersCubit(this._repo) : super(const UsersState.initial());

  final UsersRepository _repo;

  static const int _pageSize = 20;

  Future<void> loadPage(int page, {String? search}) async {
    if (isClosed) return;
    emit(const UsersState.loading());
    final usersResult = await _repo.getUsers(
      page: page,
      pageSize: _pageSize,
      search: search,
    );
    if (isClosed) return;
    final totalResult = await _repo.getTotalCount(search: search);
    if (isClosed) return;

    switch (usersResult) {
      case Left(value: final failure):
        emit(UsersState.error(failure.message));
      case Right(value: final users):
        final total = totalResult.fold((l) => 0, (r) => r);
        emit(UsersState.loaded(
          users: users,
          page: page,
          totalCount: total,
          pageSize: _pageSize,
        ));
    }
  }

  Future<void> search(String? term) async =>
      loadPage(1, search: (term == null || term.trim().isEmpty) ? null : term);
}
