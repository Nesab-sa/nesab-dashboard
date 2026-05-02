/// Military ranks with retirement ages for pilots, non-pilots, and enlisted.
enum MilitaryRank {
  // Officers – Pilots
  pilotLieutenant('طيار ملازم وملازم اول', 42),
  pilotCaptain('طيار نقيب', 46),
  pilotMajor('طيار رائد', 48),
  pilotLtColonel('طيار مقدم', 50),
  pilotColonel('طيار عقيد', 52),
  pilotBrigadier('طيار عميد', 54),
  pilotMajorGeneral('طيار لواء', 56),

  // Officers – Non-Pilots
  lieutenant('ملازم وملازم اول', 44),
  captain('نقيب', 48),
  major('رائد', 50),
  ltColonel('مقدم', 52),
  colonel('عقيد', 54),
  brigadier('عميد', 56),
  majorGeneral('لواء', 58),

  // Enlisted / Soldiers
  privateFirstClass('جندي وجندي أول', 44),
  corporal('عريف', 46),
  deputySergeant('وكيل رقيب', 48),
  sergeant('رقيب ورقيب أول', 50),
  masterSergeant('رئيس رقباء', 52);

  const MilitaryRank(this.arabicLabel, this.retirementAge);

  final String arabicLabel;

  /// Mandatory retirement age for this rank.
  final int retirementAge;

  bool get isPilot => name.startsWith('pilot');
  bool get isOfficer => !isEnlisted;
  bool get isEnlisted => index >= MilitaryRank.privateFirstClass.index;

  static List<MilitaryRank> get pilots =>
      values.where((r) => r.isPilot).toList();

  static List<MilitaryRank> get nonPilotOfficers =>
      values.where((r) => r.isOfficer && !r.isPilot).toList();

  static List<MilitaryRank> get enlisted =>
      values.where((r) => r.isEnlisted).toList();
}
