import 'package:dartz/dartz.dart';
import 'package:nesab/core/errors/failures.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';
import 'package:nesab/features/auth/domain/repositories/auth_repository.dart';

class SignInWithAppleUseCase {
  const SignInWithAppleUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Either<Failure, UserEntity>> call() {
    return _authRepository.signInWithApple();
  }
}
