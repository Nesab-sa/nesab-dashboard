import 'package:flutter/material.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';

class DialogTextField extends StatelessWidget {
  const DialogTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textDirection,
    this.prefixIcon,
    this.accentColor,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final IconData? prefixIcon;
  final Color? accentColor;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? AppColors.primary;
    final hasAccent = accentColor != null;

    final borderColor = hasAccent
        ? accent.withValues(alpha: isDark ? 0.3 : 0.2)
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final labelColor = hasAccent
        ? accent
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textDirection: textDirection,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium.copyWith(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: AppTextStyles.caption.copyWith(color: labelColor),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight)
              .withValues(alpha: 0.5),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: accent, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: accent),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        contentPadding: hasAccent
            ? const EdgeInsetsDirectional.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              )
            : null,
      ),
    );
  }
}
