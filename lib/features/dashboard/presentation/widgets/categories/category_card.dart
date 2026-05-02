import 'package:flutter/material.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_text_styles.dart';
import 'package:nesab_dashboard/shared/widgets/glass_card.dart';
import 'package:nesab_dashboard/shared/widgets/check_rounded_box.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/category_model.dart';

/// Card border radius per spec (matches nesab app).
const double categoryCardRadius = 18;

/// Category grid card size.
const double categoryCardSize = 176;

/// Shared category card used in grid display and add/edit form preview.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.label,
    required this.imageBuilder,
    required this.titleSize,
    this.imageWidthFraction = 0.17,
    this.imageHeightFraction = 0.7,
    this.opacity = 1.0,
    this.textDirection = TextDirection.ltr,
    this.showCheckbox = false,
    this.isSelected = false,
    this.onCheckChanged,
    this.onTap,
    this.heroTag,
  });

  final String label;
  final Widget Function(double width, double height) imageBuilder;
  final double titleSize;
  final double imageWidthFraction;
  final double imageHeightFraction;
  final double opacity;
  final TextDirection textDirection;
  final bool showCheckbox;
  final bool isSelected;
  final VoidCallback? onCheckChanged;
  final VoidCallback? onTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final safeTitleSize = titleSize.clamp(10.0, 32.0);

    return GlassCard(
      radius: categoryCardRadius,
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth * imageWidthFraction;
          final h = constraints.maxHeight * imageHeightFraction;
          Widget img = imageBuilder(w, h);
          if (opacity < 1.0) {
            img = Opacity(opacity: opacity, child: img);
          }
          if (heroTag != null) {
            img = Hero(tag: heroTag!, child: img);
          }

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Image at bottom-left
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, bottom: 5),
                  child: img,
                ),
              ),
              // Title at top-right
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: Text(
                    label,
                    textDirection: textDirection,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: safeTitleSize,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: textDirection == TextDirection.rtl
                        ? TextAlign.left
                        : TextAlign.right,
                  ),
                ),
              ),
              if (showCheckbox)
                Positioned(
                  top: 8,
                  left: 8,
                  child: CheckRoundedBox(
                    isSelected: isSelected,
                    onSelect: onCheckChanged ?? () {},
                    isDark: isDark,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class CategoryGridCard extends StatelessWidget {
  const CategoryGridCard({
    super.key,
    required this.category,
    required this.showEnglish,
    this.isSelected = false,
    this.onTap,
    this.onCheckChanged,
  });

  final CategoryModel category;
  final bool showEnglish;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onCheckChanged;

  @override
  Widget build(BuildContext context) {
    return CategoryCard(
      heroTag: 'cat_\${category.id}',
      label: category.displayLabel(showEnglish),
      titleSize: category.titleSize,
      imageWidthFraction: category.imageWidth,
      imageHeightFraction: category.imageHeight,
      opacity: category.opacity,
      textDirection: showEnglish ? TextDirection.ltr : TextDirection.rtl,
      showCheckbox: true,
      isSelected: isSelected,
      onTap: onTap,
      onCheckChanged: onCheckChanged,
      imageBuilder: (w, h) {
        if (category.imageUrl.isEmpty) return SizedBox(width: w, height: h);
        return CachedNetworkImage(
          imageUrl: category.imageUrl,
          width: w,
          height: h,
          fit: BoxFit.contain,
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        );
      },
    );
  }
}
