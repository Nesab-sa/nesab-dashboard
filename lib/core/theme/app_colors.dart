import 'package:flutter/material.dart';

/// Centralized color palette for the Nesab app.
///
/// All color values use the DaisyUI CMYK (light) / Black (dark) themes.
/// Never hardcode colors elsewhere; always reference [AppColors].
abstract class AppColors {
  const AppColors._();

  // ── Primary (Black) ─────────────────────────────────────────────────────

  static const Color primary = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF45AEEE);
  static const Color primaryDark = Color(0xFF1A1A1A);

  // ── Secondary Primary (Near Black) ──────────────────────────────────────

  static const Color secondPrimary = Color(0xFF1A1A1A);

  // ── Accent (Yellow – CMYK) ──────────────────────────────────────────────

  static const Color accent = Color(0xFFFFF232);
  static const Color accentLight = Color(0xFFFFFDE7);
  static const Color accentDark = Color(0xFFF9A825);

  // ── Blue Shades ─────────────────────────────────────────────────────────

  static const Color blue = Color(0xFF45AEEE);
  static const Color blueDark = Color(0xFF2A8ED4);
  static const Color blueDeep = Color(0xFF1A6FB5);
  static const Color blue50 = Color(0xFFEBF5FF);

  // ── Background ──────────────────────────────────────────────────────────

  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0B0B0B);

  // ── Surface ─────────────────────────────────────────────────────────────

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF141615);

  // ── Text – Light Mode ───────────────────────────────────────────────────

  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textDisabledLight = Color(0xFF9CA3AF);

  // ── Text – Dark Mode ────────────────────────────────────────────────────

  static const Color textPrimaryDark = Color(0xFFD6D6D6);
  static const Color textSecondaryDark = Color(0xFF808080);
  static const Color textDisabledDark = Color(0xFF525252);

  // ── Border ──────────────────────────────────────────────────────────────

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFF373737);

  // ── Semantic ────────────────────────────────────────────────────────────

  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFE93F33);
  static const Color warning = Color(0xFFEE8133);

  // ── Social / Brand ──────────────────────────────────────────────────────

  static const Color whatsapp = Color(0xFF25D366);
  static const Color gmail = Color(0xFFEA4335);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color linkedin = Color(0xFF0077B5);

  // ── Utility Colors ──────────────────────────────────────────────────────

  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color purple100 = Color(0xFFEDE9FE);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color purple600 = Color(0xFF7C3AED);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray800 = Color(0xFF1F2937);

  // ── Paywall ─────────────────────────────────────────────────────────────

  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber800 = Color(0xFF92400E);

  // ── Service Category Colors ──────────────────────────────────────────

  static const Color categoryPersonalFinance = Color(0xFF0D4B3C);
  static const Color categoryPersonalFinanceLight = Color(0xFF1A6B54);
  static const Color categoryRealEstate = Color(0xFF1E3A5F);
  static const Color categoryRealEstateLight = Color(0xFF2D5F8A);
  static const Color categoryLeasing = Color(0xFF5B2C6F);
  static const Color categoryLeasingLight = Color(0xFF7D3C98);
  static const Color categoryPos = Color(0xFFB7410E);
  static const Color categoryPosLight = Color(0xFFD4601A);
  static const Color categoryCharity = Color(0xFFC8A96E);
  static const Color categoryCharityLight = Color(0xFFE8D5A8);
  static const Color categoryTools = Color(0xFF374151);
  static const Color categoryToolsLight = Color(0xFF4B5563);
    static const Color calcBg = Color(0xFF040D1E);
  static const Color calcCard = Color(0xFF0A1A35);
  static const Color calcCard2 = Color(0xFF0D2040);
  static const Color calcBorder = Color(0xFF122850);
  static const Color calcBorder2 = Color(0xFF1A3A6A);
  static const Color calcNeon = Color(0xFF00C8FF);
  static const Color calcNeon2 = Color(0xFF0066FF);
  static const Color calcPurple = Color(0xFF4040CC);
  static const Color calcGreen = Color(0xFF00D68F);
  static const Color calcRed = Color(0xFFFF3D6B);
  static const Color calcGold = Color(0xFFF0B429);
  static const Color calcText = Color(0xFFD0E4FF);
  static const Color calcMuted = Color(0xFF4A6A9A);
  static const Color calcInput = Color(0xFF030B1A);
  static const Color calcHeaderTop = Color(0xFF040F28);

  // ── Dashboard / Light-mode aliases (used by calculator widgets) ────────

  static const Color dashboardBg = backgroundDark;
  static const Color dashboardTextPrimary = textPrimaryDark;
  static const Color lightModeTextPrimary = textPrimaryLight;
  static const Color dashboardTextSecondary = textSecondaryDark;
  static const Color lightModeTextSecondary = textSecondaryLight;
  static const Color dashboardCard = surfaceDark;
  static const Color lightModeCard = surfaceLight;
  static const Color dashboardBorder = borderDark;
  static const Color lightModeBorder = border;
}
