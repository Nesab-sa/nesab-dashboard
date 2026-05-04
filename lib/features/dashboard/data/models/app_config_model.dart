/// Models for controlling all 9 app pages from the dashboard.
/// Each model maps to a Firestore document under the `app_config` collection.
library;

// ─── Splash ───────────────────────────────────────────────────────────────────

class SplashConfig {
  final int durationSeconds;
  final String taglineAr;
  final String taglineEn;

  const SplashConfig({
    this.durationSeconds = 3,
    this.taglineAr = 'نسب | أسر التقنية المصرفية لك',
    this.taglineEn = 'Nesab | Your Financial Technology',
  });

  factory SplashConfig.fromMap(Map<String, dynamic> d) => SplashConfig(
        durationSeconds: (d['durationSeconds'] as int?) ?? 3,
        taglineAr: (d['taglineAr'] ?? 'نسب | أسر التقنية المصرفية لك').toString(),
        taglineEn: (d['taglineEn'] ?? 'Nesab | Your Financial Technology').toString(),
      );

  Map<String, dynamic> toMap() => {
        'durationSeconds': durationSeconds,
        'taglineAr': taglineAr,
        'taglineEn': taglineEn,
      };

  SplashConfig copyWith({int? durationSeconds, String? taglineAr, String? taglineEn}) =>
      SplashConfig(
        durationSeconds: durationSeconds ?? this.durationSeconds,
        taglineAr: taglineAr ?? this.taglineAr,
        taglineEn: taglineEn ?? this.taglineEn,
      );
}

// ─── Onboarding Slide ─────────────────────────────────────────────────────────

class OnboardingSlide {
  final String id;
  final String titleAr;
  final String titleEn;
  final String descAr;
  final String descEn;
  final String imageUrl;
  final int order;
  final bool isActive;

  const OnboardingSlide({
    required this.id,
    this.titleAr = '',
    this.titleEn = '',
    this.descAr = '',
    this.descEn = '',
    this.imageUrl = '',
    this.order = 0,
    this.isActive = true,
  });

  factory OnboardingSlide.fromMap(String id, Map<String, dynamic> d) =>
      OnboardingSlide(
        id: id,
        titleAr: (d['titleAr'] ?? '').toString(),
        titleEn: (d['titleEn'] ?? '').toString(),
        descAr: (d['descAr'] ?? '').toString(),
        descEn: (d['descEn'] ?? '').toString(),
        imageUrl: (d['imageUrl'] ?? '').toString(),
        order: (d['order'] as int?) ?? 0,
        isActive: (d['isActive'] as bool?) ?? true,
      );

  Map<String, dynamic> toMap() => {
        'titleAr': titleAr,
        'titleEn': titleEn,
        'descAr': descAr,
        'descEn': descEn,
        'imageUrl': imageUrl,
        'order': order,
        'isActive': isActive,
      };

  OnboardingSlide copyWith({
    String? titleAr,
    String? titleEn,
    String? descAr,
    String? descEn,
    String? imageUrl,
    int? order,
    bool? isActive,
  }) =>
      OnboardingSlide(
        id: id,
        titleAr: titleAr ?? this.titleAr,
        titleEn: titleEn ?? this.titleEn,
        descAr: descAr ?? this.descAr,
        descEn: descEn ?? this.descEn,
        imageUrl: imageUrl ?? this.imageUrl,
        order: order ?? this.order,
        isActive: isActive ?? this.isActive,
      );
}

// ─── Login ────────────────────────────────────────────────────────────────────

class LoginConfig {
  final bool showGoogleLogin;
  final bool showAppleLogin;
  final bool showEmailLogin;
  final String termsUrl;
  final String privacyUrl;

  const LoginConfig({
    this.showGoogleLogin = true,
    this.showAppleLogin = true,
    this.showEmailLogin = true,
    this.termsUrl = '',
    this.privacyUrl = '',
  });

  factory LoginConfig.fromMap(Map<String, dynamic> d) => LoginConfig(
        showGoogleLogin: (d['showGoogleLogin'] as bool?) ?? true,
        showAppleLogin: (d['showAppleLogin'] as bool?) ?? true,
        showEmailLogin: (d['showEmailLogin'] as bool?) ?? true,
        termsUrl: (d['termsUrl'] ?? '').toString(),
        privacyUrl: (d['privacyUrl'] ?? '').toString(),
      );

  Map<String, dynamic> toMap() => {
        'showGoogleLogin': showGoogleLogin,
        'showAppleLogin': showAppleLogin,
        'showEmailLogin': showEmailLogin,
        'termsUrl': termsUrl,
        'privacyUrl': privacyUrl,
      };

