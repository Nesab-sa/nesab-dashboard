import 'package:flutter/material.dart';

/// All calculator tools in the hub. Each has a value id, English name, and Arabic name.
enum CalculatorType {
  personalFinance(
    'personal_finance',
    'Personal Finance (PLAS)',
    'التمويل الشخصي (PLAS)',
  ),
  personalFinanceQuick(
    'personal_finance_quick',
    'Quick Personal Finance',
    'التمويل الشخصي المختصر',
  ),
  debtPurchase('debt_purchase', 'Debt Purchase', 'شراء مديونية'),
  realEstate(
    'real_estate',
    'Real Estate',
    'التمويل العقاري',
  ),
  realEstatePlus(
    'real_estate_plus',
    'Real Estate Plus (2-in-1)',
    'التمويل العقاري بلص (2 في 1)',
  ),
  leasingRegular('leasing_regular', 'Leasing (Tajiri)', 'التأجيري (تاجيري)'),
  leasingMicro('leasing_micro', 'Leasing Micro', 'التأجيري مايكرو'),
  posFinancing('pos_financing', 'POS Financing', 'تمويل نقاط البيع'),
  khairat('khairat', 'Khairat Savings', 'حساب خيرات'),
  protectionSavings(
    'protection_savings',
    'Protection & Savings',
    'الحماية والادخار',
  ),
  ageCalculator('age_calculator', 'Age Calculator', 'حاسبة العمر'),
  dateConverter('date_converter', 'Date Converter', 'تحويل التاريخ'),
  deductions('deductions', 'Deductions Calculator', 'حاسبة الاستقطاعات'),
  bankFees('bank_fees', 'Bank Fees', 'الرسوم البنكية');

  const CalculatorType(this.value, this.englishName, this.arabicName);

  /// Unique identifier for routing or persistence.
  final String value;

  /// Display name in English.
  final String englishName;

  /// Display name in Arabic.
  final String arabicName;

  factory CalculatorType.fromValue(String value) => values.firstWhere(
    (e) => e.value == value,
    orElse: () => CalculatorType.personalFinance,
  );
  String toJson() => value;

  /// List of [DropdownMenuItem] for subcategory or calculator-type selection.
  /// Uses [locale] to show [englishName] or [arabicName].
  static List<DropdownMenuItem<CalculatorType>> dropdownItems(Locale locale) =>
      values
          .map(
            (e) => DropdownMenuItem<CalculatorType>(
              value: e,
              child: Text(e.displayName(locale)),
            ),
          )
          .toList();

  /// Display name for the current locale (English or Arabic).
  String displayName(Locale locale) =>
      locale.languageCode == 'ar' ? arabicName : englishName;
}
