import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_fonts.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/core/utils/app_responsive.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: _onStateChanged,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppDimensions.screenPaddingHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spacingMd),

                // Back button
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.gray800,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

                // Lock icon
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.blue.withValues(alpha: 0.15)
                          : AppColors.blue50,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXl,
                      ),
                      border: Border.all(
                        color: isDark
                            ? AppColors.blue.withValues(alpha: 0.3)
                            : AppColors.blue100,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.lock_reset,
                      size: 36,
                      color: AppColors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

                // Heading
                Center(
                  child: Text(
                    l10n.forgotPasswordTitle,
                    style: TextStyle(
                      fontFamily: AppFonts.primary,
                      fontSize: AppResponsive.fontSize(context, 28),
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.gray800,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Center(
                  child: Text(
                    l10n.forgotPasswordSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontSize: AppResponsive.fontSize(context, 12),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxxl),

                // Email field
                AuthTextField(
                  label: l10n.emailLabel,
                  hint: l10n.emailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

                // Send reset link button
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    );
                    final primaryColor = Theme.of(context).colorScheme.primary;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSendResetLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: primaryColor.withValues(
                            alpha: 0.5,
                          ),
                          padding: const EdgeInsetsDirectional.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusLg,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.sendResetLink,
                                style: const TextStyle(
                                  fontFamily: AppFonts.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSendResetLink() {
    context.read<AuthCubit>().resetPassword(
      email: _emailController.text.trim(),
    );
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    state.whenOrNull(
      resetLinkSent: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.resetLinkSent,)));
        context.pop();
      },
      error: (message) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message))),
    );
  }
}
