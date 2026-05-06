import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// A glassmorphism card with blur and gradient border.
/// Use for category/service cards. Optional [onTap].
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.radius = AppDimensions.radiusCard,
    this.width,
    this.height,
    this.onTap,
    this.alignment,
  });

  final Widget child;
  final double radius;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
              tileMode: TileMode.decal,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-1, -1),
                  end: const Alignment(1, 1),
                  colors: isDark
                      ? [
                          const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.55),
                          const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.40),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.55),
                          Colors.white.withValues(alpha: 0.25),
                        ],
                ),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.24)
                      : Colors.black.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              alignment: alignment,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
