import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// Scaffold wrapper used by all individual calculator pages.
class CalculatorPageScaffold extends StatelessWidget {
  const CalculatorPageScaffold({
    super.key,
    required this.title,
    required this.inputChildren,
    this.resultChildren = const [],
    required this.onCalculate,
    required this.onReset,
    this.showResults = false,
  });

  final String title;
  final List<Widget> inputChildren;
  final List<Widget> resultChildren;
  final VoidCallback onCalculate;
  final VoidCallback onReset;
  final bool showResults;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.dashboardTextPrimary
        : AppColors.lightModeTextPrimary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        final buttonRow = Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onCalculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSm,
                    ),
                  ),
                ),
                child: Text(context.l10n.calcCalculate),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: OutlinedButton(
                onPressed: onReset,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingMd,
                    horizontal: AppDimensions.spacingXxl,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusSm,
                    ),
                  ),
                ),
                child: Text(context.l10n.calcReset),
              ),
            ),
          ],
        );

        final inputColumn = isWide
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: inputChildren,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  buttonRow,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...inputChildren,
                  const SizedBox(height: AppDimensions.spacingLg),
                  buttonRow,
                ],
              );

        final resultColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: resultChildren,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingXxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXxl),
              if (isWide)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: inputColumn),
                      if (showResults) ...[
                        const SizedBox(width: AppDimensions.spacingXxl),
                        Expanded(child: resultColumn),
                      ],
                    ],
                  ),
                )
              else ...[
                inputColumn,
                if (showResults) ...[
                  const SizedBox(height: AppDimensions.spacingXxl),
                  resultColumn,
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
