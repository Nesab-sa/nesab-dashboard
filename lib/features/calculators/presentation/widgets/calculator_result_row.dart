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
        borderColor = Colors.blue[400]!;
        bgColor = Colors.blue[50]!;
        valueColor = Colors.blue[700]!;
      case ResultHighlight.gold:
        borderColor = Colors.amber[600]!;
        bgColor = Colors.amber[50]!;
        valueColor = Colors.amber[900]!;
      case ResultHighlight.green:
        borderColor = Colors.green[600]!;
        bgColor = Colors.green[50]!;
        valueColor = Colors.green[700]!;
      case ResultHighlight.none:
        borderColor = Colors.grey[300]!;
        bgColor = Colors.grey[50]!;
        valueColor = Colors.grey[900]!;
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
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
