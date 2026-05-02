import 'dart:math' as math;

import '../models/common/eligibility_result.dart';
import '../models/common/employment_type.dart';
import '../models/common/military_rank.dart';
import '../models/common/retirement_calculator.dart';

/// Input parameters for the Personal Finance (PLAS) calculator.
class PersonalFinanceInput {
  const PersonalFinanceInput({
    required this.salary,
    required this.employmentType,
    required this.dateOfBirth,
    required this.profitRate,
    required this.durationMonths,
    this.ahliCreditCardLimit = 0,
    this.otherCreditCardLimit = 0,
    this.hasRealEstateLoan = false,
    this.militaryRank,
    this.today,
  });

  final double salary;
  final EmploymentType employmentType;
  final DateTime dateOfBirth;

  /// Profit rate as a fraction (e.g. 0.01 = 1%).
  final double profitRate;
  final int durationMonths;
  final double ahliCreditCardLimit;
  final double otherCreditCardLimit;
  final bool hasRealEstateLoan;
  final MilitaryRank? militaryRank;
  final DateTime? today;
}

/// Result of the Personal Finance (PLAS) calculation.
class PersonalFinanceResult {
  const PersonalFinanceResult({
    required this.eligibility,
    required this.deductionRatio,
    required this.monthlyInstallment,
    required this.totalFinancing,
    required this.approvalAmount,
    required this.adminFees,
    required this.vat,
    required this.totalFees,
    required this.netAmount,
    required this.bankProfit,
    required this.netAfterAllDeductions,
    required this.maxAvailableMonths,
    required this.retireAge,
    required this.ageMonths,
    required this.remMonths,
    required this.timeEligible,
  });

  final EligibilityResult eligibility;
  final double deductionRatio;
  final double monthlyInstallment;
  final double totalFinancing;
  final double approvalAmount;
  final double adminFees;
  final double vat;
  final double totalFees;
  final double netAmount;
  final double bankProfit;
  final double netAfterAllDeductions;
  final int maxAvailableMonths;
  final int retireAge;
  final int ageMonths;
  final int remMonths;
  final bool timeEligible;
}

/// Schedule row for the installment table.
class PersonalScheduleRow {
  const PersonalScheduleRow({
    required this.month,
    required this.payment,
    required this.cumulative,
  });
  final int month;
  final double payment;
  final double cumulative;
}

/// PLAS Personal Finance Calculator.
///
/// All formulas match the HTML JavaScript (shakhsi-plus.html) exactly.
///
/// HTML JS source (lines 278-300):
/// ```js
/// function calcDedRate(ws, mortgage, salary) {
///   if (mortgage === 'لا يوجد') { if (ws === 'متقاعد') return 0.25; return 0.3333; }
///   else { if (ws === 'متقاعد') return 0.55; return salary < 15000 ? 0.55 : 0.65; }
/// }
///
/// const monthlyInstall = (salary * dedRate) - (ahli * 0.05) - (other * 0.05);
/// const totalFinance   = monthlyInstall * months;
/// const approvedAmt    = totalFinance > 0 ? totalFinance / (1 + profitR * months / 12) : 0;
/// const adminFee       = Math.min(approvedAmt / 200, 2500);   // 0.5% capped at 2500
/// const tax            = adminFee * 0.15;
/// const totalFees      = adminFee + tax;
/// const bankProfit     = (approvedAmt * profitR * months) / 12;
/// const netFinal       = approvedAmt - totalFees;
/// ```
///
/// Retirement ages from HTML RETIRE_AGES constant:
///   مدني=65, متقاعد=75, military ranks per MilitaryRank enum.
///
/// Eligibility: remMonths >= 60  (retirement_age*12 - age_months >= 60).
class PersonalFinanceCalculator {
  const PersonalFinanceCalculator();

