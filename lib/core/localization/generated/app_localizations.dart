import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The app name displayed in splash, about, and header areas
  ///
  /// In ar, this message translates to:
  /// **'نِـسَـب'**
  String get appName;

  /// Short app tagline shown on splash screen
  ///
  /// In ar, this message translates to:
  /// **'حلول تمويلية ذكية'**
  String get appDescription;

  /// Loading indicator text on the splash screen
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get splashLoading;

  /// Welcome title on the login screen
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك'**
  String get loginTitle;

  /// Subtitle prompt below the login title
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك للمتابعة'**
  String get loginSubtitle;

  /// Google sign-in button label
  ///
  /// In ar, this message translates to:
  /// **'المتابعة مع Google'**
  String get loginWithGoogle;

  /// Apple sign-in button label
  ///
  /// In ar, this message translates to:
  /// **'المتابعة مع Apple'**
  String get loginWithApple;

  /// Button to continue without signing in
  ///
  /// In ar, this message translates to:
  /// **'تصفح كزائر'**
  String get browseAsGuest;

  /// Terms and privacy policy agreement text at bottom of login
  ///
  /// In ar, this message translates to:
  /// **'بالمتابعة، أنت توافق على شروط الاستخدام و سياسة الخصوصية'**
  String get termsText;

  /// Divider text between login methods and guest browsing
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get orText;

  /// Greeting shown on the home screen header with user name
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك {name}'**
  String homeGreeting(String name);

  /// Main hero card title on the home screen
  ///
  /// In ar, this message translates to:
  /// **'حلول تمويلية ذكية'**
  String get homeHeroTitle;

  /// Subtitle under the hero card title
  ///
  /// In ar, this message translates to:
  /// **'اكتشف منتجاتنا التمويلية المتنوعة بأفضل الشروط'**
  String get homeHeroSubtitle;

  /// Call-to-action button on the hero card
  ///
  /// In ar, this message translates to:
  /// **'استعرض المنتجات'**
  String get homeHeroCta;

  /// Section title above the quick action buttons
  ///
  /// In ar, this message translates to:
  /// **'خدمات سريعة'**
  String get quickActionsTitle;

  /// Quick action button label for products
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get quickActionProducts;

  /// Quick action button label for my requests
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get quickActionRequests;

  /// Quick action button label for contact
  ///
  /// In ar, this message translates to:
  /// **'تواصل'**
  String get quickActionContact;

  /// Section title for featured products on the home screen
  ///
  /// In ar, this message translates to:
  /// **'منتجات مميزة'**
  String get featuredProductsTitle;

  /// Link text to view all items in a section
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// Title of the products list screen
  ///
  /// In ar, this message translates to:
  /// **'المنتجات التمويلية'**
  String get productsTitle;

  /// Subtitle under the products screen title
  ///
  /// In ar, this message translates to:
  /// **'اختر المنتج التمويلي المناسب لاحتياجاتك'**
  String get productsSubtitle;

  /// Title for the product detail screen
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المنتج'**
  String get productDetailsTitle;

  /// Title for the sub-product detail screen
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المنتج الفرعي'**
  String get subProductDetailsTitle;

  /// Section title for sub-product options on product detail
  ///
  /// In ar, this message translates to:
  /// **'الخيارات المتاحة'**
  String get availableOptions;

  /// CTA button to apply for a financing product
  ///
  /// In ar, this message translates to:
  /// **'طلب التمويل'**
  String get applyForFinancing;

  /// Label for the financing amount field
  ///
  /// In ar, this message translates to:
  /// **'مبلغ التمويل'**
  String get amount;

  /// Label for the repayment period field
  ///
  /// In ar, this message translates to:
  /// **'مدة السداد'**
  String get period;

  /// Label for the profit rate field
  ///
  /// In ar, this message translates to:
  /// **'نسبة الأرباح'**
  String get profitRate;

  /// Section title for product features list
  ///
  /// In ar, this message translates to:
  /// **'المميزات'**
  String get features;

  /// Section title for product description
  ///
  /// In ar, this message translates to:
  /// **'وصف المنتج'**
  String get productDescription;

  /// Feature item: Sharia compliant
  ///
  /// In ar, this message translates to:
  /// **'متوافق مع أحكام الشريعة الإسلامية'**
  String get featureSharia;

  /// Feature item: fast and easy procedures
  ///
  /// In ar, this message translates to:
  /// **'إجراءات سريعة وسهلة'**
  String get featureFastProcess;

  /// Feature item: flexible installments
  ///
  /// In ar, this message translates to:
  /// **'أقساط ميسرة ومرنة'**
  String get featureFlexiblePayments;

  /// Feature item: excellent customer service
  ///
  /// In ar, this message translates to:
  /// **'خدمة عملاء متميزة'**
  String get featureCustomerService;

  /// Title of the apply/application screen
  ///
  /// In ar, this message translates to:
  /// **'طلب التمويل'**
  String get applyTitle;

  /// Step 1 title in the application form: Personal Information
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get step1Title;

  /// Step 2 title in the application form: Employment Information
  ///
  /// In ar, this message translates to:
  /// **'معلومات العمل'**
  String get step2Title;

  /// Step 3 title in the application form: Documents
  ///
  /// In ar, this message translates to:
  /// **'المستندات'**
  String get step3Title;

  /// Step 4 title in the application form: Confirmation
  ///
  /// In ar, this message translates to:
  /// **'التأكيد'**
  String get step4Title;

  /// Label for the full name input field
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// Hint text for the full name input field
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك الكامل'**
  String get fullNameHint;

  /// Label for the national ID input field
  ///
  /// In ar, this message translates to:
  /// **'رقم الهوية'**
  String get nationalId;

  /// Hint text for the national ID input field
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الهوية الوطنية'**
  String get nationalIdHint;

  /// Label for the date of birth input field
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد'**
  String get dateOfBirth;

  /// Hint text for the date of birth input field
  ///
  /// In ar, this message translates to:
  /// **'يوم / شهر / سنة'**
  String get dateOfBirthHint;

  /// Label for the phone number input field
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get phoneNumber;

  /// Hint text for the phone number input field
  ///
  /// In ar, this message translates to:
  /// **'05XXXXXXXX'**
  String get phoneNumberHint;

  /// Label for the employer input field
  ///
  /// In ar, this message translates to:
  /// **'جهة العمل'**
  String get employer;

  /// Hint text for the employer input field
  ///
  /// In ar, this message translates to:
  /// **'اسم جهة العمل'**
  String get employerHint;

  /// Label for the monthly salary input field
  ///
  /// In ar, this message translates to:
  /// **'الراتب الشهري'**
  String get monthlySalary;

  /// Hint text for the monthly salary input field
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الراتب'**
  String get monthlySalaryHint;

  /// Label for the years of service input field
  ///
  /// In ar, this message translates to:
  /// **'مدة الخدمة'**
  String get yearsOfService;

  /// Hint text for the years of service input field
  ///
  /// In ar, this message translates to:
  /// **'عدد سنوات الخدمة'**
  String get yearsOfServiceHint;

  /// Label for the employment sector selection
  ///
  /// In ar, this message translates to:
  /// **'القطاع'**
  String get employmentSector;

  /// Employment sector option: government
  ///
  /// In ar, this message translates to:
  /// **'حكومي'**
  String get government;

  /// Employment sector option: private
  ///
  /// In ar, this message translates to:
  /// **'خاص'**
  String get privateSector;

  /// Employment sector option: military
  ///
  /// In ar, this message translates to:
  /// **'عسكري'**
  String get military;

  /// Document upload label: national ID photo
  ///
  /// In ar, this message translates to:
  /// **'صورة الهوية الوطنية'**
  String get uploadId;

  /// Document upload label: salary certificate
  ///
  /// In ar, this message translates to:
  /// **'تعريف بالراتب'**
  String get uploadSalary;

  /// Document upload label: bank statement
  ///
  /// In ar, this message translates to:
  /// **'كشف حساب بنكي'**
  String get uploadBankStatement;

  /// Hint text shown under upload areas
  ///
  /// In ar, this message translates to:
  /// **'اضغط للرفع أو اسحب الملف'**
  String get uploadHint;

  /// Next button label in multi-step form
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// Previous button label in multi-step form
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// Submit button label on the final step
  ///
  /// In ar, this message translates to:
  /// **'إرسال الطلب'**
  String get submit;

  /// Loading state text while the application is being submitted
  ///
  /// In ar, this message translates to:
  /// **'جارٍ الإرسال...'**
  String get submitting;

  /// Success message after application submission
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الطلب بنجاح'**
  String get applicationSubmitted;

  /// Title for the confirmation/review step
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الطلب'**
  String get confirmationSummary;

  /// Instructional text on the confirmation step
  ///
  /// In ar, this message translates to:
  /// **'تأكد من صحة جميع البيانات قبل إرسال الطلب'**
  String get confirmationHint;

  /// Label for product name in confirmation summary
  ///
  /// In ar, this message translates to:
  /// **'المنتج'**
  String get confirmationProduct;

  /// Label for financing type in confirmation summary
  ///
  /// In ar, this message translates to:
  /// **'نوع التمويل'**
  String get confirmationFinancingType;

  /// Label for maximum amount in confirmation summary
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى'**
  String get confirmationMaxAmount;

  /// Label for period in confirmation summary
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get confirmationPeriod;

  /// Title of the my requests screen
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get myRequestsTitle;

  /// Empty state message when no requests exist
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات حالياً'**
  String get noRequests;

  /// Label for request status
  ///
  /// In ar, this message translates to:
  /// **'حالة الطلب'**
  String get requestStatus;

  /// Request status: under review
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get underReview;

  /// Request status: approved
  ///
  /// In ar, this message translates to:
  /// **'تمت الموافقة'**
  String get approved;

  /// Request status: rejected
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get rejected;

  /// Title of the profile screen
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profileTitle;

  /// Profile menu item to navigate to my requests
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get myRequests;

  /// Profile menu item for settings
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// Profile menu item for editing account details
  ///
  /// In ar, this message translates to:
  /// **'تعديل البيانات'**
  String get editDetails;

  /// Profile menu item for changing password
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// Profile menu item for about the app
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// Logout button label
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// Title of the logout confirmation dialog
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logoutConfirmTitle;

  /// Confirmation message in the logout dialog
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من رغبتك في تسجيل الخروج؟'**
  String get logoutConfirmMessage;

  /// Cancel button label used in dialogs
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// Confirm button label used in dialogs
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// Display name for unauthenticated users
  ///
  /// In ar, this message translates to:
  /// **'زائر'**
  String get guest;

  /// Badge text for guest login method
  ///
  /// In ar, this message translates to:
  /// **'زائر حساب'**
  String get guestAccount;

  /// Title of the about screen
  ///
  /// In ar, this message translates to:
  /// **'عن نِسَب'**
  String get aboutTitle;

  /// Full description of the app on the about screen
  ///
  /// In ar, this message translates to:
  /// **'تطبيق نِسَب هو منصة متكاملة لعرض المنتجات التمويلية بشكل منظم وسهل، يتيح للمستخدمين استعراض ومقارنة الحلول التمويلية المتنوعة واختيار الأنسب لاحتياجاتهم.'**
  String get aboutDescription;

  /// Version label with version number
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String aboutVersion(String version);

  /// Section title for the app idea on the about screen
  ///
  /// In ar, this message translates to:
  /// **'فكرة التطبيق'**
  String get aboutIdeaTitle;

  /// Section title for services on the about screen
  ///
  /// In ar, this message translates to:
  /// **'خدماتنا'**
  String get ourServices;

  /// Section title for advantages on the about screen
  ///
  /// In ar, this message translates to:
  /// **'المزايا'**
  String get ourAdvantages;

  /// Advantage: high security and privacy
  ///
  /// In ar, this message translates to:
  /// **'أمان وخصوصية عالية'**
  String get advantageSecurity;

  /// Advantage: fast procedures
  ///
  /// In ar, this message translates to:
  /// **'سرعة في الإجراءات'**
  String get advantageSpeed;

  /// Advantage: smooth user experience
  ///
  /// In ar, this message translates to:
  /// **'تجربة مستخدم سلسة'**
  String get advantageUx;

  /// Advantage: Sharia compliant
  ///
  /// In ar, this message translates to:
  /// **'متوافق مع الشريعة الإسلامية'**
  String get advantageSharia;

  /// Title of the contact screen
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactTitle;

  /// Subtitle text on the contact screen
  ///
  /// In ar, this message translates to:
  /// **'اختر وسيلة التواصل المفضلة لديك'**
  String get contactSubtitle;

  /// Header greeting on the contact screen
  ///
  /// In ar, this message translates to:
  /// **'نسعد بتواصلك'**
  String get contactHeader;

  /// Contact method label: WhatsApp
  ///
  /// In ar, this message translates to:
  /// **'واتساب'**
  String get whatsapp;

  /// Contact method label: email
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// Contact method label: Twitter/X
  ///
  /// In ar, this message translates to:
  /// **'تويتر / X'**
  String get twitter;

  /// Contact method label: LinkedIn
  ///
  /// In ar, this message translates to:
  /// **'لينكدإن'**
  String get linkedin;

  /// Contact method label: website
  ///
  /// In ar, this message translates to:
  /// **'الموقع الإلكتروني'**
  String get website;

  /// Title of the developer screen
  ///
  /// In ar, this message translates to:
  /// **'عن المطور'**
  String get developerTitle;

  /// Developer subtitle/role description
  ///
  /// In ar, this message translates to:
  /// **'مطور تطبيقات الجوال'**
  String get developedBy;

  /// Generic error message title
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get errorOccurred;

  /// Retry button label
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// General loading indicator text
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get loading;

  /// Empty state message when no data is available
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// Accessible label for the back navigation button
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get backButton;

  /// Bottom navigation label for the home tab
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// Bottom navigation label for the settings tab
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// Bottom navigation label for the products tab
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get navProducts;

  /// Bottom navigation label for the about tab
  ///
  /// In ar, this message translates to:
  /// **'عن نسب'**
  String get navAbout;

  /// Bottom navigation label for the profile tab
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navProfile;

  /// App logo character displayed on splash and login screens
  ///
  /// In ar, this message translates to:
  /// **'ن'**
  String get appLogo;

  /// Service name: personal financing
  ///
  /// In ar, this message translates to:
  /// **'التمويل الشخصي'**
  String get servicePersonalFinancing;

  /// Service name: real estate financing
  ///
  /// In ar, this message translates to:
  /// **'التمويل العقاري'**
  String get serviceRealEstateFinancing;

  /// Service name: lease financing
  ///
  /// In ar, this message translates to:
  /// **'التمويل التأجيري'**
  String get serviceLeaseFinancing;

  /// Service name: POS financing
  ///
  /// In ar, this message translates to:
  /// **'تمويل نقاط البيع'**
  String get servicePosFinancing;

  /// Service name: Khairat program
  ///
  /// In ar, this message translates to:
  /// **'برنامج خيرات'**
  String get serviceKhairat;

  /// Section title for development information
  ///
  /// In ar, this message translates to:
  /// **'معلومات التطوير'**
  String get devInfoTitle;

  /// Label for platform in developer info
  ///
  /// In ar, this message translates to:
  /// **'المنصة'**
  String get devPlatform;

  /// Label for version in developer info
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get devVersion;

  /// Label for architecture in developer info
  ///
  /// In ar, this message translates to:
  /// **'البنية'**
  String get devArchitecture;

  /// Label for documents attached count in confirmation step
  ///
  /// In ar, this message translates to:
  /// **'عدد المستندات المرفقة'**
  String get documentsAttachedCount;

  /// Error message for invalid product ID
  ///
  /// In ar, this message translates to:
  /// **'معرّف المنتج غير صالح'**
  String get invalidProductId;

  /// Error message when product is not found
  ///
  /// In ar, this message translates to:
  /// **'المنتج غير موجود'**
  String get productNotFound;

  /// Error message when sub-product is not found
  ///
  /// In ar, this message translates to:
  /// **'المنتج الفرعي غير موجود'**
  String get subProductNotFound;

  /// Login form submit button label
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get loginButton;

  /// Register form submit button label
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get registerButton;

  /// Forgot password link text
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// Text before register link on login page
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get dontHaveAccount;

  /// Text before login link on register page
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get alreadyHaveAccount;

  /// Title on the register page header
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get registerTitle;

  /// Subtitle on the register page header
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حسابك للمتابعة'**
  String get registerSubtitle;

  /// Title on the forgot password page
  ///
  /// In ar, this message translates to:
  /// **'استعادة كلمة المرور'**
  String get forgotPasswordTitle;

  /// Subtitle on forgot password page
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني لإرسال رابط الاستعادة'**
  String get forgotPasswordSubtitle;

  /// Send reset link button label
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط الاستعادة'**
  String get sendResetLink;

  /// Success message after reset link is sent
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط الاستعادة بنجاح'**
  String get resetLinkSent;

  /// Label for email text field
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailLabel;

  /// Hint for email text field
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني'**
  String get emailHint;

  /// Label for password text field
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordLabel;

  /// Hint for password text field
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get passwordHint;

  /// Label for display name text field
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get displayNameLabel;

  /// Hint for display name text field
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسمك'**
  String get displayNameHint;

  /// Label for auth provider column
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدخول'**
  String get authProviderLabel;

  /// Label for role column
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get roleLabel;

  /// Label for created at column
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get createdAtLabel;

  /// Label for last login column
  ///
  /// In ar, this message translates to:
  /// **'آخر دخول'**
  String get lastLoginLabel;

  /// Divider text between form and social buttons
  ///
  /// In ar, this message translates to:
  /// **'أو سجّل دخولك باستخدام'**
  String get orLoginWith;

  /// Register link text short form
  ///
  /// In ar, this message translates to:
  /// **'سجّل'**
  String get register;

  /// Login link text short form
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك'**
  String get login;

  /// Text before terms of use link
  ///
  /// In ar, this message translates to:
  /// **'بالمتابعة، أنت توافق على'**
  String get termsPrefix;

  /// Terms of use link text
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام'**
  String get termsOfUse;

  /// Conjunction between terms and privacy
  ///
  /// In ar, this message translates to:
  /// **'و'**
  String get termsAnd;

  /// Privacy policy link text
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// Profile menu item for changing theme mode
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get themeMode;

  /// Light theme option label
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get themeModeLight;

  /// Dark theme option label
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get themeModeDark;

  /// System theme option label
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get themeModeSystem;

  /// Profile menu item for changing language
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// Arabic language option label
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// English language option label
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Welcome badge text on onboarding page 1
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في Nesab'**
  String get onboardingBadge;

  /// Onboarding page 1 heading line 1
  ///
  /// In ar, this message translates to:
  /// **'بوابتك الأولى'**
  String get onboardingTitle1Line1;

  /// Onboarding page 1 heading line 2 (emerald accent)
  ///
  /// In ar, this message translates to:
  /// **'للحلول التمويلية'**
  String get onboardingTitle1Line2;

  /// Onboarding page 1 description paragraph
  ///
  /// In ar, this message translates to:
  /// **'استعرض وقارن أفضل المنتجات التمويلية الشخصية والعقارية في المملكة بكل شفافية وموثوقية.'**
  String get onboardingDesc1;

  /// Next button on onboarding page 1
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get onboardingNext;

  /// Onboarding page 2 heading line 1
  ///
  /// In ar, this message translates to:
  /// **'خيارات متنوعة،'**
  String get onboardingTitle2Line1;

  /// Onboarding page 2 heading line 2 (emerald accent)
  ///
  /// In ar, this message translates to:
  /// **'قرار واحد ذكي'**
  String get onboardingTitle2Line2;

  /// Onboarding page 2 description paragraph
  ///
  /// In ar, this message translates to:
  /// **'من القروض الشخصية إلى تمويل المنازل ونقاط البيع. نجمع لك كل الخيارات لتختار الأنسب لاحتياجك.'**
  String get onboardingDesc2;

  /// Start button on onboarding page 2
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get onboardingStart;

  /// Skip button on onboarding page 2
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get onboardingSkip;

  /// Real estate financing card title on onboarding
  ///
  /// In ar, this message translates to:
  /// **'التمويل العقاري'**
  String get onboardingRealEstate;

  /// Real estate financing card subtitle on onboarding
  ///
  /// In ar, this message translates to:
  /// **'خيارات تملك واستثمار'**
  String get onboardingRealEstateDesc;

  /// Personal financing card title on onboarding
  ///
  /// In ar, this message translates to:
  /// **'التمويل الشخصي'**
  String get onboardingPersonal;

  /// Personal financing card subtitle on onboarding
  ///
  /// In ar, this message translates to:
  /// **'سيولة نقدية فورية'**
  String get onboardingPersonalDesc;

  /// POS card title on onboarding
  ///
  /// In ar, this message translates to:
  /// **'نقاط البيع'**
  String get onboardingPos;

  /// POS card subtitle on onboarding
  ///
  /// In ar, this message translates to:
  /// **'حلول للمتاجر والأعمال'**
  String get onboardingPosDesc;

  /// Lease financing circle label on onboarding
  ///
  /// In ar, this message translates to:
  /// **'التمويل التأجيري'**
  String get onboardingLease;

  /// Lease financing circle subtitle on onboarding
  ///
  /// In ar, this message translates to:
  /// **'إيجار ينتهي بالتملك'**
  String get onboardingLeaseDesc;

  /// Paywall title (app name part)
  ///
  /// In ar, this message translates to:
  /// **'نِـسَـب'**
  String get paywallTitle;

  /// Paywall title accent part (gold colored)
  ///
  /// In ar, this message translates to:
  /// **'بلس +'**
  String get paywallTitleAccent;

  /// Paywall subtitle text
  ///
  /// In ar, this message translates to:
  /// **'ترقية حصرية لفرص تمويلية أفضل'**
  String get paywallSubtitle;

  /// Paywall benefit 1 title
  ///
  /// In ar, this message translates to:
  /// **'أولوية المعالجة'**
  String get paywallBenefit1Title;

  /// Paywall benefit 1 description
  ///
  /// In ar, this message translates to:
  /// **'يتم رفع طلبك ومعالجته بشكل فوري قبل الآخرين.'**
  String get paywallBenefit1Desc;

  /// Paywall benefit 2 title
  ///
  /// In ar, this message translates to:
  /// **'نسب ربح حصرية'**
  String get paywallBenefit2Title;

  /// Paywall benefit 2 description
  ///
  /// In ar, this message translates to:
  /// **'عروض خاصة وهوامش ربح أقل حصرياً للأعضاء.'**
  String get paywallBenefit2Desc;

  /// Paywall benefit 3 title
  ///
  /// In ar, this message translates to:
  /// **'مستشار مالي خاص'**
  String get paywallBenefit3Title;

  /// Paywall benefit 3 description
  ///
  /// In ar, this message translates to:
  /// **'تواصل مباشر مع خبير مالي لمساعدتك في اتخاذ القرار.'**
  String get paywallBenefit3Desc;

  /// Paywall social proof text
  ///
  /// In ar, this message translates to:
  /// **'انضم إلى +1500 مستفيد مميز'**
  String get paywallSocialProof;

  /// Paywall limited offer badge text
  ///
  /// In ar, this message translates to:
  /// **'عرض محدود: خصم 50% لأول مرة'**
  String get paywallOffer;

  /// Paywall CTA button text
  ///
  /// In ar, this message translates to:
  /// **'اشترك بـ 99 ريال / سنوياً'**
  String get paywallCta;

  /// Paywall strikethrough old price
  ///
  /// In ar, this message translates to:
  /// **'كان 199 ريال'**
  String get paywallOldPrice;

  /// Paywall cancellation disclaimer
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إلغاء الاشتراك في أي وقت من إعدادات الحساب'**
  String get paywallCancel;

  /// Email sign up button label on login screen
  ///
  /// In ar, this message translates to:
  /// **'التسجيل بالبريد الإلكتروني'**
  String get continueWithEmail;

  /// Sign in button label on login screen
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// Validation error when email is empty
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مطلوب'**
  String get validationEmailRequired;

  /// Validation error when email format is invalid
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صحيح'**
  String get validationEmailInvalid;

  /// Validation error when password is empty
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور مطلوبة'**
  String get validationPasswordRequired;

  /// Validation error when password is too short
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 6 أحرف على الأقل'**
  String get validationPasswordTooShort;

  /// Validation error when name is empty
  ///
  /// In ar, this message translates to:
  /// **'الاسم مطلوب'**
  String get validationNameRequired;

  /// Validation error when name is too short
  ///
  /// In ar, this message translates to:
  /// **'الاسم يجب أن يكون حرفين على الأقل'**
  String get validationNameTooShort;

  /// Generic validation error for required fields
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get validationFieldRequired;

  /// Subtitle under the quick access section on home screen
  ///
  /// In ar, this message translates to:
  /// **'اختر الخدمة للمتابعة'**
  String get homeSelectService;

  /// Short description for personal financing category card
  ///
  /// In ar, this message translates to:
  /// **'حلول تمويلية شخصية'**
  String get servicePersonalFinancingDesc;

  /// Short description for real estate financing category card
  ///
  /// In ar, this message translates to:
  /// **'تمويل عقاري ميسّر'**
  String get serviceRealEstateFinancingDesc;

  /// Short description for lease financing category card
  ///
  /// In ar, this message translates to:
  /// **'إيجار منتهٍ بالتملك'**
  String get serviceLeaseFinancingDesc;

  /// Short description for POS financing category card
  ///
  /// In ar, this message translates to:
  /// **'حلول أجهزة نقاط البيع'**
  String get servicePosFinancingDesc;

  /// Short description for Khairat charity category card
  ///
  /// In ar, this message translates to:
  /// **'التبرعات والعطاء'**
  String get serviceKhairatDesc;

  /// Service name for tools/settings category card
  ///
  /// In ar, this message translates to:
  /// **'الأدوات'**
  String get serviceTools;

  /// Short description for tools/settings category card
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات والتفضيلات'**
  String get serviceToolsDesc;

  /// Error shown when a category type is invalid
  ///
  /// In ar, this message translates to:
  /// **'الفئة غير موجودة'**
  String get categoryNotFound;

  /// No description provided for @subPersonalFinanceQuick.
  ///
  /// In ar, this message translates to:
  /// **'التمويل الشخصي المختصر'**
  String get subPersonalFinanceQuick;

  /// No description provided for @subPersonalFinanceQuickDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمويل سريع بإجراءات مبسطة للاحتياجات العاجلة'**
  String get subPersonalFinanceQuickDesc;

  /// No description provided for @subPersonalFinancePlus.
  ///
  /// In ar, this message translates to:
  /// **'التمويل الشخصي - بلص'**
  String get subPersonalFinancePlus;

  /// No description provided for @subPersonalFinancePlusDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمويل بمزايا إضافية وحدود أعلى'**
  String get subPersonalFinancePlusDesc;

  /// No description provided for @subDebtPurchase.
  ///
  /// In ar, this message translates to:
  /// **'تمويل شراء المديونية'**
  String get subDebtPurchase;

  /// No description provided for @subDebtPurchaseDesc.
  ///
  /// In ar, this message translates to:
  /// **'نقل مديونيتك من جهة تمويلية أخرى بشروط أفضل'**
  String get subDebtPurchaseDesc;

  /// No description provided for @subRealEstate.
  ///
  /// In ar, this message translates to:
  /// **'التمويل العقاري'**
  String get subRealEstate;

  /// No description provided for @subRealEstateDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمويل لشراء عقار سكني أو استثماري'**
  String get subRealEstateDesc;

  /// No description provided for @subRealEstatePlus.
  ///
  /// In ar, this message translates to:
  /// **'التمويل العقاري - بلص'**
  String get subRealEstatePlus;

  /// No description provided for @subRealEstatePlusDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمويل عقاري بمميزات حصرية وأرباح تنافسية'**
  String get subRealEstatePlusDesc;

  /// No description provided for @subLeasing.
  ///
  /// In ar, this message translates to:
  /// **'التمويل التأجيري'**
  String get subLeasing;

  /// No description provided for @subLeasingDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمويل بنظام الإجارة المنتهية بالتمليك'**
  String get subLeasingDesc;

  /// No description provided for @subLeasingPlus.
  ///
  /// In ar, this message translates to:
  /// **'التمويل التأجيري - بلص'**
  String get subLeasingPlus;

  /// No description provided for @subLeasingPlusDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمويل تأجيري بمزايا إضافية وشروط ميسرة'**
  String get subLeasingPlusDesc;

  /// No description provided for @subPos.
  ///
  /// In ar, this message translates to:
  /// **'تمويل نقاط البيع'**
  String get subPos;

  /// No description provided for @subPosDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمويل مخصص لتطوير أعمالك عبر نقاط البيع'**
  String get subPosDesc;

  /// No description provided for @subCharity.
  ///
  /// In ar, this message translates to:
  /// **'حساب خيرات'**
  String get subCharity;

  /// No description provided for @subCharityDesc.
  ///
  /// In ar, this message translates to:
  /// **'حساب ادخاري بعوائد مجزية ومتوافق مع الشريعة'**
  String get subCharityDesc;

  /// No description provided for @subToolsDateConvert.
  ///
  /// In ar, this message translates to:
  /// **'تحويل التاريخ'**
  String get subToolsDateConvert;

  /// No description provided for @subToolsDateConvertDesc.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بين التاريخ الهجري والميلادي'**
  String get subToolsDateConvertDesc;

  /// No description provided for @subToolsAgeCalc.
  ///
  /// In ar, this message translates to:
  /// **'حساب العمر'**
  String get subToolsAgeCalc;

  /// No description provided for @subToolsAgeCalcDesc.
  ///
  /// In ar, this message translates to:
  /// **'حساب العمر بالتاريخ الهجري والميلادي'**
  String get subToolsAgeCalcDesc;

  /// No description provided for @subToolsDeductions.
  ///
  /// In ar, this message translates to:
  /// **'معرفة الاستقطاعات'**
  String get subToolsDeductions;

  /// No description provided for @subToolsDeductionsDesc.
  ///
  /// In ar, this message translates to:
  /// **'حساب صافي الراتب بعد الاستقطاعات'**
  String get subToolsDeductionsDesc;

  /// No description provided for @adminLoginTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة تحكم المشرف'**
  String get adminLoginTitle;

  /// No description provided for @adminLoginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لإدارة اللوحة'**
  String get adminLoginSubtitle;

  /// No description provided for @usersTitle.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون'**
  String get usersTitle;

  /// No description provided for @toolsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأدوات'**
  String get toolsTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboardTitle;

  /// No description provided for @pageOf.
  ///
  /// In ar, this message translates to:
  /// **'صفحة {current} من {total}'**
  String pageOf(int current, int total);

  /// No description provided for @rowsPerPage.
  ///
  /// In ar, this message translates to:
  /// **'صفوف لكل صفحة'**
  String get rowsPerPage;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @managersTitle.
  ///
  /// In ar, this message translates to:
  /// **'المديرون'**
  String get managersTitle;

  /// No description provided for @managersSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عرض وإدارة مديري اللوحة.'**
  String get managersSubtitle;

  /// No description provided for @managersEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مديرون بعد. انقر \"إضافة مدير\" لإنشاء واحد.'**
  String get managersEmpty;

  /// No description provided for @addManagerButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مدير'**
  String get addManagerButton;

  /// No description provided for @createAdminsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مدير'**
  String get createAdminsTitle;

  /// No description provided for @createAdminsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مدير جديد بالبريد الإلكتروني وكلمة المرور والدور.'**
  String get createAdminsSubtitle;

  /// No description provided for @createAdminButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مدير'**
  String get createAdminButton;

  /// No description provided for @createAdminSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء المدير بنجاح.'**
  String get createAdminSuccess;

  /// No description provided for @deleteManagerButton.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteManagerButton;

  /// No description provided for @deleteManagerConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المدير'**
  String get deleteManagerConfirmTitle;

  /// No description provided for @deleteManagerConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف {name}؟ سيتم إزالة صلاحيات الدخول.'**
  String deleteManagerConfirmMessage(String name);

  /// No description provided for @deleteManagerSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المدير بنجاح.'**
  String get deleteManagerSuccess;

  /// No description provided for @deleteManagerError.
  ///
  /// In ar, this message translates to:
  /// **'فشل في حذف المدير.'**
  String get deleteManagerError;

  /// No description provided for @roleAdmin.
  ///
  /// In ar, this message translates to:
  /// **'مسؤول'**
  String get roleAdmin;

  /// No description provided for @roleUser.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get roleUser;

  /// No description provided for @categoriesTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get categoriesTitle;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الفئات والفئات الفرعية.'**
  String get categoriesSubtitle;

  /// No description provided for @addCategory.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فئة'**
  String get addCategory;

  /// No description provided for @addSubCategory.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فئة فرعية'**
  String get addSubCategory;

  /// No description provided for @categoryArabicName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالعربية'**
  String get categoryArabicName;

  /// No description provided for @categoryEnglishName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم بالإنجليزية'**
  String get categoryEnglishName;

  /// No description provided for @categoryImage.
  ///
  /// In ar, this message translates to:
  /// **'الصورة'**
  String get categoryImage;

  /// No description provided for @pickImage.
  ///
  /// In ar, this message translates to:
  /// **'اختر من الجهاز'**
  String get pickImage;

  /// No description provided for @categoryImageRequired.
  ///
  /// In ar, this message translates to:
  /// **'الصورة مطلوبة'**
  String get categoryImageRequired;

  /// No description provided for @categorySaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الفئة'**
  String get categorySaved;

  /// No description provided for @categoryTitleSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم العنوان'**
  String get categoryTitleSize;

  /// No description provided for @categoryImageWidth.
  ///
  /// In ar, this message translates to:
  /// **'عرض الصورة (0–1)'**
  String get categoryImageWidth;

  /// No description provided for @categoryImageHeight.
  ///
  /// In ar, this message translates to:
  /// **'ارتفاع الصورة (0–1)'**
  String get categoryImageHeight;

  /// No description provided for @categoryOpacity.
  ///
  /// In ar, this message translates to:
  /// **'الشفافية (0–1)'**
  String get categoryOpacity;

  /// No description provided for @categoryCalculatorType.
  ///
  /// In ar, this message translates to:
  /// **'الحاسبة / الأداة'**
  String get categoryCalculatorType;

  /// No description provided for @categoryCalculatorTypeHint.
  ///
  /// In ar, this message translates to:
  /// **'اختر الحاسبة أو الأداة'**
  String get categoryCalculatorTypeHint;

  /// No description provided for @extractionFailureLogsTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجلات فشل الاستخراج'**
  String get extractionFailureLogsTitle;

  /// No description provided for @extractionFailureLogsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'صفحات المنتجات التي لم يُعرض فيها زر الإضافة للسلة.'**
  String get extractionFailureLogsSubtitle;

  /// No description provided for @extractionFailureLogsUrl.
  ///
  /// In ar, this message translates to:
  /// **'الرابط'**
  String get extractionFailureLogsUrl;

  /// No description provided for @extractionFailureLogsMarketplace.
  ///
  /// In ar, this message translates to:
  /// **'السوق'**
  String get extractionFailureLogsMarketplace;

  /// No description provided for @extractionFailureLogsTitleFound.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get extractionFailureLogsTitleFound;

  /// No description provided for @extractionFailureLogsPriceFound.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get extractionFailureLogsPriceFound;

  /// No description provided for @extractionFailureLogsColorFound.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get extractionFailureLogsColorFound;

  /// No description provided for @extractionFailureLogsSizeFound.
  ///
  /// In ar, this message translates to:
  /// **'المقاس'**
  String get extractionFailureLogsSizeFound;

  /// No description provided for @extractionFailureLogsCreatedAt.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get extractionFailureLogsCreatedAt;

  /// No description provided for @extractionFailureLogsYes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get extractionFailureLogsYes;

  /// No description provided for @extractionFailureLogsNo.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get extractionFailureLogsNo;

  /// No description provided for @calculatorsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحاسبات المالية'**
  String get calculatorsTitle;

  /// No description provided for @calculatorsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'احسب خيارات التمويل والأهلية'**
  String get calculatorsSubtitle;

  /// No description provided for @calcPersonalFinance.
  ///
  /// In ar, this message translates to:
  /// **'التمويل الشخصي (PLAS)'**
  String get calcPersonalFinance;

  /// No description provided for @calcPersonalFinanceDesc.
  ///
  /// In ar, this message translates to:
  /// **'حساب التمويل الشخصي بالتفاصيل الكاملة'**
  String get calcPersonalFinanceDesc;

  /// No description provided for @calcPersonalFinanceQuick.
  ///
  /// In ar, this message translates to:
  /// **'التمويل الشخصي المختصر'**
  String get calcPersonalFinanceQuick;

  /// No description provided for @calcPersonalFinanceQuickDesc.
  ///
  /// In ar, this message translates to:
  /// **'حاسبة تمويل شخصي مبسطة'**
  String get calcPersonalFinanceQuickDesc;

  /// No description provided for @calcDebtPurchase.
  ///
  /// In ar, this message translates to:
  /// **'شراء مديونية'**
  String get calcDebtPurchase;

  /// No description provided for @calcDebtPurchaseDesc.
  ///
  /// In ar, this message translates to:
  /// **'نقل المديونية من بنك آخر'**
  String get calcDebtPurchaseDesc;

  /// No description provided for @calcRealEstate.
  ///
  /// In ar, this message translates to:
  /// **'التمويل العقاري'**
  String get calcRealEstate;

  /// No description provided for @calcRealEstateDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمويل عقاري مع حساب المدة المتاحة تلقائياً'**
  String get calcRealEstateDesc;

  /// No description provided for @calcRealEstatePlus.
  ///
  /// In ar, this message translates to:
  /// **'التمويل العقاري بلص (2 في 1)'**
  String get calcRealEstatePlus;

  /// No description provided for @calcRealEstatePlusDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمويل عقاري مع تمويل شخصي'**
  String get calcRealEstatePlusDesc;

  /// No description provided for @calcLeasingRegular.
  ///
  /// In ar, this message translates to:
  /// **'التأجيري (تاجيري)'**
  String get calcLeasingRegular;

  /// No description provided for @calcLeasingRegularDesc.
  ///
  /// In ar, this message translates to:
  /// **'حاسبة التمويل التأجيري للسيارات'**
  String get calcLeasingRegularDesc;

  /// No description provided for @calcLeasingMicro.
  ///
  /// In ar, this message translates to:
  /// **'التأجيري مايكرو'**
  String get calcLeasingMicro;

  /// No description provided for @calcLeasingMicroDesc.
  ///
  /// In ar, this message translates to:
  /// **'حساب أقصى سعر سيارة ممكن'**
  String get calcLeasingMicroDesc;

  /// No description provided for @calcLeasingAutoCalcMaxCar.
  ///
  /// In ar, this message translates to:
  /// **'حساب تلقائي اقصى سعر سيارة للعميل'**
  String get calcLeasingAutoCalcMaxCar;

  /// No description provided for @calcLeasingCarPriceZeroHint.
  ///
  /// In ar, this message translates to:
  /// **'وضع صفر في خانة سعر السيارة'**
  String get calcLeasingCarPriceZeroHint;

  /// No description provided for @calcResultCostOfTerm.
  ///
  /// In ar, this message translates to:
  /// **'كلفة الأجل'**
  String get calcResultCostOfTerm;

  /// No description provided for @calcLeasingAsPercent.
  ///
  /// In ar, this message translates to:
  /// **'نسبة مئوية من قيمة السيارة'**
  String get calcLeasingAsPercent;

  /// No description provided for @calcLeasingAsAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ (ريال)'**
  String get calcLeasingAsAmount;

  /// No description provided for @calcInputAdminFees.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم الإدارية (ريال)'**
  String get calcInputAdminFees;

  /// No description provided for @calcInputLicensePlateFees.
  ///
  /// In ar, this message translates to:
  /// **'رسوم اللوحات (ريال)'**
  String get calcInputLicensePlateFees;

  /// No description provided for @calcResultLicensePlateFees.
  ///
  /// In ar, this message translates to:
  /// **'رسوم اللوحات'**
  String get calcResultLicensePlateFees;

  /// No description provided for @calcPosFinancing.
  ///
  /// In ar, this message translates to:
  /// **'تمويل نقاط البيع'**
  String get calcPosFinancing;

  /// No description provided for @calcPosFinancingDesc.
  ///
  /// In ar, this message translates to:
  /// **'حاسبة تمويل نقاط البيع للأعمال'**
  String get calcPosFinancingDesc;

  /// No description provided for @calcKhairat.
  ///
  /// In ar, this message translates to:
  /// **'حساب خيرات'**
  String get calcKhairat;

  /// No description provided for @calcKhairatDesc.
  ///
  /// In ar, this message translates to:
  /// **'حاسبة أرباح حساب الادخار'**
  String get calcKhairatDesc;

  /// No description provided for @calcProtectionSavings.
  ///
  /// In ar, this message translates to:
  /// **'الحماية والادخار'**
  String get calcProtectionSavings;

  /// No description provided for @calcProtectionSavingsDesc.
  ///
  /// In ar, this message translates to:
  /// **'جدول التأمين والاستثمار'**
  String get calcProtectionSavingsDesc;

  /// No description provided for @calcAgeCalculator.
  ///
  /// In ar, this message translates to:
  /// **'حاسبة العمر'**
  String get calcAgeCalculator;

  /// No description provided for @calcAgeCalculatorDesc.
  ///
  /// In ar, this message translates to:
  /// **'حساب العمر من تاريخ الميلاد'**
  String get calcAgeCalculatorDesc;

  /// No description provided for @calcDateConverter.
  ///
  /// In ar, this message translates to:
  /// **'تحويل التاريخ'**
  String get calcDateConverter;

  /// No description provided for @calcDateConverterDesc.
  ///
  /// In ar, this message translates to:
  /// **'تحويل بين الهجري والميلادي'**
  String get calcDateConverterDesc;

  /// No description provided for @calcDeductions.
  ///
  /// In ar, this message translates to:
  /// **'حاسبة الاستقطاعات'**
  String get calcDeductions;

  /// No description provided for @calcDeductionsDesc.
  ///
  /// In ar, this message translates to:
  /// **'عرض تفصيل الاستقطاعات من الراتب'**
  String get calcDeductionsDesc;

  /// No description provided for @calcBankFees.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم البنكية'**
  String get calcBankFees;

  /// No description provided for @calcBankFeesDesc.
  ///
  /// In ar, this message translates to:
  /// **'مقارنة الرسوم البنكية وفق تعليمات ساما'**
  String get calcBankFeesDesc;

  /// No description provided for @calcInputSalary.
  ///
  /// In ar, this message translates to:
  /// **'الراتب الشهري (ريال)'**
  String get calcInputSalary;

  /// No description provided for @calcInputEmploymentType.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الوظيفي'**
  String get calcInputEmploymentType;

  /// No description provided for @calcInputSector.
  ///
  /// In ar, this message translates to:
  /// **'القطاع الوظيفي'**
  String get calcInputSector;

  /// No description provided for @calcInputDateOfBirth.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الميلاد'**
  String get calcInputDateOfBirth;

  /// No description provided for @calcInputProfitRate.
  ///
  /// In ar, this message translates to:
  /// **'هامش الربح'**
  String get calcInputProfitRate;

  /// No description provided for @calcInputDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة التمويل'**
  String get calcInputDuration;

  /// No description provided for @calcInputDurationYears.
  ///
  /// In ar, this message translates to:
  /// **'المدة (سنوات)'**
  String get calcInputDurationYears;

  /// No description provided for @calcInputCreditCardAhli.
  ///
  /// In ar, this message translates to:
  /// **'مجموع حدود بطاقات الاهلي الائتمانية'**
  String get calcInputCreditCardAhli;

  /// No description provided for @calcInputCreditCardOther.
  ///
  /// In ar, this message translates to:
  /// **'مجموع حدود بطاقات البنوك الاخرى الائتمانية'**
  String get calcInputCreditCardOther;

  /// No description provided for @calcInputHasRealEstate.
  ///
  /// In ar, this message translates to:
  /// **'هل يوجد تمويل عقاري؟'**
  String get calcInputHasRealEstate;

  /// No description provided for @calcInputMilitaryRank.
  ///
  /// In ar, this message translates to:
  /// **'الرتبة العسكرية'**
  String get calcInputMilitaryRank;

  /// No description provided for @calcInputOtherBankDebt.
  ///
  /// In ar, this message translates to:
  /// **'المديونية في البنك الآخر (ريال)'**
  String get calcInputOtherBankDebt;

  /// No description provided for @calcInputCarPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر السيارة (ريال)'**
  String get calcInputCarPrice;

  /// No description provided for @calcInputDownPayment.
  ///
  /// In ar, this message translates to:
  /// **'الدفعة الأولى'**
  String get calcInputDownPayment;

  /// No description provided for @calcInputCustomerType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العميل'**
  String get calcInputCustomerType;

  /// No description provided for @calcInputSegment.
  ///
  /// In ar, this message translates to:
  /// **'الشريحة'**
  String get calcInputSegment;

  /// No description provided for @calcInputHasPersonalLoan.
  ///
  /// In ar, this message translates to:
  /// **'هل لديه تمويل شخصي؟'**
  String get calcInputHasPersonalLoan;

  /// No description provided for @calcInputPersonalLoanPayment.
  ///
  /// In ar, this message translates to:
  /// **'قسط التمويل الشخصي'**
  String get calcInputPersonalLoanPayment;

  /// No description provided for @calcInputHasOtherDeductions.
  ///
  /// In ar, this message translates to:
  /// **'هل لديه استقطاعات أخرى؟'**
  String get calcInputHasOtherDeductions;

  /// No description provided for @calcInputOtherDeductions.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الاستقطاعات الأخرى'**
  String get calcInputOtherDeductions;

  /// No description provided for @calcInputExistingObligations.
  ///
  /// In ar, this message translates to:
  /// **'الالتزامات الشهرية الحالية'**
  String get calcInputExistingObligations;

  /// No description provided for @calcInputPersonalFinanceObligation.
  ///
  /// In ar, this message translates to:
  /// **'التزامات التمويل الشخصي'**
  String get calcInputPersonalFinanceObligation;

  /// No description provided for @calcInputLeasingCreditObligation.
  ///
  /// In ar, this message translates to:
  /// **'تمويل تاجيري او بطاقات الائتمان'**
  String get calcInputLeasingCreditObligation;

  /// No description provided for @calcInputRealEstateObligation.
  ///
  /// In ar, this message translates to:
  /// **'تمويل عقاري'**
  String get calcInputRealEstateObligation;

  /// No description provided for @calcInputRealEstatePayment.
  ///
  /// In ar, this message translates to:
  /// **'قسط التمويل العقاري'**
  String get calcInputRealEstatePayment;

  /// No description provided for @calcInputRemainingInstallments.
  ///
  /// In ar, this message translates to:
  /// **'الأقساط المتبقية للتمويل الشخصي'**
  String get calcInputRemainingInstallments;

  /// No description provided for @calcInputBusinessType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المنشأة'**
  String get calcInputBusinessType;

  /// No description provided for @calcInputBusinessActivity.
  ///
  /// In ar, this message translates to:
  /// **'نشاط المنشأة'**
  String get calcInputBusinessActivity;

  /// No description provided for @calcInputAnnualSales.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات سنوية (ريال)'**
  String get calcInputAnnualSales;

  /// No description provided for @calcInputBusinessAge.
  ///
  /// In ar, this message translates to:
  /// **'عمر المنشأة'**
  String get calcInputBusinessAge;

  /// No description provided for @calcInputPosPeriod.
  ///
  /// In ar, this message translates to:
  /// **'فترة تشغيل نقاط البيع'**
  String get calcInputPosPeriod;

  /// No description provided for @calcInputMonthlyTransactions.
  ///
  /// In ar, this message translates to:
  /// **'عدد العمليات الشهرية'**
  String get calcInputMonthlyTransactions;

  /// No description provided for @calcInputLoanAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ التمويل (ريال)'**
  String get calcInputLoanAmount;

  /// No description provided for @calcInputLoanAmountOptional.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ التمويل - اختياري (ريال)'**
  String get calcInputLoanAmountOptional;

  /// No description provided for @calcHintSpecificAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ محدد'**
  String get calcHintSpecificAmount;

  /// No description provided for @calcInputDepositAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الإيداع (ريال)'**
  String get calcInputDepositAmount;

  /// No description provided for @calcInputPeriod.
  ///
  /// In ar, this message translates to:
  /// **'فترة الاستثمار'**
  String get calcInputPeriod;

  /// No description provided for @calcInputSubscriptionAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الاشتراك (ريال)'**
  String get calcInputSubscriptionAmount;

  /// No description provided for @calcInputReturnRate.
  ///
  /// In ar, this message translates to:
  /// **'هامش ربح العائد'**
  String get calcInputReturnRate;

  /// No description provided for @calcInputCoverageAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ التغطية (ريال)'**
  String get calcInputCoverageAmount;

  /// No description provided for @calcInputProgramDuration.
  ///
  /// In ar, this message translates to:
  /// **'مدة البرنامج (سنوات)'**
  String get calcInputProgramDuration;

  /// No description provided for @calcInputInvestmentStrategy.
  ///
  /// In ar, this message translates to:
  /// **'برنامج الاستثمار'**
  String get calcInputInvestmentStrategy;

  /// No description provided for @calcInputHousingSubsidy.
  ///
  /// In ar, this message translates to:
  /// **'الدعم السكني'**
  String get calcInputHousingSubsidy;

  /// No description provided for @calcInputHasEtezaz.
  ///
  /// In ar, this message translates to:
  /// **'اعتزاز'**
  String get calcInputHasEtezaz;

  /// No description provided for @calcInputOtherObligations.
  ///
  /// In ar, this message translates to:
  /// **'التزامات اخرى'**
  String get calcInputOtherObligations;

  /// No description provided for @calcInputRemainingLoanDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة المتبقية من القرض'**
  String get calcInputRemainingLoanDuration;

  /// No description provided for @calcInputSpecificREAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ تمويل عقاري محدد'**
  String get calcInputSpecificREAmount;

  /// No description provided for @calcInputREDurationMonths.
  ///
  /// In ar, this message translates to:
  /// **'مدة التمويل العقاري (بالأشهر)'**
  String get calcInputREDurationMonths;

  /// No description provided for @calcAutoFromRetirement.
  ///
  /// In ar, this message translates to:
  /// **'تلقائي (حسب سن التقاعد)'**
  String get calcAutoFromRetirement;

  /// No description provided for @calcInputRequestedAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ المطلوب (ريال)'**
  String get calcInputRequestedAmount;

  /// No description provided for @calcInputGregorianDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ الميلادي'**
  String get calcInputGregorianDate;

  /// No description provided for @calcInputHijriDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ الهجري'**
  String get calcInputHijriDate;

  /// No description provided for @calcResultTitle.
  ///
  /// In ar, this message translates to:
  /// **'نتائج الحساب'**
  String get calcResultTitle;

  /// No description provided for @calcResultEligible.
  ///
  /// In ar, this message translates to:
  /// **'مؤهل للتمويل'**
  String get calcResultEligible;

  /// No description provided for @calcResultNotEligible.
  ///
  /// In ar, this message translates to:
  /// **'غير مؤهل'**
  String get calcResultNotEligible;

  /// No description provided for @calcResultDeductionRatio.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الاستقطاع'**
  String get calcResultDeductionRatio;

  /// No description provided for @calcResultMonthlyInstallment.
  ///
  /// In ar, this message translates to:
  /// **'القسط الشهري'**
  String get calcResultMonthlyInstallment;

  /// No description provided for @calcResultTotalFinancing.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي التمويل'**
  String get calcResultTotalFinancing;

  /// No description provided for @calcResultApprovalAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الموافقة'**
  String get calcResultApprovalAmount;

  /// No description provided for @calcResultAdminFees.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الرسوم الادارية (0.5%)'**
  String get calcResultAdminFees;

  /// No description provided for @calcResultVat.
  ///
  /// In ar, this message translates to:
  /// **'الضريبة'**
  String get calcResultVat;

  /// No description provided for @calcResultTotalFees.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الرسوم'**
  String get calcResultTotalFees;

  /// No description provided for @calcResultNetAmount.
  ///
  /// In ar, this message translates to:
  /// **'صافي مبلغ التمويل بعد استقطاع الرسوم'**
  String get calcResultNetAmount;

  /// No description provided for @calcResultBankProfit.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الربح الخاص بالبنك'**
  String get calcResultBankProfit;

  /// No description provided for @calcResultNetAfterAll.
  ///
  /// In ar, this message translates to:
  /// **'صافي مبلغ التمويل بعد خصم كل الرسوم'**
  String get calcResultNetAfterAll;

  /// No description provided for @calcResultMaxAvailableMonths.
  ///
  /// In ar, this message translates to:
  /// **'أقصى مدة متاحة'**
  String get calcResultMaxAvailableMonths;

  /// No description provided for @calcResultDebtAtOtherBank.
  ///
  /// In ar, this message translates to:
  /// **'المديونية في البنك الآخر'**
  String get calcResultDebtAtOtherBank;

  /// No description provided for @calcResultNetAfterDebt.
  ///
  /// In ar, this message translates to:
  /// **'صافي مبلغ تمويل العميل بعد خصم مديونية البنك الآخر'**
  String get calcResultNetAfterDebt;

  /// No description provided for @calcResultAdminFeesIncludingTax.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم الإدارية شامل الضريبة'**
  String get calcResultAdminFeesIncludingTax;

  /// No description provided for @calcResultMaxREAmount.
  ///
  /// In ar, this message translates to:
  /// **'أقصى مبلغ عقاري'**
  String get calcResultMaxREAmount;

  /// No description provided for @calcResultMonthlyDuringPL.
  ///
  /// In ar, this message translates to:
  /// **'القسط الشهري ( 1 ) خلال مدة القسط الشخصي'**
  String get calcResultMonthlyDuringPL;

  /// No description provided for @calcResultMonthlyAfterPL.
  ///
  /// In ar, this message translates to:
  /// **'القسط الشهري ( 2 ) بعد انتهاء القسط الشخصي'**
  String get calcResultMonthlyAfterPL;

  /// No description provided for @calcResultLoanAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ التمويل'**
  String get calcResultLoanAmount;

  /// No description provided for @calcResultDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get calcResultDuration;

  /// No description provided for @calcResultProfitAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الربح'**
  String get calcResultProfitAmount;

  /// No description provided for @calcResultTotalWithProfit.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي مع الأرباح'**
  String get calcResultTotalWithProfit;

  /// No description provided for @calcResultAdminAppraisalFees.
  ///
  /// In ar, this message translates to:
  /// **'رسوم إدارية وتقييم'**
  String get calcResultAdminAppraisalFees;

  /// No description provided for @calcResultHousingSubsidy.
  ///
  /// In ar, this message translates to:
  /// **'الدعم السكني'**
  String get calcResultHousingSubsidy;

  /// No description provided for @calcResultGrandTotal.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي الكلي'**
  String get calcResultGrandTotal;

  /// No description provided for @calcResultFinanceDurationMonths.
  ///
  /// In ar, this message translates to:
  /// **'مدة التمويل ( بالأشهر )'**
  String get calcResultFinanceDurationMonths;

  /// No description provided for @calcResultAvailableDurationYears.
  ///
  /// In ar, this message translates to:
  /// **'المدة المتاحة للعميل'**
  String get calcResultAvailableDurationYears;

  /// No description provided for @calcYear.
  ///
  /// In ar, this message translates to:
  /// **'سنة'**
  String get calcYear;

  /// No description provided for @calcResultAdminAppraisalIncludingTax.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم الإدارية والتقييم شاملة الضريبة'**
  String get calcResultAdminAppraisalIncludingTax;

  /// No description provided for @calcResultBankProfitRE.
  ///
  /// In ar, this message translates to:
  /// **'ارباح البنك'**
  String get calcResultBankProfitRE;

  /// No description provided for @calcResultFinalAmountWithSupport.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ النهائي + ( الدعم السكني / اعتزاز ) ان وجد'**
  String get calcResultFinalAmountWithSupport;

  /// No description provided for @calcInputPersonalLoanIfAny.
  ///
  /// In ar, this message translates to:
  /// **'قسط التمويل الشخصي'**
  String get calcInputPersonalLoanIfAny;

  /// No description provided for @calcResultInsurance.
  ///
  /// In ar, this message translates to:
  /// **'التأمين'**
  String get calcResultInsurance;

  /// No description provided for @calcResultDownPayment.
  ///
  /// In ar, this message translates to:
  /// **'الدفعة الأولى'**
  String get calcResultDownPayment;

  /// No description provided for @calcResultLastPayment.
  ///
  /// In ar, this message translates to:
  /// **'الدفعة الأخيرة '**
  String get calcResultLastPayment;

  /// No description provided for @calcResultFinancedAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ التمويل'**
  String get calcResultFinancedAmount;

  /// No description provided for @calcResultAPR.
  ///
  /// In ar, this message translates to:
  /// **'معدل النسبة السنوية'**
  String get calcResultAPR;

  /// No description provided for @calcResultTotalPaid.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي المدفوع'**
  String get calcResultTotalPaid;

  /// No description provided for @calcResultActualRatio.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الاستقطاع الفعلية'**
  String get calcResultActualRatio;

  /// No description provided for @calcResultRequiredDP.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ الدفعة الأولى المطلوبة'**
  String get calcResultRequiredDP;

  /// No description provided for @calcResultDecision.
  ///
  /// In ar, this message translates to:
  /// **'القرار'**
  String get calcResultDecision;

  /// No description provided for @calcResultAvailableForCar.
  ///
  /// In ar, this message translates to:
  /// **'المتاح لتمويل السيارة'**
  String get calcResultAvailableForCar;

  /// No description provided for @calcResultEffectiveCarPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر السيارة الفعلي'**
  String get calcResultEffectiveCarPrice;

  /// No description provided for @calcResultTotalReturn.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العائد'**
  String get calcResultTotalReturn;

  /// No description provided for @calcResultProfit.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get calcResultProfit;

  /// No description provided for @calcResultMinDeposit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للإيداع'**
  String get calcResultMinDeposit;

  /// No description provided for @calcResultCashValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة النقدية'**
  String get calcResultCashValue;

  /// No description provided for @calcResultSurrenderValue.
  ///
  /// In ar, this message translates to:
  /// **'قيمة الاسترداد'**
  String get calcResultSurrenderValue;

  /// No description provided for @calcResultDeathBenefit.
  ///
  /// In ar, this message translates to:
  /// **'منفعة الوفاة'**
  String get calcResultDeathBenefit;

  /// No description provided for @calcResultCoverageAmount.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ التغطية'**
  String get calcResultCoverageAmount;

  /// No description provided for @calcResultReturnRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة العائد السنوي'**
  String get calcResultReturnRate;

  /// No description provided for @calcResultFinalBenefit.
  ///
  /// In ar, this message translates to:
  /// **'المنفعة آخر المدة'**
  String get calcResultFinalBenefit;

  /// No description provided for @calcResultYear.
  ///
  /// In ar, this message translates to:
  /// **'السنة'**
  String get calcResultYear;

  /// No description provided for @calcResultProjectionTable.
  ///
  /// In ar, this message translates to:
  /// **'الجدول السنوي'**
  String get calcResultProjectionTable;

  /// No description provided for @calcResultAgeYears.
  ///
  /// In ar, this message translates to:
  /// **'العمر (سنوات)'**
  String get calcResultAgeYears;

  /// No description provided for @calcResultAgeMonths.
  ///
  /// In ar, this message translates to:
  /// **'العمر (أشهر)'**
  String get calcResultAgeMonths;

  /// No description provided for @calcResultAgeDays.
  ///
  /// In ar, this message translates to:
  /// **'العمر (أيام)'**
  String get calcResultAgeDays;

  /// No description provided for @calcResultAmountAt33.
  ///
  /// In ar, this message translates to:
  /// **'تمويل شخصي (33.33%)'**
  String get calcResultAmountAt33;

  /// No description provided for @calcResultAmountAt45.
  ///
  /// In ar, this message translates to:
  /// **'تمويل تاجيري او بطاقات الائتمان (45%)'**
  String get calcResultAmountAt45;

  /// No description provided for @calcResultAmountAt55or65.
  ///
  /// In ar, this message translates to:
  /// **'تمويل عقاري (55%/65%)'**
  String get calcResultAmountAt55or65;

  /// No description provided for @calcResultRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي من الراتب'**
  String get calcResultRemaining;

  /// No description provided for @calcResultApplicable.
  ///
  /// In ar, this message translates to:
  /// **'هل ينطبق؟'**
  String get calcResultApplicable;

  /// No description provided for @calcResultHijriDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ الهجري'**
  String get calcResultHijriDate;

  /// No description provided for @calcResultGregorianDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ الميلادي'**
  String get calcResultGregorianDate;

  /// No description provided for @calcSalaryClient.
  ///
  /// In ar, this message translates to:
  /// **'عميل رواتب'**
  String get calcSalaryClient;

  /// No description provided for @calcNonSalaryClient.
  ///
  /// In ar, this message translates to:
  /// **'غير رواتب'**
  String get calcNonSalaryClient;

  /// No description provided for @calcYes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get calcYes;

  /// No description provided for @calcNo.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get calcNo;

  /// No description provided for @calcRealEstateNone.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد'**
  String get calcRealEstateNone;

  /// No description provided for @calcRealEstateHas.
  ///
  /// In ar, this message translates to:
  /// **'يوجد'**
  String get calcRealEstateHas;

  /// No description provided for @calcCalculate.
  ///
  /// In ar, this message translates to:
  /// **'احسب'**
  String get calcCalculate;

  /// No description provided for @calcReset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة ضبط'**
  String get calcReset;

  /// No description provided for @calcSar.
  ///
  /// In ar, this message translates to:
  /// **'ريال'**
  String get calcSar;

  /// No description provided for @calcMonth.
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get calcMonth;

  /// No description provided for @calcMonths.
  ///
  /// In ar, this message translates to:
  /// **'أشهر'**
  String get calcMonths;

  /// No description provided for @calcApproved.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get calcApproved;

  /// No description provided for @calcIncreaseDownPayment.
  ///
  /// In ar, this message translates to:
  /// **'ارفع الدفعة الأولى'**
  String get calcIncreaseDownPayment;

  /// No description provided for @calcAllConditionsMet.
  ///
  /// In ar, this message translates to:
  /// **'جميع الشروط مستوفاة'**
  String get calcAllConditionsMet;

  /// No description provided for @calcConvertToHijri.
  ///
  /// In ar, this message translates to:
  /// **'تحويل إلى هجري'**
  String get calcConvertToHijri;

  /// No description provided for @calcConvertToGregorian.
  ///
  /// In ar, this message translates to:
  /// **'تحويل إلى ميلادي'**
  String get calcConvertToGregorian;

  /// No description provided for @aiSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الذكاء الاصطناعي'**
  String get aiSettings;

  /// No description provided for @aiSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إدارة مفتاح Claude AI للمساعد الذكي.'**
  String get aiSettingsSubtitle;

  /// No description provided for @aiApiKeyLabel.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح Claude API'**
  String get aiApiKeyLabel;

  /// No description provided for @aiApiKeyHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل مفتاح Claude API (sk-ant-...)'**
  String get aiApiKeyHint;

  /// No description provided for @aiApiKeyNotConfigured.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تهيئة مفتاح API بعد.'**
  String get aiApiKeyNotConfigured;

  /// No description provided for @aiApiKeySaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ مفتاح API بنجاح.'**
  String get aiApiKeySaved;

  /// No description provided for @aiApiKeyDeleted.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف مفتاح API بنجاح.'**
  String get aiApiKeyDeleted;

  /// No description provided for @aiApiKeyDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف مفتاح API'**
  String get aiApiKeyDeleteConfirmTitle;

  /// No description provided for @aiApiKeyDeleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف مفتاح API؟ ستتوقف ميزة الدردشة الذكية عن العمل.'**
  String get aiApiKeyDeleteConfirmMessage;

  /// No description provided for @aiApiKeyInvalid.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يبدأ مفتاح API بـ sk-ant-'**
  String get aiApiKeyInvalid;

  /// No description provided for @aiApiKeyRequired.
  ///
  /// In ar, this message translates to:
  /// **'مفتاح API مطلوب'**
  String get aiApiKeyRequired;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get update;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
