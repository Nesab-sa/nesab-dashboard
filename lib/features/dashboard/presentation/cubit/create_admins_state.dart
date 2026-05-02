import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_admins_state.freezed.dart';

@freezed
class CreateAdminsState with _$CreateAdminsState {
  const factory CreateAdminsState.initial() = _Initial;
  const factory CreateAdminsState.loading() = _Loading;
  const factory CreateAdminsState.success() = _Success;
  const factory CreateAdminsState.error(String message) = _Error;
}
