import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/protection_savings_calculator.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_export_buttons.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_field.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_scaffold.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_result_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_sub_section.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_grid_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/result_section_header.dart';

String _fmt(num n) => NumberFormat('#,##0', 'en_US').format(n.round());

// ---------------------------------------------------------------------------
// ProtectionSavingsPage
// ---------------------------------------------------------------------------
class ProtectionSavingsPage extends StatefulWidget {
  const ProtectionSavingsPage({super.key});

  @override
  State<ProtectionSavingsPage> createState() => _ProtectionSavingsPageState();
}

class _ProtectionSavingsPageState extends State<ProtectionSavingsPage> {
  // Controllers
  final _subAmtCtrl = TextEditingController(text: '250000');
  final _ageCtrl = TextEditingController(text: '35');

  // State
  int _progYears = 3;
  InvestmentStrategy _strategy = InvestmentStrategy.balanced;
  ProtectionSavingsResult? _result;

  final _resultKey = GlobalKey();

  @override
  void dispose() {
    _subAmtCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Calculate
  // -----------------------------------------------------------------------
  void _calculate() {
    final sub = double.tryParse(_subAmtCtrl.text) ?? 250000;
    final age = int.tryParse(_ageCtrl.text) ?? 35;

    final input = ProtectionSavingsInput(
      subscriptionAmount: sub,
      programDurationYears: _progYears,
      strategy: _strategy,
      age: age,
    );

    setState(
        () => _result = const ProtectionSavingsCalculator().calculate(input));
  }

  // -----------------------------------------------------------------------
  // AI context builder
  // -----------------------------------------------------------------------
  String _buildAiContext() {
    final d = _result;
    if (d == null) return '';
    return 'برنامج حماية وادخار: اشتراك ${_fmt(d.subscriptionAmount)} ريال، '
        'مدة ${d.years} سنة، معدل ${(d.rate * 100).toStringAsFixed(0)}%، '
        'قيمة نقدية ${_fmt(d.finalCashValue)} ريال، '
        'تغطية ${_fmt(d.coverage)} ريال';
  }

  // -----------------------------------------------------------------------
  // Build sections
  // -----------------------------------------------------------------------
  Widget _buildInputCard() => CalculatorNeonCard(children: [
        const ResultSectionHeader(title: 'بيانات البرنامج'),
        CalculatorSubSection(title: 'الاشتراك والمدة', children: [
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'مبلغ الاشتراك (ريال)',
              controller: _subAmtCtrl,
              placeholder: '250000',
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('مدة البرنامج (سنوات)',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.calcMuted,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      initialValue: _progYears,
                      items: [3, 5, 10, 15]
                          .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text('$v سنوات',
                                  style: const TextStyle(
                                      color: AppColors.calcText,
                                      fontSize: 14))))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _progYears = v!),
                      dropdownColor: AppColors.calcCard,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.calcInput,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.calcBorder2)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.calcBorder2)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.calcNeon2)),
                      ),
                      isExpanded: true,
                    ),
                  ]),
            ),
          ]),
          CalculatorGridRow(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('استراتيجية الاستثمار',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.calcMuted,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<InvestmentStrategy>(
                      initialValue: _strategy,
                      items: InvestmentStrategy.values
                          .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.label,
                                  style: const TextStyle(
                                      color: AppColors.calcText,
                                      fontSize: 14))))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _strategy = v!),
                      dropdownColor: AppColors.calcCard,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 14),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.calcInput,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.calcBorder2)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.calcBorder2)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.calcNeon2)),
                      ),
                      isExpanded: true,
                    ),
                  ]),
            ),
            CalculatorNeonField(
              label: 'العمر عند التعاقد',
              controller: _ageCtrl,
              placeholder: '35',
            ),
          ]),
        ]),
        // Calculate button
        CalculatorNeonButton(label: 'احسب الآن', onTap: _calculate),
      ]);

  Widget _buildResultCard() => RepaintBoundary(
        key: _resultKey,
        child: CalculatorNeonCard(isResult: true, children: [
          const ResultSectionHeader(title: 'النتيجة'),
          if (_result == null)
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined,
                          size: 42,
                          color: AppColors.calcText.withValues(alpha: 0.25)),
                      const SizedBox(height: 10),
                      const Text('أدخل البيانات واضغط احسب',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.calcMuted)),
                    ]),
              ),
            )
          else ...[
            CalculatorResultRow(
              label: 'القيمة النقدية بعد ${_result!.years} سنوات',
              value: '${_fmt(_result!.finalCashValue)} ر.س',
              highlight: ResultHighlight.neon,
            ),
            CalculatorResultRow(
              label: 'قيمة الاسترداد',
              value: '${_fmt(_result!.finalCashValue)} ر.س',
              highlight: ResultHighlight.gold,
            ),
            CalculatorResultRow(
              label: 'منفعة الوفاة',
              value: '${_fmt(_result!.finalDeathBenefit)} ر.س',
              highlight: ResultHighlight.green,
            ),
            CalculatorResultRow(
              label: 'التغطية التأمينية',
              value: '${_fmt(_result!.coverage)} ر.س',
            ),
            CalculatorResultRow(
              label: 'إجمالي دخل الاستثمار',
              value: '${_fmt(_result!.totalInvestmentIncome)} ر.س',
            ),
            // Projection table
            const SizedBox(height: 12),
            _buildProjectionTable(),
          ],
        ]),
      );

  Widget _buildProjectionTable() {
    if (_result == null) return const SizedBox.shrink();
    final rows = _result!.rows;
    return Column(
      children: [
        // Table header
        Container(
          color: const Color(0xFF061228),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
          child: const Row(children: [
            Expanded(
                child: Text('السنة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            Expanded(
                child: Text('القيمة النقدية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            Expanded(
                child: Text('منفعة الوفاة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            Expanded(
                child: Text('رسوم الإدارة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
          ]),
        ),
        // Table rows
        ...rows.asMap().entries.map((entry) {
          final i = entry.key;
          final r = entry.value;
          final isEven = i % 2 == 0;
          return Container(
            decoration: BoxDecoration(
              color: isEven
                  ? AppColors.calcNeon2.withValues(alpha: 0.04)
                  : Colors.transparent,
              border: const Border(
                  bottom: BorderSide(color: AppColors.calcBorder, width: 1)),
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            child: Row(children: [
              Expanded(
                  child: Text('${r.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13))),
              Expanded(
                  child: Text(_fmt(r.cashValue),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13))),
              Expanded(
                  child: Text(_fmt(r.deathBenefit),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13))),
              Expanded(
                  child: Text(_fmt(r.admin + r.risk + r.mgmtFee),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13))),
            ]),
          );
        }),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CalculatorNeonScaffold(
      subtitle: 'برنامج الحماية والادخار - الدفعة الواحدة',
      aiContextBuilder: _buildAiContext,
      body: Column(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInputCard()),
                  const SizedBox(width: 18),
                  Expanded(child: _buildResultCard()),
                ],
              );
            }
            return Column(children: [
              _buildInputCard(),
              const SizedBox(height: 18),
              _buildResultCard(),
            ]);
          }),
          CalculatorExportButtons(repaintKey: _resultKey),
        ],
      ),
    );
  }
}
