import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/real_estate_calculator.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_export_buttons.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_grid_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_field.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_scaffold.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_result_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_sub_section.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_toggle_buttons.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/result_section_header.dart';

String _fmt(num n) => NumberFormat('#,##0', 'en_US').format(n.round());

// ---------------------------------------------------------------------------
// RealEstatePage
// ---------------------------------------------------------------------------
class RealEstatePage extends StatefulWidget {
  const RealEstatePage({super.key});

  @override
  State<RealEstatePage> createState() => _RealEstatePageState();
}

class _RealEstatePageState extends State<RealEstatePage> {
  // Controllers — defaults match the HTML
  final _salaryCtrl = TextEditingController(text: '9767');
  final _mortgageYearsCtrl = TextEditingController(text: '25');
  final _profitRateCtrl = TextEditingController(text: '4.05');
  final _personalInstCtrl = TextEditingController(text: '2922');
  final _remainingPersonalCtrl = TextEditingController(text: '60');
  final _fixedLoanCtrl = TextEditingController(text: '0');

  // State
  bool _support = true;
  bool _etizaz = false;
  RealEstateResult? _result;

  final _resultKey = GlobalKey();

  @override
  void dispose() {
    for (final c in [
      _salaryCtrl,
      _mortgageYearsCtrl,
      _profitRateCtrl,
      _personalInstCtrl,
      _remainingPersonalCtrl,
      _fixedLoanCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Calculate — exact HTML formulas via RealEstateCalculator
  // -----------------------------------------------------------------------
  void _calculate() {
    final salary = double.tryParse(_salaryCtrl.text) ?? 0;
    if (salary == 0) {
      _snack('أدخل الراتب');
      return;
    }
    final input = RealEstateInput(
      salary: salary,
      mortgageYears: int.tryParse(_mortgageYearsCtrl.text) ?? 25,
      profitRate: ((double.tryParse(_profitRateCtrl.text) ?? 4.05)) / 100,
      personalInstallment: double.tryParse(_personalInstCtrl.text) ?? 0,
      remainingPersonalMonths:
          int.tryParse(_remainingPersonalCtrl.text) ?? 0,
      hasSupport: _support,
      hasEtizaz: _etizaz,
      fixedLoan: double.tryParse(_fixedLoanCtrl.text) ?? 0,
    );
    setState(
        () => _result = const RealEstateCalculator().calculate(input));
  }

  // -----------------------------------------------------------------------
  // Schedule
  // -----------------------------------------------------------------------
  void _showSchedule() {
    if (_result == null) {
      _snack('احسب أولاً');
      return;
    }
    final rows = const RealEstateCalculator().schedule(_result!);
    _showModal(
      title: 'جدول الأقساط التفصيلي',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: const Color(0xFF061228),
            padding:
                const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            child: const Row(children: [
              Expanded(
                child: Text('الشهر',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: Text('القسط',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: Text('المرحلة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: Text('إجمالي مدفوع',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          ...rows.map((r) {
            final phase = r.isPhase1 ? 'مع الشخصي' : 'بعد الشخصي';
            final phaseColor =
                r.isPhase1 ? AppColors.calcGold : AppColors.calcGreen;
            return Container(
              decoration: BoxDecoration(
                color: r.isPhase1
                    ? null
                    : AppColors.calcNeon2.withValues(alpha: 0.05),
                border: const Border(
                    bottom:
                        BorderSide(color: AppColors.calcBorder, width: 1)),
              ),
              padding: const EdgeInsets.symmetric(
                  vertical: 5, horizontal: 8),
              child: Row(children: [
                Expanded(
                  child: Text('${r.month}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13)),
                ),
                Expanded(
                  child: Text(_fmt(r.payment),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13)),
                ),
                Expanded(
                  child: Text(phase,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: phaseColor, fontSize: 11)),
                ),
                Expanded(
                  child: Text(_fmt(r.cumulative),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.calcText, fontSize: 13)),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Generic dark-themed modal
  // -----------------------------------------------------------------------
  void _showModal({required String title, required Widget child}) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          decoration: BoxDecoration(
            color: AppColors.calcCard,
            border: Border.all(color: AppColors.calcBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(20),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: AppColors.calcNeon,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close,
                          color: AppColors.calcMuted, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(color: AppColors.calcBorder),
                Flexible(
                    child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // -----------------------------------------------------------------------
  // AI context builder for the floating chat widget
  // -----------------------------------------------------------------------
  String _buildAiContext() {
    final d = _result;
    if (d == null) return 'لم يتم الحساب بعد.';
    return 'تمويل عقاري 2في1: راتب ${_fmt(d.salary)} ريال، '
        'مدة ${d.mortgageYears} سنة، '
        'مبلغ ${_fmt(d.loanAmount2in1)} ريال، '
        'قسط1 ${_fmt(d.qistPhase1)} ريال، '
        'قسط2 ${_fmt(d.qistPhase2)} ريال، '
        'دعم ${d.hasSupport ? _fmt(d.housingSupport) : 'لا'}، '
        'اعتزاز ${d.hasEtizaz ? 'نعم' : 'لا'}، '
        'إجمالي ${_fmt(d.totalWithSupport)} ريال';
  }

  // -----------------------------------------------------------------------
  // Build sections
  // -----------------------------------------------------------------------
  Widget _buildInputCard() => CalculatorNeonCard(children: [
        const ResultSectionHeader(title: 'بيانات التمويل', icon: '🏠'),
        CalculatorSubSection(title: 'المعلومات المالية', children: [
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'راتب العميل (ريال)',
              controller: _salaryCtrl,
              placeholder: '9767',
            ),
            CalculatorNeonField(
              label: 'مدة التمويل العقاري (سنة)',
              controller: _mortgageYearsCtrl,
              placeholder: '25',
            ),
          ]),
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'هامش الربح (%)',
              controller: _profitRateCtrl,
              placeholder: '4.05',
            ),
            CalculatorNeonField(
              label: 'قسط التمويل الشخصي (ريال)',
              controller: _personalInstCtrl,
              placeholder: '0',
            ),
          ]),
          CalculatorNeonField(
            label: 'عدد الأقساط المتبقية من التمويل الشخصي (شهر)',
            controller: _remainingPersonalCtrl,
            placeholder: '60',
          ),
        ]),
        CalculatorSubSection(title: 'خيارات إضافية', children: [
          CalculatorGridRow(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الدعم السكني',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.calcMuted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  CalculatorToggleButtons(
                    labels: const ['نعم', 'لا'],
                    selectedIndex: _support ? 0 : 1,
                    onChanged: (i) =>
                        setState(() => _support = i == 0),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('اعتزاز (وزارة الدفاع)',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.calcMuted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  CalculatorToggleButtons(
                    labels: const ['نعم', 'لا'],
                    selectedIndex: _etizaz ? 0 : 1,
                    onChanged: (i) =>
                        setState(() => _etizaz = i == 0),
                  ),
                ],
              ),
            ),
          ]),
          CalculatorNeonField(
            label: 'مبلغ تمويل عقاري محدد (اتركه 0 للحساب التلقائي)',
            controller: _fixedLoanCtrl,
            placeholder: '710000',
          ),
        ]),
        // Calculate button
        CalculatorNeonButton(label: 'احسب الآن', onTap: _calculate),
      ]);

  Widget _buildResultCard() => RepaintBoundary(
        key: _resultKey,
        child: CalculatorNeonCard(isResult: true, children: [
          const ResultSectionHeader(title: 'النتيجة', icon: '📊'),
          if (_result == null)
            SizedBox(
              height: 340,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home,
                          size: 42,
                          color:
                              AppColors.calcText.withValues(alpha: 0.25)),
                      const SizedBox(height: 10),
                      const Text('أدخل البيانات واضغط «احسب»',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.calcMuted)),
                    ]),
              ),
            )
          else ...[
            // بيانات التمويل
            _resSection('بيانات التمويل'),
            CalculatorResultRow(
              label: 'مدة التمويل',
              value:
                  '${_result!.mortgageYears} سنة (${_result!.totalMonths} شهر)',
            ),
            CalculatorResultRow(
              label: 'نسبة الاستقطاع المسموحة',
              value:
                  '${(_result!.dedRate * 100).toStringAsFixed(0)}%',
            ),

            // برنامج 2 في 1
            _resSection('برنامج 2 في 1'),
            CalculatorResultRow(
              label: 'مبلغ التمويل العقاري (2 في 1)',
              value: '${_fmt(_result!.loanAmount2in1)} ر.س',
              highlight: ResultHighlight.neon,
            ),
            CalculatorResultRow(
              label:
                  'القسط خلال فترة التمويل الشخصي (${_result!.remainingPersonalMonths} شهر)',
              value: '${_fmt(_result!.qistPhase1)} ر.س / شهر',
            ),
            CalculatorResultRow(
              label:
                  'القسط بعد انتهاء التمويل الشخصي (${_result!.remainingMonths} شهر)',
              value: '${_fmt(_result!.qistPhase2)} ر.س / شهر',
            ),

            // الإجمالي مع الدعم
            _resSection('الإجمالي مع الدعم'),
            CalculatorResultRow(
              label: 'الدعم السكني',
              value: _result!.hasSupport
                  ? '${_fmt(_result!.housingSupport)} ر.س'
                  : 'لا يوجد',
            ),
            CalculatorResultRow(
              label: 'اعتزاز (وزارة الدفاع)',
              value: _result!.hasEtizaz
                  ? '${_fmt(_result!.etizazAmt)} ر.س'
                  : 'لا يوجد',
            ),
            CalculatorResultRow(
              label: 'الإجمالي مع الدعم والاعتزاز',
              value: '${_fmt(_result!.totalWithSupport)} ر.س',
              highlight: ResultHighlight.gold,
            ),
            CalculatorResultRow(
              label: 'الرسوم الإدارية والتقييم',
              value: '${_fmt(_result!.adminFee)} ر.س',
            ),

            // المبلغ المحدد (if any)
            if (_result!.fixedLoan > 0) ...[
              _resSection('المبلغ المحدد'),
              CalculatorResultRow(
                label: 'مبلغ التمويل المحدد',
                value: '${_fmt(_result!.fixedLoan)} ر.س',
              ),
              CalculatorResultRow(
                label: 'إجمالي الأرباح',
                value: '${_fmt(_result!.fixedProfit)} ر.س',
              ),
              CalculatorResultRow(
                label: 'الإجمالي الكلي',
                value: '${_fmt(_result!.fixedTotal)} ر.س',
                highlight: ResultHighlight.neon,
              ),
            ],

            // Success badge
            _buildSuccessBadge(),
          ],
        ]),
      );

  Widget _resSection(String text) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Container(
          padding: const EdgeInsets.only(bottom: 6),
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: AppColors.calcBorder))),
          child: Text(text,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.calcNeon2)),
        ),
      );

  Widget _buildSuccessBadge() => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.calcGreen.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.calcGreen),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Center(
          child: Text(
            'تم الاحتساب بنجاح',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.calcGreen,
                letterSpacing: 0.5),
          ),
        ),
      );

  Widget _buildBottomCards() => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: CalculatorGridRow(
          breakpoint: 600,
          spacing: 14,
          children: [
            _btmCard(
                'جدول الأقساط التفصيلي',
                'قسط فترة التمويل الشخصي + قسط ما بعده',
                'عرض',
                _showSchedule),
            _btmCard(
                'تصدير النتيجة',
                'حفظ التقرير كاملاً كملف نصي',
                'تصدير',
                () {
                  if (_result == null) {
                    _snack('احسب أولاً');
                  }
                }),
          ],
        ),
      );

  Widget _btmCard(String title, String desc, String action,
          VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.calcCard,
            border: Border.all(color: AppColors.calcBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.calcNeon)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.calcMuted,
                        height: 1.5)),
                const SizedBox(height: 6),
                Text(action,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.calcNeon2)),
              ]),
        ),
      );

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CalculatorNeonScaffold(
      subtitle: 'حاسبة التمويل العقاري (2 في 1)',
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
        _buildBottomCards(),
      ]),
    );
  }
}
