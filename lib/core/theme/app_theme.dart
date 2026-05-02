import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_fonts.dart';
import 'app_text_styles.dart';

/// Provides complete light and dark [ThemeData] for the Nesab app.
///
/// Every value references the centralised constant files ([AppColors],
/// [AppDimensions], [AppTextStyles], [AppFonts]) so no magic numbers or
/// hardcoded colors leak into widget code.
abstract class AppTheme {
  const AppTheme._();

  // ───────────────────────────────────────────────────────────────────────────
  // Light Theme
  // ───────────────────────────────────────────────────────────────────────────

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.blue600,
      primaryContainer: AppColors.lightModeNavActive,
      secondary: AppColors.blue,
      secondaryContainer: AppColors.blue50,
      surface: AppColors.lightModeCard,
      error: AppColors.error,
      onPrimary: AppColors.onPrimaryContrast,
      onSecondary: AppColors.lightModeTextPrimary,
      onSurface: AppColors.lightModeTextPrimary,
      onError: AppColors.onPrimaryContrast,
      outline: AppColors.lightModeBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFonts.primary,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightModeBg,

      // ── Text Theme ─────────────────────────────────────────────────────
      textTheme: _buildTextTheme(
        primaryColor: AppColors.lightModeTextPrimary,
        secondaryColor: AppColors.lightModeTextSecondary,
        disabledColor: AppColors.lightModeTextSecondary,
      ),

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightModeCard,
        foregroundColor: AppColors.lightModeTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingSmall.copyWith(
          color: AppColors.lightModeTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.lightModeTextPrimary,
          size: AppDimensions.iconLg,
        ),
      ),

      // ── Input Decoration ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightModeCard,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.lightModeBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.lightModeBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.blue600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightModeTextSecondary,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.lightModeTextSecondary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),

      // ── Elevated Button ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue600,
          foregroundColor: AppColors.onPrimaryContrast,
          elevation: 0,
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeightLg,
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppDimensions.spacingXxl,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue600,
          elevation: 0,
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeightLg,
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppDimensions.spacingXxl,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          side: const BorderSide(color: AppColors.blue600),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.lightModeCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          side: const BorderSide(color: AppColors.lightModeBorder),
        ),
        margin: const EdgeInsetsDirectional.all(AppDimensions.spacingSm),
      ),

      // ── Bottom Navigation Bar ──────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDisabledLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontSize: 10,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textDisabledLight,
          fontSize: 10,
        ),
        selectedIconTheme: const IconThemeData(
          size: AppDimensions.iconLg,
          color: AppColors.primary,
        ),
        unselectedIconTheme: const IconThemeData(
          size: AppDimensions.iconLg,
          color: AppColors.textDisabledLight,
        ),
      ),

      // ── Chip ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightModeCard,
        selectedColor: AppColors.lightModeNavActive,
        disabledColor: AppColors.lightModeBorder,
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.lightModeTextPrimary,
        ),
        secondaryLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onPrimaryContrast,
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingXs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          side: const BorderSide(color: AppColors.lightModeBorder),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightModeCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        titleTextStyle: AppTextStyles.headingSmall.copyWith(
          color: AppColors.lightModeTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightModeTextSecondary,
        ),
      ),

      // ── SnackBar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightModeTextPrimary,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightModeCard,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Dark Theme
  // ───────────────────────────────────────────────────────────────────────────

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.blue,
      primaryContainer: AppColors.dashboardCardHeader,
      secondary: AppColors.accent,
      secondaryContainer: AppColors.accentDark,
      surface: AppColors.dashboardCard,
      error: AppColors.error,
      onPrimary: AppColors.onPrimaryContrast,
      onSecondary: AppColors.dashboardTextPrimary,
      onSurface: AppColors.dashboardTextPrimary,
      onError: AppColors.onPrimaryContrast,
      outline: AppColors.dashboardBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppFonts.primary,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.dashboardBg,

      // ── Text Theme ─────────────────────────────────────────────────────
      textTheme: _buildTextTheme(
        primaryColor: AppColors.dashboardTextPrimary,
        secondaryColor: AppColors.dashboardTextSecondary,
        disabledColor: AppColors.dashboardTextSecondary,
      ),

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dashboardBg,
        foregroundColor: AppColors.dashboardTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headingSmall.copyWith(
          color: AppColors.dashboardTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.dashboardTextPrimary,
          size: AppDimensions.iconLg,
        ),
      ),

      // ── Input Decoration ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.dashboardCard,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.dashboardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.dashboardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.dashboardTextSecondary,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.dashboardTextSecondary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),

      // ── Elevated Button ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.onPrimaryContrast,
          elevation: 0,
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeightLg,
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppDimensions.spacingXxl,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // ── Outlined Button ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          elevation: 0,
          minimumSize: const Size(
            double.infinity,
            AppDimensions.buttonHeightLg,
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppDimensions.spacingXxl,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          side: const BorderSide(color: AppColors.primaryLight),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.dashboardCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: const BorderSide(color: AppColors.dashboardBorder),
        ),
        margin: const EdgeInsetsDirectional.all(AppDimensions.spacingSm),
      ),

      // ── Bottom Navigation Bar ──────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primaryLight,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        selectedIconTheme: const IconThemeData(
          size: AppDimensions.iconLg,
          color: AppColors.primaryLight,
        ),
        unselectedIconTheme: const IconThemeData(
          size: AppDimensions.iconLg,
          color: AppColors.textSecondaryDark,
        ),
      ),

      // ── Chip ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.dashboardCard,
        selectedColor: AppColors.blue,
        disabledColor: AppColors.dashboardBorder,
        labelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.dashboardTextPrimary,
        ),
        secondaryLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.onPrimaryContrast,
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingXs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          side: const BorderSide(color: AppColors.dashboardBorder),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.dashboardCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        titleTextStyle: AppTextStyles.headingSmall.copyWith(
          color: AppColors.dashboardTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.dashboardTextSecondary,
        ),
      ),

      // ── SnackBar ───────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.dashboardCard,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.dashboardTextPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helpers
  // ───────────────────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color disabledColor,
  }) {
    return TextTheme(
      headlineLarge: AppTextStyles.headingLarge.copyWith(color: primaryColor),
      headlineMedium: AppTextStyles.headingMedium.copyWith(color: primaryColor),
      headlineSmall: AppTextStyles.headingSmall.copyWith(color: primaryColor),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: primaryColor),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: secondaryColor),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: disabledColor),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: primaryColor),
      labelMedium: AppTextStyles.labelMedium.copyWith(color: secondaryColor),
      labelSmall: AppTextStyles.labelSmall.copyWith(color: disabledColor),
      titleLarge: AppTextStyles.headingSmall.copyWith(color: primaryColor),
      titleMedium: AppTextStyles.labelLarge.copyWith(color: primaryColor),
      titleSmall: AppTextStyles.labelMedium.copyWith(color: secondaryColor),
    );
  }
}
