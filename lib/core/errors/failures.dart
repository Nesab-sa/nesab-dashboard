sealed class Failure {
  const Failure({required this.message});

  final String message;
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

final class GeneralFailure extends Failure {
  const GeneralFailure({required super.message});
}

enum AuthFailureCode {
  invalidEmail,
  wrongPassword,
  userNotFound,
  userDisabled,
  emailAlreadyInUse,
  weakPassword,
  tooManyRequests,
  operationNotAllowed,
  invalidCredential,
  accountExistsWithDifferentCredential,
  networkError,
  cancelled,
  unknown,
}

final class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    required this.code,
  });

  final AuthFailureCode code;
}
