import 'package:flutter/material.dart';

/// Box shadow definitions for the Nesab app.
///
/// Three elevation levels (small, medium, large) using black opacity
/// variations. Use these instead of hardcoding shadow values.
abstract class AppShadows {
  const AppShadows._();

  static const BoxShadow small = BoxShadow(
    color: Color(0x0D000000), // black 5%
    blurRadius: 4,
    offset: Offset(0, 1),
  );

  static const BoxShadow medium = BoxShadow(
    color: Color(0x1A000000), // black 10%
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow large = BoxShadow(
    color: Color(0x26000000), // black 15%
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow card = BoxShadow(
    color: Color(0x0A000000), // black 4%
    blurRadius: 16,
    offset: Offset(0, 2),
  );

  static const BoxShadow primaryGlow = BoxShadow(
    color: Color(0x6645AEEE), // blue 40%
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // ── Onboarding ─────────────────────────────────────────────────────────

  static const BoxShadow onboardingCard = BoxShadow(
    color: Color(0x14000000), // black 8%
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  static const BoxShadow blueGlow = BoxShadow(
    color: Color(0x3345AEEE), // blue 20%
    blurRadius: 16,
    offset: Offset(0, 8),
  );
}
