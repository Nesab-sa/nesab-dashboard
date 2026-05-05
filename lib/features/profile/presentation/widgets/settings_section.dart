import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/core/constants/app_assets.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/localization/cubit/locale_cubit.dart';
import 'package:nesab/core/localization/cubit/locale_state.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/core/theme/cubit/theme_cubit.dart';
import 'package:nesab/core/theme/cubit/theme_state.dart';
import 'package:nesab/core/utils/app_responsive.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';
import 'package:nesab/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:nesab/shared/widgets/animated_layout_switcher.dart';
import 'package:nesab/shared/widgets/glass.dart';
import 'package:nesab/shared/widgets/glass_card.dart';
import 'package:nesab/shared/widgets/view_mode_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsSection extends StatefulWidget {
  const SettingsSection({
    super.key,
    required this.user,
    required this.onEditDetails,
    required this.onThemePicker,
    required this.onLanguagePicker,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onAboutDeveloper,
    required this.onAboutApp,
    required this.onChangePassword,
    required this.onUploadSignature,
  });

  final UserEntity user;
  final VoidCallback onEditDetails;
  final VoidCallback onThemePicker;
  final VoidCallback onLanguagePicker;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final VoidCallback onAboutDeveloper;
  final VoidCallback onAboutApp;
  final VoidCallback onChangePassword;
  final VoidCallback onUploadSignature;

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  static const _viewModeKey = 'view_mode_is_grid';
  late bool _isGrid;

  @override
  void initState() {
    super.initState();
    _isGrid = getIt<SharedPreferences>().getBool(_viewModeKey) ?? true;
  }

  void _setViewMode(bool isGrid) {
    setState(() => _isGrid = isGrid);
    getIt<SharedPreferences>().setBool(_viewModeKey, isGrid);
  }

  List<_SettingsItemData> _buildItems() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trailingColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return [
      _SettingsItemData(
        imageAsset: AppAssets.web,
        label: context.l10n.profileWebsite,
        iconColor: AppColors.blue,
        onTap: () => launchUrl(
          Uri.parse('https://www.nesab.sa/'),
          mode: LaunchMode.externalApplication,
        ),
      ),
      _SettingsItemData(
        imageAsset: AppAssets.developer,
        label: context.l10n.developerTitle,
        iconColor: AppColors.purple600,
        onTap: widget.onAboutDeveloper,
      ),
      _SettingsItemData(
        imageAsset: AppAssets.about,
        label: context.l10n.aboutApp,
        iconColor: AppColors.blue600,
        onTap: widget.onAboutApp,
      ),
      if (widget.user.authProvider == AppAuthProvider.email)
        _SettingsItemData(
          imageAsset: AppAssets.password,
          label: context.l10n.changePassword,
          iconColor: AppColors.warning,
          onTap: widget.onChangePassword,
        ),
      if (widget.user.email != null)
        _SettingsItemData(
          imageAsset: AppAssets.deleteAccount,
          label: context.l10n.deleteAccount,
          iconColor: AppColors.error,
          onTap: widget.onDeleteAccount,
        ),

      _SettingsItemData(
        imageAsset: AppAssets.updateInfo,
        label: context.l10n.editDetails,
        iconColor: AppColors.blue,
        onTap: widget.onEditDetails,
      ),
      _SettingsItemData(
        imageAsset: AppAssets.language,
        label: context.l10n.language,
        iconColor: AppColors.blue,
        onTap: widget.onLanguagePicker,
        trailingBuilder: (ctx) => BlocBuilder<LocaleCubit, LocaleState>(
          builder: (_, state) => Text(
            _localeLabel(ctx, state.locale),
            style: AppTextStyles.caption.copyWith(color: trailingColor),
          ),
        ),
      ),
      _SettingsItemData(
        imageAsset: AppAssets.uploadYourSign,
        label: context.l10n.profileUploadSignature,
        iconColor: AppColors.purple600,
        onTap: widget.onUploadSignature,
      ),
      _SettingsItemData(
        imageAsset: AppAssets.settings,
        label: context.l10n.themeMode,
        iconColor: AppColors.purple600,
        onTap: widget.onThemePicker,
        trailingBuilder: (ctx) => BlocBuilder<ThemeCubit, ThemeState>(
          builder: (_, state) => Text(
            _themeModeLabel(ctx, state.themeMode),
            style: AppTextStyles.caption.copyWith(color: trailingColor),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _buildItems();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [ViewModeToggle(isGrid: _isGrid, onChanged: _setViewMode)],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        AnimatedLayoutSwitcher(
          isGrid: _isGrid,
          gridCrossAxisCount: AppResponsive.numberOfGrid(context),
          gridSpacing: AppDimensions.spacingMd,
          gridAspectRatio: 0.9,
          listItemHeight: 68,
          listSpacing: 10,
          itemCount: items.length,
          itemBuilder: (context, index, metrics) {
            return _MorphingSettingsCard(
              item: items[index],
              metrics: metrics,
              isDark: isDark,
            );
          },
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        GlassEffect(
          child: ProfileMenuItem(
            icon: Icons.logout,
            label: context.l10n.logout,
            isDestructive: true,
            onTap: widget.onLogout,
          ),
        ),
      ],
    );
  }

  String _themeModeLabel(BuildContext context, ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => context.l10n.themeModeLight,
      ThemeMode.dark => context.l10n.themeModeDark,
      ThemeMode.system => context.l10n.themeModeSystem,
    };
  }

  String _localeLabel(BuildContext context, Locale locale) {
    return switch (locale.languageCode) {
      'ar' => context.l10n.languageArabic,
      'en' => context.l10n.languageEnglish,
      _ => context.l10n.languageArabic,
    };
  }
}

