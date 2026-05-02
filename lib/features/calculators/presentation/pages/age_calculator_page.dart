import 'package:flutter/material.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/tools_calculator.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_scaffold.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_result_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/result_section_header.dart';

class AgeCalculatorPage extends StatefulWidget {
  const AgeCalculatorPage({super.key});

  @override
  State<AgeCalculatorPage> createState() => _AgeCalculatorPageState();
}

class _AgeCalculatorPageState extends State<AgeCalculatorPage> {
  DateTime _birthDate = DateTime(1985, 5, 29);
  DateTime _todayDate = DateTime.now();
  AgeResult? _result;

  void _calculate() {
    setState(() {
      _result = const ToolsCalculator().calculateAge(
        dateOfBirth: _birthDate,
        today: _todayDate,
      );
    });
  }

  Future<void> _pickBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickToday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _todayDate,
      firstDate: DateTime(1920),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _todayDate = picked);
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _ctxBuilder() {
    if (_result == null) return '';
    return 'عمر ميلادي ${_result!.years} سنة و ${_result!.months} شهر، هجري ${_result!.hijriYears} سنة';
  }

  Widget _dateField(String label, DateTime date, VoidCallback onTap) {
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

  @override
  Widget build(BuildContext context) {
    return CalculatorNeonScaffold(
      subtitle: 'حاسبة العمر الميلادي والهجري',
      aiContextBuilder: _ctxBuilder,
      body: CalculatorNeonCard(
        children: [
          const ResultSectionHeader(title: 'حاسبة العمر', icon: '🎂'),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 500) {
                return Row(
                  children: [
                    Expanded(child: _dateField('تاريخ الميلاد (ميلادي)', _birthDate, _pickBirth)),
                    const SizedBox(width: 10),
                    Expanded(child: _dateField('تاريخ اليوم', _todayDate, _pickToday)),
                  ],
                );
              }
              return Column(
                children: [
                  _dateField('تاريخ الميلاد (ميلادي)', _birthDate, _pickBirth),
                  _dateField('تاريخ اليوم', _todayDate, _pickToday),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          CalculatorNeonButton(label: 'احسب العمر', onTap: _calculate),
          if (_result != null) ...[
            const SizedBox(height: 12),
            CalculatorResultRow(
              label: 'العمر الميلادي',
              value: '${_result!.years} سنة و ${_result!.months} شهر',
              highlight: ResultHighlight.neon,
            ),
            CalculatorResultRow(
              label: 'العمر بالأشهر',
              value: '${_result!.totalMonths} شهر',
            ),
            CalculatorResultRow(
              label: 'العمر الهجري (تقريبي)',
              value: '${_result!.hijriYears} سنة',
            ),
          ],
        ],
      ),
    );
  }
}
