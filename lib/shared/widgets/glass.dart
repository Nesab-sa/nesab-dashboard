import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nesab/core/theme/app_dimensions.dart';

class GlassEffect extends StatelessWidget {
  const GlassEffect({
    super.key,
    required this.child,
    this.radius = AppDimensions.radiusCard,
    this.padding = const EdgeInsets.all(12),
  });
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.bottomLeft,
          //     end: Alignment.topRight,
          //     colors: isDark
          //         ? [
          //             Colors.white.withValues(alpha: 0.25),
          //             Colors.white.withValues(alpha: 0.05),
          //           ]
          //         : [
          //             Colors.black.withValues(alpha: 0.12),
          //             Colors.black.withValues(alpha: 0.02),
          //           ],
          //   ),
          //  borderRadius: BorderRadius.circular(radius),
          // ),
          child: Container(
            //  margin: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(radius - 1),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
