import 'package:dartz/dartz.dart';
import 'package:nesab/core/errors/failures.dart';
import 'package:nesab/features/auth/domain/repositories/auth_repository.dart';

/// Sends a password reset email to the given address.
class ResetPasswordUseCase {
  const ResetPasswordUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Either<Failure, void>> call({required String email}) {
    return _authRepository.resetPassword(email: email);
  }
}
