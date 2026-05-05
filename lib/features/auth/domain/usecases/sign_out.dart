import 'package:dartz/dartz.dart';
import 'package:nesab/core/errors/failures.dart';
import 'package:nesab/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Either<Failure, void>> call() {
    return _authRepository.signOut();
  }
}
