// ---------------------------------------------------------------------------
// Tools calculator – exact HTML formulas
// ---------------------------------------------------------------------------

/// Age calculation result (matches HTML: calcAge).
class AgeResult {
  const AgeResult({
    required this.years,
    required this.months,
    required this.totalMonths,
    required this.hijriYears,
  });

  final int years;
  final int months;
  final int totalMonths;
  final int hijriYears;
}

/// Date conversion result.
class DateConvertResult {
  const DateConvertResult({
    required this.day,
    required this.month,
    required this.year,
  });

  final int day;
  final int month;
  final int year;
}

/// Deduction ratio result (نسبة الاستقطاع).
class DeductionRatioResult {
  const DeductionRatioResult({
    required this.personal33,
    required this.leasing45,
    required this.realEstate,
    required this.realEstateLabel,
  });

  final double personal33;
  final double leasing45;
  final double realEstate;
  final String realEstateLabel; // '55' or '65'
}

/// Deduction Yes/No result (الاستقطاع نعم لا).
class DeductionYesNoResult {
  const DeductionYesNoResult({
    required this.personal33,
    required this.leasing45,
    required this.realEstate,
    required this.hasPersonal,
    required this.hasLeasing,
    required this.hasRealEstate,
    required this.realEstateLabel,
  });

  final double personal33;
  final double leasing45;
  final double realEstate;
  final bool hasPersonal;
  final bool hasLeasing;
  final bool hasRealEstate;
  final String realEstateLabel;
}

class ToolsCalculator {
  const ToolsCalculator();

  // -----------------------------------------------------------------------
  // Age calculator – matches HTML calcAge()
  // -----------------------------------------------------------------------
  AgeResult calculateAge({
    required DateTime dateOfBirth,
    DateTime? today,
  }) {
    final d2 = today ?? DateTime.now();
    final d1 = dateOfBirth;

    final totalMonths =
        (d2.year - d1.year) * 12 + (d2.month - d1.month);
    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;

    final diffMs = d2.difference(d1).inMilliseconds;
    final hijriYears = (diffMs / (354.367 * 24 * 3600 * 1000)).floor();

    return AgeResult(
      years: years,
      months: months,
      totalMonths: totalMonths,
      hijriYears: hijriYears,
    );
  }

  // -----------------------------------------------------------------------
  // Date converter: Gregorian → Hijri – matches HTML convertDate() AD branch
  // Uses Julian Day Number formula exactly from HTML.
  // -----------------------------------------------------------------------
  DateConvertResult gregorianToHijri(int gY, int gM, int gD) {
    final a = (14 - gM) ~/ 12;
    final y = gY + 4800 - a;
    final m = gM + 12 * a - 3;

    final jd = gD +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;

    final l = jd - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    final l2 = l - 10631 * n + 354;
    final j2 = ((10985 - l2) ~/ 5316) * ((50 * l2) ~/ 17719) +
        (l2 ~/ 5670) * ((43 * l2) ~/ 15238);
    final l3 = l2 -
        ((30 - j2) ~/ 15) * ((17719 * j2) ~/ 50) -
        (j2 ~/ 16) * ((15238 * j2) ~/ 43) +
        29;
    final hMonth = (24 * l3) ~/ 709;
    final hDay = l3 - (709 * hMonth) ~/ 24 + 1;
    final hYear = 30 * n + j2 - 29 - 1;

    return DateConvertResult(day: hDay, month: hMonth, year: hYear);
  }

  // -----------------------------------------------------------------------
  // Date converter: Hijri → Gregorian – matches HTML convertDate() HJ branch
  // -----------------------------------------------------------------------
  DateConvertResult hijriToGregorian(int hDay, int hMonth, int hYear) {
    final jd2 = (11 * hYear + 3) ~/ 30 +
        354 * hYear +
        30 * hMonth -
        (hMonth - 1) ~/ 2 +
        hDay +
        1948440 -
        385;

    final p =
        jd2 + 1401 + ((4 * jd2 + 274277) ~/ 146097) * 3 ~/ 4 - 38;
    final q = 4 * p + 3;
    final e = (q % 1461) ~/ 4;
    final h = 5 * e + 2;

    final gDay = (h % 153) ~/ 5 + 1 - 1;
    final gMonth = ((h ~/ 153) + 2) % 12 + 1;
    final gYear = q ~/ 1461 - 4716 + (14 - gMonth) ~/ 12;

    return DateConvertResult(day: gDay, month: gMonth, year: gYear);
  }

  // -----------------------------------------------------------------------
  // Deduction Ratio – matches HTML calcDeduct()
  // -----------------------------------------------------------------------
  DeductionRatioResult calculateDeductionRatio(double salary) {
    final d33 = salary * 0.3333;
    final d45 = salary * 0.45 - d33;
    final d5565 = salary < 15000 ? salary * 0.55 : salary * 0.65;

    return DeductionRatioResult(
      personal33: d33,
      leasing45: d45,
      realEstate: d5565,
      realEstateLabel: salary < 15000 ? '55' : '65',
    );
  }

  // -----------------------------------------------------------------------
  // Deduction Yes/No – matches HTML calcYN()
  // -----------------------------------------------------------------------
  DeductionYesNoResult calculateDeductionYesNo({
    required double salary,
    required bool hasPersonal,
    required bool hasLeasing,
    required bool hasRealEstate,
  }) {
    final v33 = hasPersonal ? salary * 0.3333 : 0.0;
    final v45 = hasLeasing ? (salary * 0.45 - v33) : 0.0;
    final v55 = hasRealEstate
        ? ((salary < 15000 ? salary * 0.55 : salary * 0.65) - (v33 + v45))
        : 0.0;

    return DeductionYesNoResult(
      personal33: v33,
      leasing45: v45,
      realEstate: v55,
      hasPersonal: hasPersonal,
      hasLeasing: hasLeasing,
      hasRealEstate: hasRealEstate,
      realEstateLabel: salary < 15000 ? '55' : '65',
    );
  }
}
