import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/leasing_calculator.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_export_buttons.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_field.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_scaffold.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_result_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_sub_section.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_toggle_buttons.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_grid_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/decision_badge.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/deduction_bar.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/required_dp_box.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/result_section_header.dart';

String _fmt(num n) => NumberFormat('#,##0', 'en_US').format(n.round());

// ---------------------------------------------------------------------------
// LeasingPage
// ---------------------------------------------------------------------------
class LeasingPage extends StatefulWidget {
  const LeasingPage({super.key, required this.isMicro});
  final bool isMicro;

  @override
  State<LeasingPage> createState() => _LeasingPageState();
}

class _LeasingPageState extends State<LeasingPage> {
  // Controllers
  final _salaryCtrl = TextEditingController(text: '10779');
  final _carPriceCtrl = TextEditingController(text: '121325');
  final _profitRateCtrl = TextEditingController(text: '4.7');
  final _adminFeeCtrl = TextEditingController(text: '1250');
  final _plateFeeCtrl = TextEditingController(text: '900');
  final _personalCtrl = TextEditingController(text: '3225');
  final _otherDedCtrl = TextEditingController(text: '0');
  final _realEstateCtrl = TextEditingController(text: '0');
  final _downPctCtrl = TextEditingController(text: '0');
  final _downAmtCtrl = TextEditingController(text: '0');
  final _lastPctCtrl = TextEditingController(text: '45');
  final _lastAmtCtrl = TextEditingController(text: '0');
  final _insPctCtrl = TextEditingController(text: '5.45');
  final _insAmtCtrl = TextEditingController(text: '0');

  // State
  String _segment = 'رواتب-حكومي';
  int _months = 60;
  String _downMode = 'pct';
  String _lastMode = 'pct';
  String _insMode = 'pct';
  LeasingResult? _result;
  String? _activeMode;

  final _resultKey = GlobalKey();

