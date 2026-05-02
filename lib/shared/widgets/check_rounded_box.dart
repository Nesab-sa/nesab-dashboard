import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';

/// Custom rounded checkbox matching the glass card style.
class CheckRoundedBox extends StatelessWidget {
  const CheckRoundedBox({
    super.key,
    required this.onSelect,
    required this.isSelected,
    required this.isDark,
  });

  final VoidCallback onSelect;
  final bool isSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.24)
                    : Colors.black.withValues(alpha: 0.15))
                : Colors.transparent,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.24)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: isSelected
              ? Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
