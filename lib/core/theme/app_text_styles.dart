import 'package:flutter/material.dart';

import 'app_fonts.dart';

/// Text style definitions for the Nesab app.
///
/// All styles use [AppFonts.primary] as the font family.
/// Never create ad-hoc TextStyles in widgets; always reference this class.
abstract class AppTextStyles {
  const AppTextStyles._();

  // ── Headings ─────────────────────────────────────────────────────────────

  static const TextStyle headingLarge = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // ── Body ─────────────────────────────────────────────────────────────────

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // ── Labels ───────────────────────────────────────────────────────────────

  static const TextStyle labelLarge = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // ── Buttons ──────────────────────────────────────────────────────────────

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  // ── Caption ──────────────────────────────────────────────────────────────

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.primary,
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );
}
