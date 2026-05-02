import 'dart:math' as math;

/// Segment slab data matching the HTML calculator's SLABS exactly.
///
/// Both tajiri-aadi.html and tajiri-makro.html share the same 12 slabs.
class LeasingSegmentSlab {
  const LeasingSegmentSlab({
    required this.ded,
    required this.last,
    required this.min,
  });

  /// Maximum deduction ratio (e.g. 0.45 = 45%).
  final double ded;

  /// Maximum last-payment (balloon) ratio.
  final double last;

  /// Minimum salary requirement.
  final double min;
}

/// All 12 segment slabs — identical in both HTML calculators.
///
/// ```js
/// const SLABS={
///   'رواتب-حكومي':        {ded:.45,last:.40,min:4000},
///   'رواتب-عسكري':        {ded:.45,last:.40,min:4000},
///   'رواتب-شركات كبرى':   {ded:.45,last:.40,min:5000},
///   'رواتب-قطاع خاص':     {ded:.33,last:.40,min:5000},
///   'رواتب-سريع':          {ded:.33,last:.40,min:6000},
///   'رواتب-متقاعدين':      {ded:.30,last:.30,min:4000},
///   'غير رواتب-حكومي':    {ded:.40,last:.35,min:7000},
///   'غير رواتب-عسكري':    {ded:.40,last:.35,min:7000},
///   'غير رواتب-شركات كبرى':{ded:.40,last:.35,min:7000},
///   'غير رواتب-قطاع خاص': {ded:.40,last:.35,min:4000},
///   'غير رواتب-سريع':      {ded:.40,last:.35,min:8000},
///   'غير رواتب-متقاعدين':  {ded:.25,last:.35,min:4000},
/// };
/// ```
const Map<String, LeasingSegmentSlab> leasingSlabs = {
  'رواتب-حكومي': LeasingSegmentSlab(ded: 0.45, last: 0.40, min: 4000),
  'رواتب-عسكري': LeasingSegmentSlab(ded: 0.45, last: 0.40, min: 4000),
  'رواتب-شركات كبرى': LeasingSegmentSlab(ded: 0.45, last: 0.40, min: 5000),
  'رواتب-قطاع خاص': LeasingSegmentSlab(ded: 0.33, last: 0.40, min: 5000),
  'رواتب-سريع': LeasingSegmentSlab(ded: 0.33, last: 0.40, min: 6000),
  'رواتب-متقاعدين': LeasingSegmentSlab(ded: 0.30, last: 0.30, min: 4000),
  'غير رواتب-حكومي': LeasingSegmentSlab(ded: 0.40, last: 0.35, min: 7000),
  'غير رواتب-عسكري': LeasingSegmentSlab(ded: 0.40, last: 0.35, min: 7000),
  'غير رواتب-شركات كبرى': LeasingSegmentSlab(ded: 0.40, last: 0.35, min: 7000),
  'غير رواتب-قطاع خاص': LeasingSegmentSlab(ded: 0.40, last: 0.35, min: 4000),
  'غير رواتب-سريع': LeasingSegmentSlab(ded: 0.40, last: 0.35, min: 8000),
  'غير رواتب-متقاعدين': LeasingSegmentSlab(ded: 0.25, last: 0.35, min: 4000),
};

/// Display labels for the segment dropdown.
const Map<String, String> leasingSegmentLabels = {
  'رواتب-حكومي': 'رواتب – حكومي',
  'رواتب-عسكري': 'رواتب – عسكري',
  'رواتب-شركات كبرى': 'رواتب – شركات كبرى',
  'رواتب-قطاع خاص': 'رواتب – قطاع خاص',
  'رواتب-سريع': 'رواتب – سريع',
  'رواتب-متقاعدين': 'رواتب – متقاعدين',
  'غير رواتب-حكومي': 'غير رواتب – حكومي',
  'غير رواتب-عسكري': 'غير رواتب – عسكري',
  'غير رواتب-شركات كبرى': 'غير رواتب – شركات كبرى',
  'غير رواتب-قطاع خاص': 'غير رواتب – قطاع خاص',
  'غير رواتب-سريع': 'غير رواتب – سريع',
  'غير رواتب-متقاعدين': 'غير رواتب – متقاعدين',
};

