/// Centralized route path and name constants for the Nesab app.
///
/// Every route used by [GoRouter] MUST be defined here.
/// Never hardcode route strings elsewhere.
abstract class RouteNames {
  const RouteNames._();

  // ── Splash ───────────────────────────────────────────────────────────────

  static const String splashPath = '/splash';
  static const String splashName = 'splash';

  // ── Auth ──────────────────────────────────────────────────────────────────

  static const String loginPath = '/login';
  static const String loginName = 'login';

  static const String registerPath = '/register';
  static const String registerName = 'register';

  static const String forgotPasswordPath = '/forgot-password';
  static const String forgotPasswordName = 'forgotPassword';

  // ── Home ──────────────────────────────────────────────────────────────────

  static const String homePath = '/home';
  static const String homeName = 'home';

  // ── Products ──────────────────────────────────────────────────────────────

  static const String productsPath = '/products';
  static const String productsName = 'products';

  static const String productDetailPath = '/products/:id';
  static const String productDetailName = 'productDetail';

  static const String subProductDetailPath = '/products/:id/:subId';
  static const String subProductDetailName = 'subProductDetail';

  // ── Category Details ─────────────────────────────────────────────────

  static const String categoryDetailPath = '/category/:id';
  static const String categoryDetailName = 'categoryDetail';

  // ── Apply ─────────────────────────────────────────────────────────────────

  static const String applyPath = '/apply/:productId/:subProductId';
  static const String applyName = 'apply';

  // ── Info ──────────────────────────────────────────────────────────────────

  static const String aboutPath = '/about';
  static const String aboutName = 'about';

  static const String contactPath = '/contact';
  static const String contactName = 'contact';

  static const String developerPath = '/developer';
  static const String developerName = 'developer';

  // ── Profile ───────────────────────────────────────────────────────────────

  static const String profilePath = '/profile';
  static const String profileName = 'profile';

  // ── Requests ──────────────────────────────────────────────────────────────

  static const String myRequestsPath = '/my-requests';
  static const String myRequestsName = 'myRequests';

  // ── Onboarding ──────────────────────────────────────────────────────────

  static const String onboardingPath = '/onboarding';
  static const String onboardingName = 'onboarding';

  // ── Paywall ─────────────────────────────────────────────────────────────

  static const String paywallPath = '/paywall';
  static const String paywallName = 'paywall';

  // ── Profit Margins Compare ───────────────────────────────────────────────

  static const String profitMarginsPath = '/profit-margins';
  static const String profitMarginsName = 'profitMargins';
}
