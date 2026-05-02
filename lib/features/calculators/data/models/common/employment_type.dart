/// Employment classification affecting deduction ratios and retirement age.
enum EmploymentType {
  civilianEmployee('موظف مدني', 'Civilian Employee'),
  militaryEmployee('موظف عسكري', 'Military Employee'),
  retired('متقاعد', 'Retired');

  const EmploymentType(this.arabicLabel, this.englishLabel);

  final String arabicLabel;
  final String englishLabel;

  String label({bool english = false}) => english ? englishLabel : arabicLabel;

  /// Civilian retirement age is fixed at 65 for all ranks.
  static const int civilianRetirementAge = 65;

  /// Retired clients have a max financing age of 75.
  static const int retiredMaxAge = 75;
}