/// Input model matching the HTML calculator's getInputs() exactly.
///
/// [isMicro] selects between the two insurance formulas:
/// - Regular (tajiri-aadi.html second section):
///   `calcIns(carPrice) => 0.0545 * carPrice * (37087/10000)`
///   Fixed factor, independent of months. Has plateFee.
/// - Micro (tajiri-makro.html / tajiri-aadi.html first section):
///   `calcIns(cp,mo) => 0.0545*cp*f` where
///   `f = mo===60 ? 37087/10000 : (mo/12)*(74174/100000)`
///   Factor depends on months. No plateFee.
class LeasingInput {
  const LeasingInput({
    required this.salary,
    required this.segment,
    required this.carPrice,
    required this.months,
    required this.costRate,
    this.isMicro = false,
    this.adminFee = 1250,
    this.plateFee = 0,
    this.personal = 0,
    this.otherDed = 0,
    this.realEstate = 0,
    this.downPaymentIsPercent = true,
    this.downPaymentValue = 0,
    this.lastPaymentIsPercent = true,
    this.lastPaymentValue = 45,
    this.insuranceIsPercent = true,
    this.insuranceValue = 0,
  });

  final double salary;
  final String segment;
  final double carPrice;
  final int months;

  /// Cost rate as decimal (e.g. 0.047 for 4.7%).
  final double costRate;

  /// Whether this is the micro (tajiri-makro) variant.
  final bool isMicro;

  final double adminFee;

  /// Plate fee — only used in regular mode (tajiri-aadi second section).
  final double plateFee;

  final double personal;
  final double otherDed;
  final double realEstate;
  final bool downPaymentIsPercent;
  final double downPaymentValue;
  final bool lastPaymentIsPercent;
  final double lastPaymentValue;
  final bool insuranceIsPercent;

  /// When [insuranceIsPercent] is false, this is the raw amount entered.
  final double insuranceValue;

  LeasingSegmentSlab get slab =>
      leasingSlabs[segment] ??
      const LeasingSegmentSlab(ded: 0.45, last: 0.40, min: 4000);

  bool get hasRealEstate => realEstate > 0;

  /// Deduction rate — identical in both HTML files:
  /// `hasRE ? (salary<15000 ? .65 : .70) : slab.ded`
  double get dedRate =>
      hasRealEstate ? (salary < 15000 ? 0.65 : 0.70) : slab.ded;

  /// Last payment ratio: pct mode -> user value / 100, amt mode -> slab default.
  double get lastPct =>
      lastPaymentIsPercent ? lastPaymentValue / 100 : slab.last;

  double get downPct =>
      downPaymentIsPercent ? downPaymentValue / 100 : 0;

  double get downPay =>
      downPaymentIsPercent ? carPrice * downPct : downPaymentValue;

  double get lastAmt =>
      lastPaymentIsPercent ? carPrice * lastPct : lastPaymentValue;

  /// Insurance amount.
  ///
  /// When in percent mode, uses the appropriate HTML formula:
  /// - Regular: `0.0545 * carPrice * (37087/10000)` (fixed)
  /// - Micro:   `0.0545 * cp * f` where `f = mo===60 ? 37087/10000 : (mo/12)*(74174/100000)`
  ///
  /// When in amount mode, uses the raw [insuranceValue].
  double get insAmt {
    if (!insuranceIsPercent) return insuranceValue;
    if (isMicro) {
      return LeasingCalculator.calcInsuranceMicro(carPrice, months);
    } else {
      return LeasingCalculator.calcInsuranceRegular(carPrice);
    }
  }
}

/// Result of the main calculation.
class LeasingResult {
  const LeasingResult({
    required this.monthly,
    required this.fin,
    required this.costTotal,
    required this.insAmt,
    required this.adminFee,
    required this.downPay,
    required this.lastAmt,
    required this.total,
    required this.existDed,
    required this.totalDed,
    required this.allowDed,
    required this.actualR,
    required this.dedRate,
    required this.approved,
    required this.reqDown,
    required this.salary,
    required this.carPrice,
    required this.segment,
    required this.months,
    required this.costRate,
    required this.slab,
    required this.plateFee,
    required this.personal,
    required this.otherDed,
    required this.realEstate,
    required this.lastPct,
    required this.isMicro,
  });

