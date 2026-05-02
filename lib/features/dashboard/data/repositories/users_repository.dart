import 'package:dartz/dartz.dart';
import 'package:nesab_dashboard/core/errors/failures.dart';

import '../datasources/users_firestore_datasource.dart';
import '../models/user_model.dart';

class UsersRepository {
  UsersRepository({UsersFirestoreDatasource? datasource})
    : _datasource = datasource ?? UsersFirestoreDatasource();

  final UsersFirestoreDatasource _datasource;

  List<UserModel>? _cachedUsers;

  void invalidateCache() {
    _cachedUsers = null;
  }

  Future<Either<Failure, List<UserModel>>> getUsers({
    required int page,
    required int pageSize,
    String? search,
  }) async {
    try {
      final all = _cachedUsers ?? await _datasource.getUsers();
      _cachedUsers ??= all;

      var filtered = all;
      if (search != null && search.trim().isNotEmpty) {
        final term = search.trim().toLowerCase();
        filtered = all
            .where(
              (u) =>
                  u.name.toLowerCase().contains(term) ||
                  u.email.toLowerCase().contains(term),
            )
            .toList();
      }
      final start = (page - 1) * pageSize;
      final end = (start + pageSize).clamp(0, filtered.length);
      return right(filtered.sublist(start, end));
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, int>> getTotalCount({String? search}) async {
    try {
      final all = _cachedUsers ?? await _datasource.getUsers();
      _cachedUsers ??= all;

      if (search != null && search.trim().isNotEmpty) {
        final term = search.trim().toLowerCase();
        return right(all
            .where(
              (u) =>
                  u.name.toLowerCase().contains(term) ||
                  u.email.toLowerCase().contains(term),
            )
            .length);
      }
      return right(all.length);
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }
}
