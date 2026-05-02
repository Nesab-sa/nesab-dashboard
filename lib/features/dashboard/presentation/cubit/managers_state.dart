import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/user_model.dart';

part 'managers_state.freezed.dart';

@freezed
class ManagersState with _$ManagersState {
  const factory ManagersState.initial() = _Initial;
  const factory ManagersState.loading() = _Loading;
  const factory ManagersState.loaded(List<UserModel> managers) = _Loaded;
  const factory ManagersState.error(String message) = _Error;
}
