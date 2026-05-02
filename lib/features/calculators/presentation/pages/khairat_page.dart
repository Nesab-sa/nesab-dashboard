import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/khairat_calculator.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_export_buttons.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_field.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_scaffold.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_result_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_sub_section.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/decision_badge.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/result_section_header.dart';

String _fmt(num n) => NumberFormat('#,##0', 'en_US').format(n.round());
String _fmtD(num n) => NumberFormat('#,##0.00', 'en_US').format(n);

// ---------------------------------------------------------------------------
// KhairatPage
// ---------------------------------------------------------------------------
class KhairatPage extends StatefulWidget {
  const KhairatPage({super.key});

  @override
  State<KhairatPage> createState() => _KhairatPageState();
}

class _KhairatPageState extends State<KhairatPage> {
  // Controllers
  final _amountCtrl = TextEditingController(text: '100000');

  // State
  KhairatPeriod _period = KhairatPeriod.twoWeeks;
  KhairatResult? _result;
  bool _showMinWarn = false;

  final _resultKey = GlobalKey();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Min check (mirrors checkMin in HTML)
  // -----------------------------------------------------------------------
  void _checkMin() {
    final v = double.tryParse(_amountCtrl.text) ?? 0;
    setState(() => _showMinWarn = v < 100000 && v > 0);
  }

  // -----------------------------------------------------------------------
  // Calculate (mirrors calculate() in HTML)
  // -----------------------------------------------------------------------
  void _calculate() {
    final amt = double.tryParse(_amountCtrl.text) ?? 0;
    if (amt < 100000) {
      _snack('الحد الأدنى 100,000 ريال');
      return;
    }
    final input = KhairatInput(investAmount: amt, period: _period);
    final result = const KhairatCalculator().calculate(input);
    setState(() => _result = result);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // -----------------------------------------------------------------------
  // AI context builder (used by CalculatorNeonScaffold)
  // -----------------------------------------------------------------------
  String _buildAiContext() {
    final d = _result;
    if (d == null) return '';
    return 'استثمار خيرات: مبلغ ${_fmt(d.investAmount)} ريال، '
        'فترة ${d.periodLabel}, '
        'أرباح ${_fmtD(d.profit)} ريال';
  }

  // -----------------------------------------------------------------------
  // Build sections
  // -----------------------------------------------------------------------
  Widget _buildInputCard() => CalculatorNeonCard(children: [
        const ResultSectionHeader(title: 'بيانات الاستثمار'),
        CalculatorSubSection(title: 'المبلغ والفترة', children: [
          CalculatorNeonField(
            label: 'مبلغ الاستثمار (ريال) — الحد الأدنى 100,000',
            controller: _amountCtrl,
            placeholder: '100000',
            onChanged: (_) => _checkMin(),
          ),
          if (_showMinWarn)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('الحد الأدنى 100,000 ريال',
                  style: TextStyle(fontSize: 12, color: AppColors.calcRed)),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('فترة الاستثمار',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.calcMuted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<KhairatPeriod>(
                    initialValue: _period,
                    items: KhairatPeriod.values
                        .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.dropdownLabel,
                                style: const TextStyle(
                                    color: AppColors.calcText,
                                    fontSize: 14))))
                        .toList(),
                    onChanged: (v) => setState(() => _period = v!),
                    dropdownColor: AppColors.calcCard,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.calcInput,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.calcBorder2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.calcBorder2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.calcNeon2),
                      ),
                    ),
                    isExpanded: true,
                  ),
                ]),
          ),
        ]),
        CalculatorNeonButton(label: 'احسب الأرباح', onTap: _calculate),
      ]);

  Widget _buildResultCard() => RepaintBoundary(
        key: _resultKey,
        child: CalculatorNeonCard(isResult: true, children: [
          const ResultSectionHeader(title: 'النتيجة'),
          if (_result == null)
            SizedBox(
              height: 280,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monitor,
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
              label: 'مبلغ الاستثمار',
              value: '${_fmt(_result!.investAmount)} ر.س',
            ),
            CalculatorResultRow(
              label: 'الفترة',
              value: '${_result!.periodLabel} (${_result!.days} يوم)',
            ),
            CalculatorResultRow(
              label: 'هامش الربح',
              value: '${(_result!.profitRate * 100).toStringAsFixed(2)}%',
            ),
            CalculatorResultRow(
              label: 'الأرباح',
              value: '${_fmtD(_result!.profit)} ر.س',
              highlight: ResultHighlight.gold,
            ),
            CalculatorResultRow(
              label: 'المبلغ الجديد',
              value: '${_fmt(_result!.totalReturn)} ر.س',
              highlight: ResultHighlight.green,
            ),
            DecisionBadge(
              approved: true,
              approvedText: 'المبلغ مستوفٍ للشروط',
              rejectedText: '',
            ),
          ],
        ]),
      );

  // -----------------------------------------------------------------------
  // All-periods table (mirrors renderTable in HTML)
  // -----------------------------------------------------------------------
  Widget _buildAllPeriodsTable() {
    final amt = double.tryParse(_amountCtrl.text) ?? 100000;
    final rows = const KhairatCalculator().allPeriodsTable(amt);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: CalculatorNeonCard(children: [
        const ResultSectionHeader(title: 'جدول جميع الفترات'),
        // Table header
        Container(
          color: const Color(0xFF061228),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
          child: const Row(children: [
            Expanded(
                child: Text('الفترة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            Expanded(
                child: Text('الأيام',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            Expanded(
                child: Text('هامش الربح',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            Expanded(
                child: Text('الأرباح',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600))),
            Expanded(
                child: Text('المبلغ الجديد',
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
          return Container(
            decoration: BoxDecoration(
              color: i.isEven
                  ? AppColors.calcNeon2.withValues(alpha: 0.04)
                  : Colors.transparent,
              border: const Border(
                  bottom: BorderSide(color: AppColors.calcBorder, width: 1)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            child: Row(children: [
              Expanded(
                  child: Text(r.periodName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13))),
              Expanded(
                  child: Text('${r.days}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13))),
              Expanded(
                  child: Text(
                      '${(r.profitRate * 100).toStringAsFixed(2)}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13))),
              Expanded(
                  child: Text(_fmtD(r.profit),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13))),
              Expanded(
                  child: Text(_fmt(r.newAmount),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13))),
            ]),
          );
        }),
      ]),
    );
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CalculatorNeonScaffold(
      subtitle: 'حاسبة خيرات — الودائع والاستثمار',
      aiContextBuilder: _buildAiContext,
      body: Column(children: [
        // Two-column grid (input + result)
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
        // All-periods table
        _buildAllPeriodsTable(),
      ]),
    );
  }
}
