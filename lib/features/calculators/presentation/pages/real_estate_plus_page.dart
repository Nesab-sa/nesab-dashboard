import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/real_estate_plus_calculator.dart';
import 'package:nesab_dashboard/features/calculators/data/models/common/employment_type.dart';
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
// Work type labels for the HTML dropdown mapping
// ---------------------------------------------------------------------------
const _workTypes = <String, String>{
  'مدني': 'مدني',
  'عسكري أفراد': 'عسكري أفراد',
  'ضباط غير طيارين': 'ضباط غير طيارين',
  'ضباط طيارين': 'ضباط طيارين',
};

// Rank lists matching the HTML exactly
const _ranksEnlisted = <Map<String, dynamic>>[
  {'rank': 'جندي أول', 'age': 44},
  {'rank': 'عريف', 'age': 46},
  {'rank': 'وكيل رقيب', 'age': 48},
  {'rank': 'رقيب - رقيب أول', 'age': 50},
  {'rank': 'رئيس رقباء', 'age': 52},
];

const _ranksOfficersNonPilot = <Map<String, dynamic>>[
  {'rank': 'ملازم وملازم أول', 'age': 42},
  {'rank': 'نقيب', 'age': 46},
  {'rank': 'رائد', 'age': 48},
  {'rank': 'مقدم', 'age': 50},
  {'rank': 'عقيد', 'age': 52},
  {'rank': 'عميد', 'age': 54},
  {'rank': 'لواء', 'age': 56},
];

const _ranksOfficersPilot = <Map<String, dynamic>>[
  {'rank': 'ملازم وملازم أول', 'age': 44},
  {'rank': 'نقيب', 'age': 48},
  {'rank': 'رائد', 'age': 50},
  {'rank': 'مقدم', 'age': 52},
  {'rank': 'عقيد', 'age': 54},
  {'rank': 'عميد', 'age': 56},
  {'rank': 'لواء', 'age': 58},
];

const _months = <int, String>{
  1: 'يناير',
  2: 'فبراير',
  3: 'مارس',
  4: 'أبريل',
  5: 'مايو',
  6: 'يونيو',
  7: 'يوليو',
  8: 'أغسطس',
  9: 'سبتمبر',
  10: 'أكتوبر',
  11: 'نوفمبر',
  12: 'ديسمبر',
};

// ---------------------------------------------------------------------------
// RealEstatePlusPage
// ---------------------------------------------------------------------------
class RealEstatePlusPage extends StatefulWidget {
  const RealEstatePlusPage({super.key});

  @override
  State<RealEstatePlusPage> createState() => _RealEstatePlusPageState();
}

class _RealEstatePlusPageState extends State<RealEstatePlusPage> {
  // Controllers
  final _birthYearCtrl = TextEditingController(text: '1991');
  final _salaryCtrl = TextEditingController(text: '9767');
  final _mortgageYearsCtrl = TextEditingController(text: '25');
  final _profitRateCtrl = TextEditingController(text: '4.05');
  final _personalInstallCtrl = TextEditingController(text: '2922');
  final _remainingPersonalCtrl = TextEditingController(text: '60');
  final _fixedLoanCtrl = TextEditingController(text: '0');

  // State
  String _workType = 'مدني';
  int _birthMonth = 1;
  int _selectedRankAge = 60;
  bool _support = true;
  bool _etizaz = false;
  RealEstatePlusResult? _result;

  final _resultKey = GlobalKey();

