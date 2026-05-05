import 'package:flutter/material.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';

enum DialogActionVariant { neutral, primary, destructive }

class DialogActionButton extends StatelessWidget {
  const DialogActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = DialogActionVariant.neutral,
    this.isLoading = false,
    this.icon,
    this.customColor,
  });

  final String label;
  final VoidCallback? onTap;
  final DialogActionVariant variant;
  final bool isLoading;
  final IconData? icon;
  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accent = customColor ?? switch (variant) {
      DialogActionVariant.neutral => null,
      DialogActionVariant.primary => AppColors.primary,
      DialogActionVariant.destructive => AppColors.error,
    };

    final background = accent != null
        ? accent.withValues(alpha: 0.12)
        : (isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04));

    final textColor = accent ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: AppDimensions.spacingMd,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: textColor),
                    const SizedBox(width: AppDimensions.spacingSm),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
