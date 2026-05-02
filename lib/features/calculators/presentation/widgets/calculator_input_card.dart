import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// A themed card wrapper for calculator input sections.
class CalculatorInputCard extends StatelessWidget {
  const CalculatorInputCard({super.key, required this.children, this.title});

  final List<Widget> children;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dashboardCard : AppColors.lightModeCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.dashboardTextPrimary
                      : AppColors.lightModeTextPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}
