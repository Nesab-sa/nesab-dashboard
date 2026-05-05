import 'package:dartz/dartz.dart';
import 'package:nesab/core/errors/failures.dart';
import 'package:nesab/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
