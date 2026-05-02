import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'locale_state.freezed.dart';

@freezed
sealed class LocaleState with _$LocaleState {
  const factory LocaleState({@Default(Locale('ar')) Locale locale}) =
      _LocaleState;
}
