/// Salary-bracket policy overrides for leasing (Tajiri) products.
///
/// Source: تاجيري السياسات sheet.
/// These override the segment-level ratios when real estate is involved.
abstract class LeasingPolicy {
  const LeasingPolicy._();

  /// Max deduction ratio when client HAS a real estate loan.
  static double maxWithRealEstate({required double salary}) {
    if (salary >= 25001) return 0.70;
    return 0.65;
  }

  /// Max deduction ratio when client does NOT have a real estate loan.
  static double maxWithoutRealEstate({required double salary}) {
    if (salary >= 25001) return 0.50;
    return 0.45;
  }

  /// Minimum salary for leasing across all brackets.
  static const double absoluteMinSalary = 2500;

  /// Maximum last-payment (balloon) ratio from policy.
  static const double policyLastPaymentRatio = 0.45;

  /// Effective max deduction considering real estate status.
  static double effectiveMaxDeduction({
    required double salary,
    required bool hasRealEstate,
  }) {
    return hasRealEstate
        ? maxWithRealEstate(salary: salary)
        : maxWithoutRealEstate(salary: salary);
  }
}
