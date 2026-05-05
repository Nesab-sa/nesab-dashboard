import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple_sign_in;

import 'package:nesab/core/constants/app_assets.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab/features/auth/presentation/widgets/login_form.dart';
import 'package:nesab/shared/widgets/app_image.dart';
import 'package:nesab/shared/widgets/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isIos = theme.platform == TargetPlatform.iOS;
    final onSurface = theme.colorScheme.onSurface;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final dividerColor = isDark ? AppColors.borderDark : AppColors.border;

    return BlocListener<AuthCubit, AuthState>(
      listener: _onStateChanged,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AppImage(
                  path: context.isDark
                      ? AppAssets.logoDark
                      : AppAssets.logoLight,
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: AppDimensions.spacingMd),

                // Welcome heading
                Text(
                  l10n.loginTitle,
                  style: AppTextStyles.headingMedium.copyWith(color: onSurface),
                ),
                const SizedBox(height: AppDimensions.spacingSm),

                // Subtitle
                Text(
                  l10n.appDescription,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: secondaryText,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXxxl * 1.5),

                // Email button (gradient border)
                CustomButton(
                  icon: const Icon(
                    Icons.mail_outlined,
                    color: Colors.black,
                    size: AppDimensions.iconLg,
                  ),
                  text: l10n.continueWithEmail,
                  onPressed: () => _showAuthFrom(AuthFormMode.signUp),
                ),
                const SizedBox(height: AppDimensions.spacingMd),

                // Google button
                _AuthMethodButton(
                  icon: const AppImage(
                    path: AppAssets.googleIcon,
                    width: 20,
                    height: 20,
                  ),
                  label: l10n.loginWithGoogle,
                  onTap: () => context.read<AuthCubit>().signInWithGoogle(),
                ),
                const SizedBox(height: AppDimensions.spacingMd),

                // Apple button (iOS only)
                if (isIos) ...[
                  SizedBox(
                    width: context.screenWidth * 0.75,
                    child: apple_sign_in.SignInWithAppleButton(
                      text: l10n.loginWithApple,
                      height: AppDimensions.buttonHeightLg,
                      style: isDark
                          ? apple_sign_in.SignInWithAppleButtonStyle.white
                          : apple_sign_in.SignInWithAppleButtonStyle.black,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXxl28,
                      ),
                      iconAlignment: apple_sign_in.IconAlignment.left,
                      onPressed: () =>
                          context.read<AuthCubit>().signInWithApple(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                ],
                const SizedBox(height: AppDimensions.spacingLg),

                // "or" divider
                Row(
                  children: [
                    Expanded(child: Divider(color: dividerColor, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingMd,
                      ),
                      child: Text(
                        l10n.orText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryText,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: dividerColor, thickness: 1)),
                  ],
                ),

                const SizedBox(height: AppDimensions.spacingLg),

                // Already have an account?
                Text(
                  l10n.alreadyHaveAccount,
                  style: AppTextStyles.bodyMedium.copyWith(color: onSurface),
                ),
                const SizedBox(height: AppDimensions.spacingMd),

                // Sign in button
                _AuthMethodButton(
                  label: l10n.signIn,
                  onTap: () => _showAuthFrom(),
                ),
                const SizedBox(height: AppDimensions.spacingXxxl),
              ],
            ),
          ),
        ),
      ),
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

  void _showAuthFrom([AuthFormMode mode = AuthFormMode.login]) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (dialogContext, animation, secondaryAnimation) =>
          BlocProvider.value(
            value: context.read<AuthCubit>(),
            child: Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppDimensions.spacingLg,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: LoginForm(
                    mode: mode,
                    nameController: mode == AuthFormMode.signUp
                        ? TextEditingController()
                        : null,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onModeChanged: _showAuthFrom,
                  ),
                ),
              ),
            ),
          ),
    );
  }
}

