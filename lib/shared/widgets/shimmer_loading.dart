import 'package:flutter/material.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/utils/app_responsive.dart';

/// A shimmer animation effect widget.
///
/// Wraps [child] with a sweeping highlight animation to indicate loading.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppDimensions.radiusMd,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.shade200;
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.grey.shade50;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer placeholder that mimics a category card in grid layout.
class ShimmerCategoryCard extends StatelessWidget {
  const ShimmerCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Title placeholder at top-right
          ShimmerBox(
            width: 80,
            height: 14,
            borderRadius: AppDimensions.radiusSm,
          ),
          const Spacer(),
          // Image placeholder at bottom-left
          Align(
            alignment: Alignment.bottomLeft,
            child: ShimmerBox(
              width: 72,
              height: 72,
              borderRadius: AppDimensions.radiusMd,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer grid that mimics the categories grid while loading.
class ShimmerCategoriesGrid extends StatelessWidget {
  const ShimmerCategoriesGrid({this.itemCount = 6, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = AppResponsive.numberOfGrid(context);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppDimensions.screenPaddingHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header placeholder
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: 140,
                      height: 18,
                      borderRadius: AppDimensions.radiusSm,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    ShimmerBox(
                      width: 200,
                      height: 12,
                      borderRadius: AppDimensions.radiusSm,
                    ),
                  ],
                ),
              ),
              ShimmerBox(
                width: 36,
                height: 36,
                borderRadius: AppDimensions.radiusMd,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXl),
          // Grid placeholder
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: AppDimensions.spacingMd,
              crossAxisSpacing: AppDimensions.spacingMd,
            ),
            itemCount: itemCount,
            itemBuilder: (_, __) => const ShimmerCategoryCard(),
          ),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for subcategories in the detail page.
class ShimmerSubcategoriesPage extends StatelessWidget {
  const ShimmerSubcategoriesPage({this.itemCount = 6, super.key});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = (MediaQuery.of(context).size.width / 200)
        .truncate()
        .clamp(2, 4);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
            vertical: AppDimensions.screenPaddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero header placeholder
              Center(
                child: ShimmerBox(
                  width: 120,
                  height: 120,
                  borderRadius: AppDimensions.radiusXl,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Center(
                child: ShimmerBox(
                  width: 160,
                  height: 20,
                  borderRadius: AppDimensions.radiusSm,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXxxl),
              // Section title + toggle placeholder
              Row(
                children: [
                  Expanded(
                    child: ShimmerBox(
                      width: 120,
                      height: 16,
                      borderRadius: AppDimensions.radiusSm,
                    ),
                  ),
                  ShimmerBox(
                    width: 36,
                    height: 36,
                    borderRadius: AppDimensions.radiusMd,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              // Grid placeholder
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: AppDimensions.spacingMd,
                    crossAxisSpacing: AppDimensions.spacingMd,
                  ),
                  itemCount: itemCount,
                  itemBuilder: (_, __) => const ShimmerCategoryCard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
