import 'package:cloud_functions/cloud_functions.dart';
import 'package:dartz/dartz.dart';
import 'package:nesab_dashboard/core/errors/failures.dart';

class CreateAdminRepository {
  CreateAdminRepository({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  static const String _createFunctionName = 'createAdmin';
  static const String _deleteFunctionName = 'deleteManager';

  Future<Either<Failure, String>> createAdmin({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      final callable = _functions.httpsCallable(_createFunctionName);
      final result = await callable.call<Map<String, dynamic>>({
        'email': email.trim(),
        'password': password,
        'displayName': displayName.trim(),
        'role': role,
      });
      final data = result.data as Map<String, dynamic>?;
      final uid = data == null ? null : data['uid'] as String?;
      if (uid == null) {
        return left(const GeneralFailure(message: 'Invalid response from server'));
      }
      return right(uid);
    } on FirebaseFunctionsException catch (e) {
      return left(GeneralFailure(message: e.message ?? e.code));
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> deleteManager(String uid) async {
    try {
      final callable = _functions.httpsCallable(_deleteFunctionName);
      await callable.call<Map<String, dynamic>>({'uid': uid});
      return right(uid);
    } on FirebaseFunctionsException catch (e) {
      final msg = e.message?.isNotEmpty == true
          ? e.message!
          : (e.details?.toString() ?? e.code);
      return left(GeneralFailure(message: msg));
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }
}
