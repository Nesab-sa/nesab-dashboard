import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// A themed card for displaying calculation results.
class CalculatorResultCard extends StatelessWidget {
  const CalculatorResultCard({
    super.key,
    required this.rows,
    this.title,
    this.highlight = false,
  });

  final List<ResultRow> rows;
  final String? title;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = highlight
        ? (isDark
              ? AppColors.categoryPersonalFinance.withValues(alpha: 0.3)
              : AppColors.success.withValues(alpha: 0.08))
        : (isDark ? AppColors.dashboardCard : AppColors.lightModeCard);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: highlight
              ? AppColors.success.withValues(alpha: 0.3)
              : (isDark
                    ? AppColors.dashboardBorder
                    : AppColors.lightModeBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.dashboardTextPrimary
                    : AppColors.lightModeTextPrimary,
              ),
            ),
            const Divider(height: AppDimensions.spacingXxl),
          ],
          for (int i = 0; i < rows.length; i++) ...[
            _ResultRowWidget(row: rows[i]),
            if (i < rows.length - 1)
              Divider(
                height: AppDimensions.spacingLg,
                color: isDark
                    ? AppColors.dashboardBorder.withValues(alpha: 0.5)
                    : AppColors.lightModeBorder,
              ),
          ],
        ],
      ),
    );
  }
}

/// A single label–value row in the result card.
class ResultRow {
  const ResultRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
}

class _ResultRowWidget extends StatelessWidget {
  const _ResultRowWidget({required this.row});

  final ResultRow row;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? AppColors.dashboardTextSecondary
        : AppColors.lightModeTextSecondary;
    final valueColor =
        row.valueColor ??
        (isDark
            ? AppColors.dashboardTextPrimary
            : AppColors.lightModeTextPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              row.label,
              style: context.textTheme.bodyMedium?.copyWith(color: labelColor),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Text(
            row.value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: row.isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
