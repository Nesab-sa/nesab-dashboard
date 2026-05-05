import 'package:dartz/dartz.dart';
import 'package:nesab/core/errors/failures.dart';
import 'package:nesab/features/auth/domain/repositories/auth_repository.dart';

class UploadSignatureUseCase {
  const UploadSignatureUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Either<Failure, String>> call({required String filePath}) {
    return _authRepository.uploadSignature(filePath: filePath);
  }
}
