import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/profile/presentation/dialogs/glass_dialog.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_action_button.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_header.dart';

void showLogoutDialog(BuildContext context) {
  showGlassDialog(
    context: context,
    builder: (dialogContext) {
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: context.l10n.logoutConfirmTitle,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            context.l10n.logoutConfirmMessage,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          Row(
            children: [
              Expanded(
                child: DialogActionButton(
                  label: context.l10n.cancel,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: DialogActionButton(
                  label: context.l10n.confirm,
                  variant: DialogActionVariant.destructive,
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    context.read<AuthCubit>().signOut();
                    context.go(RouteNames.loginPath);
                  },
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
