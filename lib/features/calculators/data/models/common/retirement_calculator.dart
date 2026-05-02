import 'eligibility_result.dart';
import 'employment_type.dart';
import 'military_rank.dart';

/// Computes age, months to retirement, and financing eligibility.
abstract class RetirementCalculator {
  const RetirementCalculator._();

  /// Retirement age in years based on employment type and optional rank.
  static int retirementAge({
    required EmploymentType employmentType,
    MilitaryRank? rank,
  }) {
    if (employmentType == EmploymentType.retired) {
      return EmploymentType.retiredMaxAge;
    }
    if (employmentType == EmploymentType.militaryEmployee && rank != null) {
      return rank.retirementAge;
    }
    return EmploymentType.civilianRetirementAge;
  }

  /// Age in fractional years.
  static double ageInYears({
    required DateTime dateOfBirth,
    required DateTime today,
  }) {
    final diff = today.difference(dateOfBirth);
    return diff.inDays / 365.25;
  }

  /// Age in whole months.
  static int ageInMonths({
    required DateTime dateOfBirth,
    required DateTime today,
  }) {
    return (today.year - dateOfBirth.year) * 12 +
        (today.month - dateOfBirth.month);
  }

  /// Retirement age converted to months.
  static int retirementAgeInMonths({
    required EmploymentType employmentType,
    MilitaryRank? rank,
  }) {
    return retirementAge(employmentType: employmentType, rank: rank) * 12;
  }

  /// Months remaining until mandatory retirement.
  static int monthsToRetirement({
    required DateTime dateOfBirth,
    required DateTime today,
    required EmploymentType employmentType,
    MilitaryRank? rank,
  }) {
    final retMonths = retirementAgeInMonths(
      employmentType: employmentType,
      rank: rank,
    );
    final currentMonths = ageInMonths(dateOfBirth: dateOfBirth, today: today);
    return retMonths - currentMonths;
  }

  /// Full eligibility check for a financing product.
  static EligibilityResult checkEligibility({
    required DateTime dateOfBirth,
    required DateTime today,
    required EmploymentType employmentType,
    MilitaryRank? rank,
    required int requestedDurationMonths,
    int minAge = 18,
  }) {
    final years = ageInYears(dateOfBirth: dateOfBirth, today: today);
    final months = ageInMonths(dateOfBirth: dateOfBirth, today: today);

    if (years < minAge) {
      return EligibilityResult.ineligible('العمر أقل من $minAge سنة');
    }

    final remaining = monthsToRetirement(
      dateOfBirth: dateOfBirth,
      today: today,
      employmentType: employmentType,
      rank: rank,
    );

    if (remaining <= 0) {
      return EligibilityResult.ineligible('تجاوز سن التقاعد');
    }

    final maxMonths = remaining;

    return EligibilityResult.eligible(
      remainingMonths: remaining,
      maxMonths: maxMonths,
      ageYears: years,
      ageMonths: months,
    );
  }
}
