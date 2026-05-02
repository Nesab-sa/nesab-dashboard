import 'dart:typed_data';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/personal_finance_quick_calculator.dart';
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
// PersonalFinanceQuickPage
// ---------------------------------------------------------------------------
class PersonalFinanceQuickPage extends StatefulWidget {
  const PersonalFinanceQuickPage({super.key});

  @override
  State<PersonalFinanceQuickPage> createState() =>
      _PersonalFinanceQuickPageState();
}

class _PersonalFinanceQuickPageState extends State<PersonalFinanceQuickPage> {
  // Controllers
  final _salaryCtrl = TextEditingController(text: '19165');
  final _profitRateCtrl = TextEditingController(text: '1');
  final _birthYearCtrl = TextEditingController(text: '1997');
  final _retireAgeCtrl = TextEditingController(text: '58');
  final _ahliCardsCtrl = TextEditingController(text: '0');
  final _otherCardsCtrl = TextEditingController(text: '0');

  // State
  String _workStatus = 'موظف';
  String _mortgage = 'لا يوجد';
  int _birthMonth = 1;
  int _loanMonths = 60;
  PersonalFinanceQuickResult? _result;

  final _resultKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Auto-compute retirement badges on load, like the HTML does
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateRetirement());
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
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Retirement info (kept live while editing birth/retire fields)
  // -----------------------------------------------------------------------
  RetirementInfo? _retireInfo;

  void _updateRetirement() {
    final input = _buildInput();
    setState(() {
      _retireInfo =
          const PersonalFinanceQuickCalculator().calcRetirement(input);
    });
  }

  // -----------------------------------------------------------------------
  // Build input
  // -----------------------------------------------------------------------
  PersonalFinanceQuickInput _buildInput() {
    return PersonalFinanceQuickInput(
      salary: double.tryParse(_salaryCtrl.text) ?? 0,
      workStatus: _workStatus,
      mortgage: _mortgage,
      birthYear: int.tryParse(_birthYearCtrl.text) ?? 1997,
      birthMonth: _birthMonth,
      retireAge: int.tryParse(_retireAgeCtrl.text) ?? 58,
      profitRate: double.tryParse(_profitRateCtrl.text) ?? 1,
      loanMonths: _loanMonths,
      ahliCards: double.tryParse(_ahliCardsCtrl.text) ?? 0,
      otherCards: double.tryParse(_otherCardsCtrl.text) ?? 0,
    );
  }

  // -----------------------------------------------------------------------
  // Calculate
  // -----------------------------------------------------------------------
  void _calculate() {
    final input = _buildInput();
    if (input.salary == 0) {
      _snack('أدخل الراتب');
      return;
    }
    final result = const PersonalFinanceQuickCalculator().calculate(input);
    setState(() => _result = result);
  }

  // -----------------------------------------------------------------------
  // Schedule dialog
  // -----------------------------------------------------------------------
  void _showSchedule() {
    if (_result == null) {
      _snack('احسب أولاً');
      return;
    }
    final rows =
        const PersonalFinanceQuickCalculator().schedule(_result!);
    _showModal(
      title: 'جدول الأقساط',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: const Color(0xFF061228),
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Export image
  // -----------------------------------------------------------------------
  Future<void> _exportImage() async {
    if (_result == null) {
      _snack('احسب أولاً');
      return;
    }
    try {
      final boundary = _resultKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: AppColors.calcCard,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('النتيجة',
                        style: TextStyle(
                            color: AppColors.calcNeon,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close,
                          color: AppColors.calcMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Image.memory(Uint8List.fromList(bytes)),
              ],
            ),
          ),
        ),
      );
    } catch (_) {
      _snack('تعذر التصدير');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // -----------------------------------------------------------------------
  // Shared widget helpers
  // -----------------------------------------------------------------------
  InputDecoration _inputDeco({String? hint}) => InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: AppColors.calcMuted.withValues(alpha: 0.5)),
        filled: true,
        fillColor: AppColors.calcInput,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.calcBorder2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.calcBorder2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.calcNeon2, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        isDense: true,
      );

  Widget _infoBadge(String key, String value, {String? variant}) {
    Color valColor = AppColors.calcNeon;
    if (variant == 'warn') valColor = AppColors.calcRed;
    if (variant == 'ok') valColor = AppColors.calcGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.calcNeon.withValues(alpha: 0.06),
        border:
            Border.all(color: AppColors.calcNeon.withValues(alpha: 0.18)),
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
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valColor)),
        ),
      ]),
    );
  }

  // -----------------------------------------------------------------------
  // AI context builder (for CalculatorNeonScaffold's AiChatWidget)
  // -----------------------------------------------------------------------
  String _buildAiContext() {
    final d = _result;
    if (d == null) return 'لم يتم الحساب بعد.';
    return 'تمويل شخصي مختصر: وضع ${d.workStatus}, راتب ${_fmt(d.salary)} ريال, '
        'موافقة ${_fmt(d.approvedAmount)} ريال, صافي ${_fmt(d.netAmount)} ريال, '
        'قسط ${_fmt(d.monthlyInstallment)} ريال, مدة ${d.months} شهر, '
        'رسوم ${_fmt(d.totalFees)} ريال';
  }

  // -----------------------------------------------------------------------
  // Build sections
  // -----------------------------------------------------------------------
  Widget _buildInputCard() => CalculatorNeonCard(children: [
        const ResultSectionHeader(title: 'بيانات العميل', icon: '💳'),

        // ---- الوضع الوظيفي ----
        CalculatorSubSection(title: 'الوضع الوظيفي', children: [
          CalculatorGridRow(children: [
            // الوضع الوظيفي dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الوضع الوظيفي',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.calcMuted,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _workStatus,
                      items: ['موظف', 'متقاعد']
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s,
                                  style: const TextStyle(
                                      color: AppColors.calcText,
                                      fontSize: 14))))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _workStatus = v!);
                        _updateRetirement();
                      },
                      dropdownColor: AppColors.calcCard,
                      decoration: _inputDeco(),
                      isExpanded: true,
                    ),
                  ]),
            ),
            // تمويل عقاري dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('تمويل عقاري',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.calcMuted,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _mortgage,
                      items: ['لا يوجد', 'نعم يوجد']
                          .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s,
                                  style: const TextStyle(
                                      color: AppColors.calcText,
                                      fontSize: 14))))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _mortgage = v!),
                      dropdownColor: AppColors.calcCard,
                      decoration: _inputDeco(),
                      isExpanded: true,
                    ),
                  ]),
            ),
          ]),
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'سنة الميلاد',
              controller: _birthYearCtrl,
              placeholder: '1997',
              onChanged: (_) => _updateRetirement(),
            ),
            // شهر الميلاد dropdown
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('شهر الميلاد',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.calcMuted,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      initialValue: _birthMonth,
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('يناير', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 2, child: Text('فبراير', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 3, child: Text('مارس', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 4, child: Text('أبريل', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 5, child: Text('مايو', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 6, child: Text('يونيو', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 7, child: Text('يوليو', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 8, child: Text('أغسطس', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 9, child: Text('سبتمبر', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 10, child: Text('أكتوبر', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 11, child: Text('نوفمبر', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                        DropdownMenuItem(value: 12, child: Text('ديسمبر', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
                      ],
                      onChanged: (v) {
                        setState(() => _birthMonth = v!);
                        _updateRetirement();
                      },
                      dropdownColor: AppColors.calcCard,
                      decoration: _inputDeco(),
                      isExpanded: true,
                    ),
                  ]),
            ),
          ]),
          CalculatorNeonField(
            label: 'سن التقاعد (سنة)',
            controller: _retireAgeCtrl,
            placeholder: '58',
            onChanged: (_) => _updateRetirement(),
          ),
          // Retirement badges
          if (_retireInfo != null) ...[
            _infoBadge(
              'العمر بالشهور',
              '${_retireInfo!.ageMonths} شهر (${(_retireInfo!.ageMonths / 12).toStringAsFixed(1)} سنة)',
            ),
            _infoBadge(
              'المدة المتاحة',
              '${_retireInfo!.remainingMonths} شهر',
            ),
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
          // مدة التمويل dropdown
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('مدة التمويل (شهر) *',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.calcMuted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<int>(
                    initialValue: _loanMonths,
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
                    dropdownColor: AppColors.calcCard,
                    decoration: _inputDeco(),
                    isExpanded: true,
                  ),
                ]),
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

        // Calculate button
        CalculatorNeonButton(
          label: 'احسب الآن',
          onTap: _calculate,
        ),
      ]);

  Widget _buildResultCard() => RepaintBoundary(
        key: _resultKey,
        child: CalculatorNeonCard(isResult: true, children: [
          const ResultSectionHeader(title: 'النتيجة', icon: '📊'),
          if (_result == null)
            SizedBox(
              height: 360,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card,
                          size: 42,
                          color:
                              AppColors.calcText.withValues(alpha: 0.25)),
                      const SizedBox(height: 10),
                      const Text('أدخل البيانات واضغط «احسب»',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.calcMuted)),
                    ]),
              ),
            )
          else ...[
            const ResultSectionHeader(
                title: 'الاستقطاع والقسط', icon: '📊'),
            CalculatorResultRow(
              label: 'نسبة الاستقطاع',
              value: _result!.workStatus == 'موظف' ? '33.33%' : '25%',
            ),
            CalculatorResultRow(
              label: 'القسط الشهري',
              value: '${_fmt(_result!.monthlyInstallment)} ر.س',
              highlight: ResultHighlight.neon,
            ),
            CalculatorResultRow(
              label: 'إجمالي التمويل',
              value: '${_fmt(_result!.totalFinance)} ر.س',
            ),

            const ResultSectionHeader(
                title: 'مبالغ التمويل', icon: '🏦'),
            CalculatorResultRow(
              label: 'مبلغ الموافقة',
              value: '${_fmt(_result!.approvedAmount)} ر.س',
              highlight: ResultHighlight.gold,
            ),
            CalculatorResultRow(
              label: 'ربح البنك',
              value: '${_fmt(_result!.bankProfit)} ر.س',
            ),

            const ResultSectionHeader(
                title: 'الرسوم والضريبة', icon: '💳'),
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
            CalculatorResultRow(
              label: 'صافي مبلغ التمويل',
              value: '${_fmt(_result!.netAmount)} ر.س',
              highlight: ResultHighlight.green,
            ),

            // Decision badge
            _buildDecisionBadge(),
          ],
        ]),
      );

  Widget _buildDecisionBadge() {
    final ok = _result!.isApproved;
    if (ok) {
      return const DecisionBadge(
        approved: true,
        approvedText: 'مقبول — تم الاحتساب بنجاح',
      );
    } else if (!_result!.retirement.eligible) {
      return const DecisionBadge(
        approved: false,
        rejectedText: 'غير مؤهل — المدة المتبقية أقل من 60 شهر',
      );
    } else {
      // Warning state
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.calcGold.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.calcGold),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Center(
          child: Text('راجع البيانات',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.calcGold,
                  letterSpacing: 0.5)),
        ),
      );
    }
  }

  Widget _buildBottomCards() => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: CalculatorGridRow(
          breakpoint: 600,
          children: [
            _btmCard(
                'جدول الأقساط',
                'عرض التفاصيل الشهرية الكاملة',
                'عرض',
                _showSchedule),
            _btmCard(
                'تصدير النتيجة',
                'PDF أو صورة للنتائج',
                'تصدير',
                _exportImage),
          ],
        ),
      );

  Widget _btmCard(
          String title, String desc, String action, VoidCallback onTap) =>
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
      subtitle: 'حاسبة التمويل الشخصي المختصر',
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
          _buildBottomCards(),
        ],
      ),
    );
  }
}
