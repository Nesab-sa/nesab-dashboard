import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/tools_calculator.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_scaffold.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_field.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_result_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_toggle_buttons.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/result_section_header.dart';

class DateConverterPage extends StatefulWidget {
  const DateConverterPage({super.key});

  @override
  State<DateConverterPage> createState() => _DateConverterPageState();
}

class _DateConverterPageState extends State<DateConverterPage> {
  bool _isAdToHijri = true;
  DateTime _gregorianDate = DateTime(1985, 5, 29);
  final _hjDayCtrl = TextEditingController(text: '10');
  final _hjMonthCtrl = TextEditingController(text: '9');
  final _hjYearCtrl = TextEditingController(text: '1405');
  String? _resultBig;
  List<_InfoItem> _resultInfo = [];

  void _convert() {
    final calc = const ToolsCalculator();
    setState(() {
      if (_isAdToHijri) {
        final r = calc.gregorianToHijri(
            _gregorianDate.year, _gregorianDate.month, _gregorianDate.day);
        _resultBig = '${r.day} / ${r.month} / ${r.year} هـ';
        _resultInfo = [
          _InfoItem('التاريخ الميلادي',
              '${_gregorianDate.day}/${_gregorianDate.month}/${_gregorianDate.year}'),
        ];
      } else {
        final hDay = int.tryParse(_hjDayCtrl.text) ?? 1;
        final hMonth = int.tryParse(_hjMonthCtrl.text) ?? 1;
        final hYear = int.tryParse(_hjYearCtrl.text) ?? 1400;
        final r = calc.hijriToGregorian(hDay, hMonth, hYear);
        _resultBig = '${r.day} / ${r.month} / ${r.year} م';
        _resultInfo = [
          _InfoItem('التاريخ الهجري', '$hDay / $hMonth / $hYear هـ'),
          _InfoItem('التاريخ الميلادي', '${r.day}/${r.month}/${r.year}'),
        ];
      }
    });
  }

  Future<void> _pickGregorian() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _gregorianDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _gregorianDate = picked);
  }

  @override
  void dispose() {
    _hjDayCtrl.dispose();
    _hjMonthCtrl.dispose();
    _hjYearCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return CalculatorNeonScaffold(
      subtitle: 'تحويل التاريخ ميلادي وهجري',
      aiContextBuilder: () => _resultBig != null ? 'نتيجة التحويل: $_resultBig' : '',
      body: CalculatorNeonCard(
        children: [
          const ResultSectionHeader(title: 'تحويل التاريخ', icon: '📅'),
          CalculatorToggleButtons(
            labels: const ['ميلادي ← هجري', 'هجري ← ميلادي'],
            selectedIndex: _isAdToHijri ? 0 : 1,
            onChanged: (i) => setState(() {
              _isAdToHijri = i == 0;
              _resultBig = null;
              _resultInfo = [];
            }),
          ),
          const SizedBox(height: 14),
          if (_isAdToHijri)
            _datePickerField('التاريخ الميلادي', _gregorianDate, _pickGregorian)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 500) {
                  return Row(
                    children: [
                      Expanded(child: CalculatorNeonField(label: 'اليوم', controller: _hjDayCtrl)),
                      const SizedBox(width: 8),
                      Expanded(child: CalculatorNeonField(label: 'الشهر', controller: _hjMonthCtrl)),
                      const SizedBox(width: 8),
                      Expanded(child: CalculatorNeonField(label: 'السنة الهجرية', controller: _hjYearCtrl)),
                    ],
                  );
                }
                return Column(
                  children: [
                    CalculatorNeonField(label: 'اليوم', controller: _hjDayCtrl),
                    CalculatorNeonField(label: 'الشهر', controller: _hjMonthCtrl),
                    CalculatorNeonField(label: 'السنة الهجرية', controller: _hjYearCtrl),
                  ],
                );
              },
            ),
          const SizedBox(height: 4),
          CalculatorNeonButton(label: 'تحويل', onTap: _convert),
          if (_resultBig != null) ...[
            const SizedBox(height: 12),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.calcNeon.withValues(alpha: 0.05),
                border: Border.all(color: AppColors.calcNeon.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_resultBig!,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.calcNeon)),
            ),
            const SizedBox(height: 8),
            for (final item in _resultInfo)
              CalculatorResultRow(
                label: item.label,
                value: item.value,
                highlight: ResultHighlight.neon,
              ),
          ],
        ],
      ),
    );
  }

  Widget _datePickerField(String label, DateTime date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.calcMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          InkWell(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.calcInput,
                border: Border.all(color: AppColors.calcBorder2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_fmtDate(date),
                  style: const TextStyle(color: AppColors.calcText, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);
  final String label;
  final String value;
}
