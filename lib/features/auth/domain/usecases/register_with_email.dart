import 'package:dartz/dartz.dart';
import 'package:nesab/core/errors/failures.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';
import 'package:nesab/features/auth/domain/repositories/auth_repository.dart';

class RegisterWithEmailUseCase {
  const RegisterWithEmailUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _authRepository.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
