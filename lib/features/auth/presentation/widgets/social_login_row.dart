import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart' as apple_sign_in;

import 'package:nesab/core/constants/app_assets.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/features/auth/presentation/widgets/social_login_button.dart';
import 'package:nesab/shared/widgets/app_image.dart';

/// A row of social login buttons (Google + Apple).
///
/// The Apple button is hidden on Android (detected via [Theme.platform]).
/// When only Google is shown, it renders full-width.
class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({
    required this.onGooglePressed,
    required this.onApplePressed,
    super.key,
  });

  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;

    if (!isIos) {
      return SocialLoginButton(
        label: context.l10n.loginWithGoogle,
        iconWidget: const AppImage(
          path: AppAssets.googleIcon,
          width: 20,
          height: 20,
        ),
        onPressed: onGooglePressed,
      );
    }

    return Column(
      children: [
        SocialLoginButton(
          label: context.l10n.loginWithGoogle,
          iconWidget: const AppImage(
            path: AppAssets.googleIcon,
            width: 20,
            height: 20,
          ),
          onPressed: onGooglePressed,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        SizedBox(
          width: double.infinity,
          child: apple_sign_in.SignInWithAppleButton(
            text: context.l10n.loginWithApple,
            height: AppDimensions.buttonHeightLg,
            style: Theme.of(context).brightness == Brightness.dark
                ? apple_sign_in.SignInWithAppleButtonStyle.white
                : apple_sign_in.SignInWithAppleButtonStyle.black,
            borderRadius: BorderRadius.circular(AppDimensions.radiusNav),
            iconAlignment: apple_sign_in.IconAlignment.left,
            onPressed: onApplePressed,
          ),
        ),
      ],
    );
  }
}
