/// Spacing, sizing, and radius constants for the Nesab app.
///
/// All layout values should reference this class to ensure visual consistency.
/// Never hardcode numeric dimensions elsewhere.
abstract class AppDimensions {
  const AppDimensions._();

  // ── Spacing ──────────────────────────────────────────────────────────────

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 20;
  static const double spacingXxl = 24;
  static const double spacingXxxl = 32;

  // ── Base Font Sizes ────────────────────────────────────────────────────

  static const double fontSizeXs = 10;
  static const double fontSizeSm = 12;
  static const double fontSizeBody = 14;
  static const double fontSizeMd = 16;
  static const double fontSizeLg = 18;
  static const double fontSizeXl = 20;
  static const double fontSizeXxl = 24;
  static const double fontSizeHeading = 28;

  // ── Border Radius ────────────────────────────────────────────────────────

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusXxl28 = 28;
  static const double radiusCard = 20;
  static const double radiusNav = 14;
  static const double radiusFull = 999;

  // ── Icon Sizes ───────────────────────────────────────────────────────────

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // ── Button Heights ───────────────────────────────────────────────────────

  static const double buttonHeightSm = 36;
  static const double buttonHeightMd = 44;
  static const double buttonHeightLg = 46;

  // ── Screen Padding ───────────────────────────────────────────────────────

  static const double screenPaddingHorizontal = 20;
  static const double screenPaddingVertical = 20;
}
