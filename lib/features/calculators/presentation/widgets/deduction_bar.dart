import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';

/// Deduction ratio progress bar matching HTML `.bar-wrap`.
class DeductionBar extends StatelessWidget {
  const DeductionBar({
    super.key,
    required this.actualPercent,
    required this.limitPercent,
  });

  /// Actual deduction ratio (0–1).
  final double actualPercent;

  /// Maximum allowed ratio (0–1).
  final double limitPercent;

  @override
  Widget build(BuildContext context) {
    final isOver = actualPercent > limitPercent;
    final barColor = isOver ? AppColors.calcRed : AppColors.calcGreen;
    final fillWidth = (actualPercent / limitPercent).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الاستقطاع: ${(actualPercent * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 12, color: AppColors.calcText),
              ),
              Text(
                'الحد: ${(limitPercent * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12, color: AppColors.calcMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.calcBorder,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: fillWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
