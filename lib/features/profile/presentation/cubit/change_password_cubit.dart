import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/features/auth/domain/usecases/change_password.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({
    required ChangePasswordUseCase changePasswordUseCase,
  })  : _changePasswordUseCase = changePasswordUseCase,
        super(const ChangePasswordState.initial());

  final ChangePasswordUseCase _changePasswordUseCase;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const ChangePasswordState.loading());
    final result = await _changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    result.fold(
      (failure) => emit(ChangePasswordState.error(failure.message)),
      (_) => emit(const ChangePasswordState.success()),
    );
  }
}
