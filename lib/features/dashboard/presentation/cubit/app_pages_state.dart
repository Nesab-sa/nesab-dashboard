import 'package:nesab_dashboard/features/dashboard/data/models/app_config_model.dart';

enum AppPagesStatus { initial, loading, loaded, saving, error }

class AppPagesState {
  final AppPagesStatus status;
  final String? errorMessage;
  final bool saved;

  final SplashConfig splash;
  final List<OnboardingSlide> slides;
  final LoginConfig login;
  final RegisterConfig register;
  final ForgotPasswordConfig forgotPassword;
  final HomeConfig home;
  final ProfileConfig profile;
  final SettingsConfig settings;

  const AppPagesState({
    this.status = AppPagesStatus.initial,
    this.errorMessage,
    this.saved = false,
    this.splash = const SplashConfig(),
    this.slides = const [],
    this.login = const LoginConfig(),
    this.register = const RegisterConfig(),
    this.forgotPassword = const ForgotPasswordConfig(),
    this.home = const HomeConfig(),
    this.profile = const ProfileConfig(),
    this.settings = const SettingsConfig(),
  });

  AppPagesState copyWith({
    AppPagesStatus? status,
    String? errorMessage,
    bool? saved,
    SplashConfig? splash,
    List<OnboardingSlide>? slides,
    LoginConfig? login,
    RegisterConfig? register,
    ForgotPasswordConfig? forgotPassword,
    HomeConfig? home,
    ProfileConfig? profile,
    SettingsConfig? settings,
  }) =>
      AppPagesState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        saved: saved ?? this.saved,
        splash: splash ?? this.splash,
        slides: slides ?? this.slides,
        login: login ?? this.login,
        register: register ?? this.register,
        forgotPassword: forgotPassword ?? this.forgotPassword,
        home: home ?? this.home,
        profile: profile ?? this.profile,
        settings: settings ?? this.settings,
      );
}
