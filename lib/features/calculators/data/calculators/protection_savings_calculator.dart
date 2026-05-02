import 'dart:math' as math;

/// Investment strategy options with annual return rates.
///
/// From the HTML select element:
/// ```html
/// <option value="0.12">متوازنة (12%)</option>
/// <option value="0.08">محافظة (8%)</option>
/// <option value="0.15">نمو (15%)</option>
/// ```
enum InvestmentStrategy {
  balanced('Balanced (12%)', 0.12),
  conservative('Conservative (8%)', 0.08),
  growth('Growth (15%)', 0.15);

  const InvestmentStrategy(this.label, this.annualReturn);
  final String label;
  final double annualReturn;
}

/// Input for the Protection & Savings (single-payment) calculator.
///
/// Matches the HTML's input gathering:
/// ```js
/// const sub=+document.getElementById('subAmt').value||250000;
/// const yrs=+document.getElementById('progYears').value||3;
/// const rate=+document.getElementById('strategy').value||0.12;
/// ```
class ProtectionSavingsInput {
  const ProtectionSavingsInput({
    required this.subscriptionAmount,
    required this.programDurationYears,
    required this.strategy,
    this.age = 35,
  });

  final double subscriptionAmount;
  final int programDurationYears;
  final InvestmentStrategy strategy;
  final int age;
}

/// One row in the year-by-year projection table.
///
/// Matches the HTML's row structure:
/// ```js
/// rows.push({y, partFee, admin, risk, mgmtFee, income, cashVal, deathBenefit});
/// ```
class YearProjection {
  const YearProjection({
    required this.year,
    required this.partFee,
    required this.admin,
    required this.risk,
    required this.mgmtFee,
    required this.income,
    required this.cashValue,
    required this.deathBenefit,
  });

  final int year;
  final double partFee;
  final double admin;
  final double risk;
  final double mgmtFee;
  final double income;
  final double cashValue;
  final double deathBenefit;
}

/// Result of the Protection & Savings calculation.
class ProtectionSavingsResult {
  const ProtectionSavingsResult({
    required this.subscriptionAmount,
    required this.years,
    required this.rate,
    required this.coverage,
    required this.rows,
    required this.finalCashValue,
    required this.finalDeathBenefit,
    required this.totalInvestmentIncome,
  });

  final double subscriptionAmount;
  final int years;
  final double rate;
  final double coverage;
  final List<YearProjection> rows;
  final double finalCashValue;
  final double finalDeathBenefit;
  final double totalInvestmentIncome;
}

/// Protection & Savings (Single Payment / Takaful) Calculator.
///
/// Formulas replicated exactly from himaya-iddikhar.html:
///
/// ```js
/// function calculate(){
///   const sub=+document.getElementById('subAmt').value||250000;
///   const yrs=+document.getElementById('progYears').value||3;
///   const rate=+document.getElementById('strategy').value||0.12;
///
///   const partFee1 = sub * 55/1000;
///   const adminPerYear = 420;
///   const riskPerYear  = 420;
///   const coverage = Math.min(Math.max(sub*0.10, 15000), 250000);
///   let cashVal = sub;
///   const rows = [];
///   for(let y=1; y<=yrs; y++){
///     const partFee = y===1 ? partFee1 : 0;
///     const admin   = adminPerYear;
///     const risk    = riskPerYear;
///     const invBase = cashVal - partFee - admin - risk;
///     const income  = invBase * rate;
///     const mgmtFee = (invBase + income) * (75/10000);
///     cashVal       = invBase + income - mgmtFee;
///     const deathBenefit = cashVal + coverage;
///     rows.push({y, partFee, admin, risk, mgmtFee, income, cashVal, deathBenefit});
///   }
/// }
/// ```
class ProtectionSavingsCalculator {
  const ProtectionSavingsCalculator();

  // partFee1 = sub * 55/1000
  static const double _participationRate = 55 / 1000; // 0.055

  // adminPerYear = 420
  static const double _adminPerYear = 420;

  // riskPerYear = 420
  static const double _riskPerYear = 420;

  // mgmtFee = (invBase + income) * (75/10000)
  static const double _mgmtFeeRate = 75 / 10000; // 0.0075

  /// coverage = Math.min(Math.max(sub*0.10, 15000), 250000)
  static double defaultCoverage(double subscriptionAmount) {
    return math.min(math.max(subscriptionAmount * 0.10, 15000), 250000);
  }

  ProtectionSavingsResult calculate(ProtectionSavingsInput input) {
    final sub = input.subscriptionAmount;
    final yrs = input.programDurationYears;
    final rate = input.strategy.annualReturn;

    // partFee1 = sub * 55/1000
    final partFee1 = sub * _participationRate;

    // coverage = Math.min(Math.max(sub*0.10, 15000), 250000)
    final coverage = defaultCoverage(sub);

    // let cashVal = sub
    double cashVal = sub;
    final rows = <YearProjection>[];

    for (int y = 1; y <= yrs; y++) {
      // const partFee = y===1 ? partFee1 : 0;
      final partFee = y == 1 ? partFee1 : 0.0;

      // const admin = adminPerYear;
      const admin = _adminPerYear;

      // const risk = riskPerYear;
      const risk = _riskPerYear;

      // const invBase = cashVal - partFee - admin - risk;
      final invBase = cashVal - partFee - admin - risk;

      // const income = invBase * rate;
      final income = invBase * rate;

      // const mgmtFee = (invBase + income) * (75/10000);
      final mgmtFee = (invBase + income) * _mgmtFeeRate;

      // cashVal = invBase + income - mgmtFee;
      cashVal = invBase + income - mgmtFee;

      // const deathBenefit = cashVal + coverage;
      final deathBenefit = cashVal + coverage;

      rows.add(YearProjection(
        year: y,
        partFee: partFee,
        admin: admin,
        risk: risk,
        mgmtFee: mgmtFee,
        income: income,
        cashValue: cashVal,
        deathBenefit: deathBenefit,
      ));
    }

    final last = rows.last;
    // rows.reduce((a,r)=>a+r.income,0)
    final totalIncome = rows.fold(0.0, (sum, r) => sum + r.income);

    return ProtectionSavingsResult(
      subscriptionAmount: sub,
      years: yrs,
      rate: rate,
      coverage: coverage,
      rows: rows,
      finalCashValue: last.cashValue,
      finalDeathBenefit: last.deathBenefit,
      totalInvestmentIncome: totalIncome,
    );
  }
}
