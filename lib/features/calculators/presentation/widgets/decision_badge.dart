import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';

/// Approved/rejected badge matching HTML `.dec-badge.ok` / `.dec-badge.no`.
class DecisionBadge extends StatelessWidget {
  const DecisionBadge({
    super.key,
    required this.approved,
    this.approvedText = 'مقبول — ضمن شروط ساما',
    this.rejectedText = 'مرفوض — تجاوز نسبة الاستقطاع',
  });

  final bool approved;
  final String approvedText;
  final String rejectedText;

  @override
  Widget build(BuildContext context) {
    final color = approved ? AppColors.calcGreen : AppColors.calcRed;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(13),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        approved ? approvedText : rejectedText,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
