import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/core/utils/app_validators.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:nesab/shared/widgets/custom_button.dart';

enum AuthFormMode { login, signUp, resetPassword }

class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.emailController,
    this.passwordController,
    this.nameController,
    this.mode = AuthFormMode.login,
    this.onModeChanged,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController? passwordController;
  final TextEditingController? nameController;
  final AuthFormMode mode;
  final ValueChanged<AuthFormMode>? onModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final onSurface = theme.colorScheme.onSurface;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          padding: const EdgeInsetsDirectional.all(AppDimensions.spacingXxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button + Title row
              Row(
                children: [
                  _CloseButton(onTap: () => Navigator.of(context).pop()),
                  Expanded(
                    child: Text(
                      _title(l10n),
                      style: AppTextStyles.headingSmall.copyWith(
                        color: onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.iconLg),
                ],
              ),

              // Subtitle for reset password
              if (mode == AuthFormMode.resetPassword) ...[
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  l10n.forgotPasswordSubtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppDimensions.spacingXxl),

              // Name field (sign up only)
              if (mode == AuthFormMode.signUp) ...[
                AuthTextField(
                  label: l10n.displayNameLabel,
                  hint: l10n.displayNameHint,
                  controller: nameController,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: AppDimensions.spacingLg),
              ],

              // Email field (all modes)
              AuthTextField(
                label: l10n.emailLabel,
                hint: l10n.emailHint,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
              ),

              // Password field (login & sign up)
              if (mode != AuthFormMode.resetPassword) ...[
                const SizedBox(height: AppDimensions.spacingLg),
                AuthTextField(
                  label: l10n.passwordLabel,
                  hint: l10n.passwordHint,
                  controller: passwordController,
                  obscureText: true,
                  showObscureToggle: true,
                  textDirection: TextDirection.ltr,
                ),
              ],

              // Forgot password (login only)
              if (mode == AuthFormMode.login) ...[
                const SizedBox(height: AppDimensions.spacingSm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onModeChanged?.call(AuthFormMode.resetPassword);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsetsDirectional.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.forgotPassword,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppDimensions.spacingXxl),

              // Action button
              BlocBuilder<AuthCubit, AuthState>(
                builder: (ctx, state) {
                  final isLoading = state.maybeWhen(
                    loading: () => true,
                    orElse: () => false,
                  );

                  return CustomButton(
                    text: _buttonLabel(l10n),
                    isLoading: isLoading,
                    onPressed: () => _onSubmit(ctx, l10n),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _title(dynamic l10n) => switch (mode) {
        AuthFormMode.login => l10n.loginTitle,
        AuthFormMode.signUp => l10n.registerTitle,
        AuthFormMode.resetPassword => l10n.forgotPasswordTitle,
      };

  String _buttonLabel(dynamic l10n) => switch (mode) {
        AuthFormMode.login => l10n.loginButton,
        AuthFormMode.signUp => l10n.registerButton,
        AuthFormMode.resetPassword => l10n.sendResetLink,
      };

  String? _mapValidationKey(String? key, dynamic l10n) {
    if (key == null) return null;
    return switch (key) {
      'emailRequired' => l10n.validationEmailRequired,
      'emailInvalid' => l10n.validationEmailInvalid,
      'passwordRequired' => l10n.validationPasswordRequired,
      'passwordTooShort' => l10n.validationPasswordTooShort,
      'nameRequired' => l10n.validationNameRequired,
      'nameTooShort' => l10n.validationNameTooShort,
      'fieldRequired' => l10n.validationFieldRequired,
      _ => key,
    };
  }

  void _onSubmit(BuildContext context, dynamic l10n) {
    final email = emailController.text.trim();

    // Validate email
    final emailError = AppValidators.email(email);
    if (emailError != null) {
      _showError(context, _mapValidationKey(emailError, l10n) ?? '');
      return;
    }

    // Validate name (sign up)
    if (mode == AuthFormMode.signUp) {
      final nameError = AppValidators.name(nameController?.text);
      if (nameError != null) {
        _showError(context, _mapValidationKey(nameError, l10n) ?? '');
        return;
      }
    }

    // Validate password (login & sign up)
    if (mode != AuthFormMode.resetPassword) {
      final passwordError = AppValidators.password(passwordController?.text);
      if (passwordError != null) {
        _showError(context, _mapValidationKey(passwordError, l10n) ?? '');
        return;
      }
    }

    final cubit = context.read<AuthCubit>();

    switch (mode) {
      case AuthFormMode.login:
        cubit.signInWithEmail(
          email: email,
          password: passwordController!.text,
        );
      case AuthFormMode.signUp:
        cubit.registerWithEmail(
          email: email,
          password: passwordController!.text,
          displayName: nameController?.text.trim() ?? '',
        );
      case AuthFormMode.resetPassword:
        cubit.resetPassword(email: email);
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimensions.iconLg,
        height: AppDimensions.iconLg,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08),
        ),
        child: Icon(
          Icons.close,
          color: onSurface,
          size: AppDimensions.iconSm,
        ),
      ),
    );
  }
}
