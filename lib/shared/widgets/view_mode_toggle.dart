import 'package:flutter/material.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/shared/widgets/glass_card.dart';

class ViewModeToggle extends StatelessWidget {
  const ViewModeToggle({
    required this.isGrid,
    required this.onChanged,
    super.key,
  });

  final bool isGrid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppColors.primaryLight;
    final inactiveColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassCard(
          radius: 10,
          width: 40,
          height: 40,
          alignment: Alignment.center,
          onTap: () => onChanged(true),
          child: Icon(
            Icons.grid_view_rounded,
            color: isGrid ? activeColor : inactiveColor,
            size: 20,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        GlassCard(
          radius: 10,
          width: 40,
          height: 40,
          alignment: Alignment.center,
          onTap: () => onChanged(false),
          child: Icon(
            Icons.view_list_rounded,
            color: !isGrid ? activeColor : inactiveColor,
            size: 20,
          ),
        ),
      ],
    );
  }
}
