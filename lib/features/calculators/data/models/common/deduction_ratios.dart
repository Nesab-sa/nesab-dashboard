/// Deduction ratio lookup based on salary bracket and product combination.
///
/// Source:  deduction ratio matrix.
/// Ratios are expressed as fractions (e.g. 0.3333 = 33.33%).
abstract class DeductionRatios {
  const DeductionRatios._();

  /// Personal finance + lease (Murabaha) deduction ratio.
  static double personalAndLease({
    required double salary,
    required bool isRetired,
  }) {
    return isRetired ? 0.25 : 0.3333;
  }

  /// Personal finance + credit cards combined deduction cap.
  static double personalAndCards({required double salary}) => 0.45;

  /// Lease-only (Ijara / Murabaha) deduction ratio.
  static double leaseOnly({required double salary}) {
    if (salary >= 25001) return 0.60;
    return 0.45;
  }

  /// Real estate financing deduction ratio.
  /// Excel: IF(salary < 15000, 55%, 65%)
  static double realEstate({required double salary}) {
    if (salary < 15000) return 0.55;
    return 0.65;
  }

  /// Real Estate Development Fund (REDF / صندوق التنمية العقاري).
  static double redf({required double salary}) => 0.65;

  /// Combined max deduction with real estate present.
  static double maxWithRealEstate({required double salary}) {
    if (salary >= 25001) return 0.70;
    return 0.65;
  }

  /// Combined max deduction without real estate.
  static double maxWithoutRealEstate({required double salary}) {
    if (salary >= 25001) return 0.50;
    return 0.45;
  }

  /// Returns all deduction amounts for a given salary (utility tool).
  ///
  /// [existingObligations] is the total of current monthly deductions
  /// (personal loan + cards + other). If the remaining salary after the
  /// threshold amount is less than existing obligations, the threshold
  /// is marked as not applicable ("لا").
  static DeductionBreakdown breakdown(
    double salary, {
    double existingObligations = 0,
  }) {
    final at33 = salary * 0.3333;
    final at45 = salary * 0.45;
    final reRatio = realEstate(salary: salary);
    final at55or65 = salary * reRatio;
    return DeductionBreakdown(
      salary: salary,
      amountAt33: at33,
      amountAt45: at45,
      amountAt55or65: at55or65,
      applicableAt33: at33 > existingObligations,
      applicableAt45: at45 > existingObligations,
      applicableAt55or65: at55or65 > existingObligations,
    );
  }
}

/// Breakdown of deduction amounts at each threshold.
class DeductionBreakdown {
  const DeductionBreakdown({
    required this.salary,
    required this.amountAt33,
    required this.amountAt45,
    required this.amountAt55or65,
    required this.applicableAt33,
    required this.applicableAt45,
    required this.applicableAt55or65,
  });

  final double salary;
  final double amountAt33;
  final double amountAt45;
  final double amountAt55or65;
  final bool applicableAt33;
  final bool applicableAt45;
  final bool applicableAt55or65;
}