  @override
  void dispose() {
    for (final c in [
      _birthYearCtrl,
      _salaryCtrl,
      _mortgageYearsCtrl,
      _profitRateCtrl,
      _personalInstallCtrl,
      _remainingPersonalCtrl,
      _fixedLoanCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Retirement helpers (matching HTML exactly)
  // -----------------------------------------------------------------------
  int get _retireAge {
    if (_workType == 'مدني') return 60;
    return _selectedRankAge;
  }

  int get _availableYears {
    final by = int.tryParse(_birthYearCtrl.text) ?? 1991;
    final bm = _birthMonth;
    final now = DateTime.now();
    int ageYears = now.year - by;
    if (now.month < bm) ageYears--;
    final avail = _retireAge - ageYears;
    return avail > 0 ? avail : 0;
  }

  String get _maxYearsHint {
    final avail = _availableYears;
    if (avail <= 0) return 'تجاوز سن التقاعد';
    final maxY = avail > 30 ? 30 : avail;
    return 'الحد الأقصى للمدة: $maxY سنة';
  }

  List<Map<String, dynamic>> get _currentRanks {
    switch (_workType) {
      case 'عسكري أفراد':
        return _ranksEnlisted;
      case 'ضباط غير طيارين':
        return _ranksOfficersNonPilot;
      case 'ضباط طيارين':
        return _ranksOfficersPilot;
      default:
        return [];
    }
  }

  EmploymentType get _employmentType {
    if (_workType == 'مدني') return EmploymentType.civilianEmployee;
    return EmploymentType.militaryEmployee;
  }

  // -----------------------------------------------------------------------
  // Calculate
  // -----------------------------------------------------------------------
  void _calculate() {
    final salary = double.tryParse(_salaryCtrl.text) ?? 0;
    if (salary <= 0) {
      _snack('أدخل الراتب');
      return;
    }

    final input = RealEstatePlusInput(
      salary: salary,
      employmentType: _employmentType,
      birthYear: int.tryParse(_birthYearCtrl.text) ?? 1991,
      birthMonth: _birthMonth,
      remainingPersonalMonths:
          int.tryParse(_remainingPersonalCtrl.text) ?? 0,
      personalInstallment:
          double.tryParse(_personalInstallCtrl.text) ?? 0,
      mortgageYears: int.tryParse(_mortgageYearsCtrl.text) ?? 25,
      profitRate:
          ((double.tryParse(_profitRateCtrl.text) ?? 4.05)) / 100,
      hasSupport: _support,
      hasEtizaz: _etizaz,
      fixedLoan: double.tryParse(_fixedLoanCtrl.text) ?? 0,
    );

    setState(
        () => _result = const RealEstatePlusCalculator().calculate(input));
  }

  // -----------------------------------------------------------------------
  // Schedule
  // -----------------------------------------------------------------------
  void _showSchedule() {
    if (_result == null) {
      _snack('احسب أولاً');
      return;
    }
    final rows = const RealEstatePlusCalculator().schedule(_result!);
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
          ...rows.map((r) => Container(
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
                    child: Text(
                        r.isPhase1 ? 'مع الشخصي' : 'بعد الشخصي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: r.isPhase1
                                ? AppColors.calcGold
                                : AppColors.calcGreen,
                            fontSize: 11)),
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
    return 'تمويل عقاري بلص (2في1): راتب ${_fmt(d.salary)} ريال، '
        'مدة ${d.finalYears} سنة، '
        'مبلغ ${_fmt(d.loanAmount2in1)} ريال، '
        'قسط1 ${_fmt(d.qistPhase1)} ريال، '
        'قسط2 ${_fmt(d.qistPhase2)} ريال، '
        'دعم سكني ${d.hasSupport ? _fmt(d.housingSupport) : 'لا'}، '
        'اعتزاز ${d.hasEtizaz ? 'نعم' : 'لا'}، '
        'إجمالي مع دعم ${_fmt(d.totalWithSupport)} ريال';
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
  // Build sections
  // -----------------------------------------------------------------------
  Widget _buildInputCard() => CalculatorNeonCard(children: [
        const ResultSectionHeader(title: 'بيانات العميل', icon: '🏠'),

        // Personal Info
        CalculatorSubSection(title: 'المعلومات الشخصية', children: [
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'سنة الميلاد',
              controller: _birthYearCtrl,
              placeholder: '1991',
            ),
            _styledDropdown<int>(
              label: 'شهر الميلاد',
              value: _birthMonth,
              items: _months.entries
                  .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value,
                          style: const TextStyle(
                              color: AppColors.calcText,
                              fontSize: 14))))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _birthMonth = v ?? 1),
            ),
          ]),
          // Work type
          _styledDropdown<String>(
            label: 'جهة العمل',
            value: _workType,
            items: _workTypes.entries
                .map((e) => DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value,
                        style: const TextStyle(
                            color: AppColors.calcText, fontSize: 14))))
                .toList(),
            onChanged: (v) {
              setState(() {
                _workType = v ?? 'مدني';
                if (_workType != 'مدني' &&
                    _currentRanks.isNotEmpty) {
                  _selectedRankAge =
                      _currentRanks.first['age'] as int;
                }
              });
            },
          ),
          // Rank (shown only for military)
          if (_workType != 'مدني')
            _styledDropdown<int>(
              label: 'الرتبة',
              value: _selectedRankAge,
              items: _currentRanks
                  .map((r) => DropdownMenuItem(
                      value: r['age'] as int,
                      child: Text(
                          '${r['rank']} (${r['age']})',
                          style: const TextStyle(
                              color: AppColors.calcText,
                              fontSize: 14))))
                  .toList(),
              onChanged: (v) => setState(
                  () => _selectedRankAge = v ?? 60),
            ),
          // Retire badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.calcNeon.withValues(alpha: 0.08),
              border: Border.all(
                  color: AppColors.calcNeon.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Text('سن التقاعد: ',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.calcNeon)),
              Text('$_retireAge',
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
              const Text(' | المدة المتاحة: ',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.calcNeon)),
              Text('$_availableYears',
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
              const Text(' سنة',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.calcNeon)),
            ]),
          ),
        ]),

        // Finance Data
        CalculatorSubSection(title: 'بيانات التمويل', children: [
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'راتب العميل (ريال)',
              controller: _salaryCtrl,
              placeholder: '9767',
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalculatorNeonField(
                  label: 'مدة التمويل العقاري (سنة)',
                  controller: _mortgageYearsCtrl,
                  placeholder: '25',
                ),
                Text(_maxYearsHint,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.calcNeon2)),
              ],
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
              controller: _personalInstallCtrl,
              placeholder: '0',
            ),
          ]),
          CalculatorNeonField(
            label: 'عدد الأقساط المتبقية من التمويل الشخصي (شهر)',
            controller: _remainingPersonalCtrl,
            placeholder: '60',
          ),
        ]),

        // Options
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
        child: CalculatorNeonCard(
          isResult: true,
          children: [
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
                    ],
                  ),
                ),
              )
            else ...[
              // Duration section
              _resSection('بيانات المدة'),
              CalculatorResultRow(
                label: 'المدة المتاحة للعميل',
                value: '${_result!.availableYears} سنة',
              ),
              CalculatorResultRow(
                label: 'مدة التمويل المعتمدة',
                value:
                    '${_result!.finalYears} سنة (${_result!.totalMonths} شهر)',
              ),
              CalculatorResultRow(
                label: 'نسبة الاستقطاع المسموحة',
                value:
                    '${(_result!.dedRate * 100).toStringAsFixed(0)}%',
              ),

              // 2-in-1 section
              _resSection('برنامج 2 في 1'),
              CalculatorResultRow(
                label: 'مبلغ التمويل العقاري (2 في 1)',
                value: '${_fmt(_result!.loanAmount2in1)} ر.س',
                highlight: ResultHighlight.neon,
              ),
              CalculatorResultRow(
                label: 'القسط خلال فترة التمويل الشخصي',
                value: '${_fmt(_result!.qistPhase1)} ر.س / شهر',
              ),
              CalculatorResultRow(
                label: 'القسط بعد انتهاء التمويل الشخصي',
                value: '${_fmt(_result!.qistPhase2)} ر.س / شهر',
              ),
              CalculatorResultRow(
                label: 'فترة التمويل الشخصي المتبقية',
                value: '${_result!.remainingPersonalMonths} شهر',
              ),
              CalculatorResultRow(
                label: 'الأشهر بعد انتهاء الشخصي',
                value: '${_result!.remainingMortgageMonths} شهر',
              ),

              // Total with support section
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
                    ? '${_fmt(_result!.etizazAmount)} ر.س'
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

              // Fixed loan section (if applicable)
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

              // Decision badge
              _buildDecisionBadge(),
            ],
          ],
        ),
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

  Widget _buildDecisionBadge() {
    final ok = _result!.availableYears >= _result!.finalYears;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: ok
            ? AppColors.calcGreen.withValues(alpha: 0.1)
            : AppColors.calcGold.withValues(alpha: 0.1),
        border:
            Border.all(color: ok ? AppColors.calcGreen : AppColors.calcGold),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: Text(
          ok
              ? 'مؤهل -- المدة ضمن سن التقاعد'
              : 'تعديل مطلوب -- المدة المتاحة ${_result!.availableYears} سنة فقط',
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: ok ? AppColors.calcGreen : AppColors.calcGold,
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
            _btmCard(
                'جدول الأقساط التفصيلي',
                'قسط فترة التمويل الشخصي + قسط ما بعده',
                'عرض',
                _showSchedule),
            _btmCard(
                'تصدير النتيجة',
                'حفظ التقرير كاملاً كصورة',
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
            ],
          ),
        ),
      );

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CalculatorNeonScaffold(
      subtitle: 'حاسبة التمويل العقاري بلص (2 في 1)',
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