  LoginConfig copyWith({
    bool? showGoogleLogin,
    bool? showAppleLogin,
    bool? showEmailLogin,
    String? termsUrl,
    String? privacyUrl,
  }) =>
      LoginConfig(
        showGoogleLogin: showGoogleLogin ?? this.showGoogleLogin,
        showAppleLogin: showAppleLogin ?? this.showAppleLogin,
        showEmailLogin: showEmailLogin ?? this.showEmailLogin,
        termsUrl: termsUrl ?? this.termsUrl,
        privacyUrl: privacyUrl ?? this.privacyUrl,
      );
}

// ─── Register ─────────────────────────────────────────────────────────────────

class RegisterConfig {
  final bool requireFullName;
  final bool requirePhone;
  final String termsUrl;
  final String privacyUrl;

  const RegisterConfig({
    this.requireFullName = true,
    this.requirePhone = false,
    this.termsUrl = '',
    this.privacyUrl = '',
  });

  factory RegisterConfig.fromMap(Map<String, dynamic> d) => RegisterConfig(
        requireFullName: (d['requireFullName'] as bool?) ?? true,
        requirePhone: (d['requirePhone'] as bool?) ?? false,
        termsUrl: (d['termsUrl'] ?? '').toString(),
        privacyUrl: (d['privacyUrl'] ?? '').toString(),
      );

  Map<String, dynamic> toMap() => {
        'requireFullName': requireFullName,
        'requirePhone': requirePhone,
        'termsUrl': termsUrl,
        'privacyUrl': privacyUrl,
      };

  RegisterConfig copyWith({
    bool? requireFullName,
    bool? requirePhone,
    String? termsUrl,
    String? privacyUrl,
  }) =>
      RegisterConfig(
        requireFullName: requireFullName ?? this.requireFullName,
        requirePhone: requirePhone ?? this.requirePhone,
        termsUrl: termsUrl ?? this.termsUrl,
        privacyUrl: privacyUrl ?? this.privacyUrl,
      );
}

// ─── Forgot Password ──────────────────────────────────────────────────────────

class ForgotPasswordConfig {
  final String successMessageAr;
  final String successMessageEn;

  const ForgotPasswordConfig({
    this.successMessageAr = 'تم إرسال رابط الاستعادة إلى بريدك الإلكتروني',
    this.successMessageEn = 'Reset link sent to your email',
  });

  factory ForgotPasswordConfig.fromMap(Map<String, dynamic> d) =>
      ForgotPasswordConfig(
        successMessageAr: (d['successMessageAr'] ?? 'تم إرسال رابط الاستعادة إلى بريدك الإلكتروني').toString(),
        successMessageEn: (d['successMessageEn'] ?? 'Reset link sent to your email').toString(),
      );

  Map<String, dynamic> toMap() => {
        'successMessageAr': successMessageAr,
        'successMessageEn': successMessageEn,
      };

  ForgotPasswordConfig copyWith({String? successMessageAr, String? successMessageEn}) =>
      ForgotPasswordConfig(
        successMessageAr: successMessageAr ?? this.successMessageAr,
        successMessageEn: successMessageEn ?? this.successMessageEn,
      );
}

// ─── Home ─────────────────────────────────────────────────────────────────────

class HomeConfig {
  final String welcomeTitleAr;
  final String welcomeTitleEn;
  final String welcomeSubtitleAr;
  final String welcomeSubtitleEn;
  final String defaultViewMode; // 'grid' or 'list'

  const HomeConfig({
    this.welcomeTitleAr = 'مرحباً بك',
    this.welcomeTitleEn = 'Welcome',
    this.welcomeSubtitleAr = 'اختر الخدمة للمتابعة',
    this.welcomeSubtitleEn = 'Choose a service to continue',
    this.defaultViewMode = 'grid',
  });

  factory HomeConfig.fromMap(Map<String, dynamic> d) => HomeConfig(
        welcomeTitleAr: (d['welcomeTitleAr'] ?? 'مرحباً بك').toString(),
        welcomeTitleEn: (d['welcomeTitleEn'] ?? 'Welcome').toString(),
        welcomeSubtitleAr: (d['welcomeSubtitleAr'] ?? 'اختر الخدمة للمتابعة').toString(),
        welcomeSubtitleEn: (d['welcomeSubtitleEn'] ?? 'Choose a service to continue').toString(),
        defaultViewMode: (d['defaultViewMode'] ?? 'grid').toString(),
      );

