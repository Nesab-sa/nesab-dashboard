import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/debt_purchase_calculator.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_export_buttons.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_grid_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_field.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_scaffold.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_result_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_sub_section.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/result_section_header.dart';

String _fmt(num n) => NumberFormat('#,##0', 'en_US').format(n.round());

// ---------------------------------------------------------------------------
// DebtPurchasePage
// ---------------------------------------------------------------------------
class DebtPurchasePage extends StatefulWidget {
  const DebtPurchasePage({super.key});

  @override
  State<DebtPurchasePage> createState() => _DebtPurchasePageState();
}

class _DebtPurchasePageState extends State<DebtPurchasePage> {
  // Controllers
  final _salaryCtrl = TextEditingController(text: '19165');
  final _profitRateCtrl = TextEditingController(text: '1');
  final _birthYearCtrl = TextEditingController(text: '1997');
  final _retireAgeCtrl = TextEditingController(text: '58');
  final _ahliCardsCtrl = TextEditingController(text: '0');
  final _otherCardsCtrl = TextEditingController(text: '0');
  final _debtAmtCtrl = TextEditingController(text: '0');

  // State
  String _workStatus = 'موظف';
  String _mortgage = 'لا يوجد';
  int _birthMonth = 1;
  int _loanMonths = 60;
  DebtPurchaseResult? _result;

  final _resultKey = GlobalKey();

  // Cached retire info for live display
  RetireInfo? _retireInfo;

  @override
  void initState() {
    super.initState();
    _calcRetire();
  }

