import 'dart:math' as math;

/// Real Estate (العقاري العادي) calculator.
///
/// Reproduces the exact formulas from the HTML file:
///   aqari-aadi.html → calculate()

// ---------------------------------------------------------------------------
// Input model
// ---------------------------------------------------------------------------
class RealEstateInput {
  const RealEstateInput({
    required this.salary,
    required this.mortgageYears,
    required this.profitRate,
    this.personalInstallment = 0,
    this.remainingPersonalMonths = 0,
    this.hasSupport = true,
    this.hasEtizaz = false,
    this.fixedLoan = 0,
  });

  /// راتب العميل (ريال)
  final double salary;

  /// مدة التمويل العقاري (سنة) — default 25 in HTML
  final int mortgageYears;

  /// هامش الربح as decimal (e.g. 0.0405 for 4.05%).
  /// HTML: (+profitRate.value || 4.05) / 100
  final double profitRate;

  /// قسط التمويل الشخصي (ريال)
  final double personalInstallment;

  /// عدد الأقساط المتبقية من التمويل الشخصي (شهر)
  final int remainingPersonalMonths;

  /// الدعم السكني
  final bool hasSupport;

  /// اعتزاز (وزارة الدفاع)
  final bool hasEtizaz;

  /// مبلغ تمويل عقاري محدد (0 = auto)
  final double fixedLoan;
}

// ---------------------------------------------------------------------------
// Result model
// ---------------------------------------------------------------------------
class RealEstateResult {
  const RealEstateResult({
    required this.salary,
    required this.mortgageYears,
    required this.profitRate,
    required this.personalInstallment,
    required this.remainingPersonalMonths,
    required this.fixedLoan,
    required this.dedRate,
    required this.qistPhase1,
    required this.qistPhase2,
    required this.totalPhase1,
    required this.totalPhase2,
    required this.loanAmount2in1,
    required this.housingSupport,
    required this.etizazAmt,
    required this.adminFee,
    required this.totalWithSupport,
    required this.remainingMonths,
    required this.totalAllPayments,
    required this.hasSupport,
    required this.hasEtizaz,
    required this.fixedProfit,
    required this.fixedTotal,
  });

  final double salary;
  final int mortgageYears;
  final double profitRate;
  final double personalInstallment;
  final int remainingPersonalMonths;
  final double fixedLoan;

  /// نسبة الاستقطاع المسموحة (0.55 or 0.65)
  /// HTML: salary >= 15000 ? 0.65 : 0.55
  final double dedRate;

  /// القسط خلال فترة التمويل الشخصي
  /// HTML: Math.min(salary*remDedR, salary*dedRate)
  final double qistPhase1;

  /// القسط بعد انتهاء التمويل الشخصي
  /// HTML: salary * dedRate
  final double qistPhase2;

  /// إجمالي المدفوع خلال فترة الشخصي
  /// HTML: qistPhase1 * remPers
  final double totalPhase1;

  /// إجمالي المدفوع بعد الشخصي
  /// HTML: qistPhase2 * remMonths
  final double totalPhase2;

  /// مبلغ التمويل العقاري (2 في 1) – بدون أرباح
  /// HTML: totalAllPayments / (1 + profitR * mortYears)
  final double loanAmount2in1;

  /// الدعم السكني
  /// HTML: support ? (salary <= 10000 ? 150000 : 100000) : 0
  final double housingSupport;

  /// اعتزاز
  /// HTML: etizaz ? 160000 : 0
  final double etizazAmt;

  /// رسوم إدارية وتقييم ثابتة
  /// HTML: 5750
  final double adminFee;

  /// الإجمالي مع الدعم والاعتزاز
  /// HTML: loanAmount2in1 + housingSupport + etizazAmt
  final double totalWithSupport;

  /// الأشهر المتبقية بعد انتهاء الشخصي
  /// HTML: Math.max(0, months - remPers)
  final int remainingMonths;

  /// إجمالي كل الدفعات
  /// HTML: totalPhase1 + totalPhase2
  final double totalAllPayments;

  final bool hasSupport;
  final bool hasEtizaz;

  /// ربح المبلغ المحدد
  /// HTML: fixedLoan > 0 ? fixedLoan * profitR * mortYears : 0
  final double fixedProfit;

  /// إجمالي المبلغ المحدد
  /// HTML: fixedLoan > 0 ? fixedLoan + fixedProfit : 0
  final double fixedTotal;

  int get totalMonths => mortgageYears * 12;
}

// ---------------------------------------------------------------------------
// Schedule row
// ---------------------------------------------------------------------------
class RealEstateScheduleRow {
  const RealEstateScheduleRow({
    required this.month,
    required this.payment,
    required this.cumulative,
    required this.isPhase1,
  });

  final int month;
  final double payment;
  final double cumulative;

  /// true = during personal-loan period, false = after
  final bool isPhase1;
}

// ---------------------------------------------------------------------------
// Calculator
// ---------------------------------------------------------------------------
class RealEstateCalculator {
  const RealEstateCalculator();