  @override
  void dispose() {
    for (final c in [
      _salaryCtrl, _carPriceCtrl, _profitRateCtrl, _adminFeeCtrl,
      _plateFeeCtrl, _personalCtrl, _otherDedCtrl, _realEstateCtrl,
      _downPctCtrl, _downAmtCtrl, _lastPctCtrl, _lastAmtCtrl,
      _insPctCtrl, _insAmtCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Input builder
  // -----------------------------------------------------------------------
  LeasingInput _getInput() {
    return LeasingInput(
      salary: double.tryParse(_salaryCtrl.text) ?? 0,
      segment: _segment,
      carPrice: double.tryParse(_carPriceCtrl.text) ?? 0,
      months: _months,
      costRate: ((double.tryParse(_profitRateCtrl.text) ?? 4.7)) / 100,
      isMicro: widget.isMicro,
      adminFee: double.tryParse(_adminFeeCtrl.text) ?? 1250,
      plateFee: double.tryParse(_plateFeeCtrl.text) ?? 0,
      personal: double.tryParse(_personalCtrl.text) ?? 0,
      otherDed: double.tryParse(_otherDedCtrl.text) ?? 0,
      realEstate: double.tryParse(_realEstateCtrl.text) ?? 0,
      downPaymentIsPercent: _downMode == 'pct',
      downPaymentValue: _downMode == 'pct'
          ? (double.tryParse(_downPctCtrl.text) ?? 0)
          : (double.tryParse(_downAmtCtrl.text) ?? 0),
      lastPaymentIsPercent: _lastMode == 'pct',
      lastPaymentValue: _lastMode == 'pct'
          ? (double.tryParse(_lastPctCtrl.text) ?? 45)
          : (double.tryParse(_lastAmtCtrl.text) ?? 0),
      insuranceIsPercent: _insMode == 'pct',
      insuranceValue: _insMode == 'pct'
          ? (double.tryParse(_insPctCtrl.text) ?? 5.45)
          : (double.tryParse(_insAmtCtrl.text) ?? 0),
    );
  }

  // -----------------------------------------------------------------------
  // Calculate
  // -----------------------------------------------------------------------
  void _calculate() {
    final input = _getInput();
    if (input.salary == 0 || input.carPrice == 0) {
      _snack('أدخل الراتب وسعر السيارة');
      return;
    }
    setState(() => _result = const LeasingCalculator().calculate(input));
  }

  // -----------------------------------------------------------------------
  // Mode: by car price
  // -----------------------------------------------------------------------
  void _calcByCarPrice() {
    final input = _getInput();
    if (input.salary == 0 || input.carPrice == 0) {
      _snack('أدخل الراتب وسعر السيارة');
      return;
    }
    setState(() => _activeMode = 'car');
    final r = const LeasingCalculator().calcByCarPrice(input);
    _showSamaDialog(
      title: 'تم احتساب التمويل بنجاح',
      rows: [
        ['المبلغ', '${_fmt(r.carPrice)} ريال'],
        ['الدفعة الأولى الإلزامية', '${_fmt(r.downPay)} ريال'],
        ['الدفعة الأخيرة', '${_fmt(r.lastAmt)} ريال'],
        ['القسط الشهري', '${_fmt(r.monthly)} ريال'],
        ['الإجمالي', '${_fmt(r.total)} ريال'],
      ],
      onConfirm: () {
        _downPctCtrl.text = '0';
        if (_downMode == 'amt') _downAmtCtrl.text = '0';
        _calculate();
      },
    );
  }

  // -----------------------------------------------------------------------
  // Mode: max car price
  // -----------------------------------------------------------------------
  void _calcMaxCarPrice() {
    final input = _getInput();
    if (input.salary == 0) {
      _snack('أدخل الراتب');
      return;
    }
    final r = const LeasingCalculator().calcMaxCarPrice(input);
    if (r == null) {
      _snack('الالتزامات تستهلك كامل نسبة الاستقطاع');
      return;
    }
    setState(() => _activeMode = 'max');
    _showSamaDialog(
      title: 'أقصى تمويل متاح للعميل',
      rows: [
        ['المبلغ', '${_fmt(r.carPrice)} ريال'],
        ['الدفعة الأولى', '${_fmt(r.downPay)} ريال'],
        ['الدفعة الأخيرة', '${_fmt(r.lastAmt)} ريال'],
        ['القسط الشهري', '${_fmt(r.monthly)} ريال'],
        ['الإجمالي', '${_fmt(r.total)} ريال'],
      ],
      onConfirm: () {
        _carPriceCtrl.text = r.carPrice.round().toString();
        if (_downMode == 'pct') {
          _downPctCtrl.text = '0';
        } else {
          _downAmtCtrl.text = '0';
        }
        _calculate();
      },
    );
  }

  // -----------------------------------------------------------------------
  // SAMA dialog
  // -----------------------------------------------------------------------
  void _showSamaDialog({
    required String title,
    required List<List<String>> rows,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.fromLTRB(26, 28, 26, 28),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.info_outline,
                          color: Color(0xFF1976D2), size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('نظام الاعتماد البنكي (SAMA)',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A))),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close,
                          color: Color(0xFF666666), size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 14),
                ...rows.map((r) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Color(0xFFF0F0F0))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r[0],
                              style: const TextStyle(
                                  fontSize: 14, color: Color(0xFF555555))),
                          Text(r[1],
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A))),
                        ],
                      ),
                    )),
                const SizedBox(height: 18),
                const Text('هل تريد ترجمة الاحتساب على الآلة ؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF333333))),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('نعم',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          side: const BorderSide(color: Color(0xFFCCCCCC)),
                        ),
                        child: const Text('لا',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF333333))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Schedule
  // -----------------------------------------------------------------------
  void _showSchedule() {
    if (_result == null) { _snack('احسب أولاً'); return; }
    final rows = const LeasingCalculator().schedule(_result!);
    _showModal(
      title: 'جدول الأقساط',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: const Color(0xFF061228),
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            child: Row(children: [
              Expanded(child: Text('الشهر', textAlign: TextAlign.right,
                  style: TextStyle(color: AppColors.calcNeon, fontSize: 13, fontWeight: FontWeight.w600))),
              Expanded(child: Text('القسط', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.calcNeon, fontSize: 13, fontWeight: FontWeight.w600))),
              Expanded(child: Text('إجمالي مدفوع', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.calcNeon, fontSize: 13, fontWeight: FontWeight.w600))),
            ]),
          ),
          ...rows.map((r) => Container(
                decoration: BoxDecoration(
                  color: r.isLast ? AppColors.calcGreen.withValues(alpha: 0.07) : null,
                  border: const Border(bottom: BorderSide(color: AppColors.calcBorder, width: 1)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: Row(children: [
                  Expanded(child: Text('${r.month}', textAlign: TextAlign.right,
                      style: TextStyle(color: r.isLast ? AppColors.calcGreen : AppColors.calcText, fontSize: 13))),
                  Expanded(child: Text('${_fmt(r.payment)}${r.isLast ? ' *' : ''}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: r.isLast ? AppColors.calcGreen : AppColors.calcText, fontSize: 13))),
                  Expanded(child: Text(_fmt(r.cumulative), textAlign: TextAlign.center,
                      style: TextStyle(color: r.isLast ? AppColors.calcGreen : AppColors.calcText, fontSize: 13))),
                ]),
              )),
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text('* يشمل الدفعة الأخيرة ${_fmt(_result!.lastAmt)} ر.س',
                style: const TextStyle(fontSize: 11, color: AppColors.calcMuted)),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Compare durations
  // -----------------------------------------------------------------------
  void _compareLoans() {
    if (_result == null) { _snack('احسب أولاً'); return; }
    final rows = const LeasingCalculator().compareDurations(_result!);
    _showModal(
      title: 'مقارنة مدد التمويل',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: const Color(0xFF061228),
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
            child: Row(children: [
              Expanded(child: Text('المدة', textAlign: TextAlign.right,
                  style: TextStyle(color: AppColors.calcNeon, fontSize: 13, fontWeight: FontWeight.w600))),
              Expanded(child: Text('القسط', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.calcNeon, fontSize: 13, fontWeight: FontWeight.w600))),
              Expanded(child: Text('كلفة الآجل', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.calcNeon, fontSize: 13, fontWeight: FontWeight.w600))),
              Expanded(child: Text('الإجمالي', textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.calcNeon, fontSize: 13, fontWeight: FontWeight.w600))),
            ]),
          ),
          ...rows.map((r) => Container(
                decoration: BoxDecoration(
                  color: r.isCurrent ? AppColors.calcNeon2.withValues(alpha: 0.1) : null,
                  border: const Border(bottom: BorderSide(color: AppColors.calcBorder, width: 1)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Row(children: [
                  Expanded(child: Text('${r.months} شهر${r.isCurrent ? ' ✓' : ''}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: AppColors.calcText, fontSize: 13))),
                  Expanded(child: Text(_fmt(r.monthly), textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.calcText, fontSize: 13))),
                  Expanded(child: Text(_fmt(r.cost), textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.calcText, fontSize: 13))),
                  Expanded(child: Text(_fmt(r.total), textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.calcText, fontSize: 13))),
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
                    Text(title, style: const TextStyle(
                        color: AppColors.calcNeon, fontSize: 14, fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, color: AppColors.calcMuted, size: 18),
                      padding: EdgeInsets.zero, constraints: const BoxConstraints(),
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
    if (_result == null) { _snack('احسب أولاً'); return; }
    try {
      final boundary = _resultKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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
                    const Text('النتيجة', style: TextStyle(
                        color: AppColors.calcNeon, fontSize: 14, fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, color: AppColors.calcMuted),
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
  static final _numFmt = FilteringTextInputFormatter.allow(RegExp(r'[\d.]'));

  void _setMode(String field, String mode) {
    switch (field) {
      case 'down': _downMode = mode;
      case 'last': _lastMode = mode;
      case 'ins':  _insMode = mode;
    }
  }

  Widget _dualField(String label, String field) {
    final mode = field == 'down' ? _downMode : field == 'last' ? _lastMode : _insMode;
    final pctCtrl = field == 'down' ? _downPctCtrl : field == 'last' ? _lastPctCtrl : _insPctCtrl;
    final amtCtrl = field == 'down' ? _downAmtCtrl : field == 'last' ? _lastAmtCtrl : _insAmtCtrl;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(
              fontSize: 12, color: AppColors.calcMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          CalculatorToggleButtons(
            labels: const ['نسبة %', 'مبلغ'],
            selectedIndex: mode == 'pct' ? 0 : 1,
            onChanged: (i) => setState(() => _setMode(field, i == 0 ? 'pct' : 'amt')),
          ),
          TextField(
            controller: mode == 'pct' ? pctCtrl : amtCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_numFmt],
            style: const TextStyle(color: AppColors.calcText, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.calcInput,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              isDense: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.calcBorder2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.calcBorder2)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.calcNeon2, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // AI context builder
  // -----------------------------------------------------------------------
  String _buildAiContext() {
    final d = _result;
    if (d == null) return '';
    return 'بيانات التمويل: راتب ${_fmt(d.salary)} ريال، شريحة ${d.segment}، '
        'سعر سيارة ${_fmt(d.carPrice)} ريال، مدة ${d.months} شهر، '
        'قسط ${_fmt(d.monthly)} ريال، إجمالي ${_fmt(d.total)} ريال، '
        'نسبة استقطاع ${(d.actualR * 100).toStringAsFixed(1)}%، '
        'القرار ${d.approved ? 'مقبول' : 'مرفوض'}'
        '${!d.approved ? '، الدفعة المطلوبة ${_fmt(d.reqDown)} ريال' : ''}';
  }

  // -----------------------------------------------------------------------
  // Build sections
  // -----------------------------------------------------------------------
  Widget _buildInputCard() => CalculatorNeonCard(children: [
        const ResultSectionHeader(title: 'بيانات العميل والتمويل'),
        CalculatorSubSection(title: 'معلومات العميل', children: [
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'راتب العميل (ريال)',
              controller: _salaryCtrl,
              placeholder: '10000',
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('شريحة العميل',
                    style: TextStyle(fontSize: 12, color: AppColors.calcMuted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: _segment,
                  items: leasingSegmentLabels.entries
                      .map((e) => DropdownMenuItem(value: e.key,
                          child: Text(e.value, style: const TextStyle(color: AppColors.calcText, fontSize: 14))))
                      .toList(),
                  onChanged: (v) => setState(() => _segment = v!),
                  dropdownColor: AppColors.calcCard,
                  style: const TextStyle(color: AppColors.calcText, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.calcInput,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.calcBorder2)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.calcBorder2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.calcNeon2)),
                  ),
                  isExpanded: true,
                ),
              ]),
            ),
          ]),
        ]),
        CalculatorSubSection(title: 'بيانات التمويل', children: [
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'سعر السيارة (ريال)',
              controller: _carPriceCtrl,
              placeholder: '100000',
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('مدة التمويل (شهر)',
                    style: TextStyle(fontSize: 12, color: AppColors.calcMuted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                DropdownButtonFormField<int>(
                  initialValue: _months,
                  items: [12, 24, 36, 48, 60]
                      .map((m) => DropdownMenuItem(value: m,
                          child: Text('$m شهر', style: const TextStyle(color: AppColors.calcText, fontSize: 14))))
                      .toList(),
                  onChanged: (v) => setState(() => _months = v!),
                  dropdownColor: AppColors.calcCard,
                  style: const TextStyle(color: AppColors.calcText, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.calcInput,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.calcBorder2)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.calcBorder2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.calcNeon2)),
                  ),
                  isExpanded: true,
                ),
              ]),
            ),
          ]),
          CalculatorGridRow(children: [
            CalculatorNeonField(
              label: 'هامش الربح / كلفة الآجل (%)',
              controller: _profitRateCtrl,
              placeholder: '4.7',
            ),
            CalculatorNeonField(
              label: 'الرسوم الإدارية (ريال)',
              controller: _adminFeeCtrl,
              placeholder: '1250',
            ),
          ]),
          CalculatorNeonField(
            label: 'رسوم اللوحات (ريال)',
            controller: _plateFeeCtrl,
            placeholder: '900',
          ),
        ]),
        CalculatorSubSection(title: 'الدفعات — نسبة % أو مبلغ من سعر السيارة', children: [
          CalculatorGridRow(breakpoint: 500, children: [
            _dualField('الدفعة الأولى', 'down'),
            _dualField('الدفعة الأخيرة', 'last'),
            _dualField('التأمين', 'ins'),
          ]),
        ]),
        CalculatorSubSection(title: 'الالتزامات الحالية', children: [
          CalculatorGridRow(breakpoint: 500, children: [
            CalculatorNeonField(
              label: 'قسط تمويل شخصي',
              controller: _personalCtrl,
              placeholder: '0',
            ),
            CalculatorNeonField(
              label: 'التزامات أخرى',
              controller: _otherDedCtrl,
              placeholder: '0',
            ),
            CalculatorNeonField(
              label: 'قسط تمويل عقاري',
              controller: _realEstateCtrl,
              placeholder: '0',
            ),
          ]),
        ]),
        // Mode buttons
        Row(children: [
          Expanded(child: _modeBtn('احتساب بناء على سعر السيارة', _activeMode == 'car', _calcByCarPrice)),
          const SizedBox(width: 8),
          Expanded(child: _modeBtn('أقصى سعر للسيارة', _activeMode == 'max', _calcMaxCarPrice)),
        ]),
        const SizedBox(height: 12),
        // Calculate button
        CalculatorNeonButton(label: 'احسب الآن', onTap: _calculate),
      ]);

  Widget _modeBtn(String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: on ? const LinearGradient(colors: [AppColors.calcNeon2, AppColors.calcPurple]) : null,
            color: on ? null : AppColors.calcCard,
            border: Border.all(color: on ? Colors.transparent : AppColors.calcBorder2),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                  color: on ? Colors.white : AppColors.calcText, height: 1.4)),
        ),
      );

  Widget _buildResultCard() => RepaintBoundary(
        key: _resultKey,
        child: CalculatorNeonCard(isResult: true, children: [
          const ResultSectionHeader(title: 'النتيجة'),
          if (_result == null)
            SizedBox(
              height: 280,
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.monitor, size: 42, color: AppColors.calcText.withValues(alpha: 0.25)),
                  const SizedBox(height: 10),
                  const Text('أدخل البيانات واضغط «احسب»',
                      style: TextStyle(fontSize: 14, color: AppColors.calcMuted)),
                ]),
              ),
            )
          else ...[
            CalculatorResultRow(
              label: 'القسط الشهري',
              value: '${_fmt(_result!.monthly)} ر.س',
              highlight: ResultHighlight.neon,
            ),
            CalculatorResultRow(
              label: 'مبلغ التمويل',
              value: '${_fmt(_result!.fin)} ر.س',
            ),
            CalculatorResultRow(
              label: 'كلفة الآجل (ربح البنك)',
              value: '${_fmt(_result!.costTotal)} ر.س',
            ),
            CalculatorResultRow(
              label: 'التأمين',
              value: '${_fmt(_result!.insAmt)} ر.س',
            ),
            CalculatorResultRow(
              label: 'الرسوم الإدارية',
              value: '${_fmt(_result!.adminFee)} ر.س',
            ),
            CalculatorResultRow(
              label: 'الدفعة الأولى',
              value: '${_fmt(_result!.downPay)} ر.س',
            ),
            CalculatorResultRow(
              label: 'الدفعة الأخيرة',
              value: '${_fmt(_result!.lastAmt)} ر.س',
            ),
            CalculatorResultRow(
              label: 'إجمالي السداد',
              value: '${_fmt(_result!.total)} ر.س',
            ),
            DeductionBar(
              actualPercent: _result!.actualR,
              limitPercent: _result!.dedRate,
            ),
            DecisionBadge(
              approved: _result!.approved,
              approvedText: 'مقبول — الطلب ضمن شروط ساما',
              rejectedText: 'مرفوض — تجاوز نسبة الاستقطاع',
            ),
            if (!_result!.approved)
              RequiredDpBox(
                title: 'لإقرار الطلب — ارفع الدفعة الأولى بمبلغ',
                value: '${_fmt(_result!.reqDown)} ريال',
                subtitle: 'أي ما يعادل ${(_result!.reqDown / _result!.carPrice * 100).toStringAsFixed(1)}% من سعر السيارة',
              ),
          ],
        ]),
      );

  Widget _buildBottomCards() => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: LayoutBuilder(builder: (context, constraints) {
          final cards = [
            _btmCard('جدول الأقساط', 'عرض التفاصيل الشهرية الكاملة', 'عرض', _showSchedule),
            _btmCard('مقارنة المدد', 'قارن 12 / 24 / 36 / 48 / 60 شهر', 'مقارنة', _compareLoans),
            _btmCard('تصدير النتيجة', 'PDF أو صورة للنتائج', 'تصدير', _exportImage),
          ];
          if (constraints.maxWidth < 600) {
            return Column(
              children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 14), child: c)).toList(),
            );
          }
          return Row(
            children: cards.expand((c) => [
                  Expanded(child: c),
                  if (c != cards.last) const SizedBox(width: 14),
                ]).toList(),
          );
        }),
      );

  Widget _btmCard(String title, String desc, String action, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.calcCard,
            border: Border.all(color: AppColors.calcBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.calcNeon)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.calcMuted, height: 1.5)),
            const SizedBox(height: 6),
            Text(action, style: const TextStyle(fontSize: 12, color: AppColors.calcNeon2)),
          ]),
        ),
      );

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return CalculatorNeonScaffold(
      subtitle: widget.isMicro
          ? 'حاسبة التمويل التأجيري العادي'
          : 'حاسبة التمويل التأجيري للسيارات',
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
