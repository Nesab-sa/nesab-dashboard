import 'dart:math' as math;

// ---------------------------------------------------------------------------
// Input
// ---------------------------------------------------------------------------
class PersonalFinanceQuickInput {
  const PersonalFinanceQuickInput({
    required this.salary,
    required this.workStatus,
    required this.mortgage,
    required this.birthYear,
    required this.birthMonth,
    required this.retireAge,
    required this.profitRate,
    required this.loanMonths,
    this.ahliCards = 0,
    this.otherCards = 0,
    this.today,
  });

  final double salary;

  /// 'موظف' or 'متقاعد'
  final String workStatus;

  /// 'لا يوجد' or 'نعم يوجد'
  final String mortgage;

  final int birthYear;
  final int birthMonth;
  final int retireAge;

  /// Profit rate as entered (e.g. 1 means 1 %)
  final double profitRate;

  final int loanMonths;
  final double ahliCards;
  final double otherCards;

  /// Override for unit-testing
  final DateTime? today;
}

// ---------------------------------------------------------------------------
// Retirement info
// ---------------------------------------------------------------------------
class RetirementInfo {
  const RetirementInfo({
    required this.ageMonths,
    required this.remainingMonths,
    required this.eligible,
  });

  final int ageMonths;
  final int remainingMonths;
  final bool eligible;
}

// ---------------------------------------------------------------------------
// Result
// ---------------------------------------------------------------------------
class PersonalFinanceQuickResult {
  const PersonalFinanceQuickResult({
    required this.workStatus,
    required this.mortgage,
    required this.salary,
    required this.profitRate,
    required this.months,
    required this.ahliCards,
    required this.otherCards,
    required this.deductionRatio,
    required this.monthlyInstallment,
    required this.totalFinance,
    required this.approvedAmount,
    required this.adminFee,
    required this.tax,
    required this.totalFees,
    required this.netAmount,
    required this.bankProfit,
    required this.retirement,
  });

  final String workStatus;
  final String mortgage;
  final double salary;
  final double profitRate;
  final int months;
  final double ahliCards;
  final double otherCards;
  final double deductionRatio;
  final double monthlyInstallment;
  final double totalFinance;
  final double approvedAmount;
  final double adminFee;
  final double tax;
  final double totalFees;
  final double netAmount;
  final double bankProfit;
  final RetirementInfo retirement;

  bool get isApproved => retirement.eligible && approvedAmount > 0;
}

// ---------------------------------------------------------------------------
// Schedule row
// ---------------------------------------------------------------------------
class QuickScheduleRow {
  const QuickScheduleRow({
    required this.month,
    required this.payment,
    required this.cumulative,
  });

  final int month;
  final double payment;
  final double cumulative;
}

// ---------------------------------------------------------------------------
// Calculator  --  matches the HTML JavaScript (shakhsi-mukhtasar.html) EXACTLY
//
// HTML JS source (lines 237-281):
// ```js
// function calcRetire() {
//   const by = +document.getElementById('birthYear').value || 1997;
//   const bm = +document.getElementById('birthMonth').value || 2;
//   const ra = +document.getElementById('retireAge').value || 58;
//   const now = new Date();
//   let ageM = (now.getFullYear()-by)*12 + (now.getMonth()+1-bm);
//   if (ageM < 0) ageM = 0;
//   const remM = ra*12 - ageM;
//   const elig = remM >= 60;
//   return { remM, eligible: elig };
// }
//
// function calculate() {
//   const ws = document.getElementById('workStatus').value;
//   const salary = +document.getElementById('salary').value || 0;
//   const profitR = (+document.getElementById('profitRate').value || 1) / 100;
//   const months = +document.getElementById('loanMonths').value || 60;
//   const ahli = +document.getElementById('ahliCards').value || 0;
//   const other = +document.getElementById('otherCards').value || 0;
//
//   const retire = calcRetire();
//   const monthlyInstall = salary * (ws==='موظف' ? 0.3333 : (ws==='متقاعد' ? 0.25 : 0));
//   const totalFinance = monthlyInstall * months;
//
//   // D13 -- FIXED constants: 60 months and 1%*5 divisor
//   const approvedAmt = ((monthlyInstall - (ahli+other)*0.05) * 60) / (1 + 0.01*5);
//
//   const adminFee  = Math.min(approvedAmt * 0.005, 2500);
//   const tax       = adminFee * 0.15;
//   const totalFees = adminFee + tax;
//   const netAmt    = approvedAmt - totalFees;
//   const bankProfit = (approvedAmt * profitR * months) / 12;
// }
// ```
//
// KEY DIFFERENCE from shakhsi-plus:
//   - Quick calculator does NOT use mortgage to determine deduction ratio.
//     It is always: موظف => 0.3333, متقاعد => 0.25
//   - Quick calculator uses FIXED constants for approvedAmt formula:
//     ((monthlyInstall - cards*0.05) * 60) / (1 + 0.01*5)
//     The 60 and 0.01*5 are hardcoded, NOT the user's selected months/rate.
// ---------------------------------------------------------------------------
class PersonalFinanceQuickCalculator {
  const PersonalFinanceQuickCalculator();

