import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_config_model.dart';

const String _col = 'app_config';
const String _slidesCol = 'slides';

class AppConfigDatasource {
  AppConfigDatasource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ─── Splash ───────────────────────────────────────────────────────────────

  Future<SplashConfig> getSplash() async {
    final doc = await _db.collection(_col).doc('splash').get();
    if (!doc.exists || doc.data() == null) return const SplashConfig();
    return SplashConfig.fromMap(doc.data()!);
  }

  Future<void> saveSplash(SplashConfig config) =>
      _db.collection(_col).doc('splash').set(config.toMap());

  // ─── Onboarding ───────────────────────────────────────────────────────────

  Future<List<OnboardingSlide>> getOnboardingSlides() async {
    final snap = await _db
        .collection(_col)
        .doc('onboarding')
        .collection(_slidesCol)
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => OnboardingSlide.fromMap(d.id, d.data()))
        .toList();
  }

  Future<void> saveOnboardingSlide(OnboardingSlide slide) => _db
      .collection(_col)
      .doc('onboarding')
      .collection(_slidesCol)
      .doc(slide.id)
      .set(slide.toMap());

  Future<void> deleteOnboardingSlide(String id) => _db
      .collection(_col)
      .doc('onboarding')
      .collection(_slidesCol)
      .doc(id)
      .delete();

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<LoginConfig> getLogin() async {
    final doc = await _db.collection(_col).doc('login').get();
    if (!doc.exists || doc.data() == null) return const LoginConfig();
    return LoginConfig.fromMap(doc.data()!);
  }

  Future<void> saveLogin(LoginConfig config) =>
      _db.collection(_col).doc('login').set(config.toMap());

  // ─── Register ─────────────────────────────────────────────────────────────

  Future<RegisterConfig> getRegister() async {
    final doc = await _db.collection(_col).doc('register').get();
    if (!doc.exists || doc.data() == null) return const RegisterConfig();
    return RegisterConfig.fromMap(doc.data()!);
  }

  Future<void> saveRegister(RegisterConfig config) =>
      _db.collection(_col).doc('register').set(config.toMap());

  // ─── Forgot Password ──────────────────────────────────────────────────────

  Future<ForgotPasswordConfig> getForgotPassword() async {
    final doc = await _db.collection(_col).doc('forgot_password').get();
    if (!doc.exists || doc.data() == null) return const ForgotPasswordConfig();
    return ForgotPasswordConfig.fromMap(doc.data()!);
  }

  Future<void> saveForgotPassword(ForgotPasswordConfig config) =>
      _db.collection(_col).doc('forgot_password').set(config.toMap());

  // ─── Home ─────────────────────────────────────────────────────────────────

  Future<HomeConfig> getHome() async {
    final doc = await _db.collection(_col).doc('home').get();
    if (!doc.exists || doc.data() == null) return const HomeConfig();
    return HomeConfig.fromMap(doc.data()!);
  }

  Future<void> saveHome(HomeConfig config) =>
      _db.collection(_col).doc('home').set(config.toMap());

  // ─── Profile ──────────────────────────────────────────────────────────────

  Future<ProfileConfig> getProfile() async {
    final doc = await _db.collection(_col).doc('profile').get();
    if (!doc.exists || doc.data() == null) return const ProfileConfig();
    return ProfileConfig.fromMap(doc.data()!);
  }

  Future<void> saveProfile(ProfileConfig config) =>
      _db.collection(_col).doc('profile').set(config.toMap());

  // ─── Settings ─────────────────────────────────────────────────────────────

  Future<SettingsConfig> getSettings() async {
    final doc = await _db.collection(_col).doc('settings').get();
    if (!doc.exists || doc.data() == null) return const SettingsConfig();
    return SettingsConfig.fromMap(doc.data()!);
  }

  Future<void> saveSettings(SettingsConfig config) =>
      _db.collection(_col).doc('settings').set(config.toMap());
}
