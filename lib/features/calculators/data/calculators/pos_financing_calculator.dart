import 'dart:math' as math;

/// POS Financing (نقاط البيع) Calculator.
///
/// Ported from: niqat-albay.html
///
/// HTML constants (line 246):
///   const TERMS = {
///     'سنة':           [0.05, 12],
///     'سنتين':         [0.05, 24],
///     'ثلاث سنوات':    [0.07, 36],
///     'اربع سنوات':    [0.09, 48],
///     'خمس سنوات':     [0.09, 60],
///   };
///
/// HTML formulas (lines 253-260):
///   monthly  = ann / 12
///   rejected = bizAge === 'أقل من سنتين' || posAge === 'أقل من سنة'
///   loan     = rejected ? 0 : monthly * 3
///   profit   = loan * pr * months / 12
///   total    = loan + profit
///   inst     = months > 0 ? total / months : 0
///   adminFee = Math.min(loan * 0.01, 5000) * 1.15
///   ok       = !rejected && ann >= 400000 && monthly >= 33333.33

/// Business type for POS financing.
/// Matches HTML select #bizType options (lines 101-103).
enum PosBusinessType {
  soleProprietorship('مؤسسة فردية'),
  singlePersonCompany('شركة سعودية (شخص واحد)'),
  partnershipCompany('شركة سعودية (مجموعة شركاء)'),
  foreignInvestment('شركة استثمار أجنبي'),
  mixedCompany('شركة مختلطة');

  const PosBusinessType(this.arabicLabel);
  final String arabicLabel;
}

/// Business activity categories for POS financing.
/// Matches HTML select #bizActivity options (lines 105-112).
enum PosBusinessActivity {
  wholesaleRetail('تجارة الجملة والتجزئة'),
  supermarkets('السوبر ماركت والبقالات'),
  pharmacies('الصيدليات والعيادات'),
  hotels('الفنادق والإقامة'),
  medicalCenters('المراكز الطبية'),
  restaurants('المطاعم والكافيهات'),
  foodSupplies('المواد الغذائية'),
  clothing('بيع الملابس'),
  personalCare('متاجر العناية الشخصية'),
  beautyCenters('مراكز التجميل'),
  travelAgencies('وكالات السفر والسياحة'),
  other('نشاط آخر');

  const PosBusinessActivity(this.arabicLabel);
  final String arabicLabel;
}

/// Business age bracket for POS eligibility.
/// Matches HTML select #bizAge options (lines 115-117).
/// 'أقل من سنتين' causes rejection (line 254).
enum PosBusinessAge {
  moreThanTwo('أكثر من سنتين'),
  lessThanTwo('أقل من سنتين');

  const PosBusinessAge(this.arabicLabel);
  final String arabicLabel;
}

/// POS operating period for eligibility.
/// Matches HTML select #posAge options (lines 118-120).
/// 'أقل من سنة' causes rejection (line 254).
enum PosPeriod {
  moreThanYear('أكثر من سنة'),
  lessThanYear('أقل من سنة');

  const PosPeriod(this.arabicLabel);
  final String arabicLabel;
}

/// POS monthly operations count.
/// Matches HTML select #posOps options (lines 124-126).
enum PosOperations {
  moreThan25('أكثر من 25 عملية', 'أكثر'),
  lessThan25('أقل من 25 عملية', 'أقل');

  const PosOperations(this.arabicLabel, this.value);
  final String arabicLabel;
  final String value;
}

/// Loan duration options with corresponding profit rates.
/// Matches the HTML TERMS map exactly (line 246).
enum PosDuration {
  oneYear(12, 0.05, 'سنة — 5% — 12 شهر'),
  twoYears(24, 0.05, 'سنتين — 5% — 24 شهر'),
  threeYears(36, 0.07, 'ثلاث سنوات — 7% — 36 شهر'),
  fourYears(48, 0.09, 'أربع سنوات — 9% — 48 شهر'),
  fiveYears(60, 0.09, 'خمس سنوات — 9% — 60 شهر');

  const PosDuration(this.months, this.profitRate, this.arabicLabel);
  final int months;
  final double profitRate;
  final String arabicLabel;
}

/// Input for POS financing calculator.
class PosFinancingInput {
  const PosFinancingInput({
    required this.businessType,
    required this.activity,
    required this.businessAge,
    required this.posPeriod,
    required this.annualSales,
    required this.posOperations,
    required this.duration,
  });

  final PosBusinessType businessType;
  final PosBusinessActivity activity;
  final PosBusinessAge businessAge;
  final PosPeriod posPeriod;
  final double annualSales;
  final PosOperations posOperations;
  final PosDuration duration;
}

/// Result of POS financing calculation.
///
/// Fields match the HTML result display (lines 263-270):
///   - متوسط المبيعات الشهرية      -> monthlySales
///   - مبلغ التمويل (مبيعات 3 أشهر) -> loanAmount
///   - نسبة الربح                   -> profitRate
///   - إجمالي الربح                  -> profitAmount
///   - الإجمالي                      -> totalAmount
///   - القسط الشهري                  -> monthlyPayment
///   - الرسوم الإدارية (1% + VAT)    -> adminFees
class PosFinancingResult {
  const PosFinancingResult({
    required this.monthlySales,
    required this.loanAmount,
    required this.profitRate,
    required this.profitAmount,
    required this.totalAmount,
    required this.monthlyPayment,
    required this.adminFees,
    required this.durationMonths,
    required this.isEligible,
    required this.isRejectedByAge,
    required this.annualSales,
  });

  final double monthlySales;
  final double loanAmount;
  final double profitRate;
  final double profitAmount;
  final double totalAmount;
  final double monthlyPayment;
  final double adminFees;
  final int durationMonths;
  final bool isEligible;
  final bool isRejectedByAge;
  final double annualSales;
}

/// POS Financing Calculator.
///
/// All formulas match niqat-albay.html lines 253-260 exactly.
class PosFinancingCalculator {
  const PosFinancingCalculator();

  PosFinancingResult calculate(PosFinancingInput input) {
    final pr = input.duration.profitRate;
    final months = input.duration.months;
    final ann = input.annualSales;

    // Line 253: const monthly = ann / 12;
    final monthly = ann / 12;

    // Line 254: const rejected = bizAge === 'أقل من سنتين' || posAge === 'أقل من سنة';
    final rejected = input.businessAge == PosBusinessAge.lessThanTwo ||
        input.posPeriod == PosPeriod.lessThanYear;

    // Line 255: const loan = rejected ? 0 : monthly * 3;
    final loan = rejected ? 0.0 : monthly * 3;

    // Line 256: const profit = loan * pr * months / 12;
    final profit = loan * pr * months / 12;

    // Line 257: const total = loan + profit;
    final total = loan + profit;

    // Line 258: const inst = months > 0 ? total / months : 0;
    final inst = months > 0 ? total / months : 0.0;

    // Line 259: const adminFee = Math.min(loan * 0.01, 5000) * 1.15;
    final adminFee = math.min(loan * 0.01, 5000.0) * 1.15;

    // Line 260: const ok = !rejected && ann >= 400000 && monthly >= 33333.33;
    final ok = !rejected && ann >= 400000 && monthly >= 33333.33;

    return PosFinancingResult(
      monthlySales: monthly,
      loanAmount: loan,
      profitRate: pr,
      profitAmount: profit,
      totalAmount: total,
      monthlyPayment: inst,
      adminFees: adminFee,
      durationMonths: months,
      isEligible: ok,
      isRejectedByAge: rejected,
      annualSales: ann,
    );
  }
}
