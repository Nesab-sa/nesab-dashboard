import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab/features/profile/presentation/dialogs/glass_dialog.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_action_button.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_header.dart';

void showDeleteAccountDialog(BuildContext context) {
  showGlassDialog(
    context: context,
    builder: (dialogContext) {
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: context.l10n.deleteAccountTitle,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            context.l10n.deleteAccountMessage,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.8,
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
                  label: context.l10n.deleteAccountConfirm,
                  variant: DialogActionVariant.destructive,
                  onTap: () async {
                    final authCubit = context.read<AuthCubit>();
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(dialogContext).pop();
                    await authCubit.deleteAccount();
                    if (!context.mounted) return;
                    final state = authCubit.state;
                    state.maybeWhen(
                      unauthenticated: () =>
                          context.go(RouteNames.loginPath),
                      error: (message) => messenger.showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: AppColors.error,
                        ),
                      ),
                      orElse: () {},
                    );
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
