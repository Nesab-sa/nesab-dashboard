sealed class AppException implements Exception {
  const AppException({required this.message});

  final String message;

  @override
  String toString() => message;
}

final class ServerException extends AppException {
  const ServerException({required super.message});
}

final class CacheException extends AppException {
  const CacheException({required super.message});
}

final class GeneralException extends AppException {
  const GeneralException({required super.message});
}

final class AuthException extends AppException {
  const AuthException({
    required super.message,
    required this.code,
  });

  final String code;
}

final class AuthCancelledException extends AppException {
  const AuthCancelledException({
    super.message = 'Authentication was cancelled by user',
  });
}
