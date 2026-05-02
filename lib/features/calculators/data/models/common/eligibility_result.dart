/// Result of an eligibility check for a financing product.
class EligibilityResult {
  const EligibilityResult({
    required this.isEligible,
    this.reason,
    this.remainingMonthsToRetirement,
    this.maxAvailableMonths,
    this.ageInYears,
    this.ageInMonths,
  });

  final bool isEligible;
  final String? reason;
  final int? remainingMonthsToRetirement;
  final int? maxAvailableMonths;
  final double? ageInYears;
  final int? ageInMonths;

  factory EligibilityResult.eligible({
    required int remainingMonths,
    required int maxMonths,
    required double ageYears,
    required int ageMonths,
  }) {
    return EligibilityResult(
      isEligible: true,
      remainingMonthsToRetirement: remainingMonths,
      maxAvailableMonths: maxMonths,
      ageInYears: ageYears,
      ageInMonths: ageMonths,
    );
  }

  factory EligibilityResult.ineligible(String reason) {
    return EligibilityResult(isEligible: false, reason: reason);
  }
}
