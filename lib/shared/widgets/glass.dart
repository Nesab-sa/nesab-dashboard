import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

class GlassEffect extends StatelessWidget {
  const GlassEffect({
    super.key,
    required this.child,
    this.radius = AppDimensions.radiusCard,
  });
  final Widget child;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceLight.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(radius - 1),
          ),
          padding: const EdgeInsetsDirectional.all(12),
          child: child,
        ),
      ),
    );
  }
}