  final int monthly;
  final double fin;
  final double costTotal;
  final double insAmt;
  final double adminFee;
  final double downPay;
  final double lastAmt;
  final double total;
  final double existDed;
  final double totalDed;
  final double allowDed;
  final double actualR;
  final double dedRate;
  final bool approved;
  final double reqDown;
  final double salary;
  final double carPrice;
  final String segment;
  final int months;
  final double costRate;
  final LeasingSegmentSlab slab;
  final double plateFee;
  final double personal;
  final double otherDed;
  final double realEstate;
  final double lastPct;
  final bool isMicro;
}

/// Result for mode calculations (SAMA popup).
class LeasingModeResult {
  const LeasingModeResult({
    required this.carPrice,
    required this.downPay,
    required this.lastAmt,
    required this.monthly,
    required this.total,
    required this.insAmt,
  });

  final double carPrice;
  final double downPay;
  final double lastAmt;
  final int monthly;
  final double total;
  final double insAmt;
}

/// Schedule row for the payment schedule.
class LeasingScheduleRow {
  const LeasingScheduleRow({
    required this.month,
    required this.payment,
    required this.cumulative,
    required this.isLast,
  });

  final int month;
  final int payment;
  final int cumulative;
  final bool isLast;
}

/// Comparison row for comparing loan durations.
class LeasingCompareRow {
  const LeasingCompareRow({
    required this.months,
    required this.monthly,
    required this.cost,
    required this.total,
    required this.isCurrent,
  });

  final int months;
  final int monthly;
  final double cost;
  final int total;
  final bool isCurrent;
}

/// Leasing calculator with exact HTML formulas from both tajiri-aadi.html
/// and tajiri-makro.html.
///
/// Two variants share the same SLABS, calcMonthly, calcRequiredDown and
/// calculate formulas but differ in the insurance calculation:
///
/// **Regular** (tajiri-aadi.html second section):
/// ```js
/// function calcIns(carPrice){
///   return 0.0545 * carPrice * (37087/10000);
/// }
/// ```
///
/// **Micro** (tajiri-makro.html / tajiri-aadi.html first section):
/// ```js
/// function calcIns(cp,mo){
///   const f=mo===60?37087/10000:(mo/12)*(74174/100000);
///   return 0.0545*cp*f;
/// }
/// ```
class LeasingCalculator {
  const LeasingCalculator();

  /// Regular insurance (tajiri-aadi.html second section):
  /// `0.0545 * carPrice * (37087/10000)`
  ///
  /// Fixed factor independent of months.
  static double calcInsuranceRegular(double carPrice) {
    return 0.0545 * carPrice * (37087 / 10000);
  }

  /// Micro insurance (tajiri-makro.html):
  /// `const f=mo===60?37087/10000:(mo/12)*(74174/100000);`
  /// `return 0.0545*cp*f;`
  static double calcInsuranceMicro(double carPrice, int months) {
    final f = months == 60
        ? 37087 / 10000
        : (months / 12) * (74174 / 100000);
    return 0.0545 * carPrice * f;
  }

  /// Monthly installment — identical in both HTML calculators:
  /// ```js
  /// function calcMonthly(cp,dp,la,ins,cr,mo){
  ///   const fin=cp-dp;
  ///   return Math.ceil((fin+fin*cr*(mo/12)+ins-la)/mo);
  /// }
  /// ```
  static int calcMonthly(
    double carPrice,
    double downPay,
    double lastAmt,
    double insAmt,
    double costRate,
    int months,
  ) {
    final fin = carPrice - downPay;
    return ((fin + fin * costRate * (months / 12) + insAmt - lastAmt) / months)
        .ceil();
  }