  /// Main calculation — mirrors aqari-aadi.html calculate() exactly.
  ///
  /// JS source (line 313-361 of aqari-aadi.html):
  /// ```js
  /// const months   = mortYears * 12;
  /// const dedRate  = salary >= 15000 ? 0.65 : 0.55;
  /// const persDedR = salary > 0 ? persInst/salary : 0;
  /// const remDedR  = dedRate - persDedR;
  /// const qistPhase1 = Math.min(salary*remDedR, salary*dedRate);
  /// const totalPhase1 = qistPhase1 * remPers;
  /// const qistPhase2 = salary * dedRate;
  /// const remMonths   = Math.max(0, months - remPers);
  /// const totalPhase2 = qistPhase2 * remMonths;
  /// const totalAllPayments = totalPhase1 + totalPhase2;
  /// const loanAmount2in1   = totalAllPayments / (1 + profitR * mortYears);
  /// const housingSupport = support ? (salary <= 10000 ? 150000 : 100000) : 0;
  /// const etizazAmt = etizaz ? 160000 : 0;
  /// const adminFee  = 5750;
  /// const totalWithSupport = loanAmount2in1 + housingSupport + etizazAmt;
  /// const fixedProfit = fixedLoan > 0 ? fixedLoan * profitR * mortYears : 0;
  /// const fixedTotal  = fixedLoan > 0 ? fixedLoan + fixedProfit : 0;
  /// ```
  RealEstateResult calculate(RealEstateInput input) {
    final salary = input.salary;
    final mortYears = input.mortgageYears;
    final profitR = input.profitRate; // already decimal
    final persInst = input.personalInstallment;
    final remPers = input.remainingPersonalMonths;
    final fixedLoan = input.fixedLoan;

    // months = mortYears * 12
    final months = mortYears * 12;

    // dedRate = salary >= 15000 ? 0.65 : 0.55
    final dedRate = salary >= 15000 ? 0.65 : 0.55;

    // persDedR = salary > 0 ? persInst/salary : 0
    final persDedR = salary > 0 ? persInst / salary : 0.0;

    // remDedR = dedRate - persDedR
    final remDedR = dedRate - persDedR;

    // qistPhase1 = Math.min(salary*remDedR, salary*dedRate)
    final qistPhase1 = math.min(salary * remDedR, salary * dedRate);

    // totalPhase1 = qistPhase1 * remPers
    final totalPhase1 = qistPhase1 * remPers;

    // qistPhase2 = salary * dedRate
    final qistPhase2 = salary * dedRate;

    // remMonths = Math.max(0, months - remPers)
    final remMonths = math.max(0, months - remPers);

    // totalPhase2 = qistPhase2 * remMonths
    final totalPhase2 = qistPhase2 * remMonths;

    // totalAllPayments = totalPhase1 + totalPhase2
    final totalAllPayments = totalPhase1 + totalPhase2;

    // loanAmount2in1 = totalAllPayments / (1 + profitR * mortYears)
    final loanAmount2in1 = totalAllPayments / (1 + profitR * mortYears);

    // housingSupport = support ? (salary <= 10000 ? 150000 : 100000) : 0
    final housingSupport =
        input.hasSupport ? (salary <= 10000 ? 150000.0 : 100000.0) : 0.0;

    // etizazAmt = etizaz ? 160000 : 0
    final etizazAmt = input.hasEtizaz ? 160000.0 : 0.0;

    // adminFee = 5750
    const adminFee = 5750.0;

    // totalWithSupport = loanAmount2in1 + housingSupport + etizazAmt
    final totalWithSupport = loanAmount2in1 + housingSupport + etizazAmt;

    // fixedProfit = fixedLoan > 0 ? fixedLoan * profitR * mortYears : 0
    final fixedProfit =
        fixedLoan > 0 ? fixedLoan * profitR * mortYears : 0.0;

    // fixedTotal = fixedLoan > 0 ? fixedLoan + fixedProfit : 0
    final fixedTotal = fixedLoan > 0 ? fixedLoan + fixedProfit : 0.0;

    return RealEstateResult(
      salary: salary,
      mortgageYears: mortYears,
      profitRate: profitR,
      personalInstallment: persInst,
      remainingPersonalMonths: remPers,
      fixedLoan: fixedLoan,
      dedRate: dedRate,
      qistPhase1: qistPhase1,
      qistPhase2: qistPhase2,
      totalPhase1: totalPhase1,
      totalPhase2: totalPhase2,
      loanAmount2in1: loanAmount2in1,
      housingSupport: housingSupport,
      etizazAmt: etizazAmt,
      adminFee: adminFee,
      totalWithSupport: totalWithSupport,
      remainingMonths: remMonths,
      totalAllPayments: totalAllPayments,
      hasSupport: input.hasSupport,
      hasEtizaz: input.hasEtizaz,
      fixedProfit: fixedProfit,
      fixedTotal: fixedTotal,
    );
  }

  /// Generate payment schedule — two phases:
  ///   Phase 1: months 1..remPers → qistPhase1
  ///   Phase 2: months (remPers+1)..totalMonths → qistPhase2
  List<RealEstateScheduleRow> schedule(RealEstateResult r) {
    final rows = <RealEstateScheduleRow>[];
    final total = r.mortgageYears * 12;
    var cum = 0.0;
    for (var i = 1; i <= total; i++) {
      final isP1 = i <= r.remainingPersonalMonths;
      final q = isP1 ? r.qistPhase1 : r.qistPhase2;
      cum += q;
      rows.add(RealEstateScheduleRow(
        month: i,
        payment: q,
        cumulative: cum,
        isPhase1: isP1,
      ));
    }
    return rows;
  }
}
