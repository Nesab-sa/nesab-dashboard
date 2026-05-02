import '../datasources/app_config_datasource.dart';
import '../models/app_config_model.dart';

class AppConfigRepository {
  AppConfigRepository() : _ds = AppConfigDatasource();
  final AppConfigDatasource _ds;

  Future<SplashConfig> getSplash() => _ds.getSplash();
  Future<void> saveSplash(SplashConfig c) => _ds.saveSplash(c);

  Future<List<OnboardingSlide>> getOnboardingSlides() => _ds.getOnboardingSlides();
  Future<void> saveOnboardingSlide(OnboardingSlide s) => _ds.saveOnboardingSlide(s);
  Future<void> deleteOnboardingSlide(String id) => _ds.deleteOnboardingSlide(id);

  Future<LoginConfig> getLogin() => _ds.getLogin();
  Future<void> saveLogin(LoginConfig c) => _ds.saveLogin(c);

  Future<RegisterConfig> getRegister() => _ds.getRegister();
  Future<void> saveRegister(RegisterConfig c) => _ds.saveRegister(c);

  Future<ForgotPasswordConfig> getForgotPassword() => _ds.getForgotPassword();
  Future<void> saveForgotPassword(ForgotPasswordConfig c) => _ds.saveForgotPassword(c);

  Future<HomeConfig> getHome() => _ds.getHome();
  Future<void> saveHome(HomeConfig c) => _ds.saveHome(c);

  Future<ProfileConfig> getProfile() => _ds.getProfile();
  Future<void> saveProfile(ProfileConfig c) => _ds.saveProfile(c);

  Future<SettingsConfig> getSettings() => _ds.getSettings();
  Future<void> saveSettings(SettingsConfig c) => _ds.saveSettings(c);
}
