import 'dart:math' as math;

// ---------------------------------------------------------------------------
// Debt Purchase Calculator — mirrors shira-madyoniya.html JS exactly
// ---------------------------------------------------------------------------

/// Input for the Debt Purchase calculator.
class DebtPurchaseInput {
  const DebtPurchaseInput({
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
    this.debtAmt = 0,
  });

  final double salary;

  /// 'موظف' or 'متقاعد'
  final String workStatus;

  /// 'لا يوجد' or 'نعم يوجد'
  final String mortgage;

  final int birthYear;
  final int birthMonth;
  final int retireAge;

  /// Annual profit rate as entered (e.g. 1 means 1%).
  /// HTML: (+profitRate.value || 1)
  final double profitRate;

  final int loanMonths;
  final double ahliCards;
  final double otherCards;

  /// Outstanding debt at the other bank.
  final double debtAmt;
}

/// Retirement / age info computed from birth data.
///
/// Mirrors HTML calcRetire():
/// ```js
/// let ageM=(now.getFullYear()-by)*12+(now.getMonth()+1-bm);
/// if(ageM<0)ageM=0;
/// const remM=ra*12-ageM;const elig=remM>=60;
/// ```
class RetireInfo {
  const RetireInfo({
    required this.ageMonths,
    required this.remMonths,
    required this.eligible,
  });

  final int ageMonths;
  final int remMonths;
  final bool eligible;
}

/// Full result produced by [DebtPurchaseCalculator.calculate].
class DebtPurchaseResult {
  const DebtPurchaseResult({
    required this.retire,
    required this.dedRate,
    required this.monthlyInstallment,
    required this.totalFinance,
    required this.approvedAmt,
    required this.adminFee,
    required this.tax,
    required this.totalFees,
    required this.netAmt,
    required this.bankProfit,
    required this.debtAmt,
    required this.netAfterDebt,
    required this.workStatus,
    required this.mortgage,
    required this.salary,
    required this.profitRate,
    required this.months,
  });

  final RetireInfo retire;
  final double dedRate;
  final double monthlyInstallment;
  final double totalFinance;
  final double approvedAmt;
  final double adminFee;
  final double tax;
  final double totalFees;
  final double netAmt;
  final double bankProfit;
  final double debtAmt;
  final double netAfterDebt;
  final String workStatus;
  final String mortgage;
  final double salary;
  final double profitRate;
  final int months;

  bool get finalOk => retire.eligible && approvedAmt > 0;
}

/// Schedule row for the instalment table.
class DebtPurchaseScheduleRow {
  const DebtPurchaseScheduleRow({
    required this.month,
    required this.payment,
    required this.cumulative,
  });

  final int month;
  final double payment;
  final double cumulative;
}

/// Debt Purchase Calculator replicating the HTML/JS formulas 1-for-1.
///
/// Source: shira-madyoniya.html lines 240-292
class DebtPurchaseCalculator {
  const DebtPurchaseCalculator();

