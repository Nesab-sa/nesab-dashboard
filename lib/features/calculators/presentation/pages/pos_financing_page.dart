import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/pos_financing_calculator.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_export_buttons.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_grid_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_field.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_scaffold.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_result_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_sub_section.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/decision_badge.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/result_section_header.dart';

String _fmt(num n) => NumberFormat('#,##0', 'en_US').format(n.round());

// ---------------------------------------------------------------------------
// PosFinancingPage
// ---------------------------------------------------------------------------
class PosFinancingPage extends StatefulWidget {
  const PosFinancingPage({super.key});

  @override
  State<PosFinancingPage> createState() => _PosFinancingPageState();
}

class _PosFinancingPageState extends State<PosFinancingPage> {
  // Controllers
  final _annualSalesCtrl = TextEditingController(text: '400000');

  // State
  PosBusinessType _bizType = PosBusinessType.soleProprietorship;
  PosBusinessActivity _bizActivity = PosBusinessActivity.wholesaleRetail;
  PosBusinessAge _bizAge = PosBusinessAge.moreThanTwo;
  PosPeriod _posAge = PosPeriod.moreThanYear;
  PosOperations _posOps = PosOperations.moreThan25;
  PosDuration _duration = PosDuration.fiveYears;
  PosFinancingResult? _result;

  final _resultKey = GlobalKey();

