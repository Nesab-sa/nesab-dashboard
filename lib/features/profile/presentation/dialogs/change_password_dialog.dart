import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/features/profile/presentation/cubit/change_password_cubit.dart';
import 'package:nesab/features/profile/presentation/cubit/change_password_state.dart';
import 'package:nesab/features/profile/presentation/dialogs/glass_dialog.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_action_button.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_header.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_text_field.dart';

void showChangePasswordDialog(BuildContext context) {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final cubit = getIt<ChangePasswordCubit>();

  showGlassDialog(
    context: context,
    builder: (dialogContext) {
      final l10n = context.l10n;

      return BlocProvider.value(
        value: cubit,
        child: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
          listener: (_, state) {
            state.maybeWhen(
              success: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.passwordChanged),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              error: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              orElse: () {},
            );
          },
          builder: (_, state) {
            final isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogHeader(
                  title: l10n.changePassword,
                  onClose: () {
                    Navigator.of(dialogContext).pop();
                    cubit.close();
                  },
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                DialogTextField(
                  controller: currentPasswordController,
                  enabled: !isLoading,
                  obscureText: true,
                  textDirection: TextDirection.ltr,
                  labelText: l10n.currentPassword,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                DialogTextField(
                  controller: newPasswordController,
                  enabled: !isLoading,
                  obscureText: true,
                  textDirection: TextDirection.ltr,
                  labelText: l10n.newPassword,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                DialogTextField(
                  controller: confirmPasswordController,
                  enabled: !isLoading,
                  obscureText: true,
                  textDirection: TextDirection.ltr,
                  labelText: l10n.confirmNewPassword,
                ),
                const SizedBox(height: AppDimensions.spacingXxl),
                Row(
                  children: [
                    Expanded(
                      child: DialogActionButton(
                        label: l10n.cancel,
                        isLoading: isLoading,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          cubit.close();
                        },
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: DialogActionButton(
                        label: l10n.saveChanges,
                        variant: DialogActionVariant.primary,
                        isLoading: isLoading,
                        onTap: () {
                          final newPass = newPasswordController.text.trim();
                          final confirmPass =
                              confirmPasswordController.text.trim();
                          if (newPass.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.passwordTooShort),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          if (newPass != confirmPass) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.passwordsDoNotMatch),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          cubit.changePassword(
                            currentPassword:
                                currentPasswordController.text.trim(),
                            newPassword: newPass,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