  /// Required down payment — identical in both HTML calculators:
  /// ```js
  /// function calcRequiredDown(g){
  ///   const av=g.salary*0.45-(g.personal+g.otherDed+g.realEst);
  ///   if(av<=0)return g.carPrice;
  ///   const reqFin=(av*g.months-g.insAmt+g.lastAmt)/(1+g.costRate*(g.months/12));
  ///   return Math.max(0,Math.ceil((g.carPrice-reqFin)/50)*50);
  /// }
  /// ```
  static double calcRequiredDown({
    required double salary,
    required double carPrice,
    required double insAmt,
    required double lastAmt,
    required double personal,
    required double otherDed,
    required double realEstate,
    required double costRate,
    required int months,
  }) {
    final available = salary * 0.45 - (personal + otherDed + realEstate);
    if (available <= 0) return carPrice;
    final reqFin =
        (available * months - insAmt + lastAmt) / (1 + costRate * (months / 12));
    final raw = carPrice - reqFin;
    return math.max(0.0, (raw / 50).ceil() * 50.0);
  }

  /// Main calculation — matches both HTML calculate() functions exactly.
  ///
  /// Regular (tajiri-aadi.html second section):
  /// ```js
  /// const monthly  = calcMonthly(g.carPrice,g.downPay,g.lastAmt,g.insAmt,g.costRate,g.months);
  /// const fin      = g.carPrice - g.downPay;
  /// const costAmt  = fin*g.costRate*(g.months/12);
  /// const total    = monthly*g.months + g.lastAmt + g.downPay;
  /// const existDed = g.personal+g.otherDed+g.realEst;
  /// const totalDed = existDed+monthly;
  /// const allowDed = g.salary*g.dedRate;
  /// const actualR  = totalDed/g.salary;
  /// const approved = actualR<=g.dedRate && g.salary>=g.slab.min;
  /// const reqDown  = approved ? 0 : calcRequiredDown(g);
  /// ```
  ///
  /// Micro (tajiri-makro.html):
  /// ```js
  /// const monthly=calcMonthly(g.carPrice,g.downPay,g.lastAmt,g.insAmt,g.costRate,g.months);
  /// const fin=g.carPrice-g.downPay;
  /// const costAmt=fin*g.costRate*(g.months/12);
  /// const total=monthly*g.months+g.lastAmt+g.downPay;
  /// const existDed=g.personal+g.otherDed+g.realEst;
  /// const actualR=(existDed+monthly)/g.salary;
  /// const approved=actualR<=g.dedRate&&g.salary>=g.slab.min;
  /// const reqDown=approved?0:calcRequiredDown(g);
  /// ```
  ///
  /// The formulas are structurally identical; the only difference is the
  /// insurance amount fed in (via [LeasingInput.insAmt]).
  LeasingResult calculate(LeasingInput input) {
    final monthly = calcMonthly(
      input.carPrice,
      input.downPay,
      input.lastAmt,
      input.insAmt,
      input.costRate,
      input.months,
    );
    final fin = input.carPrice - input.downPay;
    final costTotal = fin * input.costRate * (input.months / 12);
    final total = monthly * input.months + input.lastAmt + input.downPay;
    final existDed = input.personal + input.otherDed + input.realEstate;
    final totalDed = existDed + monthly;
    final allowDed = input.salary * input.dedRate;
    final actualR = input.salary > 0 ? totalDed / input.salary : 0.0;
    final approved =
        actualR <= input.dedRate && input.salary >= input.slab.min;
    final reqDown = approved
        ? 0.0
        : calcRequiredDown(
            salary: input.salary,
            carPrice: input.carPrice,
            insAmt: input.insAmt,
            lastAmt: input.lastAmt,
            personal: input.personal,
            otherDed: input.otherDed,
            realEstate: input.realEstate,
            costRate: input.costRate,
            months: input.months,
          );

    return LeasingResult(
      monthly: monthly,
      fin: fin,
      costTotal: costTotal,
      insAmt: input.insAmt,
      adminFee: input.adminFee,
      downPay: input.downPay,
      lastAmt: input.lastAmt,
      total: total,
      existDed: existDed,
      totalDed: totalDed,
      allowDed: allowDed,
      actualR: actualR,
      dedRate: input.dedRate,
      approved: approved,
      reqDown: reqDown,
      salary: input.salary,
      carPrice: input.carPrice,
      segment: input.segment,
      months: input.months,
      costRate: input.costRate,
      slab: input.slab,
      plateFee: input.plateFee,
      personal: input.personal,
      otherDed: input.otherDed,
      realEstate: input.realEstate,
      lastPct: input.lastPct,
      isMicro: input.isMicro,
    );
  }

