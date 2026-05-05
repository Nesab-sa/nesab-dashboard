import 'package:flutter/animation.dart';

abstract class AppConstants {
  const AppConstants._();

  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration staggerDelay = Duration(milliseconds: 100);
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve entranceCurve = Curves.easeOutCubic;

  static const String privacyPolicyUrl = 'https://nesab.sa/privacy/';
  static const String termsOfUseUrl = 'https://nesab.sa/terms-of-use.html';
}
