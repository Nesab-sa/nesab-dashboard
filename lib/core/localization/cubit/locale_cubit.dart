import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._prefs) : super(const LocaleState());

  final SharedPreferences _prefs;
  static const _key = 'locale';

  void loadLocale() {
    final value = _prefs.getString(_key) ?? 'ar';
    emit(LocaleState(locale: Locale(value)));
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_key, locale.languageCode);
    emit(LocaleState(locale: locale));
  }
}
