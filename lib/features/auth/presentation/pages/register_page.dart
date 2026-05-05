import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nesab/core/constants/app_assets.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_fonts.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/core/utils/app_responsive.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:nesab/features/auth/presentation/widgets/social_login_row.dart';
import 'package:nesab/features/auth/presentation/widgets/terms_text.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
                const SizedBox(height: AppDimensions.spacingXxxl),

                // Logo
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
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
                    child: Image.asset(
                      context.isDark ? AppAssets.logoDark : AppAssets.logoLight,
                      width: 36,
                      height: 36,
                      color: AppColors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

                // Heading
                Text(
                  l10n.registerTitle,
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
                Text(
                  l10n.registerSubtitle,
                  style: TextStyle(
                    fontFamily: AppFonts.primary,
                    fontSize: AppResponsive.fontSize(context, 15),

                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxxl),

                // Display name field
                AuthTextField(
                  label: l10n.displayNameLabel,
                  hint: l10n.displayNameHint,
                  controller: _displayNameController,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Email field
                AuthTextField(
                  label: l10n.emailLabel,
                  hint: l10n.emailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Password field
                AuthTextField(
                  label: l10n.passwordLabel,
                  hint: l10n.passwordHint,
                  controller: _passwordController,
                  obscureText: true,
                  showObscureToggle: true,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: AppDimensions.spacingXxl),

                // Register button
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
                        onPressed: isLoading ? null : _onRegister,
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
                                l10n.registerButton,
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
                const SizedBox(height: AppDimensions.spacingXxl),

                // Divider
                _buildDivider(context),
                const SizedBox(height: AppDimensions.spacingXxl),

                // Social login
                SocialLoginRow(
                  onGooglePressed: () =>
                      context.read<AuthCubit>().signInWithGoogle(),
                  onApplePressed: () =>
                      context.read<AuthCubit>().signInWithApple(),
                ),
                const SizedBox(height: AppDimensions.spacingXxxl),

                // Already have account
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(RouteNames.loginPath),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppDimensions.spacingXs,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.login,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingLg),

                // Terms
                const Center(child: TermsText()),
                const SizedBox(height: AppDimensions.spacingXxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.borderDark : AppColors.border;

    return Row(
      children: [
        Expanded(child: Divider(color: dividerColor)),
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          child: Text(
            context.l10n.orLoginWith,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ),
        ),
        Expanded(child: Divider(color: dividerColor)),
      ],
    );
  }

  void _onRegister() {
    context.read<AuthCubit>().registerWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _displayNameController.text.trim(),
    );
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    state.whenOrNull(
      authenticated: (_) => context.go(RouteNames.homePath),
      error: (message) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message))),
    );
  }
}
