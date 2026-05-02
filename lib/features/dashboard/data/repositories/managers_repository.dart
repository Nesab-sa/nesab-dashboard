import 'package:dartz/dartz.dart';
import 'package:nesab_dashboard/core/errors/failures.dart';

import '../datasources/managers_firestore_datasource.dart';
import '../models/user_model.dart';

class ManagersRepository {
  ManagersRepository({ManagersFirestoreDatasource? datasource})
      : _datasource = datasource ?? ManagersFirestoreDatasource();

  final ManagersFirestoreDatasource _datasource;

  Future<Either<Failure, List<UserModel>>> getManagers() async {
    try {
      final result = await _datasource.getManagers();
      return right(result);
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }
}
