import 'package:flutter/material.dart';

/// Gradient definitions for the Nesab app.
///
/// All gradients use the CMYK blue palette.
abstract class AppGradients {
  const AppGradients._();

  /// Splash screen: blue diagonal gradient.
  static const LinearGradient splash = LinearGradient(
    begin: Alignment(-0.34, -0.94),
    end: Alignment(0.34, 0.94),
    colors: [Color(0xFF1A6FB5), Color(0xFF2A8ED4), Color(0xFF45AEEE)],
    stops: [0.0, 0.4, 1.0],
  );

  /// Hero card: blue gradient (135deg).
  static const LinearGradient heroCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A6FB5), Color(0xFF2A8ED4), Color(0xFF45AEEE)],
    stops: [0.0, 0.6, 1.0],
  );

  /// Login / auth header: blue 2-color.
  static const LinearGradient loginHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF45AEEE), Color(0xFF2A8ED4)],
  );

  /// Personal Finance: blue tones.
  static const LinearGradient personalFinance = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A8ED4), Color(0xFF45AEEE)],
  );

  /// Real Estate: deep blue tones.
  static const LinearGradient realEstate = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A5F), Color(0xFF2D5F8A)],
  );

  /// Lease: rich purple tones.
  static const LinearGradient lease = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B2C6F), Color(0xFF7D3C98)],
  );

  /// POS (Point of Sale): warm burnt-orange tones.
  static const LinearGradient pos = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB7410E), Color(0xFFD4601A)],
  );

  /// Khairat: light blue tones.
  static const LinearGradient khairat = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF45AEEE), Color(0xFF6BC1F5)],
  );

  // ── Onboarding ─────────────────────────────────────────────────────────

  /// Onboarding page 2: blue-50 to white vertical (light).
  static const LinearGradient onboardingCards = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEBF5FF), Color(0xFFFFFFFF)],
  );

  /// Onboarding page 2: dark blue to black vertical (dark).
  static const LinearGradient onboardingCardsDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A2A42), Color(0xFF000000)],
  );

  /// Onboarding hero placeholder gradient (light).
  static const LinearGradient onboardingHero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF45AEEE), Color(0xFF2A8ED4), Color(0xFFFFFFFF)],
    stops: [0.0, 0.7, 1.0],
  );

  /// Onboarding hero placeholder gradient (dark).
  static const LinearGradient onboardingHeroDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A6FB5), Color(0xFF0A2A42), Color(0xFF000000)],
    stops: [0.0, 0.7, 1.0],
  );

  // ── Auth ──────────────────────────────────────────────────────────────

  /// Aurora gradient for primary auth button border.
  static const LinearGradient aurora = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFE040FB),
      Color(0xFF7C4DFF),
      Color(0xFF448AFF),
      Color(0xFF18FFFF),
      Color(0xFF69F0AE),
      Color(0xFFFFD740),
    ],
  );

  // ── Paywall ────────────────────────────────────────────────────────────

  /// Paywall crown icon: blue diagonal.
  static const LinearGradient paywallCrown = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6BC1F5), Color(0xFF2A8ED4)],
  );

  /// Paywall bottom fade: black gradient for fixed footer.
  static const LinearGradient paywallFooter = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0xFF000000), Color(0xE6000000), Color(0x00000000)],
    stops: [0.0, 0.6, 1.0],
  );
}
