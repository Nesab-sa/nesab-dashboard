import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/user_model.dart';

part 'users_state.freezed.dart';

@freezed
class UsersState with _$UsersState {
  const factory UsersState.initial() = _Initial;
  const factory UsersState.loading() = _Loading;
  const factory UsersState.loaded({
    required List<UserModel> users,
    required int page,
    required int totalCount,
    required int pageSize,
  }) = _Loaded;
  const factory UsersState.error(String message) = _Error;
}
