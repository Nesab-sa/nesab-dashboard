import 'dart:math' as math;

/// Shared financial formulas used across multiple calculator types.
///
/// All amounts are in SAR. Rates are fractional (e.g. 0.01 = 1%).
abstract class BaseFinanceCalculator {
  const BaseFinanceCalculator();

  static const double _adminFeeCap = 2500;

  /// Monthly installment = salary * deductionRatio.
  static double monthlyInstallment({
    required double salary,
    required double deductionRatio,
  }) {
    return salary * deductionRatio;
  }

  /// Total financing = monthlyInstallment * durationMonths.
  static double totalFinancing({
    required double monthlyInstallment,
    required int durationMonths,
  }) {
    return monthlyInstallment * durationMonths;
  }

  /// PLAS approval (principal) amount.
  /// Formula: total / (1 + profitRate * months / 12).
  static double approvalAmount({
    required double totalFinancing,
    required double profitRate,
    required int durationMonths,
  }) {
    return totalFinancing / (1 + profitRate * durationMonths / 12);
  }

  /// Administrative fee = MIN(base * 0.005, 2500).
  ///
  /// [feeBase] is the approval amount for PLAS, or totalFinancing for Quick/Debt.
  static double adminFees({required double feeBase}) {
    return math.min(feeBase * 0.005, _adminFeeCap);
  }

  /// VAT on admin fees at 15%.
  static double vat({required double adminFees}) {
    return adminFees * 0.15;
  }

  /// Total fees = adminFees + VAT.
  static double totalFees({required double adminFees, required double vat}) {
    return adminFees + vat;
  }

  /// Net after admin fees = approval - adminFees - totalFees.
  /// (This is how the Excel formulas compute it.)
  static double netAmount({
    required double approvalAmount,
    required double adminFees,
    required double totalFees,
  }) {
    return approvalAmount - adminFees - totalFees;
  }

  /// Profit earned by the bank = (approval * rate * months) / 12.
  static double bankProfit({
    required double approvalAmount,
    required double profitRate,
    required int durationMonths,
  }) {
    return (approvalAmount * profitRate * durationMonths) / 12;
  }

  /// Net amount after all deductions = approval - totalFees.
  static double netAfterAllDeductions({
    required double approvalAmount,
    required double totalFees,
  }) {
    return approvalAmount - totalFees;
  }
}