  @override
  void dispose() {
    for (final c in [
      _salaryCtrl,
      _profitRateCtrl,
      _birthYearCtrl,
      _retireAgeCtrl,
      _ahliCardsCtrl,
      _otherCardsCtrl,
      _debtAmtCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Retire calculation (live badges)
  // -----------------------------------------------------------------------
  void _calcRetire() {
    final by = int.tryParse(_birthYearCtrl.text) ?? 1997;
    final ra = int.tryParse(_retireAgeCtrl.text) ?? 58;
    setState(() {
      _retireInfo = const DebtPurchaseCalculator().calcRetire(
        birthYear: by,
        birthMonth: _birthMonth,
        retireAge: ra,
      );
    });
  }

  // -----------------------------------------------------------------------
  // Calculate
  // -----------------------------------------------------------------------
  void _calculate() {
    final salary = double.tryParse(_salaryCtrl.text) ?? 0;
    if (salary == 0) {
      _snack('أدخل الراتب');
      return;
    }

    final input = DebtPurchaseInput(
      salary: salary,
      workStatus: _workStatus,
      mortgage: _mortgage,
      birthYear: int.tryParse(_birthYearCtrl.text) ?? 1997,
      birthMonth: _birthMonth,
      retireAge: int.tryParse(_retireAgeCtrl.text) ?? 58,
      profitRate: double.tryParse(_profitRateCtrl.text) ?? 1,
      loanMonths: _loanMonths,
      ahliCards: double.tryParse(_ahliCardsCtrl.text) ?? 0,
      otherCards: double.tryParse(_otherCardsCtrl.text) ?? 0,
      debtAmt: double.tryParse(_debtAmtCtrl.text) ?? 0,
    );

    final d = const DebtPurchaseCalculator().calculate(input);
    setState(() {
      _result = d;
      _retireInfo = d.retire;
    });
  }

  // -----------------------------------------------------------------------
  // Schedule dialog
  // -----------------------------------------------------------------------
  void _showSchedule() {
    if (_result == null) {
      _snack('احسب أولاً');
      return;
    }
    final rows = const DebtPurchaseCalculator().schedule(_result!);
    _showModal(
      title: 'جدول الأقساط',
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
                child: Text('إجمالي مدفوع',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.calcNeon,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          ...rows.map((r) => Container(
                decoration: const BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: AppColors.calcBorder, width: 1)),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 6, horizontal: 8),
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
                    child: Text(_fmt(r.cumulative),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.calcText, fontSize: 13)),
                  ),
                ]),
              )),
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
    return 'تمويل شراء مديونية: وضع ${d.workStatus}، راتب ${_fmt(d.salary)} ريال، '
        'موافقة ${_fmt(d.approvedAmt)} ريال، صافي ${_fmt(d.netAmt)} ريال، '
        'مديونية ${_fmt(d.debtAmt)} ريال، صافي بعد المديونية ${_fmt(d.netAfterDebt)} ريال، '
        'قسط ${_fmt(d.monthlyInstallment)} ريال، مدة ${d.months} شهر';
  }

  // -----------------------------------------------------------------------
  // Dropdown helper (styled like CalculatorNeonField)
  // -----------------------------------------------------------------------
  Widget _styledDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
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
            items: items,
            onChanged: onChanged,
            dropdownColor: AppColors.calcCard,
            style: const TextStyle(color: AppColors.calcText, fontSize: 14),
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
  // Info badge (used for retire info display)
  // -----------------------------------------------------------------------
  Widget _infoBadge(String key, String value,
      {String variant = 'normal'}) {
    Color valColor;
    switch (variant) {
      case 'ok':
        valColor = AppColors.calcGreen;
      case 'warn':
        valColor = AppColors.calcRed;
      default:
        valColor = AppColors.calcNeon;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.calcNeon.withValues(alpha: 0.06),
        border: Border.all(
            color: AppColors.calcNeon.withValues(alpha: 0.18)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        SizedBox(
          width: 110,
          child: Text(key,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.calcMuted)),
        ),
        const SizedBox(width: 8),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valColor)),
      ]),
    );
  }

  // -----------------------------------------------------------------------
  // Build sections
  // -----------------------------------------------------------------------
  Widget _buildInputCard() => CalculatorNeonCard(children: [
        const ResultSectionHeader(title: 'بيانات العميل', icon: '🏦'),

        // ---- الوضع الوظيفي ----
        CalculatorSubSection(title: 'الوضع الوظيفي', children: [
          CalculatorGridRow(children: [
            _styledDropdown<String>(
              label: 'الوضع الوظيفي',
              value: _workStatus,
              items: ['موظف', 'متقاعد']
                  .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(v,
                          style: const TextStyle(
                              color: AppColors.calcText,
                              fontSize: 14))))
                  .toList(),
              onChanged: (v) {
                setState(() => _workStatus = v!);
                _calcRetire();
              },
            ),
            _styledDropdown<String>(
              label: 'تمويل عقاري',
              value: _mortgage,
              items: ['لا يوجد', 'نعم يوجد']
                  .map((v) => DropdownMenuItem(
                      value: v,
                      child: Text(v,
                          style: const TextStyle(
                              color: AppColors.calcText,
                              fontSize: 14))))
                  .toList(),
              onChanged: (v) => setState(() => _mortgage = v!),
            ),
          ]),
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'سنة الميلاد',
              controller: _birthYearCtrl,
              placeholder: '1997',
              onChanged: (_) => _calcRetire(),
            ),
            _styledDropdown<int>(
              label: 'شهر الميلاد',
              value: _birthMonth,
              items: const [
                DropdownMenuItem(
                    value: 1,
                    child: Text('يناير',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 2,
                    child: Text('فبراير',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 3,
                    child: Text('مارس',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 4,
                    child: Text('أبريل',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 5,
                    child: Text('مايو',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 6,
                    child: Text('يونيو',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 7,
                    child: Text('يوليو',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 8,
                    child: Text('أغسطس',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 9,
                    child: Text('سبتمبر',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 10,
                    child: Text('أكتوبر',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 11,
                    child: Text('نوفمبر',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
                DropdownMenuItem(
                    value: 12,
                    child: Text('ديسمبر',
                        style: TextStyle(
                            color: AppColors.calcText, fontSize: 14))),
              ],
              onChanged: (v) {
                setState(() => _birthMonth = v!);
                _calcRetire();
              },
            ),
          ]),
          CalculatorNeonField(
            label: 'سن التقاعد (سنة)',
            controller: _retireAgeCtrl,
            placeholder: '58',
            onChanged: (_) => _calcRetire(),
          ),
          // Retire badges
          if (_retireInfo != null) ...[
            _infoBadge('العمر بالشهور',
                '${_retireInfo!.ageMonths} شهر (${(_retireInfo!.ageMonths / 12).toStringAsFixed(1)} سنة)'),
            _infoBadge('المدة المتاحة',
                '${_retireInfo!.remMonths} شهر'),
            _infoBadge(
              'الأهلية الزمنية',
              _retireInfo!.eligible
                  ? 'مؤهل'
                  : 'غير مؤهل (أقل من 60 شهر)',
              variant: _retireInfo!.eligible ? 'ok' : 'warn',
            ),
          ],
        ]),

        // ---- بيانات التمويل ----
        CalculatorSubSection(title: 'بيانات التمويل', children: [
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'راتب العميل (ريال) *',
              controller: _salaryCtrl,
              placeholder: '19165',
            ),
            CalculatorNeonField(
              label: 'هامش الربح (%) *',
              controller: _profitRateCtrl,
              placeholder: '1',
            ),
          ]),
          // مدة التمويل
          _styledDropdown<int>(
            label: 'مدة التمويل (شهر) *',
            value: _loanMonths,
            items: [12, 24, 36, 48, 60]
                .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text('$m شهر',
                        style: const TextStyle(
                            color: AppColors.calcText,
                            fontSize: 14))))
                .toList(),
            onChanged: (v) =>
                setState(() => _loanMonths = v!),
          ),
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'مجموع حدود بطاقات الأهلي *',
              controller: _ahliCardsCtrl,
              placeholder: '0',
            ),
            CalculatorNeonField(
              label: 'مجموع حدود بطاقات البنوك الأخرى *',
              controller: _otherCardsCtrl,
              placeholder: '0',
            ),
          ]),
        ]),

        // ---- المديونية ----
        CalculatorSubSection(title: 'المديونية في البنك الآخر', children: [
          CalculatorNeonField(
            label: 'مبلغ المديونية في البنك الآخر (ريال)',
            controller: _debtAmtCtrl,
            placeholder: '0',
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
              height: 380,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monitor,
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
            // نسبة الاستقطاع
            _resSection('نسبة الاستقطاع'),
            CalculatorResultRow(
              label: 'نسبة الاستقطاع',
              value:
                  '${(_result!.dedRate * 100).toStringAsFixed(2)}%',
            ),
            CalculatorResultRow(
              label: 'القسط الشهري',
              value: '${_fmt(_result!.monthlyInstallment)} ر.س',
              highlight: ResultHighlight.neon,
            ),

            // مبالغ التمويل
            _resSection('مبالغ التمويل'),
            CalculatorResultRow(
              label: 'إجمالي التمويل',
              value: '${_fmt(_result!.totalFinance)} ر.س',
            ),
            CalculatorResultRow(
              label: 'مبلغ الموافقة',
              value: '${_fmt(_result!.approvedAmt)} ر.س',
              highlight: ResultHighlight.gold,
            ),
            CalculatorResultRow(
              label: 'ربح البنك',
              value: '${_fmt(_result!.bankProfit)} ر.س',
            ),

            // الرسوم والضريبة
            _resSection('الرسوم والضريبة'),
            CalculatorResultRow(
              label: 'الرسوم الإدارية (0.5% | أقصى 2,500)',
              value: '${_fmt(_result!.adminFee)} ر.س',
            ),
            CalculatorResultRow(
              label: 'الضريبة (15%)',
              value: '${_fmt(_result!.tax)} ر.س',
            ),
            CalculatorResultRow(
              label: 'إجمالي الرسوم',
              value: '${_fmt(_result!.totalFees)} ر.س',
            ),

            // الصافي
            _resSection('الصافي'),
            CalculatorResultRow(
              label: 'صافي مبلغ التمويل',
              value: '${_fmt(_result!.netAmt)} ر.س',
              highlight: ResultHighlight.green,
            ),
            CalculatorResultRow(
              label: 'المديونية في البنك الآخر',
              value: '${_fmt(_result!.debtAmt)} ر.س',
            ),
            CalculatorResultRow(
              label: 'صافي المبلغ بعد خصم المديونية',
              value: '${_fmt(_result!.netAfterDebt)} ر.س',
              highlight: ResultHighlight.neon,
            ),

            // Decision badge
            _buildDecisionBadge(),
          ],
        ]),
      );

  Widget _resSection(String title) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        child: Container(
          padding: const EdgeInsets.only(bottom: 6),
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: AppColors.calcBorder))),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.calcNeon2)),
        ),
      );

  Widget _buildDecisionBadge() {
    final d = _result!;

    String text;
    Color badgeColor;
    Color bgColor;

    if (!d.retire.eligible) {
      text = 'غير مؤهل -- المدة المتبقية أقل من 60 شهر';
      badgeColor = AppColors.calcRed;
      bgColor = AppColors.calcRed.withValues(alpha: 0.1);
    } else if (d.netAfterDebt < 0) {
      text = 'المديونية تتجاوز صافي التمويل';
      badgeColor = AppColors.calcGold;
      bgColor = AppColors.calcGold.withValues(alpha: 0.1);
    } else {
      text = 'مقبول -- تم الاحتساب بنجاح';
      badgeColor = AppColors.calcGreen;
      bgColor = AppColors.calcGreen.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: badgeColor),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: badgeColor,
              letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildBottomCards() => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: CalculatorGridRow(
          breakpoint: 600,
          spacing: 14,
          children: [
            _btmCard('جدول الأقساط',
                'عرض التفاصيل الشهرية الكاملة', 'عرض', _showSchedule),
            _btmCard(
                'تصدير النتيجة',
                'PDF أو صورة للنتائج',
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
      subtitle: 'حاسبة تمويل شراء مديونية',
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
