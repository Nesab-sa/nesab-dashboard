import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/localization/cubit/locale_cubit.dart';
import 'package:nesab/core/models/category_model.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/core/utils/app_responsive.dart';
import 'package:nesab/shared/widgets/app_image.dart';
import 'package:nesab/shared/widgets/glass_card.dart';
import 'package:nesab/shared/widgets/shimmer_loading.dart';
import 'package:nesab/shared/widgets/animated_layout_switcher.dart';
import 'package:nesab/shared/widgets/view_mode_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Card border radius per spec.
const double _categoryCardRadius = 18;

class ServiceCategoriesGrid extends StatefulWidget {
  const ServiceCategoriesGrid({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelectionChanged,
  });

  final List<CategoryModel> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;

  @override
  State<ServiceCategoriesGrid> createState() => _ServiceCategoriesGridState();
}

class _ServiceCategoriesGridState extends State<ServiceCategoriesGrid> {
  static const _viewModeKey = 'view_mode_is_grid';
  late bool _isGrid;

  @override
  void initState() {
    super.initState();
    _isGrid = getIt<SharedPreferences>().getBool(_viewModeKey) ?? true;
  }

  void _setViewMode(bool isGrid) {
    setState(() => _isGrid = isGrid);
    getIt<SharedPreferences>().setBool(_viewModeKey, isGrid);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useEnglish =
        context.read<LocaleCubit>().state.locale.languageCode == 'en';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.quickActionsTitle,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Text(
                    context.l10n.homeSelectService,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            ViewModeToggle(isGrid: _isGrid, onChanged: _setViewMode),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXl),
        AnimatedLayoutSwitcher(
          gridCrossAxisCount: AppResponsive.numberOfGrid(context),
          isGrid: _isGrid,
          gridAspectRatio: 1.0,
          itemCount: widget.categories.length,
          itemBuilder: (context, index, metrics) {
            final category = widget.categories[index];
            return _MorphingServiceCard(
              category: category,
              useEnglish: useEnglish,
              isSelected: widget.selectedIndex == index,
              onSelect: () => widget.onSelectionChanged(index),
              metrics: metrics,
            );
          },
        ),
      ],
    );
  }
}

class _MorphingServiceCard extends StatelessWidget {
  const _MorphingServiceCard({
    required this.category,
    required this.useEnglish,
    required this.isSelected,
    required this.onSelect,
    required this.metrics,
  });

  final CategoryModel category;
  final bool useEnglish;
  final bool isSelected;
  final VoidCallback onSelect;
  final LayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = metrics.t;
    const listImageSize = 56.0;

    // List: image 56×56; Grid: from dashboard (0.17/0.7 or category fractions)
    final gridImageW =
        (metrics.gridWidth *
                (metrics.gridWidth > context.screenWidth * 0.8
                    ? 0.17
                    : category.clampedImageWidth))
            .clamp(1.0, metrics.gridWidth);
    final gridImageH =
        (metrics.gridHeight *
                (metrics.gridHeight > context.screenWidth * 0.8
                    ? 0.7
                    : category.clampedImageHeight))
            .clamp(1.0, metrics.gridHeight);
    final imageW = lerpDouble(gridImageW, listImageSize, t)!;
    final imageH = lerpDouble(gridImageH, listImageSize, t)!;

    final label = category.displayLabel(useEnglish);
    final titleSize = category.clampedTitleSize;
    final textDirection = useEnglish && category.englishName.isNotEmpty
        ? TextDirection.ltr
        : TextDirection.rtl;

    // ShaderMask fades out going to list
    final shaderOpacity = (1.0 - t * 1.5).clamp(0.0, 1.0);

    Widget buildImage(double? width, double? height) {
      final w = width ?? listImageSize;
      final h = height ?? width ?? listImageSize;
      final opacityValue = category.clampedOpacity.clamp(0.01, 1.0);
      Widget content;
      if (category.imageUrl.trim().isEmpty) {
        content = SizedBox(
          width: w,
          height: h,
          child: Icon(
            Icons.image_not_supported,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      } else {
        content = ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: AppImage(
            path: category.imageUrl,
            width: w,
            height: h,
            fit: BoxFit.contain,
            alignment: t < 0.5 ? Alignment.bottomLeft : Alignment.centerRight,
            placeholder: ShimmerBox(width: w, height: h),
          ),
        );
      }
      if (opacityValue < 1) {
        content = Opacity(opacity: opacityValue, child: content);
      }
      return Hero(tag: 'category-icon-${category.id}', child: content);
    }

    Widget imageWithShader([double? w, double? h]) {
      if (shaderOpacity <= 0.01) return buildImage(w, h);
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Colors.transparent,
            Colors.blue.withValues(alpha: 0.8 * shaderOpacity),
          ],
          stops: const [0.0, 0.3],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: buildImage(w, h),
      );
    }

    return GlassCard(
      radius: _categoryCardRadius,
      onTap: onSelect,
      child: LayoutBuilder(
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ── Image: grid bottom-left (dashboard), list bottom-end ──
              Align(
                alignment: AlignmentGeometry.lerp(
                  Alignment.bottomLeft,
                  const AlignmentDirectional(1.0, 1.0),
                  t,
                )!,
                child: Padding(
                  padding: t < 0.5
                      ? EdgeInsets.only(left: 5, bottom: 5)
                      : EdgeInsetsDirectional.only(end: 12, bottom: 5),
                  child: imageWithShader(imageW, imageH),
                ),
              ),
              // ── List text (t > 0.3) ──
              if (t > 0.3)
                PositionedDirectional(
                  start: 38,
                  end: listImageSize + 12 + 10,
                  top: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: ((t - 0.3) / 0.4).clamp(0.0, 1.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: titleSize,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              // ── Title at top-right (grid only) ──
              if (t < 0.6)
                Opacity(
                  opacity: (1.0 - t * 2.5).clamp(0.0, 1.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, top: 8),
                      child: Text(
                        label,
                        textDirection: textDirection,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: titleSize,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              // ── Checkbox: grid top-left, list start ──
              Align(
                alignment: AlignmentGeometry.lerp(
                  Alignment.topLeft,
                  const AlignmentDirectional(-1.0, 0.0),
                  t,
                )!,
                child: CheckRoundedBox(
                  onSelect: onSelect,
                  isSelected: isSelected,
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

class CheckRoundedBox extends StatelessWidget {
  const CheckRoundedBox({
    super.key,
    required this.onSelect,
    required this.isSelected,
    required this.isDark,
  });

  final VoidCallback onSelect;
  final bool isSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? (isDark
                      ? Colors.white.withValues(alpha: 0.24)
                      : Colors.black.withValues(alpha: 0.15))
                : Colors.transparent,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.24)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
