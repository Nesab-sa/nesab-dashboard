import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';

part 'edit_profile_state.freezed.dart';

@freezed
sealed class EditProfileState with _$EditProfileState {
  const factory EditProfileState.initial() = _Initial;
  const factory EditProfileState.loading() = _Loading;
  const factory EditProfileState.success(UserEntity user) = _Success;
  const factory EditProfileState.error(String message) = _Error;
}