  Map<String, dynamic> toMap() => {
        'welcomeTitleAr': welcomeTitleAr,
        'welcomeTitleEn': welcomeTitleEn,
        'welcomeSubtitleAr': welcomeSubtitleAr,
        'welcomeSubtitleEn': welcomeSubtitleEn,
        'defaultViewMode': defaultViewMode,
      };

  HomeConfig copyWith({
    String? welcomeTitleAr,
    String? welcomeTitleEn,
    String? welcomeSubtitleAr,
    String? welcomeSubtitleEn,
    String? defaultViewMode,
  }) =>
      HomeConfig(
        welcomeTitleAr: welcomeTitleAr ?? this.welcomeTitleAr,
        welcomeTitleEn: welcomeTitleEn ?? this.welcomeTitleEn,
        welcomeSubtitleAr: welcomeSubtitleAr ?? this.welcomeSubtitleAr,
        welcomeSubtitleEn: welcomeSubtitleEn ?? this.welcomeSubtitleEn,
        defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      );
}

// ─── Profile ──────────────────────────────────────────────────────────────────

class ProfileConfig {
  final bool showSignature;
  final bool showLanguageOption;
  final bool showThemeOption;
  final bool showDeleteAccount;

  const ProfileConfig({
    this.showSignature = true,
    this.showLanguageOption = true,
    this.showThemeOption = true,
    this.showDeleteAccount = true,
  });

  factory ProfileConfig.fromMap(Map<String, dynamic> d) => ProfileConfig(
        showSignature: (d['showSignature'] as bool?) ?? true,
        showLanguageOption: (d['showLanguageOption'] as bool?) ?? true,
        showThemeOption: (d['showThemeOption'] as bool?) ?? true,
        showDeleteAccount: (d['showDeleteAccount'] as bool?) ?? true,
      );

  Map<String, dynamic> toMap() => {
        'showSignature': showSignature,
        'showLanguageOption': showLanguageOption,
        'showThemeOption': showThemeOption,
        'showDeleteAccount': showDeleteAccount,
      };

  ProfileConfig copyWith({
    bool? showSignature,
    bool? showLanguageOption,
    bool? showThemeOption,
    bool? showDeleteAccount,
  }) =>
      ProfileConfig(
        showSignature: showSignature ?? this.showSignature,
        showLanguageOption: showLanguageOption ?? this.showLanguageOption,
        showThemeOption: showThemeOption ?? this.showThemeOption,
        showDeleteAccount: showDeleteAccount ?? this.showDeleteAccount,
      );
}

// ─── Settings ─────────────────────────────────────────────────────────────────

class SettingsConfig {
  final bool showNotifications;
  final bool showDeleteAccount;
  final String supportEmail;
  final String supportWhatsapp;
  final String termsUrl;
  final String privacyUrl;

  const SettingsConfig({
    this.showNotifications = true,
    this.showDeleteAccount = true,
    this.supportEmail = '',
    this.supportWhatsapp = '',
    this.termsUrl = '',
    this.privacyUrl = '',
  });

  factory SettingsConfig.fromMap(Map<String, dynamic> d) => SettingsConfig(
        showNotifications: (d['showNotifications'] as bool?) ?? true,
        showDeleteAccount: (d['showDeleteAccount'] as bool?) ?? true,
        supportEmail: (d['supportEmail'] ?? '').toString(),
        supportWhatsapp: (d['supportWhatsapp'] ?? '').toString(),
        termsUrl: (d['termsUrl'] ?? '').toString(),
        privacyUrl: (d['privacyUrl'] ?? '').toString(),
      );

  Map<String, dynamic> toMap() => {
        'showNotifications': showNotifications,
        'showDeleteAccount': showDeleteAccount,
        'supportEmail': supportEmail,
        'supportWhatsapp': supportWhatsapp,
        'termsUrl': termsUrl,
        'privacyUrl': privacyUrl,
      };

  SettingsConfig copyWith({
    bool? showNotifications,
    bool? showDeleteAccount,
    String? supportEmail,
    String? supportWhatsapp,
    String? termsUrl,
    String? privacyUrl,
  }) =>
      SettingsConfig(
        showNotifications: showNotifications ?? this.showNotifications,
        showDeleteAccount: showDeleteAccount ?? this.showDeleteAccount,
        supportEmail: supportEmail ?? this.supportEmail,
        supportWhatsapp: supportWhatsapp ?? this.supportWhatsapp,
        termsUrl: termsUrl ?? this.termsUrl,
        privacyUrl: privacyUrl ?? this.privacyUrl,
      );
}
