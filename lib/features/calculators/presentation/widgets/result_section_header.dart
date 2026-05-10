import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';

/// Section title divider in calculator cards, matching HTML `.sec-t`.
class ResultSectionHeader extends StatelessWidget {
  const ResultSectionHeader({
    super.key,
    required this.title,
    this.icon,
  });

  final String title;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 7),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
