import 'package:flutter/material.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/core/models/sub_category_model.dart';
import 'package:nesab/shared/widgets/app_image.dart';
import 'package:nesab/shared/widgets/glass_card.dart';

class SubCategoryCard extends StatelessWidget {
  const SubCategoryCard({required this.subCategory, super.key});

  final SubCategoryModel subCategory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Text content at the top
              Positioned(
                top: 10,
                left: 10,
                right: constraints.maxWidth * 0.35,
                child: Text(
                  subCategory.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Image - positioned at bottom-left
              Positioned(
                bottom: 0,
                left: 0,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Colors.transparent,
                      Colors.blue.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.3],
                  ).createShader(bounds),
                  blendMode: BlendMode.dstIn,
                  child: AppImage(
                    path: subCategory.imagePath,
                    width: constraints.maxWidth * 0.5,
                    height: constraints.maxWidth * 0.4,
                  ),
                ),
              ),
              // Coming Soon badge
              if (subCategory.isComingSoon)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'قريباً',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
