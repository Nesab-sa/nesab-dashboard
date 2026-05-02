import 'dart:typed_data';
import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/personal_finance_calculator.dart';
import 'package:nesab_dashboard/features/calculators/data/models/common/employment_type.dart';
import 'package:nesab_dashboard/features/calculators/data/models/common/military_rank.dart';
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
// Military rank groups for the dropdown (matching HTML exactly)
// ---------------------------------------------------------------------------
const _milTypes = ['طيار', 'غير طيار', 'أفراد'];

List<MilitaryRank> _ranksForMilType(String milType) {
  switch (milType) {
    case 'طيار':
      return MilitaryRank.pilots;
    case 'غير طيار':
      return MilitaryRank.nonPilotOfficers;
    case 'أفراد':
      return MilitaryRank.enlisted;
    default:
      return MilitaryRank.pilots;
  }
}

// ---------------------------------------------------------------------------
// PersonalFinancePage
// ---------------------------------------------------------------------------
class PersonalFinancePage extends StatefulWidget {
  const PersonalFinancePage({super.key});

  @override
  State<PersonalFinancePage> createState() => _PersonalFinancePageState();
}

class _PersonalFinancePageState extends State<PersonalFinancePage> {
  // Controllers
  final _salaryCtrl = TextEditingController(text: '19165');
  final _profitRateCtrl = TextEditingController(text: '1');
  final _ahliCardCtrl = TextEditingController(text: '0');
  final _otherCardCtrl = TextEditingController(text: '0');
  final _birthYearCtrl = TextEditingController(text: '1988');

  // State
  EmploymentType _workStatus = EmploymentType.civilianEmployee;
  String _milType = 'طيار';
  MilitaryRank? _militaryRank;
  int _birthMonth = 1;
  int _months = 60;
  String _mortgage = 'لا يوجد';
  PersonalFinanceResult? _result;