  // ---- Retirement (matches HTML calcRetire) ----
  RetirementInfo calcRetirement(PersonalFinanceQuickInput input) {
    final now = input.today ?? DateTime.now();

    // HTML: let ageM = (now.getFullYear()-by)*12 + (now.getMonth()+1-bm);
    // Note: JS getMonth() is 0-based, so getMonth()+1 = Dart's month.
    int ageMonths =
        (now.year - input.birthYear) * 12 + (now.month - input.birthMonth);

    // HTML: if (ageM < 0) ageM = 0;
    if (ageMonths < 0) ageMonths = 0;

    // HTML: const remM = ra*12 - ageM;
    final remMonths = input.retireAge * 12 - ageMonths;

    // HTML: const elig = remM >= 60;
    final eligible = remMonths >= 60;

    return RetirementInfo(
      ageMonths: ageMonths,
      remainingMonths: math.max(0, remMonths),
      eligible: eligible,
    );
  }

  // ---- Main calculation (matches HTML calculate) ----
  PersonalFinanceQuickResult calculate(PersonalFinanceQuickInput input) {
    final retire = calcRetirement(input);

    // HTML: const monthlyInstall = salary * (ws==='موظف' ? 0.3333 : (ws==='متقاعد' ? 0.25 : 0));
    final ratio = input.workStatus == 'موظف' ? 0.3333 : 0.25;
    final monthlyInstall = input.salary * ratio;

    // HTML: const totalFinance = monthlyInstall * months;
    final totalFinance = monthlyInstall * input.loanMonths;

    // HTML D13: const approvedAmt = ((monthlyInstall-(ahli+other)*0.05)*60) / (1+0.01*5);
    // NOTE: 60 and 0.01*5 are FIXED constants in the HTML source.
    final approvedAmt = ((monthlyInstall -
                (input.ahliCards + input.otherCards) * 0.05) *
            60) /
        (1 + 0.01 * 5);

    // HTML: const adminFee = Math.min(approvedAmt * 0.005, 2500);
    final adminFee = math.min(approvedAmt * 0.005, 2500.0);

    // HTML: const tax = adminFee * 0.15;
    final tax = adminFee * 0.15;

    // HTML: const totalFees = adminFee + tax;
    final totalFees = adminFee + tax;

    // HTML: const netAmt = approvedAmt - totalFees;
    final netAmt = approvedAmt - totalFees;

    // HTML: const bankProfit = (approvedAmt * profitR * months) / 12;
    final profitR = input.profitRate / 100;
    final bankProfit = (approvedAmt * profitR * input.loanMonths) / 12;

    return PersonalFinanceQuickResult(
      workStatus: input.workStatus,
      mortgage: input.mortgage,
      salary: input.salary,
      profitRate: profitR,
      months: input.loanMonths,
      ahliCards: input.ahliCards,
      otherCards: input.otherCards,
      deductionRatio: ratio,
      monthlyInstallment: monthlyInstall,
      totalFinance: totalFinance,
      approvedAmount: approvedAmt,
      adminFee: adminFee,
      tax: tax,
      totalFees: totalFees,
      netAmount: netAmt,
      bankProfit: bankProfit,
      retirement: retire,
    );
  }

  // ---- Schedule ----
  List<QuickScheduleRow> schedule(PersonalFinanceQuickResult r) {
    final rows = <QuickScheduleRow>[];
    double cum = 0;
    for (int i = 1; i <= r.months; i++) {
      cum += r.monthlyInstallment;
      rows.add(QuickScheduleRow(
          month: i, payment: r.monthlyInstallment, cumulative: cum));
    }
    return rows;
  }
}
