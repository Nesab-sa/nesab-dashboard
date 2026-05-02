import 'dart:math' as math;

import '../models/common/eligibility_result.dart';
import '../models/common/employment_type.dart';
import '../models/common/military_rank.dart';
import '../models/common/retirement_calculator.dart';

/// Input for the Real Estate Plus (2-in-1) calculator.
///
/// Core calculation fields match aqari-plus.html calculate() exactly.
/// Retirement/eligibility fields are used by the Flutter UI page only
/// (the HTML has no retirement logic in JS — it is purely UI).
class RealEstatePlusInput {
  const RealEstatePlusInput({
    required this.salary,
    required this.employmentType,
    required this.birthYear,
    required this.birthMonth,
    required this.remainingPersonalMonths,
    required this.personalInstallment,
    required this.mortgageYears,
    required this.profitRate,
    this.militaryRank,
    this.hasSupport = true,
    this.hasEtizaz = false,
    this.fixedLoan = 0,
    this.today,
  });

  final double salary;
  final EmploymentType employmentType;
  final int birthYear;
  final int birthMonth;
  final int remainingPersonalMonths;
  final double personalInstallment;
  final int mortgageYears;
  final double profitRate; // e.g. 0.0405 for 4.05%
  final MilitaryRank? militaryRank;
  final bool hasSupport;
  final bool hasEtizaz;
  final double fixedLoan; // 0 = auto calc
  final DateTime? today;
}

/// Result of the Real Estate Plus (2-in-1) calculation.
class RealEstatePlusResult {
  const RealEstatePlusResult({
    required this.eligibility,
    required this.salary,
    required this.availableYears,
    required this.maxYears,
    required this.finalYears,
    required this.totalMonths,
    required this.dedRate,
    required this.personalDedRate,
    required this.remainingDedRate,
    required this.qistPhase1,
    required this.qistPhase2,
    required this.totalPhase1,
    required this.totalPhase2,
    required this.remainingPersonalMonths,
    required this.remainingMortgageMonths,
    required this.totalAllPayments,
    required this.loanAmount2in1,
    required this.hasSupport,
    required this.housingSupport,
    required this.hasEtizaz,
    required this.etizazAmount,
    required this.adminFee,
    required this.totalWithSupport,
    required this.fixedLoan,
    required this.fixedProfit,
    required this.fixedTotal,
    required this.retireAge,
    required this.profitRate,
  });

  final EligibilityResult eligibility;
  final double salary;
  final int availableYears;
  final int maxYears;
  final int finalYears;
  final int totalMonths;
  final double dedRate;
  final double personalDedRate;
  final double remainingDedRate;
  final double qistPhase1;
  final double qistPhase2;
  final double totalPhase1;
  final double totalPhase2;
  final int remainingPersonalMonths;
  final int remainingMortgageMonths;
  final double totalAllPayments;
  final double loanAmount2in1;
  final bool hasSupport;
  final double housingSupport;
  final bool hasEtizaz;
  final double etizazAmount;
  final double adminFee;
  final double totalWithSupport;
  final double fixedLoan;
  final double fixedProfit;
  final double fixedTotal;
  final int retireAge;
  final double profitRate;
}

/// Schedule row for the instalment table.
class RealEstatePlusScheduleRow {
  const RealEstatePlusScheduleRow({
    required this.month,
    required this.payment,
    required this.cumulative,
    required this.isPhase1,
  });

  final int month;
  final double payment;
  final double cumulative;
  final bool isPhase1;
}

/// Real Estate Plus (2-in-1 Sakani) Calculator.
///
/// Core formulas match aqari-plus.html calculate() exactly:
/// ```js
/// const months=mortYears*12;
/// const dedRate=salary>=15000?0.65:0.55;
/// const persDedR=salary>0?persInst/salary:0;
/// const remDedR=dedRate-persDedR;
/// const qistPhase1=Math.min(salary*remDedR,salary*dedRate);
/// const totalPhase1=qistPhase1*remPers;
/// const qistPhase2=salary*dedRate;
/// const remMonths=Math.max(0,months-remPers);
/// const totalPhase2=qistPhase2*remMonths;
/// const totalAllPayments=totalPhase1+totalPhase2;
/// const loanAmount2in1=totalAllPayments/(1+profitR*mortYears);
/// const housingSupport=support?(salary<=10000?150000:100000):0;
/// const etizazAmt=etizaz?160000:0;
/// const adminFee=5750;
/// const totalWithSupport=loanAmount2in1+housingSupport+etizazAmt;
/// const fixedProfit=fixedLoan>0?fixedLoan*profitR*mortYears:0;
/// const fixedTotal=fixedLoan>0?fixedLoan+fixedProfit:0;
/// ```
///
/// Retirement/eligibility is computed here for the Flutter UI page,
/// which displays available years, max years, and eligibility badges.
class RealEstatePlusCalculator {
  const RealEstatePlusCalculator();

  static const double _adminAndAppraisalFees = 5750;
  static const int _civilRetireAge = 60;

  /// Get retirement age based on employment type and rank.
  int _getRetireAge(EmploymentType type, MilitaryRank? rank) {
    if (type == EmploymentType.civilianEmployee ||
        type == EmploymentType.retired) {
      return _civilRetireAge;
    }
    return rank?.retirementAge ?? _civilRetireAge;
  }