class _SettingsItemData {
  const _SettingsItemData({
    required this.imageAsset,
    required this.label,
    required this.iconColor,
    required this.onTap,
    this.trailingBuilder,
  });

  final String imageAsset;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  final Widget Function(BuildContext)? trailingBuilder;
}

class _MorphingSettingsCard extends StatelessWidget {
  const _MorphingSettingsCard({
    required this.item,
    required this.metrics,
    required this.isDark,
  });

  final _SettingsItemData item;
  final LayoutMetrics metrics;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final t = metrics.t;

    iconWidget([double? defaultWidth, double? defaultHeight]) => ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Image.asset(
        item.imageAsset,
        fit: BoxFit.contain,
        width: defaultWidth,
        height: defaultHeight ?? defaultWidth,
      ),
    );

    return GlassCard(
      onTap: item.onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isGrid = constraints.maxWidth > context.screenWidth * 0.5;
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Align(
                alignment: AlignmentDirectional.lerp(
                  const AlignmentDirectional(0.0, -1),
                  const AlignmentDirectional(-1.0, 0.0),
                  t,
                )!,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: lerpDouble(0, 12, t)!,
                  ),
                  child: iconWidget(
                    isGrid
                        ? constraints.maxWidth * 0.17
                        : constraints.maxHeight * 0.7,
                  ),
                ),
              ),
              if (t < 0.6)
                Opacity(
                  opacity: (1.0 - t * 2.5).clamp(0.0, 1.0),
                  child: Align(
                    alignment: const AlignmentDirectional(0.1, 0.69),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 4,
                      ),
                      child: Text(
                        item.label,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize:
                              6 *
                              (AppResponsive.numberOfGrid(context).toDouble() /
                                  1.5),
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              if (t > 0.3)
                Opacity(
                  opacity: ((t - 0.3) / 0.4).clamp(0.0, 1.0),
                  child: Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 80,
                        end: 12,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 150),
                          Expanded(
                            child: Text(
                              item.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.trailingBuilder != null) ...[
                            const SizedBox(width: AppDimensions.spacingSm),
                            item.trailingBuilder!(context),
                          ],
                          const SizedBox(width: AppDimensions.spacingSm),
                          Icon(
                            Icons.chevron_right,
                            color: isDark
                                ? AppColors.textDisabledDark
                                : AppColors.textDisabledLight,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
