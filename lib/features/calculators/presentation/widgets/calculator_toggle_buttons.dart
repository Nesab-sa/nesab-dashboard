import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';

/// Toggle buttons matching the HTML `.tog` class.
/// Used for pct/amt mode switches and page/section toggles.
class CalculatorToggleButtons extends StatelessWidget {
  const CalculatorToggleButtons({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.grey[300]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 5),
                color: active ? Colors.blue[600] : Colors.grey[100],
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    color: active ? Colors.white : Colors.grey[600],
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