  /// Get available years until retirement.
  /// Mirrors the page's _availableYears getter:
  ///   ageYears = now.year - by; if (now.month < bm) ageYears--;
  ///   avail = retireAge - ageYears;
  int _getAvailableYears(
      int birthYear, int birthMonth, int retireAge, DateTime today) {
    int ageYears = today.year - birthYear;
    if (today.month < birthMonth) ageYears--;
    return retireAge - ageYears;
  }

  RealEstatePlusResult calculate(RealEstatePlusInput input) {
    final today = input.today ?? DateTime.now();
    final salary = input.salary;

    // -- Retirement & available years (Flutter UI feature) --
    final retireAge =
        _getRetireAge(input.employmentType, input.militaryRank);
    final availableYears = _getAvailableYears(
        input.birthYear, input.birthMonth, retireAge, today);
    final maxYears =
        availableYears < 0 ? 0 : (availableYears > 30 ? 30 : availableYears);
    final finalYears =
        input.mortgageYears > maxYears ? maxYears : input.mortgageYears;

    // -- Core HTML formulas (identical to aqari-plus.html) --

    // months = mortYears * 12
    final months = finalYears * 12;

    // Eligibility check (Flutter UI feature)
    final dateOfBirth = DateTime(input.birthYear, input.birthMonth, 1);
    final eligibility = RetirementCalculator.checkEligibility(
      dateOfBirth: dateOfBirth,
      today: today,
      employmentType: input.employmentType,
      rank: input.militaryRank,
      requestedDurationMonths: months,
    );

    // dedRate = salary >= 15000 ? 0.65 : 0.55
    final dedRate = salary >= 15000 ? 0.65 : 0.55;

    // persDedR = salary > 0 ? persInst/salary : 0
    final persDedR = salary > 0 ? input.personalInstallment / salary : 0.0;

    // remDedR = dedRate - persDedR
    final remDedR = dedRate - persDedR;

    // qistPhase1 = Math.min(salary*remDedR, salary*dedRate)
    final qistPhase1 = math.min(salary * remDedR, salary * dedRate);

    // totalPhase1 = qistPhase1 * remPers
    final totalPhase1 = qistPhase1 * input.remainingPersonalMonths;

    // qistPhase2 = salary * dedRate
    final qistPhase2 = salary * dedRate;

    // remMonths = Math.max(0, months - remPers)
    final remMonths = math.max(0, months - input.remainingPersonalMonths);

    // totalPhase2 = qistPhase2 * remMonths
    final totalPhase2 = qistPhase2 * remMonths;

    // totalAllPayments = totalPhase1 + totalPhase2
    final totalAllPayments = totalPhase1 + totalPhase2;

    // loanAmount2in1 = totalAllPayments / (1 + profitR * mortYears)
    final loanAmount2in1 =
        totalAllPayments / (1 + input.profitRate * finalYears);

    // housingSupport = support ? (salary <= 10000 ? 150000 : 100000) : 0
    final housingSupport =
        input.hasSupport ? (salary <= 10000 ? 150000.0 : 100000.0) : 0.0;

    // etizazAmt = etizaz ? 160000 : 0
    final etizazAmt = input.hasEtizaz ? 160000.0 : 0.0;

    // totalWithSupport = loanAmount2in1 + housingSupport + etizazAmt
    final totalWithSupport = loanAmount2in1 + housingSupport + etizazAmt;

    // fixedProfit = fixedLoan > 0 ? fixedLoan * profitR * mortYears : 0
    final fixedProfit = input.fixedLoan > 0
        ? input.fixedLoan * input.profitRate * finalYears
        : 0.0;

    // fixedTotal = fixedLoan > 0 ? fixedLoan + fixedProfit : 0
    final fixedTotal =
        input.fixedLoan > 0 ? input.fixedLoan + fixedProfit : 0.0;

    return RealEstatePlusResult(
      eligibility: eligibility,
      salary: salary,
      availableYears: availableYears > 0 ? availableYears : 0,
      maxYears: maxYears,
      finalYears: finalYears,
      totalMonths: months,
      dedRate: dedRate,
      personalDedRate: persDedR,
      remainingDedRate: remDedR,
      qistPhase1: qistPhase1,
      qistPhase2: qistPhase2,
      totalPhase1: totalPhase1,
      totalPhase2: totalPhase2,
      remainingPersonalMonths: input.remainingPersonalMonths,
      remainingMortgageMonths: remMonths > 0 ? remMonths : 0,
      totalAllPayments: totalAllPayments,
      loanAmount2in1: loanAmount2in1,
      hasSupport: input.hasSupport,
      housingSupport: housingSupport,
      hasEtizaz: input.hasEtizaz,
      etizazAmount: etizazAmt,
      adminFee: _adminAndAppraisalFees,
      totalWithSupport: totalWithSupport,
      fixedLoan: input.fixedLoan,
      fixedProfit: fixedProfit,
      fixedTotal: fixedTotal,
      retireAge: retireAge,
      profitRate: input.profitRate,
    );
  }

  /// Generate a monthly schedule showing Phase 1 and Phase 2.
  List<RealEstatePlusScheduleRow> schedule(RealEstatePlusResult r) {
    final rows = <RealEstatePlusScheduleRow>[];
    double cumulative = 0;
    final total = r.totalMonths;
    for (int i = 1; i <= total; i++) {
      final isP1 = i <= r.remainingPersonalMonths;
      final q = isP1 ? r.qistPhase1 : r.qistPhase2;
      cumulative += q;
      rows.add(RealEstatePlusScheduleRow(
        month: i,
        payment: q,
        cumulative: cumulative,
        isPhase1: isP1,
      ));
    }
    return rows;
  }
}
