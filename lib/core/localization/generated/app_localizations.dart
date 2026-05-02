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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Nesab'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Smart Financing Solutions'**
  String get appDescription;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginWithApple;

  /// No description provided for @browseAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Browse as Guest'**
  String get browseAsGuest;

  /// No description provided for @termsText.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the Terms of Use and Privacy Policy'**
  String get termsText;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orText;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Financing Solutions'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover our diverse financing products with the best terms'**
  String get homeHeroSubtitle;

  /// No description provided for @homeHeroCta.
  ///
  /// In en, this message translates to:
  /// **'Browse Products'**
  String get homeHeroCta;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Services'**
  String get quickActionsTitle;

  /// No description provided for @quickActionProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get quickActionProducts;

  /// No description provided for @quickActionRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get quickActionRequests;

  /// No description provided for @quickActionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get quickActionContact;

  /// No description provided for @featuredProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Featured Products'**
  String get featuredProductsTitle;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @productsTitle.
  ///
  /// In en, this message translates to:
  /// **'Financing Products'**
  String get productsTitle;

  /// No description provided for @productsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the financing product that suits your needs'**
  String get productsSubtitle;

  /// No description provided for @productDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetailsTitle;

  /// No description provided for @subProductDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sub-Product Details'**
  String get subProductDetailsTitle;

  /// No description provided for @availableOptions.
  ///
  /// In en, this message translates to:
  /// **'Available Options'**
  String get availableOptions;

  /// No description provided for @applyForFinancing.
  ///
  /// In en, this message translates to:
  /// **'Apply for Financing'**
  String get applyForFinancing;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Financing Amount'**
  String get amount;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Repayment Period'**
  String get period;

  /// No description provided for @profitRate.
  ///
  /// In en, this message translates to:
  /// **'Profit Rate'**
  String get profitRate;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get productDescription;

  /// No description provided for @featureSharia.
  ///
  /// In en, this message translates to:
  /// **'Sharia compliant'**
  String get featureSharia;

  /// No description provided for @featureFastProcess.
  ///
  /// In en, this message translates to:
  /// **'Fast and easy procedures'**
  String get featureFastProcess;

  /// No description provided for @featureFlexiblePayments.
  ///
  /// In en, this message translates to:
  /// **'Flexible installments'**
  String get featureFlexiblePayments;

  /// No description provided for @featureCustomerService.
  ///
  /// In en, this message translates to:
  /// **'Excellent customer service'**
  String get featureCustomerService;

  /// No description provided for @applyTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply for Financing'**
  String get applyTitle;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get step1Title;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Employment Information'**
  String get step2Title;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get step3Title;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get step4Title;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @nationalIdHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your national ID number'**
  String get nationalIdHint;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @dateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'DD / MM / YYYY'**
  String get dateOfBirthHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'05XXXXXXXX'**
  String get phoneNumberHint;

  /// No description provided for @employer.
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get employer;

  /// No description provided for @employerHint.
  ///
  /// In en, this message translates to:
  /// **'Employer name'**
  String get employerHint;

  /// No description provided for @monthlySalary.
  ///
  /// In en, this message translates to:
  /// **'Monthly Salary'**
  String get monthlySalary;

  /// No description provided for @monthlySalaryHint.
  ///
  /// In en, this message translates to:
  /// **'Salary amount'**
  String get monthlySalaryHint;

  /// No description provided for @yearsOfService.
  ///
  /// In en, this message translates to:
  /// **'Years of Service'**
  String get yearsOfService;

  /// No description provided for @yearsOfServiceHint.
  ///
  /// In en, this message translates to:
  /// **'Number of years of service'**
  String get yearsOfServiceHint;

  /// No description provided for @employmentSector.
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get employmentSector;

  /// No description provided for @government.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government;

  /// No description provided for @privateSector.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateSector;

  /// No description provided for @military.
  ///
  /// In en, this message translates to:
  /// **'Military'**
  String get military;

  /// No description provided for @uploadId.
  ///
  /// In en, this message translates to:
  /// **'National ID Photo'**
  String get uploadId;

  /// No description provided for @uploadSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary Certificate'**
  String get uploadSalary;

  /// No description provided for @uploadBankStatement.
  ///
  /// In en, this message translates to:
  /// **'Bank Statement'**
  String get uploadBankStatement;

  /// No description provided for @uploadHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload or drag the file'**
  String get uploadHint;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submit;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @applicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Application submitted successfully'**
  String get applicationSubmitted;

  /// No description provided for @confirmationSummary.
  ///
  /// In en, this message translates to:
  /// **'Review Application'**
  String get confirmationSummary;

  /// No description provided for @confirmationHint.
  ///
  /// In en, this message translates to:
  /// **'Please verify all information before submitting'**
  String get confirmationHint;

  /// No description provided for @confirmationProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get confirmationProduct;

  /// No description provided for @confirmationFinancingType.
  ///
  /// In en, this message translates to:
  /// **'Financing Type'**
  String get confirmationFinancingType;

  /// No description provided for @confirmationMaxAmount.
  ///
  /// In en, this message translates to:
  /// **'Maximum Amount'**
  String get confirmationMaxAmount;

  /// No description provided for @confirmationPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get confirmationPeriod;

  /// No description provided for @myRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequestsTitle;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests at this time'**
  String get noRequests;

  /// No description provided for @requestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get requestStatus;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get profileTitle;

  /// No description provided for @myRequests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get myRequests;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get editDetails;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutApp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @guestAccount.
  ///
  /// In en, this message translates to:
  /// **'Guest account'**
  String get guestAccount;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Nesab'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Nesab is a comprehensive platform for displaying financing products in an organized and easy way, allowing users to browse and compare diverse financing solutions and choose the most suitable for their needs.'**
  String get aboutDescription;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutIdeaTitle.
  ///
  /// In en, this message translates to:
  /// **'App Concept'**
  String get aboutIdeaTitle;

  /// No description provided for @ourServices.
  ///
  /// In en, this message translates to:
  /// **'Our Services'**
  String get ourServices;

  /// No description provided for @ourAdvantages.
  ///
  /// In en, this message translates to:
  /// **'Advantages'**
  String get ourAdvantages;

  /// No description provided for @advantageSecurity.
  ///
  /// In en, this message translates to:
  /// **'High security and privacy'**
  String get advantageSecurity;

  /// No description provided for @advantageSpeed.
  ///
  /// In en, this message translates to:
  /// **'Fast procedures'**
  String get advantageSpeed;

  /// No description provided for @advantageUx.
  ///
  /// In en, this message translates to:
  /// **'Smooth user experience'**
  String get advantageUx;

  /// No description provided for @advantageSharia.
  ///
  /// In en, this message translates to:
  /// **'Sharia compliant'**
  String get advantageSharia;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactTitle;

  /// No description provided for @contactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred contact method'**
  String get contactSubtitle;

  /// No description provided for @contactHeader.
  ///
  /// In en, this message translates to:
  /// **'We are happy to hear from you'**
  String get contactHeader;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter / X'**
  String get twitter;

  /// No description provided for @linkedin.
  ///
  /// In en, this message translates to:
  /// **'LinkedIn'**
  String get linkedin;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @developerTitle.
  ///
  /// In en, this message translates to:
  /// **'About the Developer'**
  String get developerTitle;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Mobile App Developer'**
  String get developedBy;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About Nesab'**
  String get navAbout;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get navProfile;

  /// No description provided for @appLogo.
  ///
  /// In en, this message translates to:
  /// **'ن'**
  String get appLogo;

  /// No description provided for @servicePersonalFinancing.
  ///
  /// In en, this message translates to:
  /// **'Personal Financing'**
  String get servicePersonalFinancing;

  /// No description provided for @serviceRealEstateFinancing.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Financing'**
  String get serviceRealEstateFinancing;

  /// No description provided for @serviceLeaseFinancing.
  ///
  /// In en, this message translates to:
  /// **'Lease Financing'**
  String get serviceLeaseFinancing;

  /// No description provided for @servicePosFinancing.
  ///
  /// In en, this message translates to:
  /// **'POS Financing'**
  String get servicePosFinancing;

  /// No description provided for @serviceKhairat.
  ///
  /// In en, this message translates to:
  /// **'Khairat Program'**
  String get serviceKhairat;

  /// No description provided for @devInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Development Info'**
  String get devInfoTitle;

  /// No description provided for @devPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get devPlatform;

  /// No description provided for @devVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get devVersion;

  /// No description provided for @devArchitecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture'**
  String get devArchitecture;

  /// No description provided for @documentsAttachedCount.
  ///
  /// In en, this message translates to:
  /// **'Documents attached'**
  String get documentsAttachedCount;

  /// No description provided for @invalidProductId.
  ///
  /// In en, this message translates to:
  /// **'Invalid product ID'**
  String get invalidProductId;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @subProductNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sub-product not found'**
  String get subProductNotFound;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to continue'**
  String get registerSubtitle;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a reset link'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent successfully'**
  String get resetLinkSent;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get displayNameLabel;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get displayNameHint;

  /// No description provided for @authProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Auth Provider'**
  String get authProviderLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @createdAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAtLabel;

  /// No description provided for @lastLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Login'**
  String get lastLoginLabel;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'or sign in with'**
  String get orLoginWith;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @termsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to the'**
  String get termsPrefix;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @termsAnd.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get termsAnd;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeMode;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeModeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @onboardingBadge.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Nesab'**
  String get onboardingBadge;

  /// No description provided for @onboardingTitle1Line1.
  ///
  /// In en, this message translates to:
  /// **'Your First Gateway'**
  String get onboardingTitle1Line1;

  /// No description provided for @onboardingTitle1Line2.
  ///
  /// In en, this message translates to:
  /// **'to Financing Solutions'**
  String get onboardingTitle1Line2;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Browse and compare the best personal and real estate financing products in the Kingdom with full transparency and reliability.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingTitle2Line1.
  ///
  /// In en, this message translates to:
  /// **'Diverse Options,'**
  String get onboardingTitle2Line1;

  /// No description provided for @onboardingTitle2Line2.
  ///
  /// In en, this message translates to:
  /// **'One Smart Decision'**
  String get onboardingTitle2Line2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'From personal loans to home financing and POS. We gather all options so you can choose what suits your needs.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Financing'**
  String get onboardingRealEstate;

  /// No description provided for @onboardingRealEstateDesc.
  ///
  /// In en, this message translates to:
  /// **'Ownership and investment options'**
  String get onboardingRealEstateDesc;

  /// No description provided for @onboardingPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal Financing'**
  String get onboardingPersonal;

  /// No description provided for @onboardingPersonalDesc.
  ///
  /// In en, this message translates to:
  /// **'Instant cash liquidity'**
  String get onboardingPersonalDesc;

  /// No description provided for @onboardingPos.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get onboardingPos;

  /// No description provided for @onboardingPosDesc.
  ///
  /// In en, this message translates to:
  /// **'Solutions for shops and businesses'**
  String get onboardingPosDesc;

  /// No description provided for @onboardingLease.
  ///
  /// In en, this message translates to:
  /// **'Lease Financing'**
  String get onboardingLease;

  /// No description provided for @onboardingLeaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Lease-to-own options'**
  String get onboardingLeaseDesc;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Nesab'**
  String get paywallTitle;

  /// No description provided for @paywallTitleAccent.
  ///
  /// In en, this message translates to:
  /// **'Plus +'**
  String get paywallTitleAccent;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exclusive upgrade for better financing opportunities'**
  String get paywallSubtitle;

  /// No description provided for @paywallBenefit1Title.
  ///
  /// In en, this message translates to:
  /// **'Priority Processing'**
  String get paywallBenefit1Title;

  /// No description provided for @paywallBenefit1Desc.
  ///
  /// In en, this message translates to:
  /// **'Your application is submitted and processed immediately before others.'**
  String get paywallBenefit1Desc;

  /// No description provided for @paywallBenefit2Title.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Profit Rates'**
  String get paywallBenefit2Title;

  /// No description provided for @paywallBenefit2Desc.
  ///
  /// In en, this message translates to:
  /// **'Special offers and lower profit margins exclusively for members.'**
  String get paywallBenefit2Desc;

  /// No description provided for @paywallBenefit3Title.
  ///
  /// In en, this message translates to:
  /// **'Personal Financial Advisor'**
  String get paywallBenefit3Title;

  /// No description provided for @paywallBenefit3Desc.
  ///
  /// In en, this message translates to:
  /// **'Direct communication with a financial expert to help you make decisions.'**
  String get paywallBenefit3Desc;

  /// No description provided for @paywallSocialProof.
  ///
  /// In en, this message translates to:
  /// **'Join 1500+ distinguished beneficiaries'**
  String get paywallSocialProof;

  /// No description provided for @paywallOffer.
  ///
  /// In en, this message translates to:
  /// **'Limited offer: 50% off for first time'**
  String get paywallOffer;

  /// No description provided for @paywallCta.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for 99 SAR / yearly'**
  String get paywallCta;

  /// No description provided for @paywallOldPrice.
  ///
  /// In en, this message translates to:
  /// **'Was 199 SAR'**
  String get paywallOldPrice;

  /// No description provided for @paywallCancel.
  ///
  /// In en, this message translates to:
  /// **'You can cancel anytime from account settings'**
  String get paywallCancel;

  /// No description provided for @continueWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign up with Email'**
  String get continueWithEmail;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validationNameRequired;

  /// No description provided for @validationNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get validationNameTooShort;

  /// No description provided for @validationFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationFieldRequired;

  /// No description provided for @homeSelectService.
  ///
  /// In en, this message translates to:
  /// **'Select a service to continue'**
  String get homeSelectService;

  /// No description provided for @servicePersonalFinancingDesc.
  ///
  /// In en, this message translates to:
  /// **'Personal financing solutions'**
  String get servicePersonalFinancingDesc;

  /// No description provided for @serviceRealEstateFinancingDesc.
  ///
  /// In en, this message translates to:
  /// **'Affordable home financing'**
  String get serviceRealEstateFinancingDesc;

  /// No description provided for @serviceLeaseFinancingDesc.
  ///
  /// In en, this message translates to:
  /// **'Lease-to-own financing'**
  String get serviceLeaseFinancingDesc;

  /// No description provided for @servicePosFinancingDesc.
  ///
  /// In en, this message translates to:
  /// **'POS terminal solutions'**
  String get servicePosFinancingDesc;

  /// No description provided for @serviceKhairatDesc.
  ///
  /// In en, this message translates to:
  /// **'Donations & giving'**
  String get serviceKhairatDesc;

  /// No description provided for @serviceTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get serviceTools;

  /// No description provided for @serviceToolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Settings & preferences'**
  String get serviceToolsDesc;

  /// No description provided for @categoryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Category not found'**
  String get categoryNotFound;

  /// No description provided for @subPersonalFinanceQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick Personal Finance'**
  String get subPersonalFinanceQuick;

  /// No description provided for @subPersonalFinanceQuickDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast financing with simplified procedures'**
  String get subPersonalFinanceQuickDesc;

  /// No description provided for @subPersonalFinancePlus.
  ///
  /// In en, this message translates to:
  /// **'Personal Finance Plus'**
  String get subPersonalFinancePlus;

  /// No description provided for @subPersonalFinancePlusDesc.
  ///
  /// In en, this message translates to:
  /// **'Financing with extra benefits and higher limits'**
  String get subPersonalFinancePlusDesc;

  /// No description provided for @subDebtPurchase.
  ///
  /// In en, this message translates to:
  /// **'Debt Purchase Financing'**
  String get subDebtPurchase;

  /// No description provided for @subDebtPurchaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Transfer your debt from another provider with better terms'**
  String get subDebtPurchaseDesc;

  /// No description provided for @subRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Financing'**
  String get subRealEstate;

  /// No description provided for @subRealEstateDesc.
  ///
  /// In en, this message translates to:
  /// **'Financing for residential or investment property'**
  String get subRealEstateDesc;

  /// No description provided for @subRealEstatePlus.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Plus'**
  String get subRealEstatePlus;

  /// No description provided for @subRealEstatePlusDesc.
  ///
  /// In en, this message translates to:
  /// **'Premium real estate financing with exclusive benefits'**
  String get subRealEstatePlusDesc;

  /// No description provided for @subLeasing.
  ///
  /// In en, this message translates to:
  /// **'Lease Financing'**
  String get subLeasing;

  /// No description provided for @subLeasingDesc.
  ///
  /// In en, this message translates to:
  /// **'Lease-to-own financing arrangement'**
  String get subLeasingDesc;

  /// No description provided for @subLeasingPlus.
  ///
  /// In en, this message translates to:
  /// **'Lease Financing Plus'**
  String get subLeasingPlus;

  /// No description provided for @subLeasingPlusDesc.
  ///
  /// In en, this message translates to:
  /// **'Lease financing with extra benefits and flexible terms'**
  String get subLeasingPlusDesc;

  /// No description provided for @subPos.
  ///
  /// In en, this message translates to:
  /// **'POS Financing'**
  String get subPos;

  /// No description provided for @subPosDesc.
  ///
  /// In en, this message translates to:
  /// **'Financing to grow your business through POS terminals'**
  String get subPosDesc;

  /// No description provided for @subCharity.
  ///
  /// In en, this message translates to:
  /// **'Khairat Account'**
  String get subCharity;

  /// No description provided for @subCharityDesc.
  ///
  /// In en, this message translates to:
  /// **'Savings account with competitive returns, Sharia-compliant'**
  String get subCharityDesc;

  /// No description provided for @subToolsDateConvert.
  ///
  /// In en, this message translates to:
  /// **'Date Converter'**
  String get subToolsDateConvert;

  /// No description provided for @subToolsDateConvertDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between Hijri and Gregorian dates'**
  String get subToolsDateConvertDesc;

  /// No description provided for @subToolsAgeCalc.
  ///
  /// In en, this message translates to:
  /// **'Age Calculator'**
  String get subToolsAgeCalc;

  /// No description provided for @subToolsAgeCalcDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate age in Hijri and Gregorian'**
  String get subToolsAgeCalcDesc;

  /// No description provided for @subToolsDeductions.
  ///
  /// In en, this message translates to:
  /// **'Deductions Calculator'**
  String get subToolsDeductions;

  /// No description provided for @subToolsDeductionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate net salary after deductions'**
  String get subToolsDeductionsDesc;

  /// No description provided for @adminLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminLoginTitle;

  /// No description provided for @adminLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage the dashboard'**
  String get adminLoginSubtitle;

  /// No description provided for @usersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTitle;

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get toolsTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageOf(int current, int total);

  /// No description provided for @rowsPerPage.
  ///
  /// In en, this message translates to:
  /// **'Rows per page'**
  String get rowsPerPage;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @managersTitle.
  ///
  /// In en, this message translates to:
  /// **'Managers'**
  String get managersTitle;

  /// No description provided for @managersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage dashboard managers.'**
  String get managersSubtitle;

  /// No description provided for @managersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No managers yet. Click \"Add manager\" to create one.'**
  String get managersEmpty;

  /// No description provided for @addManagerButton.
  ///
  /// In en, this message translates to:
  /// **'Add manager'**
  String get addManagerButton;

  /// No description provided for @createAdminsTitle.
  ///
  /// In en, this message translates to:
  /// **'Create manager'**
  String get createAdminsTitle;

  /// No description provided for @createAdminsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add new manager with email, password, and role.'**
  String get createAdminsSubtitle;

  /// No description provided for @createAdminButton.
  ///
  /// In en, this message translates to:
  /// **'Create manager'**
  String get createAdminButton;

  /// No description provided for @createAdminSuccess.
  ///
  /// In en, this message translates to:
  /// **'Manager created successfully.'**
  String get createAdminSuccess;

  /// No description provided for @deleteManagerButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteManagerButton;

  /// No description provided for @deleteManagerConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete manager'**
  String get deleteManagerConfirmTitle;

  /// No description provided for @deleteManagerConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This will remove their access.'**
  String deleteManagerConfirmMessage(String name);

  /// No description provided for @deleteManagerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Manager deleted successfully.'**
  String get deleteManagerSuccess;

  /// No description provided for @deleteManagerError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete manager.'**
  String get deleteManagerError;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get roleUser;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoriesTitle;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage categories and subcategories.'**
  String get categoriesSubtitle;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @addSubCategory.
  ///
  /// In en, this message translates to:
  /// **'Add sub category'**
  String get addSubCategory;

  /// No description provided for @categoryArabicName.
  ///
  /// In en, this message translates to:
  /// **'Arabic name'**
  String get categoryArabicName;

  /// No description provided for @categoryEnglishName.
  ///
  /// In en, this message translates to:
  /// **'English name'**
  String get categoryEnglishName;

  /// No description provided for @categoryImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get categoryImage;

  /// No description provided for @pickImage.
  ///
  /// In en, this message translates to:
  /// **'Pick from device'**
  String get pickImage;

  /// No description provided for @categoryImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Image is required'**
  String get categoryImageRequired;

  /// No description provided for @categorySaved.
  ///
  /// In en, this message translates to:
  /// **'Category saved'**
  String get categorySaved;

  /// No description provided for @categoryTitleSize.
  ///
  /// In en, this message translates to:
  /// **'Title size'**
  String get categoryTitleSize;

  /// No description provided for @categoryImageWidth.
  ///
  /// In en, this message translates to:
  /// **'Image width (0–1)'**
  String get categoryImageWidth;

  /// No description provided for @categoryImageHeight.
  ///
  /// In en, this message translates to:
  /// **'Image height (0–1)'**
  String get categoryImageHeight;

  /// No description provided for @categoryOpacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity (0–1)'**
  String get categoryOpacity;

  /// No description provided for @categoryCalculatorType.
  ///
  /// In en, this message translates to:
  /// **'Calculator / Tool'**
  String get categoryCalculatorType;

  /// No description provided for @categoryCalculatorTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select calculator or tool'**
  String get categoryCalculatorTypeHint;

  /// No description provided for @extractionFailureLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Extraction Failure Logs'**
  String get extractionFailureLogsTitle;

  /// No description provided for @extractionFailureLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Product pages where add-to-cart could not be shown.'**
  String get extractionFailureLogsSubtitle;

  /// No description provided for @extractionFailureLogsUrl.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get extractionFailureLogsUrl;

  /// No description provided for @extractionFailureLogsMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get extractionFailureLogsMarketplace;

  /// No description provided for @extractionFailureLogsTitleFound.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get extractionFailureLogsTitleFound;

  /// No description provided for @extractionFailureLogsPriceFound.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get extractionFailureLogsPriceFound;

  /// No description provided for @extractionFailureLogsColorFound.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get extractionFailureLogsColorFound;

  /// No description provided for @extractionFailureLogsSizeFound.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get extractionFailureLogsSizeFound;

  /// No description provided for @extractionFailureLogsCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get extractionFailureLogsCreatedAt;

  /// No description provided for @extractionFailureLogsYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get extractionFailureLogsYes;

  /// No description provided for @extractionFailureLogsNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get extractionFailureLogsNo;

  /// No description provided for @calculatorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance Calculators'**
  String get calculatorsTitle;

  /// No description provided for @calculatorsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate financing options and eligibility'**
  String get calculatorsSubtitle;

  /// No description provided for @calcPersonalFinance.
  ///
  /// In en, this message translates to:
  /// **'Personal Finance (PLAS)'**
  String get calcPersonalFinance;

  /// No description provided for @calcPersonalFinanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate personal financing with full details'**
  String get calcPersonalFinanceDesc;

  /// No description provided for @calcPersonalFinanceQuick.
  ///
  /// In en, this message translates to:
  /// **'Quick Personal Finance'**
  String get calcPersonalFinanceQuick;

  /// No description provided for @calcPersonalFinanceQuickDesc.
  ///
  /// In en, this message translates to:
  /// **'Simplified personal financing calculator'**
  String get calcPersonalFinanceQuickDesc;

  /// No description provided for @calcDebtPurchase.
  ///
  /// In en, this message translates to:
  /// **'Debt Purchase'**
  String get calcDebtPurchase;

  /// No description provided for @calcDebtPurchaseDesc.
  ///
  /// In en, this message translates to:
  /// **'Transfer debt from another bank'**
  String get calcDebtPurchaseDesc;

  /// No description provided for @calcRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Real Estate'**
  String get calcRealEstate;

  /// No description provided for @calcRealEstateDesc.
  ///
  /// In en, this message translates to:
  /// **'Real estate financing with auto-calculated duration'**
  String get calcRealEstateDesc;

  /// No description provided for @calcRealEstatePlus.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Plus (2-in-1)'**
  String get calcRealEstatePlus;

  /// No description provided for @calcRealEstatePlusDesc.
  ///
  /// In en, this message translates to:
  /// **'Real estate financing with personal loan'**
  String get calcRealEstatePlusDesc;

  /// No description provided for @calcLeasingRegular.
  ///
  /// In en, this message translates to:
  /// **'Leasing (Tajiri)'**
  String get calcLeasingRegular;

  /// No description provided for @calcLeasingRegularDesc.
  ///
  /// In en, this message translates to:
  /// **'Vehicle leasing calculator'**
  String get calcLeasingRegularDesc;

  /// No description provided for @calcLeasingMicro.
  ///
  /// In en, this message translates to:
  /// **'Leasing Micro'**
  String get calcLeasingMicro;

  /// No description provided for @calcLeasingMicroDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto-calculate max affordable vehicle'**
  String get calcLeasingMicroDesc;

  /// No description provided for @calcLeasingAutoCalcMaxCar.
  ///
  /// In en, this message translates to:
  /// **'Auto-calculate max vehicle price for client'**
  String get calcLeasingAutoCalcMaxCar;

  /// No description provided for @calcLeasingCarPriceZeroHint.
  ///
  /// In en, this message translates to:
  /// **'Put zero in the car price field'**
  String get calcLeasingCarPriceZeroHint;

  /// No description provided for @calcResultCostOfTerm.
  ///
  /// In en, this message translates to:
  /// **'Cost of term'**
  String get calcResultCostOfTerm;

  /// No description provided for @calcLeasingAsPercent.
  ///
  /// In en, this message translates to:
  /// **'Percentage of vehicle value'**
  String get calcLeasingAsPercent;

  /// No description provided for @calcLeasingAsAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount (SAR)'**
  String get calcLeasingAsAmount;

  /// No description provided for @calcInputAdminFees.
  ///
  /// In en, this message translates to:
  /// **'Administrative fees (SAR)'**
  String get calcInputAdminFees;

  /// No description provided for @calcInputLicensePlateFees.
  ///
  /// In en, this message translates to:
  /// **'License plate fees (SAR)'**
  String get calcInputLicensePlateFees;

  /// No description provided for @calcResultLicensePlateFees.
  ///
  /// In en, this message translates to:
  /// **'License plate fees'**
  String get calcResultLicensePlateFees;

  /// No description provided for @calcPosFinancing.
  ///
  /// In en, this message translates to:
  /// **'POS Financing'**
  String get calcPosFinancing;

  /// No description provided for @calcPosFinancingDesc.
  ///
  /// In en, this message translates to:
  /// **'Business POS financing calculator'**
  String get calcPosFinancingDesc;

  /// No description provided for @calcKhairat.
  ///
  /// In en, this message translates to:
  /// **'Khairat Savings'**
  String get calcKhairat;

  /// No description provided for @calcKhairatDesc.
  ///
  /// In en, this message translates to:
  /// **'Savings account profit calculator'**
  String get calcKhairatDesc;

  /// No description provided for @calcProtectionSavings.
  ///
  /// In en, this message translates to:
  /// **'Protection & Savings'**
  String get calcProtectionSavings;

  /// No description provided for @calcProtectionSavingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Insurance and investment projection'**
  String get calcProtectionSavingsDesc;

  /// No description provided for @calcAgeCalculator.
  ///
  /// In en, this message translates to:
  /// **'Age Calculator'**
  String get calcAgeCalculator;

  /// No description provided for @calcAgeCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate age from date of birth'**
  String get calcAgeCalculatorDesc;

  /// No description provided for @calcDateConverter.
  ///
  /// In en, this message translates to:
  /// **'Date Converter'**
  String get calcDateConverter;

  /// No description provided for @calcDateConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert Hijri to Gregorian and vice versa'**
  String get calcDateConverterDesc;

  /// No description provided for @calcDeductions.
  ///
  /// In en, this message translates to:
  /// **'Deductions Calculator'**
  String get calcDeductions;

  /// No description provided for @calcDeductionsDesc.
  ///
  /// In en, this message translates to:
  /// **'View salary deduction breakdown'**
  String get calcDeductionsDesc;

  /// No description provided for @calcBankFees.
  ///
  /// In en, this message translates to:
  /// **'Bank Fees'**
  String get calcBankFees;

  /// No description provided for @calcBankFeesDesc.
  ///
  /// In en, this message translates to:
  /// **'SAMA banking fee comparison and guide'**
  String get calcBankFeesDesc;

  /// No description provided for @calcInputSalary.
  ///
  /// In en, this message translates to:
  /// **'Monthly Salary (SAR)'**
  String get calcInputSalary;

  /// No description provided for @calcInputEmploymentType.
  ///
  /// In en, this message translates to:
  /// **'Employment Type'**
  String get calcInputEmploymentType;

  /// No description provided for @calcInputSector.
  ///
  /// In en, this message translates to:
  /// **'Employment Sector'**
  String get calcInputSector;

  /// No description provided for @calcInputDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get calcInputDateOfBirth;

  /// No description provided for @calcInputProfitRate.
  ///
  /// In en, this message translates to:
  /// **'Profit Rate'**
  String get calcInputProfitRate;

  /// No description provided for @calcInputDuration.
  ///
  /// In en, this message translates to:
  /// **'Finance Duration'**
  String get calcInputDuration;

  /// No description provided for @calcInputDurationYears.
  ///
  /// In en, this message translates to:
  /// **'Duration (Years)'**
  String get calcInputDurationYears;

  /// No description provided for @calcInputCreditCardAhli.
  ///
  /// In en, this message translates to:
  /// **'Total Credit Card Limits'**
  String get calcInputCreditCardAhli;

  /// No description provided for @calcInputCreditCardOther.
  ///
  /// In en, this message translates to:
  /// **'Total Other Bank Credit Card Limits'**
  String get calcInputCreditCardOther;

  /// No description provided for @calcInputHasRealEstate.
  ///
  /// In en, this message translates to:
  /// **'Has Real Estate Loan?'**
  String get calcInputHasRealEstate;

  /// No description provided for @calcInputMilitaryRank.
  ///
  /// In en, this message translates to:
  /// **'Military Rank'**
  String get calcInputMilitaryRank;

  /// No description provided for @calcInputOtherBankDebt.
  ///
  /// In en, this message translates to:
  /// **'Debt at Other Bank (SAR)'**
  String get calcInputOtherBankDebt;

  /// No description provided for @calcInputCarPrice.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Price (SAR)'**
  String get calcInputCarPrice;

  /// No description provided for @calcInputDownPayment.
  ///
  /// In en, this message translates to:
  /// **'Down Payment'**
  String get calcInputDownPayment;

  /// No description provided for @calcInputCustomerType.
  ///
  /// In en, this message translates to:
  /// **'Customer Type'**
  String get calcInputCustomerType;

  /// No description provided for @calcInputSegment.
  ///
  /// In en, this message translates to:
  /// **'Segment'**
  String get calcInputSegment;

  /// No description provided for @calcInputHasPersonalLoan.
  ///
  /// In en, this message translates to:
  /// **'Has Personal Loan?'**
  String get calcInputHasPersonalLoan;

  /// No description provided for @calcInputPersonalLoanPayment.
  ///
  /// In en, this message translates to:
  /// **'Personal Loan Monthly Payment'**
  String get calcInputPersonalLoanPayment;

  /// No description provided for @calcInputHasOtherDeductions.
  ///
  /// In en, this message translates to:
  /// **'Has Other Deductions?'**
  String get calcInputHasOtherDeductions;

  /// No description provided for @calcInputOtherDeductions.
  ///
  /// In en, this message translates to:
  /// **'Other Deductions Amount'**
  String get calcInputOtherDeductions;

  /// No description provided for @calcInputExistingObligations.
  ///
  /// In en, this message translates to:
  /// **'Current Monthly Obligations'**
  String get calcInputExistingObligations;

  /// No description provided for @calcInputPersonalFinanceObligation.
  ///
  /// In en, this message translates to:
  /// **'Personal Finance Obligations'**
  String get calcInputPersonalFinanceObligation;

  /// No description provided for @calcInputLeasingCreditObligation.
  ///
  /// In en, this message translates to:
  /// **'Leasing / Credit Card Obligations'**
  String get calcInputLeasingCreditObligation;

  /// No description provided for @calcInputRealEstateObligation.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Financing'**
  String get calcInputRealEstateObligation;

  /// No description provided for @calcInputRealEstatePayment.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Loan Payment'**
  String get calcInputRealEstatePayment;

  /// No description provided for @calcInputRemainingInstallments.
  ///
  /// In en, this message translates to:
  /// **'Remaining Personal Loan Installments'**
  String get calcInputRemainingInstallments;

  /// No description provided for @calcInputBusinessType.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get calcInputBusinessType;

  /// No description provided for @calcInputBusinessActivity.
  ///
  /// In en, this message translates to:
  /// **'Business Activity'**
  String get calcInputBusinessActivity;

  /// No description provided for @calcInputAnnualSales.
  ///
  /// In en, this message translates to:
  /// **'Annual Sales (SAR)'**
  String get calcInputAnnualSales;

  /// No description provided for @calcInputBusinessAge.
  ///
  /// In en, this message translates to:
  /// **'Business Age'**
  String get calcInputBusinessAge;

  /// No description provided for @calcInputPosPeriod.
  ///
  /// In en, this message translates to:
  /// **'POS Operating Period'**
  String get calcInputPosPeriod;

  /// No description provided for @calcInputMonthlyTransactions.
  ///
  /// In en, this message translates to:
  /// **'Monthly POS Transactions'**
  String get calcInputMonthlyTransactions;

  /// No description provided for @calcInputLoanAmount.
  ///
  /// In en, this message translates to:
  /// **'Loan Amount (SAR)'**
  String get calcInputLoanAmount;

  /// No description provided for @calcInputLoanAmountOptional.
  ///
  /// In en, this message translates to:
  /// **'Financing Amount - Optional (SAR)'**
  String get calcInputLoanAmountOptional;

  /// No description provided for @calcHintSpecificAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter specific amount'**
  String get calcHintSpecificAmount;

  /// No description provided for @calcInputDepositAmount.
  ///
  /// In en, this message translates to:
  /// **'Deposit Amount (SAR)'**
  String get calcInputDepositAmount;

  /// No description provided for @calcInputPeriod.
  ///
  /// In en, this message translates to:
  /// **'Investment Period'**
  String get calcInputPeriod;

  /// No description provided for @calcInputSubscriptionAmount.
  ///
  /// In en, this message translates to:
  /// **'Subscription Amount (SAR)'**
  String get calcInputSubscriptionAmount;

  /// No description provided for @calcInputReturnRate.
  ///
  /// In en, this message translates to:
  /// **'Return Rate'**
  String get calcInputReturnRate;

  /// No description provided for @calcInputCoverageAmount.
  ///
  /// In en, this message translates to:
  /// **'Coverage Amount (SAR)'**
  String get calcInputCoverageAmount;

  /// No description provided for @calcInputProgramDuration.
  ///
  /// In en, this message translates to:
  /// **'Program Duration (Years)'**
  String get calcInputProgramDuration;

  /// No description provided for @calcInputInvestmentStrategy.
  ///
  /// In en, this message translates to:
  /// **'Investment Strategy'**
  String get calcInputInvestmentStrategy;

  /// No description provided for @calcInputHousingSubsidy.
  ///
  /// In en, this message translates to:
  /// **'Housing Support'**
  String get calcInputHousingSubsidy;

  /// No description provided for @calcInputHasEtezaz.
  ///
  /// In en, this message translates to:
  /// **'Eitizaz'**
  String get calcInputHasEtezaz;

  /// No description provided for @calcInputOtherObligations.
  ///
  /// In en, this message translates to:
  /// **'Other Obligations'**
  String get calcInputOtherObligations;

  /// No description provided for @calcInputRemainingLoanDuration.
  ///
  /// In en, this message translates to:
  /// **'Remaining Loan Duration'**
  String get calcInputRemainingLoanDuration;

  /// No description provided for @calcInputSpecificREAmount.
  ///
  /// In en, this message translates to:
  /// **'Specific Real Estate Amount'**
  String get calcInputSpecificREAmount;

  /// No description provided for @calcInputREDurationMonths.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Financing Duration (Months)'**
  String get calcInputREDurationMonths;

  /// No description provided for @calcAutoFromRetirement.
  ///
  /// In en, this message translates to:
  /// **'Auto (from retirement age)'**
  String get calcAutoFromRetirement;

  /// No description provided for @calcInputRequestedAmount.
  ///
  /// In en, this message translates to:
  /// **'Requested Amount (SAR)'**
  String get calcInputRequestedAmount;

  /// No description provided for @calcInputGregorianDate.
  ///
  /// In en, this message translates to:
  /// **'Gregorian Date'**
  String get calcInputGregorianDate;

  /// No description provided for @calcInputHijriDate.
  ///
  /// In en, this message translates to:
  /// **'Hijri Date'**
  String get calcInputHijriDate;

  /// No description provided for @calcResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculation Results'**
  String get calcResultTitle;

  /// No description provided for @calcResultEligible.
  ///
  /// In en, this message translates to:
  /// **'Eligible for Financing'**
  String get calcResultEligible;

  /// No description provided for @calcResultNotEligible.
  ///
  /// In en, this message translates to:
  /// **'Not Eligible'**
  String get calcResultNotEligible;

  /// No description provided for @calcResultDeductionRatio.
  ///
  /// In en, this message translates to:
  /// **'Deduction Ratio'**
  String get calcResultDeductionRatio;

  /// No description provided for @calcResultMonthlyInstallment.
  ///
  /// In en, this message translates to:
  /// **'Monthly Installment'**
  String get calcResultMonthlyInstallment;

  /// No description provided for @calcResultTotalFinancing.
  ///
  /// In en, this message translates to:
  /// **'Total Financing'**
  String get calcResultTotalFinancing;

  /// No description provided for @calcResultApprovalAmount.
  ///
  /// In en, this message translates to:
  /// **'Approval Amount'**
  String get calcResultApprovalAmount;

  /// No description provided for @calcResultAdminFees.
  ///
  /// In en, this message translates to:
  /// **'Admin Fees Amount (0.5%)'**
  String get calcResultAdminFees;

  /// No description provided for @calcResultVat.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get calcResultVat;

  /// No description provided for @calcResultTotalFees.
  ///
  /// In en, this message translates to:
  /// **'Total Fees'**
  String get calcResultTotalFees;

  /// No description provided for @calcResultNetAmount.
  ///
  /// In en, this message translates to:
  /// **'Net Finance after Fee Deduction'**
  String get calcResultNetAmount;

  /// No description provided for @calcResultBankProfit.
  ///
  /// In en, this message translates to:
  /// **'Total Bank Profit'**
  String get calcResultBankProfit;

  /// No description provided for @calcResultNetAfterAll.
  ///
  /// In en, this message translates to:
  /// **'Net Finance after All Deductions'**
  String get calcResultNetAfterAll;

  /// No description provided for @calcResultMaxAvailableMonths.
  ///
  /// In en, this message translates to:
  /// **'Max Available Months'**
  String get calcResultMaxAvailableMonths;

  /// No description provided for @calcResultDebtAtOtherBank.
  ///
  /// In en, this message translates to:
  /// **'Debt at Other Bank'**
  String get calcResultDebtAtOtherBank;

  /// No description provided for @calcResultNetAfterDebt.
  ///
  /// In en, this message translates to:
  /// **'Net client financing after deducting other bank debt'**
  String get calcResultNetAfterDebt;

  /// No description provided for @calcResultAdminFeesIncludingTax.
  ///
  /// In en, this message translates to:
  /// **'Administrative fees including tax'**
  String get calcResultAdminFeesIncludingTax;

  /// No description provided for @calcResultMaxREAmount.
  ///
  /// In en, this message translates to:
  /// **'Max Real Estate Amount'**
  String get calcResultMaxREAmount;

  /// No description provided for @calcResultMonthlyDuringPL.
  ///
  /// In en, this message translates to:
  /// **'Monthly Installment (1) During Personal Loan'**
  String get calcResultMonthlyDuringPL;

  /// No description provided for @calcResultMonthlyAfterPL.
  ///
  /// In en, this message translates to:
  /// **'Monthly Installment (2) After Personal Loan'**
  String get calcResultMonthlyAfterPL;

  /// No description provided for @calcResultLoanAmount.
  ///
  /// In en, this message translates to:
  /// **'Financing Amount'**
  String get calcResultLoanAmount;

  /// No description provided for @calcResultDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get calcResultDuration;

  /// No description provided for @calcResultProfitAmount.
  ///
  /// In en, this message translates to:
  /// **'Profit Amount'**
  String get calcResultProfitAmount;

  /// No description provided for @calcResultTotalWithProfit.
  ///
  /// In en, this message translates to:
  /// **'Total With Profit'**
  String get calcResultTotalWithProfit;

  /// No description provided for @calcResultAdminAppraisalFees.
  ///
  /// In en, this message translates to:
  /// **'Admin & Appraisal Fees'**
  String get calcResultAdminAppraisalFees;

  /// No description provided for @calcResultHousingSubsidy.
  ///
  /// In en, this message translates to:
  /// **'Housing Subsidy'**
  String get calcResultHousingSubsidy;

  /// No description provided for @calcResultGrandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get calcResultGrandTotal;

  /// No description provided for @calcResultFinanceDurationMonths.
  ///
  /// In en, this message translates to:
  /// **'Finance Duration (in Months)'**
  String get calcResultFinanceDurationMonths;

  /// No description provided for @calcResultAvailableDurationYears.
  ///
  /// In en, this message translates to:
  /// **'Available Duration for Client'**
  String get calcResultAvailableDurationYears;

  /// No description provided for @calcYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get calcYear;

  /// No description provided for @calcResultAdminAppraisalIncludingTax.
  ///
  /// In en, this message translates to:
  /// **'Admin & Valuation Fees'**
  String get calcResultAdminAppraisalIncludingTax;

  /// No description provided for @calcResultBankProfitRE.
  ///
  /// In en, this message translates to:
  /// **'Bank Profits'**
  String get calcResultBankProfitRE;

  /// No description provided for @calcResultFinalAmountWithSupport.
  ///
  /// In en, this message translates to:
  /// **'Final Amount + ( Housing Support / Eitizaz ) if any'**
  String get calcResultFinalAmountWithSupport;

  /// No description provided for @calcInputPersonalLoanIfAny.
  ///
  /// In en, this message translates to:
  /// **'Personal Finance Installment'**
  String get calcInputPersonalLoanIfAny;

  /// No description provided for @calcResultInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get calcResultInsurance;

  /// No description provided for @calcResultDownPayment.
  ///
  /// In en, this message translates to:
  /// **'Down Payment'**
  String get calcResultDownPayment;

  /// No description provided for @calcResultLastPayment.
  ///
  /// In en, this message translates to:
  /// **'Last Payment (Balloon)'**
  String get calcResultLastPayment;

  /// No description provided for @calcResultFinancedAmount.
  ///
  /// In en, this message translates to:
  /// **'Financed Amount'**
  String get calcResultFinancedAmount;

  /// No description provided for @calcResultAPR.
  ///
  /// In en, this message translates to:
  /// **'APR'**
  String get calcResultAPR;

  /// No description provided for @calcResultTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get calcResultTotalPaid;

  /// No description provided for @calcResultActualRatio.
  ///
  /// In en, this message translates to:
  /// **'Actual Deduction Ratio'**
  String get calcResultActualRatio;

  /// No description provided for @calcResultRequiredDP.
  ///
  /// In en, this message translates to:
  /// **'Required Down Payment'**
  String get calcResultRequiredDP;

  /// No description provided for @calcResultDecision.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get calcResultDecision;

  /// No description provided for @calcResultAvailableForCar.
  ///
  /// In en, this message translates to:
  /// **'Available for Vehicle'**
  String get calcResultAvailableForCar;

  /// No description provided for @calcResultEffectiveCarPrice.
  ///
  /// In en, this message translates to:
  /// **'Effective Vehicle Price'**
  String get calcResultEffectiveCarPrice;

  /// No description provided for @calcResultTotalReturn.
  ///
  /// In en, this message translates to:
  /// **'Total Return'**
  String get calcResultTotalReturn;

  /// No description provided for @calcResultProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get calcResultProfit;

  /// No description provided for @calcResultMinDeposit.
  ///
  /// In en, this message translates to:
  /// **'Minimum Deposit'**
  String get calcResultMinDeposit;

  /// No description provided for @calcResultCashValue.
  ///
  /// In en, this message translates to:
  /// **'Cash Value'**
  String get calcResultCashValue;

  /// No description provided for @calcResultSurrenderValue.
  ///
  /// In en, this message translates to:
  /// **'Surrender Value'**
  String get calcResultSurrenderValue;

  /// No description provided for @calcResultDeathBenefit.
  ///
  /// In en, this message translates to:
  /// **'Death Benefit'**
  String get calcResultDeathBenefit;

  /// No description provided for @calcResultCoverageAmount.
  ///
  /// In en, this message translates to:
  /// **'Coverage Amount'**
  String get calcResultCoverageAmount;

  /// No description provided for @calcResultReturnRate.
  ///
  /// In en, this message translates to:
  /// **'Annual Return Rate'**
  String get calcResultReturnRate;

  /// No description provided for @calcResultFinalBenefit.
  ///
  /// In en, this message translates to:
  /// **'Final Benefit'**
  String get calcResultFinalBenefit;

  /// No description provided for @calcResultYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get calcResultYear;

  /// No description provided for @calcResultProjectionTable.
  ///
  /// In en, this message translates to:
  /// **'Year-by-Year Projection'**
  String get calcResultProjectionTable;

  /// No description provided for @calcResultAgeYears.
  ///
  /// In en, this message translates to:
  /// **'Age (Years)'**
  String get calcResultAgeYears;

  /// No description provided for @calcResultAgeMonths.
  ///
  /// In en, this message translates to:
  /// **'Age (Months)'**
  String get calcResultAgeMonths;

  /// No description provided for @calcResultAgeDays.
  ///
  /// In en, this message translates to:
  /// **'Age (Days)'**
  String get calcResultAgeDays;

  /// No description provided for @calcResultAmountAt33.
  ///
  /// In en, this message translates to:
  /// **'Personal Finance (33.33%)'**
  String get calcResultAmountAt33;

  /// No description provided for @calcResultAmountAt45.
  ///
  /// In en, this message translates to:
  /// **'Leasing / Credit Cards (45%)'**
  String get calcResultAmountAt45;

  /// No description provided for @calcResultAmountAt55or65.
  ///
  /// In en, this message translates to:
  /// **'Real Estate (55%/65%)'**
  String get calcResultAmountAt55or65;

  /// No description provided for @calcResultRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining Salary'**
  String get calcResultRemaining;

  /// No description provided for @calcResultApplicable.
  ///
  /// In en, this message translates to:
  /// **'Applicable?'**
  String get calcResultApplicable;

  /// No description provided for @calcResultHijriDate.
  ///
  /// In en, this message translates to:
  /// **'Hijri Date'**
  String get calcResultHijriDate;

  /// No description provided for @calcResultGregorianDate.
  ///
  /// In en, this message translates to:
  /// **'Gregorian Date'**
  String get calcResultGregorianDate;

  /// No description provided for @calcSalaryClient.
  ///
  /// In en, this message translates to:
  /// **'Salary Client'**
  String get calcSalaryClient;

  /// No description provided for @calcNonSalaryClient.
  ///
  /// In en, this message translates to:
  /// **'Non-Salary Client'**
  String get calcNonSalaryClient;

  /// No description provided for @calcYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get calcYes;

  /// No description provided for @calcNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get calcNo;

  /// No description provided for @calcRealEstateNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get calcRealEstateNone;

  /// No description provided for @calcRealEstateHas.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get calcRealEstateHas;

  /// No description provided for @calcCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calcCalculate;

  /// No description provided for @calcReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get calcReset;

  /// No description provided for @calcSar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get calcSar;

  /// No description provided for @calcMonth.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get calcMonth;

  /// No description provided for @calcMonths.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get calcMonths;

  /// No description provided for @calcApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get calcApproved;

  /// No description provided for @calcIncreaseDownPayment.
  ///
  /// In en, this message translates to:
  /// **'Increase Down Payment'**
  String get calcIncreaseDownPayment;

  /// No description provided for @calcAllConditionsMet.
  ///
  /// In en, this message translates to:
  /// **'All conditions met'**
  String get calcAllConditionsMet;

  /// No description provided for @calcConvertToHijri.
  ///
  /// In en, this message translates to:
  /// **'Convert to Hijri'**
  String get calcConvertToHijri;

  /// No description provided for @calcConvertToGregorian.
  ///
  /// In en, this message translates to:
  /// **'Convert to Gregorian'**
  String get calcConvertToGregorian;

  /// No description provided for @aiSettings.
  ///
  /// In en, this message translates to:
  /// **'AI Settings'**
  String get aiSettings;

  /// No description provided for @aiSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage the Claude AI API key for the chat assistant.'**
  String get aiSettingsSubtitle;

  /// No description provided for @aiApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Claude API Key'**
  String get aiApiKeyLabel;

  /// No description provided for @aiApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your Claude API key (sk-ant-...)'**
  String get aiApiKeyHint;

  /// No description provided for @aiApiKeyNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'No API key configured yet.'**
  String get aiApiKeyNotConfigured;

  /// No description provided for @aiApiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API key saved successfully.'**
  String get aiApiKeySaved;

  /// No description provided for @aiApiKeyDeleted.
  ///
  /// In en, this message translates to:
  /// **'API key deleted successfully.'**
  String get aiApiKeyDeleted;

  /// No description provided for @aiApiKeyDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete API Key'**
  String get aiApiKeyDeleteConfirmTitle;

  /// No description provided for @aiApiKeyDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the API key? The AI chat feature will stop working.'**
  String get aiApiKeyDeleteConfirmMessage;

  /// No description provided for @aiApiKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'API key must start with sk-ant-'**
  String get aiApiKeyInvalid;

  /// No description provided for @aiApiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'API key is required'**
  String get aiApiKeyRequired;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
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
