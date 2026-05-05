import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/cubit/theme_cubit.dart';
import 'package:nesab/features/profile/presentation/dialogs/glass_dialog.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_header.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_option.dart';

void showThemePickerDialog(BuildContext context) {
  final cubit = context.read<ThemeCubit>();

  showGlassDialog(
    context: context,
    builder: (dialogContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: context.l10n.themeMode,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          for (final mode in ThemeMode.values)
            DialogOption(
              icon: switch (mode) {
                ThemeMode.system => Icons.brightness_auto,
                ThemeMode.light => Icons.light_mode,
                ThemeMode.dark => Icons.dark_mode,
              },
              iconColor: AppColors.purple600,
              label: _themeModeLabel(context, mode),
              isSelected: cubit.state.themeMode == mode,
              onTap: () {
                cubit.setTheme(mode);
                Navigator.of(dialogContext).pop();
              },
            ),
        ],
      );
    },
  );
}

String _themeModeLabel(BuildContext context, ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => context.l10n.themeModeLight,
    ThemeMode.dark => context.l10n.themeModeDark,
    ThemeMode.system => context.l10n.themeModeSystem,
  };
}
