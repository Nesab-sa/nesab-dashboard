import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:nesab/features/profile/presentation/cubit/edit_profile_state.dart';
import 'package:nesab/features/profile/presentation/dialogs/glass_dialog.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_action_button.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_header.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_text_field.dart';

void showEditDetailsDialog(BuildContext context, UserEntity user) {
  final nameController = TextEditingController(text: user.displayName ?? '');
  final editCubit = getIt<EditProfileCubit>();

  showGlassDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: editCubit,
        child: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: (_, state) {
            state.maybeWhen(
              success: (_) {
                Navigator.of(dialogContext).pop();
                context.read<AuthCubit>().checkAuth();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.profileUpdated),
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
                  title: context.l10n.editDetails,
                  onClose: () {
                    Navigator.of(dialogContext).pop();
                    editCubit.close();
                  },
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                DialogTextField(
                  controller: nameController,
                  enabled: !isLoading,
                  labelText: context.l10n.displayNameLabel,
                  hintText: context.l10n.displayNameHint,
                ),
                const SizedBox(height: AppDimensions.spacingXxl),
                Row(
                  children: [
                    Expanded(
                      child: DialogActionButton(
                        label: context.l10n.cancel,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          editCubit.close();
                        },
                        isLoading: isLoading,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: DialogActionButton(
                        label: context.l10n.saveChanges,
                        variant: DialogActionVariant.primary,
                        isLoading: isLoading,
                        onTap: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty || name.length < 2) return;
                          if (name == user.displayName) {
                            Navigator.of(dialogContext).pop();
                            editCubit.close();
                            return;
                          }
                          editCubit.updateProfile(displayName: name);
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
