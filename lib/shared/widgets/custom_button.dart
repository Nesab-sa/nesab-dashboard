import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/constants/app_assets.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/core/theme/app_text_styles.dart';

/// A frosted glass pill button with a gradient image background.
///
/// Uses [AppAssets.gradientBg] as its background, clipped to a pill shape.
/// Supports [isLoading] state and optional [icon].
class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = AppDimensions.buttonHeightLg,
    this.width,
    this.borderRadius = AppDimensions.radiusFull,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: width ?? double.infinity,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Gradient image background
              Image.asset(
                AppAssets.gradientBg,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Center(
                child: isLoading
                    ? SizedBox(
                        height: AppDimensions.iconMd,
                        width: AppDimensions.iconMd,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            icon!,
                            const SizedBox(width: AppDimensions.spacingMd),
                          ],
                          Text(
                            text,
                            style: AppTextStyles.buttonLarge.copyWith(
                              color: AppColors.onPrimaryContrast,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
