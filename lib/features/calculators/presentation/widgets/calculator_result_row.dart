import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';

/// Highlight level for result rows matching HTML `.hl`, `.hl2`, `.hl3`.
enum ResultHighlight { none, neon, gold, green }

/// Single result row matching HTML `.res-row`.
class CalculatorResultRow extends StatelessWidget {
  const CalculatorResultRow({
    super.key,
    required this.label,
    required this.value,
    this.highlight = ResultHighlight.none,
  });

  final String label;
  final String value;
  final ResultHighlight highlight;

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color bgColor;
    final Color valueColor;

    switch (highlight) {
      case ResultHighlight.neon:
        borderColor = AppColors.calcNeon;
        bgColor = AppColors.calcNeon.withValues(alpha: 0.04);
        valueColor = AppColors.calcNeon;
      case ResultHighlight.gold:
        borderColor = AppColors.calcGold;
        bgColor = AppColors.calcGold.withValues(alpha: 0.04);
        valueColor = AppColors.calcGold;
      case ResultHighlight.green:
        borderColor = AppColors.calcGreen;
        bgColor = AppColors.calcGreen.withValues(alpha: 0.04);
        valueColor = AppColors.calcGreen;
      case ResultHighlight.none:
        borderColor = AppColors.calcBorder;
        bgColor = AppColors.calcCard;
        valueColor = AppColors.calcText;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.calcMuted),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight != ResultHighlight.none ? 16 : 15,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