  // -----------------------------------------------------------------------
  // calcRetire — mirrors JS calcRetire() exactly (lines 240-252)
  //
  // ```js
  // const by=+document.getElementById('birthYear').value||1997;
  // const bm=+document.getElementById('birthMonth').value||2;
  // const ra=+document.getElementById('retireAge').value||58;
  // const now=new Date();
  // let ageM=(now.getFullYear()-by)*12+(now.getMonth()+1-bm);
  // if(ageM<0)ageM=0;
  // const remM=ra*12-ageM;
  // const elig=remM>=60;
  // ```
  // -----------------------------------------------------------------------
  RetireInfo calcRetire({
    required int birthYear,
    required int birthMonth,
    required int retireAge,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final curY = today.year;
    final curM = today.month;

    // ageM = (now.getFullYear()-by)*12 + (now.getMonth()+1 - bm)
    // NOTE: JS getMonth() is 0-based, so getMonth()+1 = Dart's today.month
    int ageMonths = (curY - birthYear) * 12 + (curM - birthMonth);
    if (ageMonths < 0) ageMonths = 0;

    // remM = ra*12 - ageM
    final retireMonths = retireAge * 12;
    final remMonths = retireMonths - ageMonths;

    // elig = remM >= 60
    final eligible = remMonths >= 60;

    return RetireInfo(
      ageMonths: ageMonths,
      remMonths: math.max(0, remMonths),
      eligible: eligible,
    );
  }

  // -----------------------------------------------------------------------
  // calcDedRate — mirrors JS calcDedRate() exactly (lines 253-256)
  //
  // ```js
  // function calcDedRate(ws,mortgage,salary){
  //   if(mortgage==='لا يوجد'){if(ws==='متقاعد')return 0.25;return 0.3333;}
  //   else{if(ws==='متقاعد')return 0.55;return salary<15000?0.55:0.65;}
  // }
  // ```
  // -----------------------------------------------------------------------
  double calcDedRate(String workStatus, String mortgage, double salary) {
    if (mortgage == 'لا يوجد') {
      if (workStatus == 'متقاعد') return 0.25;
      return 0.3333;
    } else {
      if (workStatus == 'متقاعد') return 0.55;
      return salary < 15000 ? 0.55 : 0.65;
    }
  }

  // -----------------------------------------------------------------------
  // calculate — mirrors JS calculate() exactly (lines 257-292)
  //
  // ```js
  // const retire=calcRetire();
  // const dedRate=calcDedRate(ws,mortgage,salary);
  // const monthlyInstall=salary*(ws==='موظف'?0.3333:(ws==='متقاعد'?0.25:0));
  // const totalFinance=monthlyInstall*months;
  // const approvedAmt=totalFinance>0?totalFinance/(1+months*(profitR/12)):0;
  // const adminFee=Math.min(approvedAmt*0.005,2500);
  // const tax=adminFee*0.15;
  // const totalFees=adminFee+tax;
  // const netAmt=approvedAmt-totalFees;
  // const bankProfit=(approvedAmt*profitR*months)/12;
  // const netAfterDebt=netAmt-debtAmt;
  // ```
  // -----------------------------------------------------------------------
  DebtPurchaseResult calculate(DebtPurchaseInput input) {
    // profitR = (+profitRate.value || 1) / 100
    final profitR = input.profitRate / 100;
    final months = input.loanMonths;
    final salary = input.salary;
    final ws = input.workStatus;
    final mortgage = input.mortgage;
    final debtAmt = input.debtAmt;

    // retire = calcRetire()
    final retire = calcRetire(
      birthYear: input.birthYear,
      birthMonth: input.birthMonth,
      retireAge: input.retireAge,
    );

    // dedRate = calcDedRate(ws, mortgage, salary)
    final dedRate = calcDedRate(ws, mortgage, salary);

    // monthlyInstall = salary * (ws==='موظف' ? 0.3333 : (ws==='متقاعد' ? 0.25 : 0))
    final monthlyInstall =
        salary * (ws == 'موظف' ? 0.3333 : (ws == 'متقاعد' ? 0.25 : 0));

    // totalFinance = monthlyInstall * months
    final totalFinance = monthlyInstall * months;

    // approvedAmt = totalFinance > 0 ? totalFinance / (1 + months*(profitR/12)) : 0
    final approvedAmt = totalFinance > 0
        ? totalFinance / (1 + months * (profitR / 12))
        : 0.0;

    // adminFee = Math.min(approvedAmt * 0.005, 2500)
    final adminFee = math.min(approvedAmt * 0.005, 2500.0);

    // tax = adminFee * 0.15
    final tax = adminFee * 0.15;

    // totalFees = adminFee + tax
    final totalFees = adminFee + tax;

    // netAmt = approvedAmt - totalFees
    final netAmt = approvedAmt - totalFees;

    // bankProfit = (approvedAmt * profitR * months) / 12
    final bankProfit = (approvedAmt * profitR * months) / 12;

    // netAfterDebt = netAmt - debtAmt
    final netAfterDebt = netAmt - debtAmt;

    return DebtPurchaseResult(
      retire: retire,
      dedRate: dedRate,
      monthlyInstallment: monthlyInstall,
      totalFinance: totalFinance,
      approvedAmt: approvedAmt,
      adminFee: adminFee,
      tax: tax,
      totalFees: totalFees,
      netAmt: netAmt,
      bankProfit: bankProfit,
      debtAmt: debtAmt,
      netAfterDebt: netAfterDebt,
      workStatus: ws,
      mortgage: mortgage,
      salary: salary,
      profitRate: profitR,
      months: months,
    );
  }

  // -----------------------------------------------------------------------
  // schedule — instalment table
  // -----------------------------------------------------------------------
  List<DebtPurchaseScheduleRow> schedule(DebtPurchaseResult r) {
    final rows = <DebtPurchaseScheduleRow>[];
    double cum = 0;
    for (int i = 1; i <= r.months; i++) {
      cum += r.monthlyInstallment;
      rows.add(DebtPurchaseScheduleRow(
        month: i,
        payment: r.monthlyInstallment,
        cumulative: cum,
      ));
    }
    return rows;
  }
}
