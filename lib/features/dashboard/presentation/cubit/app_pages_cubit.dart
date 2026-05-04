import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:nesab_dashboard/features/dashboard/data/models/app_config_model.dart';
import 'package:nesab_dashboard/features/dashboard/data/repositories/app_config_repository.dart';
import 'app_pages_state.dart';

class AppPagesCubit extends Cubit<AppPagesState> {
  AppPagesCubit(this._repo) : super(const AppPagesState());

  final AppConfigRepository _repo;
  final _uuid = const Uuid();

  Future<void> loadAll() async {
    emit(state.copyWith(status: AppPagesStatus.loading));
    try {
      final results = await Future.wait([
        _repo.getSplash(),
        _repo.getOnboardingSlides(),
        _repo.getLogin(),
        _repo.getRegister(),
        _repo.getForgotPassword(),
        _repo.getHome(),
        _repo.getProfile(),
        _repo.getSettings(),
      ]);
      emit(state.copyWith(
        status: AppPagesStatus.loaded,
        splash: results[0] as SplashConfig,
        slides: results[1] as List<OnboardingSlide>,
        login: results[2] as LoginConfig,
        register: results[3] as RegisterConfig,
        forgotPassword: results[4] as ForgotPasswordConfig,
        home: results[5] as HomeConfig,
        profile: results[6] as ProfileConfig,
        settings: results[7] as SettingsConfig,
      ));
    } catch (e) {
      emit(state.copyWith(status: AppPagesStatus.error, errorMessage: e.toString()));
    }
  }

  // ─── Splash ───────────────────────────────────────────────────────────────

  Future<void> saveSplash(SplashConfig config) async {
    emit(state.copyWith(status: AppPagesStatus.saving, saved: false));
    try {
      await _repo.saveSplash(config);
      emit(state.copyWith(status: AppPagesStatus.loaded, splash: config, saved: true));
    } catch (e) {
      emit(state.copyWith(status: AppPagesStatus.error, errorMessage: e.toString()));
    }
  }

  // ─── Onboarding ───────────────────────────────────────────────────────────

  Future<void> saveSlide(OnboardingSlide slide) async {
    emit(state.copyWith(status: AppPagesStatus.saving, saved: false));
    try {
      await _repo.saveOnboardingSlide(slide);
      final updated = [...state.slides];
      final idx = updated.indexWhere((s) => s.id == slide.id);
      if (idx >= 0) {
        updated[idx] = slide;
      } else {
        updated.add(slide);
      }
      updated.sort((a, b) => a.order.compareTo(b.order));
      emit(state.copyWith(status: AppPagesStatus.loaded, slides: updated, saved: true));
    } catch (e) {
      emit(state.copyWith(status: AppPagesStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> deleteSlide(String id) async {
    emit(state.copyWith(status: AppPagesStatus.saving, saved: false));
    try {
      await _repo.deleteOnboardingSlide(id);
      final updated = state.slides.where((s) => s.id != id).toList();
      emit(state.copyWith(status: AppPagesStatus.loaded, slides: updated, saved: true));
    } catch (e) {
      emit(state.copyWith(status: AppPagesStatus.error, errorMessage: e.toString()));
    }
  }

  String newSlideId() => _uuid.v4();

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<void> saveLogin(LoginConfig config) async {
    emit(state.copyWith(status: AppPagesStatus.saving, saved: false));
    try {
      await _repo.saveLogin(config);
      emit(state.copyWith(status: AppPagesStatus.loaded, login: config, saved: true));
    } catch (e) {
      emit(state.copyWith(status: AppPagesStatus.error, errorMessage: e.toString()));
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  Future<void> saveRegister(RegisterConfig config) async {
    emit(state.copyWith(status: AppPagesStatus.saving, saved: false));
    try {
      await _repo.saveRegister(config);
      emit(state.copyWith(status: AppPagesStatus.loaded, register: config, saved: true));
    } catch (e) {
      emit(state.copyWith(status: AppPagesStatus.error, errorMessage: e.toString()));
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────

  Future<void> saveForgotPassword(ForgotPasswordConfig config) async {
    emit(state.copyWith(status: AppPagesStatus.saving, saved: false));
    try {
      await _repo.saveForgotPassword(config);
      emit(state.copyWith(status: AppPagesStatus.loaded, forgotPassword: config, saved: true));
    } catch (e) {
      emit(state.copyWith(status: AppPagesStatus.error, errorMessage: e.toString()));
    }
  }

  // ─── Home ─────────────────────────────────────────────────────────────────

  Future<void> saveHome(HomeConfig config) async {
    emit(state.copyWith(status: AppPagesStatus.saving, saved: false));
    try {
      await _repo.saveHome(config);
      emit(state.copyWith(status: AppPagesStatus.loaded, home: config, saved: true));
    } catch (e) {
      emit(state.copyWith(status: AppPagesStatus.error, errorMessage: e.toString()));
    }
  }

  // ─── Profile ──────────────────────────────────────────────────────────────

  Future<void> saveProfile(ProfileConfig config) async {
    emit(state.copyWith(status: AppPagesStatus.saving, saved: false));
    try {
      await _repo.saveProfile(config);
      emit(state.copyWith(status: AppPagesStatus.loaded, profile: config, saved: true));
    } catch (e) {
      emit(state.copyWith(status: AppPagesStatus.error, errorMessage: e.toString()));
    }
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  Future<void> saveSettings(SettingsConfig config) async {
    emit(state.copyWith(status: AppPagesStatus.saving, saved: false));
    try {
      await _repo.saveSettings(config);
      emit(state.copyWith(status: AppPagesStatus.loaded, settings: config, saved: true));
    } catch (e) {
      emit(state.copyWith(status: AppPagesStatus.error, errorMessage: e.toString()));
    }
  }
}
