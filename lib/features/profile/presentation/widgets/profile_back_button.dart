import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/shared/widgets/glass_card.dart';

class ProfileBackButton extends StatelessWidget {
  const ProfileBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: GlassCard(
        radius: 100,
        width: 40,
        height: 40,
        alignment: Alignment.center,
        onTap: () => context.pop(),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          size: AppDimensions.iconSm,
        ),
      ),
    );
  }
}
