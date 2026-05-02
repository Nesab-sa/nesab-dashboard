import 'package:flutter/material.dart';

import 'package:nesab_dashboard/features/calculators/data/models/calculator_type.dart';

import 'age_calculator_page.dart';
import 'date_converter_page.dart';
import 'debt_purchase_page.dart';
import 'deduction_calculator_page.dart';
import 'khairat_page.dart';
import 'leasing_page.dart';
import 'personal_finance_page.dart';
import 'personal_finance_quick_page.dart';
import 'pos_financing_page.dart';
import 'protection_savings_page.dart';
import 'real_estate_page.dart';
import 'real_estate_plus_page.dart';
import 'bank_fees_page.dart';

/// Returns the calculator page [Widget] for this [CalculatorType].
extension CalculatorTypePages on CalculatorType {
  Widget get page => switch (this) {
        CalculatorType.personalFinance => const PersonalFinancePage(),
        CalculatorType.personalFinanceQuick => const PersonalFinanceQuickPage(),
        CalculatorType.debtPurchase => const DebtPurchasePage(),
        CalculatorType.realEstate => const RealEstatePage(),
        CalculatorType.realEstatePlus => const RealEstatePlusPage(),
        CalculatorType.leasingRegular => const LeasingPage(isMicro: false),
        CalculatorType.leasingMicro => const LeasingPage(isMicro: true),
        CalculatorType.posFinancing => const PosFinancingPage(),
        CalculatorType.khairat => const KhairatPage(),
        CalculatorType.protectionSavings => const ProtectionSavingsPage(),
        CalculatorType.ageCalculator => const AgeCalculatorPage(),
        CalculatorType.dateConverter => const DateConverterPage(),
        CalculatorType.deductions => const DeductionCalculatorPage(),
        CalculatorType.bankFees => const BankFeesPage(),
      };
}