  final _resultKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _militaryRank = _ranksForMilType(_milType).first;
  }

  @override
  void dispose() {
    for (final c in [
      _salaryCtrl,
      _profitRateCtrl,
      _ahliCardCtrl,
      _otherCardCtrl,
      _birthYearCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Build input from state
  // -----------------------------------------------------------------------
  PersonalFinanceInput _getInput() {
    final birthYear = int.tryParse(_birthYearCtrl.text) ?? 1988;
    return PersonalFinanceInput(
      salary: double.tryParse(_salaryCtrl.text) ?? 0,
      employmentType: _workStatus,
      dateOfBirth: DateTime(birthYear, _birthMonth),
      profitRate: (double.tryParse(_profitRateCtrl.text) ?? 1) / 100,
      durationMonths: _months,
      ahliCreditCardLimit: double.tryParse(_ahliCardCtrl.text) ?? 0,
      otherCreditCardLimit: double.tryParse(_otherCardCtrl.text) ?? 0,
      hasRealEstateLoan: _mortgage == 'نعم يوجد',
      militaryRank: _workStatus == EmploymentType.militaryEmployee
          ? _militaryRank
          : null,
    );
  }

  // -----------------------------------------------------------------------
  // Retirement info (matches HTML calcRetire)
  // -----------------------------------------------------------------------
  Map<String, dynamic> _calcRetireInfo() {
    final input = _getInput();
    final today = DateTime.now();
    final ageMonths = (today.year - input.dateOfBirth.year) * 12 +
        (today.month - input.dateOfBirth.month);
    final ageYears = ageMonths / 12;

    int retireAge;
    if (_workStatus == EmploymentType.retired) {
      retireAge = 75;
    } else if (_workStatus == EmploymentType.civilianEmployee) {
      retireAge = 65;
    } else {
      retireAge = _militaryRank?.retirementAge ?? 60;
    }

    final retireMonths = retireAge * 12;
    final remMonths = retireMonths - ageMonths;
    final eligible = remMonths >= 60;

    return {
      'retireAge': retireAge,
      'ageYears': ageYears,
      'ageMonths': ageMonths,
      'remMonths': remMonths > 0 ? remMonths : 0,
      'eligible': eligible,
    };
  }

  // -----------------------------------------------------------------------
  // Calculate
  // -----------------------------------------------------------------------
  void _calculate() {
    final input = _getInput();
    if (input.salary == 0) {
      _snack('أدخل الراتب');
      return;
    }
    setState(
      () => _result = const PersonalFinanceCalculator().calculate(input),
    );
  }

  // -----------------------------------------------------------------------
  // Schedule
  // -----------------------------------------------------------------------
  void _showSchedule() {
    if (_result == null) {
      _snack('احسب أولاً');
      return;
    }
    final rows = const PersonalFinanceCalculator().schedule(_result!);
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
  // Export
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

  Widget _infoBadge(String key, String value,
      {String type = 'default'}) {
    Color borderColor;
    Color bgColor;
    Color valueColor;
    switch (type) {
      case 'ok':
        borderColor = AppColors.calcGreen.withValues(alpha: 0.4);
        bgColor = AppColors.calcGreen.withValues(alpha: 0.06);
        valueColor = AppColors.calcGreen;
      case 'warn':
        borderColor = AppColors.calcRed.withValues(alpha: 0.4);
        bgColor = AppColors.calcRed.withValues(alpha: 0.06);
        valueColor = AppColors.calcRed;
      default:
        borderColor = AppColors.calcNeon.withValues(alpha: 0.18);
        bgColor = AppColors.calcNeon.withValues(alpha: 0.06);
        valueColor = AppColors.calcNeon;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        SizedBox(
          width: 100,
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
                  color: valueColor)),
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
    final eligible = d.timeEligible && d.approvalAmount > 0;
    return 'تمويل شخصي بلص: وضع ${eligible ? "مؤهل" : "غير مؤهل"}, '
        'استقطاع ${(d.deductionRatio * 100).toStringAsFixed(2)}%, '
        'قسط ${_fmt(d.monthlyInstallment)} ريال, '
        'موافقة ${_fmt(d.approvalAmount)} ريال, '
        'صافي ${_fmt(d.netAfterAllDeductions)} ريال, '
        'رسوم ${_fmt(d.totalFees)} ريال, '
        'مدة ${(d.totalFinancing / d.monthlyInstallment).round()} شهر';
  }

  // -----------------------------------------------------------------------
  // Build sections
  // -----------------------------------------------------------------------
  Widget _buildInputCard() {
    final retireInfo = _calcRetireInfo();
    return CalculatorNeonCard(children: [
      const ResultSectionHeader(title: 'بيانات العميل', icon: '💳'),

      // -- الوضع الوظيفي --
      CalculatorSubSection(title: 'الوضع الوظيفي', children: [
        CalculatorGridRow(children: [
          // Work status dropdown
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
                DropdownButtonFormField<EmploymentType>(
                  initialValue: _workStatus,
                  items: EmploymentType.values
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.arabicLabel,
                              style: const TextStyle(
                                  color: AppColors.calcText,
                                  fontSize: 14))))
                      .toList(),
                  onChanged: (v) => setState(() {
                    _workStatus = v!;
                    if (v == EmploymentType.militaryEmployee) {
                      _militaryRank =
                          _ranksForMilType(_milType).first;
                    } else {
                      _militaryRank = null;
                    }
                  }),
                  dropdownColor: AppColors.calcCard,
                  decoration: _inputDeco(),
                  isExpanded: true,
                ),
              ],
            ),
          ),
          // Military type dropdown (shown only for military)
          if (_workStatus == EmploymentType.militaryEmployee)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('نوع العسكري',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.calcMuted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: _milType,
                    items: _milTypes
                        .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t,
                                style: const TextStyle(
                                    color: AppColors.calcText,
                                    fontSize: 14))))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _milType = v!;
                      _militaryRank =
                          _ranksForMilType(_milType).first;
                    }),
                    dropdownColor: AppColors.calcCard,
                    decoration: _inputDeco(),
                    isExpanded: true,
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
        ]),

        // Rank dropdown (shown only for military)
        if (_workStatus == EmploymentType.militaryEmployee)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الرتبة العسكرية',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.calcMuted,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                DropdownButtonFormField<MilitaryRank>(
                  initialValue: _militaryRank,
                  items: _ranksForMilType(_milType)
                      .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                              '${r.arabicLabel} (${r.retirementAge})',
                              style: const TextStyle(
                                  color: AppColors.calcText,
                                  fontSize: 14))))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _militaryRank = v),
                  dropdownColor: AppColors.calcCard,
                  decoration: _inputDeco(),
                  isExpanded: true,
                ),
              ],
            ),
          ),

        // Birth year / month
        CalculatorGridRow(children: [
          CalculatorNeonField(
            label: 'سنة الميلاد',
            controller: _birthYearCtrl,
            placeholder: '1988',
          ),
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
                  onChanged: (v) =>
                      setState(() => _birthMonth = v ?? 1),
                  dropdownColor: AppColors.calcCard,
                  decoration: _inputDeco(),
                  isExpanded: true,
                ),
              ],
            ),
          ),
        ]),

        // Retirement info badges
        _infoBadge('سن التقاعد', '${retireInfo['retireAge']} سنة'),
        _infoBadge('العمر الحالي',
            '${(retireInfo['ageYears'] as double).toStringAsFixed(1)} سنة (${retireInfo['ageMonths']} شهر)'),
        _infoBadge('المدة المتاحة', '${retireInfo['remMonths']} شهر'),
        _infoBadge(
          'الأهلية الزمنية',
          retireInfo['eligible'] as bool
              ? 'مؤهل للتمويل'
              : 'غير مؤهل (أقل من 60 شهر)',
          type: retireInfo['eligible'] as bool ? 'ok' : 'warn',
        ),

        // Mortgage
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
                items: const [
                  DropdownMenuItem(
                      value: 'لا يوجد',
                      child: Text('لا يوجد',
                          style: TextStyle(
                              color: AppColors.calcText, fontSize: 14))),
                  DropdownMenuItem(
                      value: 'نعم يوجد',
                      child: Text('نعم يوجد',
                          style: TextStyle(
                              color: AppColors.calcText, fontSize: 14))),
                ],
                onChanged: (v) =>
                    setState(() => _mortgage = v ?? 'لا يوجد'),
                dropdownColor: AppColors.calcCard,
                decoration: _inputDeco(),
                isExpanded: true,
              ),
            ],
          ),
        ),
      ]),

      // -- بيانات التمويل --
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
        // Duration dropdown
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
                initialValue: _months,
                items: [12, 24, 36, 48, 60]
                    .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text('$m شهر',
                            style: const TextStyle(
                                color: AppColors.calcText,
                                fontSize: 14))))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _months = v ?? 60),
                dropdownColor: AppColors.calcCard,
                decoration: _inputDeco(),
                isExpanded: true,
              ),
            ],
          ),
        ),
        CalculatorGridRow(children: [
          CalculatorNeonField(
            label: 'مجموع حدود بطاقات الأهلي *',
            controller: _ahliCardCtrl,
            placeholder: '0',
          ),
          CalculatorNeonField(
            label: 'مجموع حدود بطاقات البنوك الأخرى *',
            controller: _otherCardCtrl,
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
  }

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
            // نسبة الاستقطاع
            const ResultSectionHeader(title: 'نسبة الاستقطاع', icon: '📊'),
            CalculatorResultRow(
              label: 'نسبة الاستقطاع المطبقة',
              value:
                  '${(_result!.deductionRatio * 100).toStringAsFixed(2)}%',
            ),
            CalculatorResultRow(
              label: 'القسط الشهري',
              value: '${_fmt(_result!.monthlyInstallment)} ر.س',
              highlight: ResultHighlight.neon,
            ),

            // مبالغ التمويل
            const ResultSectionHeader(title: 'مبالغ التمويل', icon: '🏦'),
            CalculatorResultRow(
              label:
                  'إجمالي التمويل (${(_result!.totalFinancing / _result!.monthlyInstallment).round()} x القسط)',
              value: '${_fmt(_result!.totalFinancing)} ر.س',
            ),
            CalculatorResultRow(
              label: 'مبلغ الموافقة',
              value: '${_fmt(_result!.approvalAmount)} ر.س',
              highlight: ResultHighlight.gold,
            ),
            CalculatorResultRow(
              label: 'صافي التمويل (بعد كل الرسوم)',
              value: '${_fmt(_result!.netAfterAllDeductions)} ر.س',
              highlight: ResultHighlight.green,
            ),
            CalculatorResultRow(
              label: 'ربح البنك',
              value: '${_fmt(_result!.bankProfit)} ر.س',
            ),

            // الرسوم والضريبة
            const ResultSectionHeader(
                title: 'الرسوم والضريبة', icon: '💳'),
            CalculatorResultRow(
              label: 'الرسوم الإدارية (0.5% | أقصى 2,500)',
              value: '${_fmt(_result!.adminFees)} ر.س',
            ),
            CalculatorResultRow(
              label: 'الضريبة (15% على الرسوم)',
              value: '${_fmt(_result!.vat)} ر.س',
            ),
            CalculatorResultRow(
              label: 'إجمالي الرسوم',
              value: '${_fmt(_result!.totalFees)} ر.س',
            ),

            // Decision badge
            _buildDecisionBadge(),
          ],
        ]),
      );

  Widget _buildDecisionBadge() {
    final d = _result!;
    final eligible = d.timeEligible && d.approvalAmount > 0;

    if (eligible) {
      return const DecisionBadge(
        approved: true,
        approvedText: 'مقبول — مؤهل زمنياً ومالياً',
      );
    } else if (!d.timeEligible) {
      return const DecisionBadge(
        approved: false,
        rejectedText: 'غير مؤهل — المدة المتبقية أقل من 60 شهر',
      );
    } else {
      // Warning state — approval is zero but time-eligible
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
              _showSchedule,
            ),
            _btmCard(
              'تصدير النتيجة',
              'PDF أو صورة للنتائج',
              'تصدير',
              _exportImage,
            ),
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
      subtitle: 'حاسبة التمويل الشخصي بلص',
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
