import 'package:flutter/material.dart';
import 'package:nesab/core/constants/app_assets.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_gradients.dart';
import 'package:nesab/core/theme/app_text_styles.dart';

/// The branded header area displayed at the top of auth pages.
///
/// Shows the app logo, a [title] and [subtitle], with an emerald gradient
/// background and decorative circles.
class LoginHeader extends StatelessWidget {
  const LoginHeader({this.title, this.subtitle, super.key});

  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppGradients.loginHeader,
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(32),
          bottomEnd: Radius.circular(32),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative circle top-left
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          // Decorative circle bottom-right
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Small decorative dot
          Positioned(
            top: 60,
            right: 40,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                bottom: AppDimensions.spacingXxxl,
                top: AppDimensions.spacingLg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXxl),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                    context.isDark ?  AppAssets.logoDark : AppAssets.logoLight,
                      width: 48,
                      height: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  // Title
                  Text(
                    title ?? l10n.loginTitle,
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  // Subtitle
                  Text(
                    subtitle ?? l10n.loginSubtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
