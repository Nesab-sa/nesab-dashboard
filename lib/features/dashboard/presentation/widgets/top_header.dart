import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab_dashboard/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab_dashboard/core/localization/cubit/locale_cubit.dart';
import 'package:nesab_dashboard/core/localization/cubit/locale_state.dart';
import 'package:nesab_dashboard/core/theme/cubit/theme_cubit.dart';

class TopHeader extends StatelessWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.dashboardBg : AppColors.lightModeBg;
    final textColor = isDark
        ? AppColors.dashboardTextPrimary
        : AppColors.lightModeTextPrimary;
    final hintColor = isDark
        ? AppColors.dashboardTextSecondary
        : AppColors.lightModeTextSecondary;
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.dashboardBorder
                : AppColors.lightModeBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 300) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      right: AppDimensions.spacingMd,
                    ),
                    child: SearchField(
                      hintText: 'Search',
                      hintColor: hintColor,
                      isDark: isDark,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          const SizedBox(width: AppDimensions.spacingMd),
          const LanguageToggleButton(),
          const SizedBox(width: AppDimensions.spacingSm),
          ThemeToggleButton(textColor: textColor),
          const SizedBox(width: AppDimensions.spacingSm),
          LogoutButton(textColor: textColor),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hintText,
    required this.hintColor,
    required this.isDark,
  });

  final String hintText;
  final Color hintColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        prefixIcon: Icon(Icons.search, size: 20, color: hintColor),
        filled: true,
        fillColor: isDark ? AppColors.dashboardCard : AppColors.lightModeCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
      ),
    );
  }
}

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.dashboardTextPrimary
        : AppColors.lightModeTextPrimary;

    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        final isArabic = localeState.locale.languageCode == 'ar';
        return IconButton(
          icon: Icon(Icons.language, color: textColor),
          onPressed: () {
            context.read<LocaleCubit>().setLocale(
              isArabic ? const Locale('en') : const Locale('ar'),
            );
          },
          tooltip: context.l10n.language,
        );
      },
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: textColor),
      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
      tooltip: context.l10n.themeMode,
    );
  }
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(FontAwesomeIcons.arrowRightFromBracket, color: textColor),
      onPressed: () => _showLogoutDialog(context),
      tooltip: context.l10n.logout,
    );
  }

  static Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.logoutConfirmTitle),
        content: Text(context.l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.logout),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<AuthCubit>().logout();
    }
  }
}
