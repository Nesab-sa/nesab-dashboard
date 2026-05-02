/// Customer segment for leasing (Tajiri) products.
///
/// Each segment has a minimum salary, deduction ratio, and
/// down/last payment percentages that differ for salary vs non-salary clients.
enum CustomerSegment {
  government(
    arabicLabel: 'حكومي',
    salaryMinSalary: 4000,
    salaryDeductionRatio: 0.45,
    salaryDownPayment: 0.0,
    salaryLastPayment: 0.40,
    nonSalaryMinSalary: 7000,
    nonSalaryDeductionRatio: 0.40,
    nonSalaryDownPayment: 0.05,
    nonSalaryLastPayment: 0.35,
  ),
  military(
    arabicLabel: 'عسكري',
    salaryMinSalary: 4000,
    salaryDeductionRatio: 0.45,
    salaryDownPayment: 0.0,
    salaryLastPayment: 0.40,
    nonSalaryMinSalary: 7000,
    nonSalaryDeductionRatio: 0.40,
    nonSalaryDownPayment: 0.05,
    nonSalaryLastPayment: 0.35,
  ),
  largeCorporate(
    arabicLabel: 'شركات كبرى',
    salaryMinSalary: 5000,
    salaryDeductionRatio: 0.45,
    salaryDownPayment: 0.0,
    salaryLastPayment: 0.40,
    nonSalaryMinSalary: 7000,
    nonSalaryDeductionRatio: 0.40,
    nonSalaryDownPayment: 0.05,
    nonSalaryLastPayment: 0.35,
  ),
  privateSector(
    arabicLabel: 'قطاع خاص',
    salaryMinSalary: 5000,
    salaryDeductionRatio: 0.33,
    salaryDownPayment: 0.0,
    salaryLastPayment: 0.40,
    nonSalaryMinSalary: 4000,
    nonSalaryDeductionRatio: 0.40,
    nonSalaryDownPayment: 0.05,
    nonSalaryLastPayment: 0.35,
  ),
  express(
    arabicLabel: 'سريع',
    salaryMinSalary: 6000,
    salaryDeductionRatio: 0.33,
    salaryDownPayment: 0.0,
    salaryLastPayment: 0.40,
    nonSalaryMinSalary: 8000,
    nonSalaryDeductionRatio: 0.40,
    nonSalaryDownPayment: 0.05,
    nonSalaryLastPayment: 0.35,
  ),
  retiredCustomer(
    arabicLabel: 'متقاعدين',
    salaryMinSalary: 4000,
    salaryDeductionRatio: 0.30,
    salaryDownPayment: 0.0,
    salaryLastPayment: 0.30,
    nonSalaryMinSalary: 4000,
    nonSalaryDeductionRatio: 0.25,
    nonSalaryDownPayment: 0.05,
    nonSalaryLastPayment: 0.35,
  );

  const CustomerSegment({
    required this.arabicLabel,
    required this.salaryMinSalary,
    required this.salaryDeductionRatio,
    required this.salaryDownPayment,
    required this.salaryLastPayment,
    required this.nonSalaryMinSalary,
    required this.nonSalaryDeductionRatio,
    required this.nonSalaryDownPayment,
    required this.nonSalaryLastPayment,
  });

  final String arabicLabel;

  final double salaryMinSalary;
  final double salaryDeductionRatio;
  final double salaryDownPayment;
  final double salaryLastPayment;

  final double nonSalaryMinSalary;
  final double nonSalaryDeductionRatio;
  final double nonSalaryDownPayment;
  final double nonSalaryLastPayment;

  double minSalary({required bool isSalaryClient}) =>
      isSalaryClient ? salaryMinSalary : nonSalaryMinSalary;

  double deductionRatio({required bool isSalaryClient}) =>
      isSalaryClient ? salaryDeductionRatio : nonSalaryDeductionRatio;

  double downPaymentRatio({required bool isSalaryClient}) =>
      isSalaryClient ? salaryDownPayment : nonSalaryDownPayment;

  double lastPaymentRatio({required bool isSalaryClient}) =>
      isSalaryClient ? salaryLastPayment : nonSalaryLastPayment;
}
