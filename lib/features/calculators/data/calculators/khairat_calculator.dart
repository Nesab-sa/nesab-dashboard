// Khairat (خيرات) Investment Calculator.
//
// Ported from: khayrat.html
//
// HTML constants (line 213):
//   const PERIODS = {
//     'أسبوعين':       [0.0395, 14],
//     'ثلاثة أسابيع':  [0.0405, 21],
//     'شهر':           [0.0435, 30],
//     'شهرين':         [0.0448, 60],
//     'ثلاثة شهور':    [0.046,  90],
//     'ستة شهور':      [0.0465, 180],
//     'تسعة شهور':     [0.0455, 270],
//     'سنة':           [0.0445, 360],
//   };
//
// HTML formula (lines 220-221):
//   profit = amt * r * days / 360
//   total  = amt + profit
//
// Minimum deposit: 100,000 SAR (line 217).

// Investment period with corresponding profit rate and number of days.
// Each entry matches a key in the HTML PERIODS object.
enum KhairatPeriod {
  twoWeeks(14, 0.0395, 'أسبوعين', 'أسبوعين — 3.95% — 14 يوم'),
  threeWeeks(21, 0.0405, 'ثلاثة أسابيع', 'ثلاثة أسابيع — 4.05% — 21 يوم'),
  oneMonth(30, 0.0435, 'شهر', 'شهر — 4.35% — 30 يوم'),
  twoMonths(60, 0.0448, 'شهرين', 'شهرين — 4.48% — 60 يوم'),
  threeMonths(90, 0.046, 'ثلاثة شهور', 'ثلاثة شهور — 4.60% — 90 يوم'),
  sixMonths(180, 0.0465, 'ستة شهور', 'ستة شهور — 4.65% — 180 يوم'),
  nineMonths(270, 0.0455, 'تسعة شهور', 'تسعة شهور — 4.55% — 270 يوم'),
  oneYear(360, 0.0445, 'سنة', 'سنة — 4.45% — 360 يوم');

  const KhairatPeriod(
    this.days,
    this.profitRate,
    this.arabicLabel,
    this.dropdownLabel,
  );

  final int days;
  final double profitRate;
  final String arabicLabel;
  final String dropdownLabel;
}

/// Input for the Khairat investment calculator.
class KhairatInput {
  const KhairatInput({
    required this.investAmount,
    required this.period,
  });

  final double investAmount;
  final KhairatPeriod period;
}

/// Result of the Khairat investment calculation.
///
/// Fields match the HTML result display (lines 224-229):
///   - مبلغ الاستثمار  -> investAmount
///   - الفترة          -> periodLabel, days
///   - هامش الربح       -> profitRate
///   - الأرباح          -> profit
///   - المبلغ الجديد    -> totalReturn
class KhairatResult {
  const KhairatResult({
    required this.investAmount,
    required this.profitRate,
    required this.days,
    required this.profit,
    required this.totalReturn,
    required this.isEligible,
    required this.periodLabel,
  });

  final double investAmount;
  final double profitRate;
  final int days;
  final double profit;
  final double totalReturn;
  final bool isEligible;
  final String periodLabel;
}

/// Row for the "all periods" comparison table.
class KhairatTableRow {
  const KhairatTableRow({
    required this.periodName,
    required this.days,
    required this.profitRate,
    required this.profit,
    required this.newAmount,
  });

  final String periodName;
  final int days;
  final double profitRate;
  final double profit;
  final double newAmount;
}

/// Khairat Investment Calculator.
///
/// Minimum deposit: 100,000 SAR.
/// Formula: profit = amt * r * days / 360
class KhairatCalculator {
  const KhairatCalculator();

  /// HTML line 217: if(amt < 100000) { alert(...); return }
  static const double minDeposit = 100000;

  /// Calculate profit for a given input.
  ///
  /// HTML lines 219-221:
  ///   const [r, days] = PERIODS[period];
  ///   const profit = amt * r * days / 360;
  ///   const total  = amt + profit;
  KhairatResult calculate(KhairatInput input) {
    final amt = input.investAmount;
    final r = input.period.profitRate;
    final days = input.period.days;

    // profit = amt * r * days / 360
    final profit = amt * r * days / 360;

    // total = amt + profit
    final total = amt + profit;

    // HTML line 217: amt < 100000 -> rejected
    final isEligible = amt >= minDeposit;

    return KhairatResult(
      investAmount: amt,
      profitRate: r,
      days: days,
      profit: profit,
      totalReturn: total,
      isEligible: isEligible,
      periodLabel: input.period.arabicLabel,
    );
  }

  /// Build a comparison table for all periods using the same formula.
  /// (Not in the HTML -- added for Flutter UI convenience.)
  ///
  /// Per row: profit = amt * r * days / 360
  List<KhairatTableRow> allPeriodsTable(double investAmount) {
    return KhairatPeriod.values.map((p) {
      final profit = investAmount * p.profitRate * p.days / 360;
      return KhairatTableRow(
        periodName: p.arabicLabel,
        days: p.days,
        profitRate: p.profitRate,
        profit: profit,
        newAmount: investAmount + profit,
      );
    }).toList();
  }
}
