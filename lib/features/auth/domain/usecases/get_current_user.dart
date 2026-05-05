import 'package:nesab/features/auth/domain/entities/user_entity.dart';
import 'package:nesab/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._authRepository);

  final AuthRepository _authRepository;

  UserEntity? call() {
    return _authRepository.currentUser;
  }

  Stream<UserEntity?> get authStateChanges {
    return _authRepository.authStateChanges;
  }
}
