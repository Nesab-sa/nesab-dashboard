import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/features/calculators/data/calculators/tools_calculator.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_scaffold.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_neon_field.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_result_row.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/calculator_toggle_buttons.dart';
import 'package:nesab_dashboard/features/calculators/presentation/widgets/result_section_header.dart';

String _fmt(num n) => NumberFormat('#,##0', 'en_US').format(n.round());

class DeductionCalculatorPage extends StatefulWidget {
  const DeductionCalculatorPage({super.key});

  @override
  State<DeductionCalculatorPage> createState() => _DeductionCalculatorPageState();
}

class _DeductionCalculatorPageState extends State<DeductionCalculatorPage> {
  bool _isRatioMode = true;
  final _salaryCtrl = TextEditingController(text: '15000');

  bool _yn33 = false;
  bool _yn45 = false;
  bool _yn5565 = false;

  DeductionRatioResult? _ratioResult;
  DeductionYesNoResult? _ynResult;

  void _calculate() {
    final salary = double.tryParse(_salaryCtrl.text) ?? 0;
    setState(() {
      if (_isRatioMode) {
        _ratioResult = const ToolsCalculator().calculateDeductionRatio(salary);
        _ynResult = null;
      } else {
        _ynResult = const ToolsCalculator().calculateDeductionYesNo(
          salary: salary,
          hasPersonal: _yn33,
          hasLeasing: _yn45,
          hasRealEstate: _yn5565,
        );
        _ratioResult = null;
      }
    });
  }

  String _ctxBuilder() {
    final salary = _salaryCtrl.text;
    if (_ratioResult != null) {
      return 'راتب $salary ريال، شخصي ${_fmt(_ratioResult!.personal33)}، تأجيري ${_fmt(_ratioResult!.leasing45)}، عقاري ${_fmt(_ratioResult!.realEstate)}';
    }
    if (_ynResult != null) {
      return 'راتب $salary، شخصي ${_yn33 ? _fmt(_ynResult!.personal33) : '—'}، تأجيري ${_yn45 ? _fmt(_ynResult!.leasing45) : '—'}، عقاري ${_yn5565 ? _fmt(_ynResult!.realEstate) : '—'}';
    }
    return '';
  }

  @override
  void dispose() {
    _salaryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorNeonScaffold(
      subtitle: _isRatioMode ? 'احتساب نسب الاستقطاع' : 'الاستقطاع المتاح حسب المنتجات',
      aiContextBuilder: _ctxBuilder,
      body: CalculatorNeonCard(
        children: [
          CalculatorToggleButtons(
            labels: const ['📊 نسبة الاستقطاع', '✅ الاستقطاع (نعم / لا)'],
            selectedIndex: _isRatioMode ? 0 : 1,
            onChanged: (i) => setState(() {
              _isRatioMode = i == 0;
              _ratioResult = null;
              _ynResult = null;
            }),
          ),
          const SizedBox(height: 14),
          ResultSectionHeader(
            title: _isRatioMode ? 'احتساب نسب الاستقطاع' : 'الاستقطاع المتاح (نعم / لا)',
            icon: _isRatioMode ? '📊' : '✅',
          ),
          CalculatorNeonField(
            label: 'إجمالي الراتب (ريال)',
            controller: _salaryCtrl,
            placeholder: '15000',
          ),
          if (!_isRatioMode)
            LayoutBuilder(
              builder: (context, constraints) {
                final items = [
                  _ynDropdown('تمويل شخصي 33%؟', _yn33, (v) => setState(() => _yn33 = v == 'نعم')),
                  _ynDropdown('تمويل تأجيري 45%؟', _yn45, (v) => setState(() => _yn45 = v == 'نعم')),
                  _ynDropdown('تمويل عقاري 55/65%؟', _yn5565, (v) => setState(() => _yn5565 = v == 'نعم')),
                ];
                if (constraints.maxWidth > 500) {
                  return Row(
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        Expanded(child: items[i]),
                        if (i < items.length - 1) const SizedBox(width: 8),
                      ],
                    ],
                  );
                }
                return Column(children: items);
              },
            ),
          CalculatorNeonButton(label: 'احتساب', onTap: _calculate),
          if (_isRatioMode && _ratioResult != null) ...[
            const SizedBox(height: 12),
            CalculatorResultRow(
              label: 'التمويل الشخصي (33.33%)',
              value: '${_fmt(_ratioResult!.personal33)} ر.س',
            ),
            CalculatorResultRow(
              label: 'التمويل التأجيري — المتبقي من 45%',
              value: '${_fmt(_ratioResult!.leasing45)} ر.س',
            ),
            CalculatorResultRow(
              label: 'التمويل العقاري (${_ratioResult!.realEstateLabel}%)',
              value: '${_fmt(_ratioResult!.realEstate)} ر.س',
              highlight: ResultHighlight.neon,
            ),
          ],
          if (!_isRatioMode && _ynResult != null) ...[
            const SizedBox(height: 12),
            CalculatorResultRow(
              label: 'تمويل شخصي (33.33%)',
              value: _ynResult!.hasPersonal ? '${_fmt(_ynResult!.personal33)} ر.س' : '—',
            ),
            CalculatorResultRow(
              label: 'تمويل تأجيري (45%)',
              value: _ynResult!.hasLeasing ? '${_fmt(_ynResult!.leasing45)} ر.س' : '—',
            ),
            CalculatorResultRow(
              label: 'تمويل عقاري (${_ynResult!.realEstateLabel}%)',
              value: _ynResult!.hasRealEstate ? '${_fmt(_ynResult!.realEstate)} ر.س' : '—',
              highlight: ResultHighlight.neon,
            ),
          ],
        ],
      ),
    );
  }

  Widget _ynDropdown(String label, bool value, ValueChanged<String?> onChanged) {
    return CalculatorNeonDropdown(
      label: label,
      value: value ? 'نعم' : 'لا',
      items: const [
        DropdownMenuItem(value: 'نعم', child: Text('نعم', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
        DropdownMenuItem(value: 'لا', child: Text('لا', style: TextStyle(color: AppColors.calcText, fontSize: 14))),
      ],
      onChanged: onChanged,
    );
  }
}
