import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/calculators/data/models/calculator_type.dart';

import 'calculator_type_pages.dart';

/// Main hub showing a grid of all available calculators.
class CalculatorsHubPage extends StatefulWidget {
  const CalculatorsHubPage({super.key});

  @override
  State<CalculatorsHubPage> createState() => _CalculatorsHubPageState();
}

class _CalculatorsHubPageState extends State<CalculatorsHubPage> {
  Widget? _activePage;

  void _openCalculator(Widget page) {
    setState(() => _activePage = page);
  }

  void _goBack() {
    setState(() => _activePage = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_activePage != null) {
      return Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppDimensions.spacingLg,
                left: AppDimensions.spacingXxl,
                right: AppDimensions.spacingXxl,
              ),
              child: TextButton.icon(
                onPressed: _goBack,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(context.l10n.calculatorsTitle),
              ),
            ),
          ),
          Expanded(child: _activePage!),
        ],
      );
    }

    return _HubGrid(onOpenCalculator: _openCalculator);
  }
}

class _HubGrid extends StatelessWidget {
  const _HubGrid({required this.onOpenCalculator});

  final void Function(Widget page) onOpenCalculator;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.dashboardTextPrimary
        : AppColors.lightModeTextPrimary;

    final items = _calculatorItems(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.calculatorsTitle,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            context.l10n.calculatorsSubtitle,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.dashboardTextSecondary
                  : AppColors.lightModeTextSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXxl),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossCount = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 600
                  ? 3
                  : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  mainAxisSpacing: AppDimensions.spacingLg,
                  crossAxisSpacing: AppDimensions.spacingLg,
                  childAspectRatio: 1.3,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _CalculatorCard(
                    title: item.title,
                    description: item.description,
                    icon: item.icon,
                    color: item.color,
                    onTap: () => onOpenCalculator(item.page),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  List<_CalcItem> _calculatorItems(BuildContext context) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context);
    final configs = _calculatorConfigs();
    return configs
        .map(
          (c) => _CalcItem(
            title: c.type.displayName(locale),
            description: _descriptionFor(l, c.type),
            icon: c.icon,
            color: c.color,
            page: c.type.page,
          ),
        )
        .toList();
  }

  static String _descriptionFor(dynamic l10n, CalculatorType type) {
    return switch (type) {
      CalculatorType.personalFinance => l10n.calcPersonalFinanceDesc,
      CalculatorType.personalFinanceQuick => l10n.calcPersonalFinanceQuickDesc,
      CalculatorType.debtPurchase => l10n.calcDebtPurchaseDesc,
      CalculatorType.realEstate => l10n.calcRealEstateDesc,
      CalculatorType.realEstatePlus => l10n.calcRealEstatePlusDesc,
      CalculatorType.leasingRegular => l10n.calcLeasingRegularDesc,
      CalculatorType.leasingMicro => l10n.calcLeasingMicroDesc,
      CalculatorType.posFinancing => l10n.calcPosFinancingDesc,
      CalculatorType.khairat => l10n.calcKhairatDesc,
      CalculatorType.protectionSavings => l10n.calcProtectionSavingsDesc,
      CalculatorType.ageCalculator => l10n.calcAgeCalculatorDesc,
      CalculatorType.dateConverter => l10n.calcDateConverterDesc,
      CalculatorType.deductions => l10n.calcDeductionsDesc,
      CalculatorType.bankFees => l10n.calcBankFeesDesc,
    };
  }

  static List<_CalcConfig> _calculatorConfigs() {
    return [
      _CalcConfig(
        type: CalculatorType.personalFinance,
        icon: FontAwesomeIcons.moneyBillWave,
        color: AppColors.categoryPersonalFinance,
      ),
      _CalcConfig(
        type: CalculatorType.personalFinanceQuick,
        icon: FontAwesomeIcons.bolt,
        color: AppColors.categoryPersonalFinanceLight,
      ),
      _CalcConfig(
        type: CalculatorType.debtPurchase,
        icon: FontAwesomeIcons.rightLeft,
        color: AppColors.blue600,
      ),
      _CalcConfig(
        type: CalculatorType.realEstate,
        icon: FontAwesomeIcons.building,
        color: AppColors.categoryRealEstate,
      ),
      _CalcConfig(
        type: CalculatorType.realEstatePlus,
        icon: FontAwesomeIcons.house,
        color: AppColors.categoryRealEstate,
      ),
      _CalcConfig(
        type: CalculatorType.leasingRegular,
        icon: FontAwesomeIcons.car,
        color: AppColors.categoryLeasing,
      ),
      _CalcConfig(
        type: CalculatorType.leasingMicro,
        icon: FontAwesomeIcons.carSide,
        color: AppColors.categoryLeasingLight,
      ),
      _CalcConfig(
        type: CalculatorType.posFinancing,
        icon: FontAwesomeIcons.cashRegister,
        color: AppColors.categoryPos,
      ),
      _CalcConfig(
        type: CalculatorType.khairat,
        icon: FontAwesomeIcons.piggyBank,
        color: AppColors.categoryCharity,
      ),
      _CalcConfig(
        type: CalculatorType.protectionSavings,
        icon: FontAwesomeIcons.shieldHalved,
        color: AppColors.purple600,
      ),
      _CalcConfig(
        type: CalculatorType.ageCalculator,
        icon: FontAwesomeIcons.cakeCandles,
        color: AppColors.categoryTools,
      ),
      _CalcConfig(
        type: CalculatorType.dateConverter,
        icon: FontAwesomeIcons.calendarDays,
        color: AppColors.categoryToolsLight,
      ),
      _CalcConfig(
        type: CalculatorType.deductions,
        icon: FontAwesomeIcons.percent,
        color: AppColors.warning,
      ),
      _CalcConfig(
        type: CalculatorType.bankFees,
        icon: FontAwesomeIcons.buildingColumns,
        color: AppColors.categoryRealEstateLight,
      ),
    ];
  }
}

class _CalcConfig {
  const _CalcConfig({
    required this.type,
    required this.icon,
    required this.color,
  });

  final CalculatorType type;
  final IconData icon;
  final Color color;
}

class _CalcItem {
  const _CalcItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.page,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget page;
}

class _CalculatorCard extends StatelessWidget {
  const _CalculatorCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.dashboardCard : AppColors.lightModeCard,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: isDark
                  ? AppColors.dashboardBorder
                  : AppColors.lightModeBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Center(child: FaIcon(icon, size: 18, color: color)),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.dashboardTextPrimary
                      : AppColors.lightModeTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.dashboardTextSecondary
                      : AppColors.lightModeTextSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
