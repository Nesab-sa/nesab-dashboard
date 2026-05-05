import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/features/profile/presentation/cubit/upload_signature_cubit.dart';
import 'package:nesab/features/profile/presentation/cubit/upload_signature_state.dart';
import 'package:nesab/features/profile/presentation/dialogs/glass_dialog.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_action_button.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_header.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_text_field.dart';

void showUploadSignatureDialog(BuildContext context) {
  final cubit = getIt<UploadSignatureCubit>();
  final picker = ImagePicker();
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  var controllersInitialized = false;

  cubit.loadSignature();

  showGlassDialog<void>(
    context: context,
    builder: (dialogContext) {
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
      final l10n = context.l10n;

      return BlocProvider.value(
        value: cubit,
        child: BlocConsumer<UploadSignatureCubit, UploadSignatureState>(
          listener: (_, state) {
            state.maybeWhen(
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
            final signaturePath = state.maybeWhen(
              success: (signaturePath, name, number) => signaturePath,
              orElse: () => null,
            );
            final savedName = state.maybeWhen(
              success: (signaturePath, name, number) => name,
              orElse: () => '',
            );
            final savedNumber = state.maybeWhen(
              success: (signaturePath, name, number) => number,
              orElse: () => '',
            );

            // Seed controllers once from the first real state so rebuilds
            // triggered by save-on-change don't recreate the field and kill
            // its focus after every keystroke.
            if (!controllersInitialized) {
              nameController.text = savedName;
              numberController.text = savedNumber;
              controllersInitialized = true;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogHeader(
                  title: l10n.profileUploadSignature,
                  onClose: () => Navigator.of(dialogContext).pop(),
                ),
                const SizedBox(height: AppDimensions.spacingXxl),
                DialogTextField(
                  controller: nameController,
                  labelText: l10n.signatureName,
                  hintText: l10n.signatureNameHint,
                  prefixIcon: Icons.person_outline,
                  accentColor: AppColors.purple600,
                  onChanged: (value) => cubit.saveName(value),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                DialogTextField(
                  controller: numberController,
                  labelText: l10n.signatureNumber,
                  hintText: l10n.signatureNumberHint,
                  prefixIcon: Icons.phone_outlined,
                  accentColor: AppColors.purple600,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => cubit.saveNumber(value),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                if (signaturePath != null) ...[
                  _SignaturePreview(
                    path: signaturePath,
                    isDark: isDark,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                ] else ...[
                  _SignaturePlaceholder(
                    isDark: isDark,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  Text(
                    isLoading
                        ? l10n.uploading
                        : l10n.profileUploadSignature,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppDimensions.spacingMd),
                DialogActionButton(
                  label: l10n.pickImage,
                  icon: Icons.photo_library_outlined,
                  isLoading: isLoading,
                  onTap: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (image == null) return;
                    cubit.uploadSignature(filePath: image.path);
                  },
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                DialogActionButton(
                  label: l10n.camera,
                  icon: Icons.camera_alt_outlined,
                  customColor: AppColors.purple600,
                  isLoading: isLoading,
                  onTap: () async {
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (image == null) return;
                    cubit.uploadSignature(filePath: image.path);
                  },
                ),
                if (signaturePath != null) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  DialogActionButton(
                    label: l10n.deleteSignature,
                    icon: Icons.delete_outline,
                    variant: DialogActionVariant.destructive,
                    isLoading: isLoading,
                    onTap: () => cubit.deleteSignature(),
                  ),
                ],
              ],
            );
          },
        ),
      );
    },
  ).whenComplete(() {
    nameController.dispose();
    numberController.dispose();
    cubit.close();
  });
}

class _SignaturePreview extends StatelessWidget {
  const _SignaturePreview({required this.path, required this.isDark});

  final String path;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark
              ? AppColors.purple600.withValues(alpha: 0.3)
              : AppColors.purple600.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Image.file(File(path), fit: BoxFit.contain),
    );
  }
}

class _SignaturePlaceholder extends StatelessWidget {
  const _SignaturePlaceholder({required this.isDark, required this.isLoading});

  final bool isDark;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.purple600.withValues(alpha: 0.15)
            : AppColors.purple100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(
          color: isDark
              ? AppColors.purple600.withValues(alpha: 0.3)
              : AppColors.purple600.withValues(alpha: 0.2),
        ),
      ),
      alignment: Alignment.center,
      child: isLoading
          ? const SizedBox(
              height: 32,
              width: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.purple600,
              ),
            )
          : const Icon(
              Icons.draw_outlined,
              size: 36,
              color: AppColors.purple600,
            ),
    );
  }
}
