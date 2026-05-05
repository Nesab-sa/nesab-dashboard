import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_fonts.dart';
import 'package:nesab/core/theme/app_gradients.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(AppDimensions.spacingXxl),
      decoration: BoxDecoration(
        gradient: AppGradients.heroCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
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
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.homeHeroTitle,
                style: const TextStyle(
                  fontFamily: AppFonts.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                context.l10n.homeHeroSubtitle,
                style: TextStyle(
                  fontFamily: AppFonts.primary,
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              GestureDetector(
                onTap: () => context.push(RouteNames.productsPath),
                child: Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppDimensions.spacingXxl,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusLg,
                    ),
                  ),
                  child: Text(
                    context.l10n.homeHeroCta,
                    style: const TextStyle(
                      fontFamily: AppFonts.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
