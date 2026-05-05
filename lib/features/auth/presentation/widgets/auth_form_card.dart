import 'package:flutter/material.dart';

import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:nesab/shared/widgets/app_button.dart';

/// The mode in which [AuthFormCard] is displayed.
enum AuthFormMode {
  /// Email + password fields with a "Forgot password?" link.
  login,

  /// Display name + email + password fields.
  register,
}

/// A reusable card containing email/password fields and a submit button.
///
/// In [AuthFormMode.login], shows email, password, and an optional
/// "Forgot password?" link. In [AuthFormMode.register], adds a display
/// name field above the email field.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    required this.mode,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    this.displayNameController,
    this.onForgotPassword,
    this.isLoading = false,
    super.key,
  });

  /// Whether this form is for login or registration.
  final AuthFormMode mode;

  /// Controller for the email text field.
  final TextEditingController emailController;

  /// Controller for the password text field.
  final TextEditingController passwordController;

  /// Controller for the display name field (register mode only).
  final TextEditingController? displayNameController;

  /// Called when the submit button is pressed.
  final VoidCallback onSubmit;

  /// Called when the "Forgot password?" link is tapped (login mode only).
  final VoidCallback? onForgotPassword;

  /// Whether the form is in a loading state.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        side: BorderSide(color: context.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppDimensions.spacingXxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mode == AuthFormMode.register) ...[
              AuthTextField(
                label: l10n.displayNameLabel,
                hint: l10n.displayNameHint,
                controller: displayNameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: AppDimensions.spacingLg),
            ],
            AuthTextField(
              label: l10n.emailLabel,
              hint: l10n.emailHint,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            AuthTextField(
              label: l10n.passwordLabel,
              hint: l10n.passwordHint,
              controller: passwordController,
              obscureText: true,
              showObscureToggle: true,
              textDirection: TextDirection.ltr,
            ),
            if (mode == AuthFormMode.login && onForgotPassword != null) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: onForgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsetsDirectional.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.forgotPassword,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.spacingXxl),
            AppButton(
              label: mode == AuthFormMode.login
                  ? l10n.loginButton
                  : l10n.registerButton,
              onPressed: onSubmit,
              isLoading: isLoading,
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}
