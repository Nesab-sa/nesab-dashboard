import 'package:flutter/material.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_fonts.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/features/profile/presentation/dialogs/glass_dialog.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_header.dart';
import 'package:nesab/features/profile/presentation/widgets/glass_info_row.dart';
import 'package:url_launcher/url_launcher.dart';

void showAboutDeveloperDialog(BuildContext context) {
  showGlassDialog(
    context: context,
    builder: (dialogContext) {
      final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
      final l10n = context.l10n;
      const accentColor = AppColors.purple600;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: l10n.developerTitle,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [accentColor, AppColors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: const Text(
              'ع',
              style: TextStyle(
                fontFamily: AppFonts.primary,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          Text(
            l10n.developerName,
            style: AppTextStyles.headingSmall.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            l10n.developerRole,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          GlassInfoRow(
            icon: Icons.email_outlined,
            iconColor: AppColors.gmail,
            label: l10n.developerEmail,
            onTap: () => launchUrl(
              Uri.parse('mailto:Abdullahalmalki@nesab.sa'),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          GlassInfoRow(
            icon: Icons.language,
            iconColor: AppColors.blue,
            label: l10n.developerWebsite,
            onTap: () => launchUrl(
              Uri.parse('https://www.nesab.sa/'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
      );
    },
  );
}
