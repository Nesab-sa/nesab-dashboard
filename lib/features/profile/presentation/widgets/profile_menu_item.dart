import 'package:flutter/material.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    required this.label,
    this.icon,
    this.imageAsset,
    this.description,
    this.onTap,
    this.isDestructive = false,
    this.iconColor,
    this.trailing,
    super.key,
  }) : assert(icon != null || imageAsset != null);

  final IconData? icon;
  final String? imageAsset;
  final String label;
  final String? description;
  final VoidCallback? onTap;
  final bool isDestructive;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDestructive
        ? AppColors.error
        : isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final icColor = isDestructive
        ? AppColors.error
        : (iconColor ??
              (isDark ? AppColors.textPrimaryDark : AppColors.primary));
    final bgColor = icColor.withValues(alpha: 0.12);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 0,
          vertical: AppDimensions.spacingMd,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: imageAsset != null
                  ? Image.asset(imageAsset!, width: 34, height: 34)
                  : Icon(icon, color: icColor, size: 22),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isDestructive)
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: isDark
                        ? AppColors.textDisabledDark
                        : AppColors.textDisabledLight,
                    size: 20,
                  ),
          ],
        ),
      ),
    );
  }
}
