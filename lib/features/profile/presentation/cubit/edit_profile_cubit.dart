import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/features/auth/domain/usecases/update_profile.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({
    required UpdateProfileUseCase updateProfileUseCase,
  })  : _updateProfileUseCase = updateProfileUseCase,
        super(const EditProfileState.initial());

  final UpdateProfileUseCase _updateProfileUseCase;

  Future<void> updateProfile({required String displayName}) async {
    emit(const EditProfileState.loading());
    final result = await _updateProfileUseCase(displayName: displayName);
    result.fold(
      (failure) => emit(EditProfileState.error(failure.message)),
      (user) => emit(EditProfileState.success(user)),
    );
  }
}