  /// Calculate by car price mode (matching HTML's calcByCarPrice).
  ///
  /// Uses the appropriate insurance formula based on [LeasingInput.isMicro].
  LeasingModeResult calcByCarPrice(LeasingInput input) {
    const downPay = 0.0;
    final lastAmt = input.carPrice * input.lastPct;
    final insAmt = input.isMicro
        ? calcInsuranceMicro(input.carPrice, input.months)
        : calcInsuranceRegular(input.carPrice);
    final m = calcMonthly(
      input.carPrice,
      downPay,
      lastAmt,
      insAmt,
      input.costRate,
      input.months,
    );
    final total = m * input.months + lastAmt + downPay;
    return LeasingModeResult(
      carPrice: input.carPrice,
      downPay: downPay,
      lastAmt: lastAmt,
      monthly: m,
      total: total,
      insAmt: insAmt,
    );
  }

  /// Max car price mode (matching HTML's calcMaxCarPrice).
  /// Returns null if obligations exceed allowed deduction.
  ///
  /// Uses the appropriate insurance factor based on [LeasingInput.isMicro].
  LeasingModeResult? calcMaxCarPrice(LeasingInput input) {
    final existDed = input.personal + input.otherDed + input.realEstate;
    final maxM = input.salary * input.dedRate - existDed;
    if (maxM <= 0) return null;
    final years = input.months / 12;

    // Insurance factor for the algebraic solve.
    // Regular: fixed 0.0545 * (37087/10000)
    // Micro: 0.0545 * (mo===60 ? 37087/10000 : (mo/12)*(74174/100000))
    final double insFactor;
    if (input.isMicro) {
      final f = input.months == 60
          ? 37087 / 10000
          : (input.months / 12) * (74174 / 100000);
      insFactor = 0.0545 * f;
    } else {
      insFactor = 0.0545 * (37087 / 10000);
    }

    final divisor = 1 + input.costRate * years + insFactor - input.lastPct;
    if (divisor <= 0) return null;

    final maxCar = ((maxM * input.months) / divisor).floor().toDouble();
    final lastAmt = (maxCar * input.lastPct).round().toDouble();
    final insAmt = input.isMicro
        ? calcInsuranceMicro(maxCar, input.months)
        : calcInsuranceRegular(maxCar);
    final total = maxM * input.months + lastAmt;
    return LeasingModeResult(
      carPrice: maxCar,
      downPay: 0,
      lastAmt: lastAmt,
      monthly: maxM.round(),
      total: total,
      insAmt: insAmt,
    );
  }

  /// Generate payment schedule.
  List<LeasingScheduleRow> schedule(LeasingResult result) {
    final rows = <LeasingScheduleRow>[];
    var cumulative = 0;
    for (var i = 1; i <= result.months; i++) {
      final isLast = i == result.months;
      final payment =
          isLast ? result.monthly + result.lastAmt.round() : result.monthly;
      cumulative += payment;
      rows.add(LeasingScheduleRow(
        month: i,
        payment: payment,
        cumulative: cumulative,
        isLast: isLast,
      ));
    }
    return rows;
  }

  /// Compare loan durations.
  List<LeasingCompareRow> compareDurations(LeasingResult result) {
    return [12, 24, 36, 48, 60].map((m) {
      // Recompute insurance for the given duration using the correct formula.
      final insAmt = result.isMicro
          ? calcInsuranceMicro(result.carPrice, m)
          : calcInsuranceRegular(result.carPrice);
      final mo = calcMonthly(
        result.carPrice,
        result.downPay,
        result.lastAmt,
        insAmt,
        result.costRate,
        m,
      );
      final fin = result.carPrice - result.downPay;
      final cost = fin * result.costRate * (m / 12);
      final tot = (mo * m + result.lastAmt + result.downPay).round();
      return LeasingCompareRow(
        months: m,
        monthly: mo,
        cost: cost,
        total: tot,
        isCurrent: m == result.months,
      );
    }).toList();
  }
}