  @override
  void dispose() {
    _annualSalesCtrl.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Calculate -- matches HTML JS exactly
  // -----------------------------------------------------------------------
  void _calculate() {
    final ann = double.tryParse(_annualSalesCtrl.text) ?? 0;
    final input = PosFinancingInput(
      businessType: _bizType,
      activity: _bizActivity,
      businessAge: _bizAge,
      posPeriod: _posAge,
      annualSales: ann,
      posOperations: _posOps,
      duration: _duration,
    );
    final d = const PosFinancingCalculator().calculate(input);
    setState(() => _result = d);
  }

  // -----------------------------------------------------------------------
  // AI context builder (used by CalculatorNeonScaffold)
  // -----------------------------------------------------------------------
  String _buildAiContext() {
    final d = _result;
    if (d == null) return 'لم يتم الحساب.';
    return 'تمويل نقاط بيع: مبيعات ${_fmt(d.annualSales)} ريال، '
        'تمويل ${_fmt(d.loanAmount)} ريال، '
        'قسط ${_fmt(d.monthlyPayment)} ريال، '
        '${d.isEligible ? 'مقبولة' : 'مرفوضة'}';
  }

  // -----------------------------------------------------------------------
  // Dropdown helper (typed, for enum values)
  // -----------------------------------------------------------------------
  Widget _dropdown<T>(String label, T value, List<T> items,
      String Function(T) labelFn, ValueChanged<T?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.calcMuted,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          DropdownButtonFormField<T>(
            initialValue: value,
            items: items
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(labelFn(e),
                        style: const TextStyle(
                            color: AppColors.calcText, fontSize: 14))))
                .toList(),
            onChanged: onChanged,
            dropdownColor: AppColors.calcCard,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.calcInput,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.calcBorder2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.calcBorder2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.calcNeon2),
              ),
            ),
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Build sections
  // -----------------------------------------------------------------------
  Widget _buildInputCard() => CalculatorNeonCard(children: [
        const ResultSectionHeader(title: 'بيانات المنشأة'),
        CalculatorSubSection(title: 'معلومات المنشأة', children: [
          CalculatorGridRow(children: [
            _dropdown<PosBusinessType>(
              'نوع المنشأة',
              _bizType,
              PosBusinessType.values,
              (e) => e.arabicLabel,
              (v) => setState(() => _bizType = v!),
            ),
            _dropdown<PosBusinessActivity>(
              'نشاط المنشأة',
              _bizActivity,
              PosBusinessActivity.values,
              (e) => e.arabicLabel,
              (v) => setState(() => _bizActivity = v!),
            ),
          ]),
          CalculatorGridRow(children: [
            _dropdown<PosBusinessAge>(
              'عمر المنشأة',
              _bizAge,
              PosBusinessAge.values,
              (e) => e.arabicLabel,
              (v) => setState(() => _bizAge = v!),
            ),
            _dropdown<PosPeriod>(
              'فترة تشغيل نقاط البيع',
              _posAge,
              PosPeriod.values,
              (e) => e.arabicLabel,
              (v) => setState(() => _posAge = v!),
            ),
          ]),
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'متوسط المبيعات السنوية (ريال)',
              controller: _annualSalesCtrl,
              placeholder: '400000',
            ),
            _dropdown<PosOperations>(
              'عدد عمليات نقاط البيع شهريا',
              _posOps,
              PosOperations.values,
              (e) => e.arabicLabel,
              (v) => setState(() => _posOps = v!),
            ),
          ]),
        ]),
        CalculatorSubSection(title: 'مدة التمويل', children: [
          _dropdown<PosDuration>(
            'مدة التمويل',
            _duration,
            PosDuration.values,
            (e) => e.arabicLabel,
            (v) => setState(() => _duration = v!),
          ),
        ]),
        CalculatorNeonButton(label: 'احسب الآن', onTap: _calculate),
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
            // Result section title
            Container(
              padding: const EdgeInsets.only(bottom: 6),
              margin: const EdgeInsets.only(top: 6, bottom: 8),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: AppColors.calcBorder)),
              ),
              child: const Text('تفاصيل التمويل',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.calcNeon2)),
            ),
            // متوسط المبيعات الشهرية -- normal row
            CalculatorResultRow(
              label: 'متوسط المبيعات الشهرية',
              value: '${_fmt(_result!.monthlySales)} ر.س',
            ),
            // مبلغ التمويل -- neon if ok, shows 'مرفوض' if rejected by age
            CalculatorResultRow(
              label: 'مبلغ التمويل (مبيعات 3 أشهر)',
              value: _result!.isRejectedByAge
                  ? 'مرفوض'
                  : '${_fmt(_result!.loanAmount)} ر.س',
              highlight: _result!.isEligible
                  ? ResultHighlight.neon
                  : ResultHighlight.none,
            ),
            // نسبة الربح -- normal
            CalculatorResultRow(
              label: 'نسبة الربح',
              value:
                  '${(_result!.profitRate * 100).toStringAsFixed(0)}%',
            ),
            // إجمالي الربح -- normal
            CalculatorResultRow(
              label: 'إجمالي الربح',
              value: '${_fmt(_result!.profitAmount)} ر.س',
            ),
            // الإجمالي -- gold
            CalculatorResultRow(
              label: 'الإجمالي',
              value: '${_fmt(_result!.totalAmount)} ر.س',
              highlight: ResultHighlight.gold,
            ),
            // القسط الشهري -- neon
            CalculatorResultRow(
              label: 'القسط الشهري',
              value: '${_fmt(_result!.monthlyPayment)} ر.س',
              highlight: ResultHighlight.neon,
            ),
            // الرسوم الإدارية -- normal
            CalculatorResultRow(
              label: 'الرسوم الإدارية (1% + VAT)',
              value: '${_fmt(_result!.adminFees)} ر.س',
            ),
            // Decision badge
            DecisionBadge(
              approved: _result!.isEligible,
              approvedText: 'مقبولة — المنشأة مؤهلة',
              rejectedText: _result!.isRejectedByAge
                  ? 'مرفوضة — عمر المنشأة أو نقاط البيع غير كاف'
                  : 'مرفوضة — المبيعات أقل من 400,000 ريال',
            ),
          ],
        ]),
      );

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CalculatorNeonScaffold(
      subtitle: 'حاسبة تمويل نقاط البيع',
      aiContextBuilder: _buildAiContext,
      body: Column(children: [
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
      ]),
    );
  }
}
