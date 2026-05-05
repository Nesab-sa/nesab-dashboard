import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/core/constants/app_assets.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/features/auth/presentation/widgets/terms_text.dart';
import 'package:nesab/shared/widgets/app_image.dart';
import 'package:nesab/shared/widgets/custom_button.dart';
import 'package:nesab/shared/widgets/theme_toggle_button.dart';

const String kOnboardingSeenKey = 'has_seen_onboarding';

bool hasSeenOnboarding() {
  return getIt<SharedPreferences>().getBool(kOnboardingSeenKey) ?? false;
}

Future<void> _markOnboardingSeen() {
  return getIt<SharedPreferences>().setBool(kOnboardingSeenKey, true);
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> _onStart(BuildContext context) async {
    await _markOnboardingSeen();
    if (!context.mounted) return;
    context.go(RouteNames.loginPath);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText = isDark
        ? theme.textTheme.bodySmall!.color
        : AppColors.textSecondaryLight;

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppDimensions.screenPaddingHorizontal,
            ),
            child: Column(
              children: [
                const Spacer(),
                AppImage(
                  path: context.isDark
                      ? AppAssets.logoDark
                      : AppAssets.logoLight,
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  l10n.appDescription,
                  style: AppTextStyles.bodySmall.copyWith(color: secondaryText),
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 2),
                CustomButton(
                  text: l10n.onboardingStart,
                  onPressed: () => _onStart(context),
                ),
                const SizedBox(height: AppDimensions.spacingLg),
                const TermsText(),
                const SizedBox(height: AppDimensions.spacingXxl),
              ],
            ),
          ),
          const PositionedDirectional(
            top: 0,
            start: 0,
            child: ThemeToggleButton(),
          ),
        ],
      ),
    );
  }
}
