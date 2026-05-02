/// Employment sector with eligibility constraints (min salary, min/max age).
///
/// Source: PLAS Sheet1.
enum EmploymentSector {
  civilianAndLargeCorporate(
    arabicLabel: 'حكومي مدني والشركات الكبرى',
    minSalary: 3000,
    minAge: 18,
    maxAge: 60,
  ),
  retired(arabicLabel: 'المتقاعدين', minSalary: 4000, minAge: 30, maxAge: 75),
  healthAndEducation(
    arabicLabel: 'قطاع الصحة والتعليم',
    minSalary: 3000,
    minAge: 18,
    maxAge: 60,
  ),
  airForce(
    arabicLabel: 'القوات الجوية',
    minSalary: 3000,
    minAge: 18,
    maxAge: 60,
  ),
  publicSecurity(
    arabicLabel: 'جميع قطاعات الأمن العام',
    minSalary: 3000,
    minAge: 18,
    maxAge: 60,
  ),
  navy(arabicLabel: 'القوات البحرية', minSalary: 7000, minAge: 18, maxAge: 60),
  militaryMedical(
    arabicLabel: 'القطاع الطبي العسكري',
    minSalary: 3000,
    minAge: 18,
    maxAge: 60,
  ),
  airDefense(
    arabicLabel: 'الدفاع الجوي',
    minSalary: 3000,
    minAge: 22,
    maxAge: 60,
  ),
  nationalGuard(
    arabicLabel: 'الحرس الوطني',
    minSalary: 3000,
    minAge: 18,
    maxAge: 60,
  ),
  groundForces(
    arabicLabel: 'القوات البرية',
    minSalary: 3000,
    minAge: 18,
    maxAge: 60,
  ),
  saudiAirlines(
    arabicLabel: 'الخطوط السعودية',
    minSalary: 5000,
    minAge: 18,
    maxAge: 60,
  ),
  premiumCompanies(
    arabicLabel: 'الشركات المميزة',
    minSalary: 3000,
    minAge: 22,
    maxAge: 60,
  ),
  privateAgreement(
    arabicLabel: 'القطاع الخاص باتفاقية',
    minSalary: 5000,
    minAge: 24,
    maxAge: 60,
  );

  const EmploymentSector({
    required this.arabicLabel,
    required this.minSalary,
    required this.minAge,
    required this.maxAge,
  });

  final String arabicLabel;
  final double minSalary;
  final int minAge;
  final int maxAge;

  /// Check if a client meets this sector's eligibility.
  bool isEligible({required double salary, required double ageYears}) {
    return salary >= minSalary && ageYears >= minAge && ageYears <= maxAge;
  }

  /// Returns the rejection reason, or null if eligible.
  String? rejectionReason({required double salary, required double ageYears}) {
    if (salary < minSalary) {
      return 'الراتب أقل من الحد الأدنى (${minSalary.toStringAsFixed(0)} ريال)';
    }
    if (ageYears < minAge) return 'العمر أقل من $minAge سنة';
    if (ageYears > maxAge) return 'العمر أكبر من $maxAge سنة';
    return null;
  }
}
