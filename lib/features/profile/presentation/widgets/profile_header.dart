import 'package:flutter/material.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';
import 'package:nesab/shared/widgets/glass.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.user, super.key});

  final UserEntity user;

  String _methodLabel(BuildContext context) => switch (user.authProvider) {
    AppAuthProvider.google => context.l10n.authProviderGoogle,
    AppAuthProvider.apple => context.l10n.authProviderApple,
    AppAuthProvider.email => context.l10n.authProviderEmail,
    AppAuthProvider.guest => context.l10n.guestAccount,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firstLetter = user.displayName?? '?';

    return Column(
      children: [
        const SizedBox(height: AppDimensions.spacingXl),
        // Rounded rect avatar
        GlassEffect(
          radius: AppDimensions.radiusFull,
          child: SizedBox(
            width: 60,
            height: 60,
            child: Center(
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),
        Text(
          user.displayName ?? '',
          style: AppTextStyles.headingSmall.copyWith(
            fontSize: 20,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          user.email ?? '',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingXs,
          ),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.textPrimaryDark : AppColors.primary)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(
            _methodLabel(context),
            style: AppTextStyles.caption.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXxl),
      ],
    );
  }
}
