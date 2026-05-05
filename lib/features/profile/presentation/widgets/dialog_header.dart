import 'package:flutter/material.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_text_styles.dart';

class DialogHeader extends StatelessWidget {
  const DialogHeader({super.key, required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            child: Icon(
              Icons.close,
              size: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.headingSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 32),
      ],
    );
  }
}
