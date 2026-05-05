import 'package:flutter/material.dart';
import 'package:nesab/app/app.dart';
import 'package:nesab/core/constants/app_assets.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_fonts.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/features/profile/presentation/dialogs/glass_dialog.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_header.dart';
import 'package:nesab/features/profile/presentation/widgets/glass_info_row.dart';
import 'package:url_launcher/url_launcher.dart';

void showAboutAppDialog(BuildContext context) {
  showGlassDialog(
    context: context,
    builder: (dialogContext) {
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
      final l10n = context.l10n;
      const accentColor = AppColors.blue;

      final features = [
        (Icons.calculate_outlined, l10n.aboutAppFeatureCalculator),
        (Icons.trending_up, l10n.aboutAppFeaturePlanning),
        (Icons.school_outlined, l10n.aboutAppFeatureGuidance),
        (Icons.verified_outlined, l10n.aboutAppFeatureSharia),
      ];

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: l10n.aboutApp,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              image: DecorationImage(
                image: AssetImage(
                  context.isDark
                      ? AppAssets.appLogoDark
                      : AppAssets.appLogoLight,
                ),
              ),
            ),
            alignment: Alignment.center,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            l10n.aboutAppName,
            style: AppTextStyles.headingSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            l10n.aboutAppTagline,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            l10n.aboutAppFullDescription,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.features,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          for (final (icon, label) in features) ...[
            GlassInfoRow(icon: icon, iconColor: accentColor, label: label),
            const SizedBox(height: AppDimensions.spacingSm),
          ],
          const SizedBox(height: AppDimensions.spacingLg),
          GlassInfoRow(
            icon: Icons.public,
            iconColor: AppColors.blue,
            label: l10n.aboutAppWebsite,
            onTap: () => launchUrl(
              Uri.parse('https://www.nesab.sa/'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            l10n.aboutVersion('1.0.0'),
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ),
        ],
      );
    },
  );
}
