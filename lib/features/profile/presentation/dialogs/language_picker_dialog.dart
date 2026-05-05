import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/localization/cubit/locale_cubit.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/features/profile/presentation/dialogs/glass_dialog.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_header.dart';
import 'package:nesab/features/profile/presentation/widgets/dialog_option.dart';

void showLanguagePickerDialog(BuildContext context) {
  final cubit = context.read<LocaleCubit>();
  final languages = [
    (locale: const Locale('ar'), label: context.l10n.languageArabic),
    (locale: const Locale('en'), label: context.l10n.languageEnglish),
  ];

  showGlassDialog(
    context: context,
    builder: (dialogContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DialogHeader(
            title: context.l10n.language,
            onClose: () => Navigator.of(dialogContext).pop(),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          for (final lang in languages)
            DialogOption(
              icon: Icons.language,
              iconColor: AppColors.blue,
              label: lang.label,
              isSelected: cubit.state.locale.languageCode ==
                  lang.locale.languageCode,
              onTap: () {
                cubit.setLocale(lang.locale);
                Navigator.of(dialogContext).pop();
              },
            ),
        ],
      );
    },
  );
}