class _AuthMethodButton extends StatelessWidget {
  const _AuthMethodButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final Widget? icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.screenWidth * 0.75,
        height: AppDimensions.buttonHeightLg,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl28),
          border: isDark ? null : Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: AppDimensions.spacingSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: AppDimensions.spacingMd),
            ],
            Text(
              label,
              style: AppTextStyles.buttonLarge.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// // ─── Sign In Bottom Sheet ──────────────────────────────────────────────────

// class _SignInBottomSheet extends StatelessWidget {
//   const _SignInBottomSheet({
//     required this.emailController,
//     required this.passwordController,
//   });

//   final TextEditingController emailController;
//   final TextEditingController passwordController;

//   @override
//   Widget build(BuildContext context) {
//     final l10n = context.l10n;

//     return Container(
//       decoration: const BoxDecoration(
//         color: AppColors.surfaceDark,
//         borderRadius: BorderRadiusDirectional.only(
//           topStart: Radius.circular(AppDimensions.radiusXxl),
//           topEnd: Radius.circular(AppDimensions.radiusXxl),
//         ),
//       ),
//       padding: EdgeInsetsDirectional.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//         start: AppDimensions.screenPaddingHorizontal,
//         end: AppDimensions.screenPaddingHorizontal,
//         top: AppDimensions.spacingXxl,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Handle bar
//           Container(
//             width: 40,
//             height: 4,
//             decoration: BoxDecoration(
//               color: AppColors.borderDark,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingXxl),

//           // Title
//           Text(
//             l10n.loginTitle,
//             style: AppTextStyles.headingSmall.copyWith(
//               color: AppColors.textPrimaryDark,
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingXxl),

//           // Email field
//           AuthTextField(
//             label: l10n.emailLabel,
//             hint: l10n.emailHint,
//             controller: emailController,
//             keyboardType: TextInputType.emailAddress,
//             textDirection: TextDirection.ltr,
//           ),
//           const SizedBox(height: AppDimensions.spacingLg),

//           // Password field
//           AuthTextField(
//             label: l10n.passwordLabel,
//             hint: l10n.passwordHint,
//             controller: passwordController,
//             obscureText: true,
//             showObscureToggle: true,
//             textDirection: TextDirection.ltr,
//           ),
//           const SizedBox(height: AppDimensions.spacingSm),

//           // Forgot password
//           Align(
//             alignment: AlignmentDirectional.centerStart,
//             child: TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 context.go(RouteNames.forgotPasswordPath);
//               },
//               style: TextButton.styleFrom(
//                 padding: EdgeInsetsDirectional.zero,
//                 minimumSize: Size.zero,
//                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               ),
//               child: Text(
//                 l10n.forgotPassword,
//                 style: AppTextStyles.labelSmall.copyWith(color: AppColors.blue),
//               ),
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingXxl),

//           // Login button
//           BlocBuilder<AuthCubit, AuthState>(
//             builder: (ctx, state) {
//               final isLoading = state.maybeWhen(
//                 loading: () => true,
//                 orElse: () => false,
//               );

//               return SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: isLoading
//                       ? null
//                       : () {
//                           ctx.read<AuthCubit>().signInWithEmail(
//                             email: emailController.text.trim(),
//                             password: passwordController.text,
//                           );
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.blue,
//                     foregroundColor: Colors.white,
//                     disabledBackgroundColor: AppColors.blue.withValues(
//                       alpha: 0.5,
//                     ),
//                     padding: const EdgeInsetsDirectional.symmetric(
//                       vertical: AppDimensions.spacingLg,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(
//                         AppDimensions.radiusLg,
//                       ),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: isLoading
//                       ? const SizedBox(
//                           height: 20,
//                           width: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Colors.white,
//                           ),
//                         )
//                       : Text(
//                           l10n.loginButton,
//                           style: AppTextStyles.buttonLarge.copyWith(
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(height: AppDimensions.spacingXxxl),
//         ],
//       ),
//     );
//   }
// }