  PersonalFinanceResult calculate(PersonalFinanceInput input) {
    final today = input.today ?? DateTime.now();

    // ---- Retirement / eligibility (matches HTML calcRetire) ----
    // HTML: getRetireAge():
    //   if ws === 'متقاعد' => 75
    //   if ws === 'موظف مدني' => 65
    //   else => RETIRE_AGES[rankSel] || 60
    final retireAge = RetirementCalculator.retirementAge(
      employmentType: input.employmentType,
      rank: input.militaryRank,
    );

    // HTML: let ageM = (now.getFullYear()-by)*12 + (now.getMonth()+1-bm);
    // Note: JS getMonth() is 0-based, so getMonth()+1 = Dart's month.
    final ageMonths = RetirementCalculator.ageInMonths(
      dateOfBirth: input.dateOfBirth,
      today: today,
    );

    // HTML: const remM = ra*12 - ageM;
    final retireMonths = retireAge * 12;
    final remMonths = retireMonths - ageMonths;

    // HTML: const elig = remM >= 60;
    final timeEligible = remMonths >= 60;

    final eligibility = RetirementCalculator.checkEligibility(
      dateOfBirth: input.dateOfBirth,
      today: today,
      employmentType: input.employmentType,
      rank: input.militaryRank,
      requestedDurationMonths: input.durationMonths,
    );

    // ---- Deduction ratio (HTML calcDedRate) ----
    // function calcDedRate(ws, mortgage, salary) {
    //   if (mortgage === 'لا يوجد') {
    //     if (ws === 'متقاعد') return 0.25;
    //     return 0.3333;
    //   } else {
    //     if (ws === 'متقاعد') return 0.55;
    //     return salary < 15000 ? 0.55 : 0.65;
    //   }
    // }
    final isRetired = input.employmentType == EmploymentType.retired;
    final double deductionRatio;
    if (!input.hasRealEstateLoan) {
      // mortgage === 'لا يوجد'
      deductionRatio = isRetired ? 0.25 : 0.3333;
    } else {
      // mortgage === 'نعم يوجد'
      if (isRetired) {
        deductionRatio = 0.55;
      } else {
        deductionRatio = input.salary < 15000 ? 0.55 : 0.65;
      }
    }

    // HTML: const monthlyInstall = (salary * dedRate) - (ahli * 0.05) - (other * 0.05);
    final monthly = (input.salary * deductionRatio) -
        (input.ahliCreditCardLimit * 0.05) -
        (input.otherCreditCardLimit * 0.05);

    // HTML: const totalFinance = monthlyInstall * months;
    final total = monthly * input.durationMonths;

    // HTML: const approvedAmt = totalFinance > 0
    //         ? totalFinance / (1 + profitR * months / 12) : 0;
    final approval = total > 0
        ? total / (1 + input.profitRate * input.durationMonths / 12)
        : 0.0;

    // HTML: const adminFee = Math.min(approvedAmt / 200, 2500);
    // i.e. 0.5% capped at 2500
    final adminFee = math.min(approval / 200, 2500.0);

    // HTML: const tax = adminFee * 0.15;
    final vatAmount = adminFee * 0.15;

    // HTML: const totalFees = adminFee + tax;
    final totalFees = adminFee + vatAmount;

    // HTML: const bankProfit = (approvedAmt * profitR * months) / 12;
    final bankProfit =
        (approval * input.profitRate * input.durationMonths) / 12;

    // HTML: const netFinal = approvedAmt - totalFees;
    final netFinal = approval - totalFees;

    return PersonalFinanceResult(
      eligibility: eligibility,
      deductionRatio: deductionRatio,
      monthlyInstallment: monthly,
      totalFinancing: total,
      approvalAmount: approval,
      adminFees: adminFee,
      vat: vatAmount,
      totalFees: totalFees,
      netAmount: netFinal,
      bankProfit: bankProfit,
      netAfterAllDeductions: netFinal,
      maxAvailableMonths: eligibility.maxAvailableMonths ?? 0,
      retireAge: retireAge,
      ageMonths: ageMonths,
      remMonths: remMonths,
      timeEligible: timeEligible,
    );
  }

  /// Generate a payment schedule: fixed monthly installment for each month.
  List<PersonalScheduleRow> schedule(PersonalFinanceResult r) {
    final rows = <PersonalScheduleRow>[];
    double cumulative = 0;
    final months = r.totalFinancing > 0
        ? (r.totalFinancing / r.monthlyInstallment).round()
        : 0;
    for (int i = 1; i <= months; i++) {
      cumulative += r.monthlyInstallment;
      rows.add(PersonalScheduleRow(
        month: i,
        payment: r.monthlyInstallment,
        cumulative: cumulative,
      ));
    }
    return rows;
  }

  PersonalFinanceResult zeroResult() {
    return const PersonalFinanceResult(
      eligibility: EligibilityResult(isEligible: false),
      deductionRatio: 0,
      monthlyInstallment: 0,
      totalFinancing: 0,
      approvalAmount: 0,
      adminFees: 0,
      vat: 0,
      totalFees: 0,
      netAmount: 0,
      bankProfit: 0,
      netAfterAllDeductions: 0,
      maxAvailableMonths: 0,
      retireAge: 0,
      ageMonths: 0,
      remMonths: 0,
      timeEligible: false,
    );
  }
}
