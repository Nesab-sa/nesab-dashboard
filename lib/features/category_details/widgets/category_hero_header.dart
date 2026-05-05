import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/shared/widgets/app_image.dart';
import 'package:nesab/shared/widgets/glass_card.dart';

const double _heroImageHeight = 120;

class CategoryHeroHeader extends StatelessWidget {
  const CategoryHeroHeader({
    required this.categoryId,
    required this.imagePath,
    required this.title,
    this.description,
    super.key,
  });

  final String categoryId;
  final String imagePath;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
      ),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GlassCard(
              radius: 100,
              width: 40,
              height: 40,
              alignment: Alignment.center,
              onTap: () => context.pop(),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                size: AppDimensions.iconSm,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Hero(
            tag: 'category-icon-$categoryId',
            child: AppImage(
              path: imagePath,
              height: _heroImageHeight,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          Text(
            title,
            style: AppTextStyles.headingMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
