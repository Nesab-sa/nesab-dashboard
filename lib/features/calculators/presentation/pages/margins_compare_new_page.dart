import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/core/theme/app_text_styles.dart';

// ملاحظة: هذه الصفحة تقرأ من نفس مصدر صفحة "هوامش الربح" المربوطة مع Grok،
// أي المستند bank_rates/profit_margins. تقارن قيمة Grok الحيّة لكل منتج
// مقابل المؤشر التمثيلي الافتراضي، وتُصدر حكماً تلقائياً على حجم الفرق.

// ── Verdict ───────────────────────────────────────────────────────────────────

enum _Verdict { match, slight, conflict, single }

_Verdict _computeVerdict(double? grok, double? representative) {
  if (grok == null || representative == null) return _Verdict.single;
  final diff = (grok - representative).abs();
  if (diff < 0.5) return _Verdict.match;
  if (diff < 1.5) return _Verdict.slight;
  return _Verdict.conflict;
}

extension _VerdictExt on _Verdict {
  String get label => switch (this) {
        _Verdict.match    => '🟢 متطابق',
        _Verdict.slight   => '🟡 فرق بسيط',
        _Verdict.conflict => '🔴 تعارض',
        _Verdict.single   => '⚪ مصدر واحد',
      };

  Color get color => switch (this) {
        _Verdict.match    => AppColors.calcGreen,
        _Verdict.slight   => AppColors.warning,
        _Verdict.conflict => AppColors.calcRed,
        _Verdict.single   => AppColors.calcMuted,
      };
}

// ── Constants (ported from profit_margins_page.dart) ──────────────────────────

const _banks = [
  'البنك الأهلي السعودي',
  'مصرف الراجحي',
  'بنك الرياض',
  'البنك السعودي الأول (ساب)',
  'البنك السعودي الفرنسي',
  'البنك العربي الوطني',
  'مصرف الإنماء',
  'بنك البلاد',
  'بنك الجزيرة',
  'البنك السعودي للاستثمار',
  'بنك الإمارات دبي الوطني',
];

const _subSections = <String, List<String>>{
  'تمويل شخصي': ['جديد', 'تكميلي', 'شراء مديونية'],
  'عقاري مدعوم': ['جاهز', 'على الخارطة', 'بناء ذاتي', 'رهن عقار'],
  'عقاري اعتيادي': ['عقاري اعتيادي'],
  'تأجيري': ['نظام 5 سنوات', 'نظام 50/50'],
};

const _sectionToFirestoreKey = <String, Map<String, String>>{
  'تمويل شخصي': {
    'جديد': 'personalBasic',
    'تكميلي': 'personalSpecial',
    'شراء مديونية': 'personalSpecial',
  },
  'عقاري مدعوم': {
    'جاهز': 'realEstateSupportedProgram',
    'على الخارطة': 'realEstateSupportedProgram',
    'بناء ذاتي': 'realEstateSupportedMinistry',
    'رهن عقار': 'realEstateSupportedMinistry',
  },
  'عقاري اعتيادي': {
    'عقاري اعتيادي': 'realEstateCommercial',
  },
  'تأجيري': {
    'نظام 5 سنوات': 'leasingVehicles',
    'نظام 50/50': 'leasingVehicles',
  },
};

const _bankAliases = <String, String>{
  'البنك السعودي': 'البنك الأهلي السعودي',
  'البنك الأهلي التجاري': 'البنك الأهلي السعودي',
  'بنك ساب': 'البنك السعودي الأول (ساب)',
  'البنك السعودي الأول': 'البنك السعودي الأول (ساب)',
  'البنك السعودي البريطاني': 'البنك السعودي الأول (ساب)',
  'بنك الاستثمار السعودي': 'البنك السعودي للاستثمار',
  'البنك الخليجي الدولي': 'بنك الإمارات دبي الوطني',
  'بنك الإنماء': 'مصرف الإنماء',
  'بنك الراجحي': 'مصرف الراجحي',
};

const _bankIdToName = <String, String>{
  'rajhi': 'مصرف الراجحي',
  'snb': 'البنك الأهلي السعودي',
  'inma': 'مصرف الإنماء',
  'riyadh': 'بنك الرياض',
  'saab': 'البنك السعودي الأول (ساب)',
  'fransi': 'البنك السعودي الفرنسي',
  'anb': 'البنك العربي الوطني',
  'saib': 'البنك السعودي للاستثمار',
  'bilad': 'بنك البلاد',
  'jazira': 'بنك الجزيرة',
  'enbd': 'بنك الإمارات دبي الوطني',
};

String _normalizeBankName(String name) =>
    _bankAliases[name.trim()] ?? name.trim();

double _parseMargin(String m) {
  final cleaned = m.replaceAll('%', '').split('-').first.trim();
  return double.tryParse(cleaned) ?? 0;
}

// المؤشر التمثيلي الافتراضي: bankName → 'الفئة|القسم' → النسبة.
Map<String, Map<String, double>>? _representativeCache;
Map<String, Map<String, double>> _representativeMargins() {
  final cached = _representativeCache;
  if (cached != null) return cached;

  final map = <String, Map<String, double>>{};
  void put(String bank, String cat, String sub, String pct) {
    (map[bank] ??= <String, double>{})['$cat|$sub'] = _parseMargin(pct);
  }

  const personalNew  = ['5.35%','4.85%','5.15%','4.95%','5.45%','5.25%','4.75%','5.55%','5.65%','5.80%','5.10%'];
  const personalComp = ['5.75%','5.25%','5.50%','5.35%','5.85%','5.60%','5.15%','5.95%','6.10%','6.25%','5.45%'];
  const personalDebt = ['5.95%','5.45%','5.70%','5.55%','6.05%','5.80%','5.35%','6.15%','6.30%','6.45%','5.65%'];
  const sr  = ['3.25%','2.89%','3.15%','3.05%','3.35%','3.20%','2.95%','3.45%','3.55%','3.65%','3.10%'];
  const so  = ['3.10%','2.75%','3.00%','2.90%','3.20%','3.05%','2.80%','3.30%','3.40%','3.50%','2.95%'];
  const ss  = ['3.35%','2.99%','3.25%','3.15%','3.45%','3.30%','3.05%','3.55%','3.65%','3.75%','3.20%'];
  const sm  = ['3.50%','3.15%','3.40%','3.30%','3.60%','3.45%','3.20%','3.70%','3.80%','3.90%','3.35%'];
  const rm  = ['4.25%','3.85%','4.15%','3.95%','4.35%','4.20%','3.90%','4.45%','4.55%','4.75%','4.10%'];
  const l5  = ['6.25%','5.85%','6.15%','5.95%','6.45%','6.20%','5.80%','6.55%','6.75%','6.90%','6.10%'];
  const l50 = ['6.75%','6.35%','6.65%','6.45%','6.95%','6.70%','6.30%','7.05%','7.25%','7.40%','6.60%'];

  for (var i = 0; i < _banks.length; i++) {
    final b = _banks[i];
    put(b, 'تمويل شخصي', 'جديد', personalNew[i]);
    put(b, 'تمويل شخصي', 'تكميلي', personalComp[i]);
    put(b, 'تمويل شخصي', 'شراء مديونية', personalDebt[i]);
    put(b, 'عقاري مدعوم', 'جاهز', sr[i]);
    put(b, 'عقاري مدعوم', 'على الخارطة', so[i]);
    put(b, 'عقاري مدعوم', 'بناء ذاتي', ss[i]);
    put(b, 'عقاري مدعوم', 'رهن عقار', sm[i]);
    put(b, 'عقاري اعتيادي', 'عقاري اعتيادي', rm[i]);
    put(b, 'تأجيري', 'نظام 5 سنوات', l5[i]);
    put(b, 'تأجيري', 'نظام 50/50', l50[i]);
  }

  _representativeCache = map;
  return map;
}

/// قراءة منتج واحد من بيانات بنك بأي من التنسيقات الثلاثة المدعومة.
Map<String, dynamic>? _readProduct(Map<String, dynamic> bankMap, String fsKey) {
  if (fsKey.isEmpty) return null;

  final prods = bankMap['products'];
  if (prods is Map) {
    final p = prods[fsKey];
    if (p is Map) return Map<String, dynamic>.from(p);
  }

  final flat = bankMap[fsKey];
  if (flat is Map) return Map<String, dynamic>.from(flat);

  final legacyKey = _legacyKeyFor(fsKey);
  if (legacyKey != null) {
    final lv = bankMap[legacyKey];
    if (lv is Map) return Map<String, dynamic>.from(lv);
  }

  return null;
}

String? _legacyKeyFor(String fsKey) {
  if (fsKey.startsWith('personal')) return 'personal';
  if (fsKey.startsWith('realEstate')) return 'realEstate';
  if (fsKey.startsWith('leasing')) return 'leasing';
  return null;
}

// ── Data model ────────────────────────────────────────────────────────────────

class _CompareRow {
  const _CompareRow({
    required this.bankName,
    required this.category,
    required this.sub,
    this.grokRate,
    this.representativeRate,
    required this.verdict,
  });

  final String bankName;
  final String category;
  final String sub;
  final double? grokRate;
  final double? representativeRate;
  final _Verdict verdict;

  String get productLabel => '$category — $sub';

  double? get diff => (grokRate != null && representativeRate != null)
      ? (grokRate! - representativeRate!).abs()
      : null;
}

// ── Page ──────────────────────────────────────────────────────────────────────

class MarginsComparePage extends StatefulWidget {
  const MarginsComparePage({super.key});

  @override
  State<MarginsComparePage> createState() => _MarginsComparePageState();
}

class _MarginsComparePageState extends State<MarginsComparePage> {
  static const _docPath = 'bank_rates/profit_margins';

  bool _loading = true;
  String? _error;
  List<_CompareRow> _allRows = [];
  DateTime? _lastUpdated;
  bool _noLiveData = false;

  String? _filterBank;
  String? _filterProduct;
  bool _conflictOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final doc = await FirebaseFirestore.instance.doc(_docPath).get();

      List<dynamic> banksData = const [];
      DateTime? lastUpdated;
      if (doc.exists) {
        final data = doc.data()!;
        final banks = data['banks'];
        if (banks is List) banksData = banks;
        final ts = data['lastUpdated'];
        if (ts is Timestamp) lastUpdated = ts.toDate();
      }

      // فهرسة بيانات البنوك حسب الاسم القانوني.
      final byBank = <String, Map<String, dynamic>>{};
      for (final raw in banksData) {
        if (raw is! Map) continue;
        final bankMap = Map<String, dynamic>.from(raw);
        final bankId = bankMap['bankId']?.toString() ?? '';
        final rawName = bankMap['bankName']?.toString() ?? '';
        final name = _bankIdToName[bankId] ?? _normalizeBankName(rawName);
        byBank[name] = bankMap;
      }

      final rep = _representativeMargins();
      final rows = <_CompareRow>[];
      var liveCount = 0;

      for (final catEntry in _subSections.entries) {
        final category = catEntry.key;
        for (final sub in catEntry.value) {
          final fsKey = _sectionToFirestoreKey[category]?[sub] ?? '';
          for (final bank in _banks) {
            // قيمة Grok الحيّة: منتصف نطاق min-max عند توفّره فقط.
            double? grokRate;
            final bankMap = byBank[bank];
            if (bankMap != null) {
              final product = _readProduct(bankMap, fsKey);
              if (product != null && product['available'] != false) {
                final min = (product['min'] as num?)?.toDouble();
                final max = (product['max'] as num?)?.toDouble();
                if (min != null && max != null && (min > 0 || max > 0)) {
                  grokRate = (min + max) / 2;
                  liveCount++;
                }
              }
            }

            final representativeRate = rep[bank]?['$category|$sub'];

            rows.add(_CompareRow(
              bankName: bank,
              category: category,
              sub: sub,
              grokRate: grokRate,
              representativeRate: representativeRate,
              verdict: _computeVerdict(grokRate, representativeRate),
            ));
          }
        }
      }

      if (mounted) {
        setState(() {
          _allRows = rows;
          _lastUpdated = lastUpdated;
          _noLiveData = liveCount == 0;
          _filterBank = null;
          _filterProduct = null;
          _conflictOnly = false;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'تعذّر تحميل البيانات. يرجى المحاولة مرة أخرى.';
          _loading = false;
        });
      }
    }
  }

  List<_CompareRow> get _filteredRows {
    var rows = _allRows;
    if (_filterBank != null) {
      rows = rows.where((r) => r.bankName == _filterBank).toList();
    }
    if (_filterProduct != null) {
      rows = rows.where((r) => r.productLabel == _filterProduct).toList();
    }
    if (_conflictOnly) {
      rows = rows.where((r) => r.verdict == _Verdict.conflict).toList();
    }
    return rows;
  }

  String _fmtDate(DateTime d) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.day)} ${months[d.month - 1]} ${d.year}  ${p(d.hour)}:${p(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(children: [
        Container(color: AppColors.calcBg),
        Positioned(
          top: 0, left: 0, right: 0, height: 200,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.calcHeaderTop, AppColors.calcBg.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(child: _buildBody()),
        ),
      ]),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.calcNeon));
    }
    if (_error != null) {
      return _ErrorRetry(message: _error!, onRetry: _load);
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPaddingHorizontal, AppDimensions.spacingMd,
            AppDimensions.screenPaddingHorizontal, AppDimensions.spacingMd,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _PageTitle(),
            const SizedBox(height: AppDimensions.spacingMd),
            _MetaCard(lastUpdated: _lastUpdated, fmt: _fmtDate, onRefresh: _load),
            if (_noLiveData) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              _NoLiveBanner(),
            ],
            const SizedBox(height: AppDimensions.spacingMd),
            _SummaryCards(rows: _allRows),
            const SizedBox(height: AppDimensions.spacingMd),
            _FilterBar(
              banks: _banks,
              selectedBank: _filterBank,
              selectedProduct: _filterProduct,
              conflictOnly: _conflictOnly,
              onBankChanged:     (v) => setState(() => _filterBank    = v),
              onProductChanged:  (v) => setState(() => _filterProduct = v),
              onConflictToggled: (v) => setState(() => _conflictOnly  = v),
            ),
          ]),
        ),
        _buildTable(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTable() {
    final rows = _filteredRows;
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Center(
          child: Text(
            'لا توجد نتائج تطابق الفلتر المحدد.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.calcMuted),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingHorizontal),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _CompareTable(
          rows: rows,
          highlightMinMax: _filterBank == null && _filterProduct != null,
        ),
      ),
    );
  }
}

// ── Page Title ────────────────────────────────────────────────────────────────

class _PageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(color: AppColors.calcNeon2, borderRadius: BorderRadius.circular(10)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'مقارنة هوامش الربح',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.calcText, fontWeight: FontWeight.w900),
          ),
        ),
      ]),
      const SizedBox(height: 4),
      Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: Text(
          'قيمة Grok الحيّة مقابل المؤشر التمثيلي',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.calcMuted),
        ),
      ),
    ]);
  }
}

// ── Meta Card ─────────────────────────────────────────────────────────────────

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.lastUpdated, required this.fmt, required this.onRefresh});
  final DateTime? lastUpdated;
  final String Function(DateTime) fmt;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.calcCard2,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.calcBorder2),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('آخر تحديث لبيانات Grok', style: AppTextStyles.labelSmall.copyWith(color: AppColors.calcMuted)),
          const SizedBox(height: 2),
          Text(
            lastUpdated != null ? fmt(lastUpdated!) : 'مؤشر تمثيلي — لم يُحدّث بعد',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.calcText, fontWeight: FontWeight.w700),
          ),
        ])),
        GestureDetector(
          onTap: onRefresh,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.calcNeon2.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.calcBorder2),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.refresh_rounded, size: 15, color: AppColors.calcNeon),
              const SizedBox(width: 6),
              Text('تحديث', style: AppTextStyles.bodySmall.copyWith(color: AppColors.calcNeon, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── No Live Data Banner ───────────────────────────────────────────────────────

class _NoLiveBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd, vertical: AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
        const SizedBox(width: AppDimensions.spacingSm),
        Expanded(
          child: Text(
            'لا توجد قيم Grok حيّة بعد — افتح صفحة «هوامش الربح» واضغط «تحديث البيانات الآن»، ثم عُد إلى هنا. تظهر حالياً المؤشرات التمثيلية مع حكم ⚪ مصدر واحد.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning, height: 1.5),
          ),
        ),
      ]),
    );
  }
}

// ── Summary Cards ─────────────────────────────────────────────────────────────

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.rows});
  final List<_CompareRow> rows;

  @override
  Widget build(BuildContext context) {
    int match = 0, slight = 0, conflict = 0, single = 0;
    for (final r in rows) {
      switch (r.verdict) {
        case _Verdict.match:    match++;    break;
        case _Verdict.slight:   slight++;   break;
        case _Verdict.conflict: conflict++; break;
        case _Verdict.single:   single++;   break;
      }
    }
    return Row(children: [
      _SumCard(emoji: '📊', count: rows.length, label: 'إجمالي'),
      const SizedBox(width: 8),
      _SumCard(emoji: '🟢', count: match,    label: 'متطابق',    color: AppColors.calcGreen),
      const SizedBox(width: 8),
      _SumCard(emoji: '🟡', count: slight,   label: 'فرق بسيط', color: AppColors.warning),
      const SizedBox(width: 8),
      _SumCard(emoji: '🔴', count: conflict, label: 'تعارض',     color: AppColors.calcRed),
      const SizedBox(width: 8),
      _SumCard(emoji: '⚪', count: single,   label: 'مصدر واحد', color: AppColors.calcMuted),
    ]);
  }
}

class _SumCard extends StatelessWidget {
  const _SumCard({required this.emoji, required this.count, required this.label, this.color});
  final String emoji;
  final int count;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.calcCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.calcBorder),
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text('$count', style: AppTextStyles.labelLarge.copyWith(color: color ?? AppColors.calcText, fontWeight: FontWeight.w900)),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.calcMuted, fontSize: 10), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ── Filter Bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.banks,
    required this.selectedBank,
    required this.selectedProduct,
    required this.conflictOnly,
    required this.onBankChanged,
    required this.onProductChanged,
    required this.onConflictToggled,
  });

  final List<String> banks;
  final String? selectedBank;
  final String? selectedProduct;
  final bool conflictOnly;
  final ValueChanged<String?> onBankChanged;
  final ValueChanged<String?> onProductChanged;
  final ValueChanged<bool> onConflictToggled;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _FilterDropdown(
        hint: 'الكل — البنوك',
        value: selectedBank,
        items: banks,
        labelOf: (b) => b,
        onChanged: onBankChanged,
      ),
      _ProductFilterPopup(
        value: selectedProduct,
        onChanged: onProductChanged,
      ),
      GestureDetector(
        onTap: () => onConflictToggled(!conflictOnly),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: conflictOnly
                ? AppColors.calcRed.withValues(alpha: 0.15)
                : AppColors.calcCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: conflictOnly
                  ? AppColors.calcRed.withValues(alpha: 0.5)
                  : AppColors.calcBorder2,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              conflictOnly ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
              color: conflictOnly ? AppColors.calcRed : AppColors.calcMuted,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              'التعارضات فقط 🔴',
              style: AppTextStyles.bodySmall.copyWith(
                color: conflictOnly ? AppColors.calcRed : AppColors.calcMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  final String hint;
  final String? value;
  final List<String> items;
  final String Function(String) labelOf;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.calcCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.calcBorder2),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint, style: AppTextStyles.bodySmall.copyWith(color: AppColors.calcMuted)),
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.calcCard2,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.calcMuted, size: 18),
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.calcText),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text(hint, style: AppTextStyles.bodySmall.copyWith(color: AppColors.calcMuted)),
          ),
          ...items.map(
            (v) => DropdownMenuItem<String>(
              value: v,
              child: Text(labelOf(v), overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ProductFilterPopup extends StatefulWidget {
  const _ProductFilterPopup({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  State<_ProductFilterPopup> createState() => _ProductFilterPopupState();
}

class _ProductFilterPopupState extends State<_ProductFilterPopup> {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _togglePopup() {
    if (_isOpen) {
      _closePopup();
    } else {
      _openPopup();
    }
  }

  void _openPopup() {
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closePopup() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  void _select(String? val) {
    widget.onChanged(val);
    _closePopup();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            GestureDetector(
              onTap: _closePopup,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 4),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 320,
                  constraints: const BoxConstraints(maxHeight: 420),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1d2e),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.calcBorder2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _popupItem(
                            label: 'الكل — المنتجات',
                            isSelected: widget.value == null,
                            isMuted: true,
                            onTap: () => _select(null),
                          ),
                          ..._subSections.entries.expand((catEntry) {
                            final category = catEntry.key;
                            return [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                child: Text(
                                  category,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.calcNeon,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              ...catEntry.value.map((sub) {
                                final productLabel = '$category — $sub';
                                return _popupItem(
                                  label: sub,
                                  isSelected: widget.value == productLabel,
                                  onTap: () => _select(productLabel),
                                );
                              }),
                            ];
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popupItem({
    required String label,
    required bool isSelected,
    bool isMuted = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: isSelected ? AppColors.calcNeon2.withValues(alpha: 0.12) : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isMuted
                      ? AppColors.calcMuted
                      : isSelected
                          ? AppColors.calcNeon
                          : AppColors.calcText,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, color: AppColors.calcNeon, size: 16),
          ],
        ),
      ),
    );
  }

  String get _displayText {
    if (widget.value == null) return 'الكل — المنتجات';
    final parts = widget.value!.split(' — ');
    if (parts.length == 2) return parts[1];
    return widget.value!;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _togglePopup,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.value != null
                ? AppColors.calcNeon2.withValues(alpha: 0.10)
                : AppColors.calcCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.value != null
                  ? AppColors.calcNeon2.withValues(alpha: 0.4)
                  : AppColors.calcBorder2,
            ),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(
              _displayText,
              style: AppTextStyles.bodySmall.copyWith(
                color: widget.value != null ? AppColors.calcNeon : AppColors.calcMuted,
                fontWeight: widget.value != null ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              _isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: AppColors.calcMuted,
              size: 18,
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Comparison Table ──────────────────────────────────────────────────────────

class _CompareTable extends StatelessWidget {
  const _CompareTable({required this.rows, this.highlightMinMax = false});
  final List<_CompareRow> rows;
  final bool highlightMinMax;

  double? _effectiveRate(_CompareRow r) => r.grokRate ?? r.representativeRate;

  @override
  Widget build(BuildContext context) {
    final headerStyle = AppTextStyles.labelSmall.copyWith(color: AppColors.calcMuted, fontWeight: FontWeight.w700);
    const headerDecor = BoxDecoration(color: Color(0x145D5FEF));

    int minIdx = -1, maxIdx = -1;
    if (highlightMinMax) {
      double? minVal, maxVal;
      for (var i = 0; i < rows.length; i++) {
        final rate = _effectiveRate(rows[i]);
        if (rate == null) continue;
        if (minVal == null || rate < minVal) { minVal = rate; minIdx = i; }
        if (maxVal == null || rate > maxVal) { maxVal = rate; maxIdx = i; }
      }
      if (minIdx == maxIdx) { minIdx = -1; maxIdx = -1; }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.calcBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FixedColumnWidth(180),
            2: IntrinsicColumnWidth(),
            3: IntrinsicColumnWidth(),
            4: IntrinsicColumnWidth(),
            5: IntrinsicColumnWidth(),
          },
          children: [
            TableRow(
              decoration: headerDecor,
              children: [
                _HeaderCell('البنك',          style: headerStyle),
                _HeaderCell('المنتج',         style: headerStyle),
                _HeaderCell('نسبة Grok',      style: headerStyle),
                _HeaderCell('مؤشر تمثيلي',    style: headerStyle),
                _HeaderCell('الفرق',          style: headerStyle),
                _HeaderCell('الحكم',          style: headerStyle),
              ],
            ),
            ...rows.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              final isLast = i == rows.length - 1;
              final isMin = i == minIdx;
              final isMax = i == maxIdx;

              Color? bgColor;
              Border? rowBorder;

              if (isMin) {
                bgColor = AppColors.calcGreen.withValues(alpha: 0.08);
                rowBorder = Border.all(color: AppColors.calcGreen.withValues(alpha: 0.6), width: 1.5);
              } else if (isMax) {
                bgColor = AppColors.calcRed.withValues(alpha: 0.08);
                rowBorder = Border.all(color: AppColors.calcRed.withValues(alpha: 0.6), width: 1.5);
              }

              return TableRow(
                decoration: BoxDecoration(
                  color: bgColor ?? (i.isOdd ? AppColors.calcCard.withValues(alpha: 0.4) : Colors.transparent),
                  border: rowBorder ?? (isLast
                      ? null
                      : Border(bottom: BorderSide(color: AppColors.calcBorder, width: 0.5))),
                ),
                children: [
                  _BankCell(
                    name: r.bankName,
                    badge: isMin ? 'أقل هامش' : isMax ? 'أعلى هامش' : null,
                    badgeColor: isMin ? AppColors.calcGreen : isMax ? AppColors.calcRed : null,
                  ),
                  _DataCell(r.productLabel),
                  _RateCell(r.grokRate, color: const Color(0xFFa5b4fc)),
                  _RateCell(r.representativeRate, color: AppColors.calcGold),
                  _DiffCell(r.diff),
                  _VerdictCell(r.verdict),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, {required this.style});
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(text, style: style),
      );
}

class _BankCell extends StatelessWidget {
  const _BankCell({required this.name, this.badge, this.badgeColor});
  final String name;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.calcText,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor!.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor!.withValues(alpha: 0.5)),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
}

class _DataCell extends StatelessWidget {
  const _DataCell(this.text, {this.bold = false});
  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.calcText,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      );
}

class _RateCell extends StatelessWidget {
  const _RateCell(this.rate, {required this.color});
  final double? rate;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: rate != null
            ? Text(
                '${rate!.toStringAsFixed(2)}%',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.labelMedium.copyWith(color: color, fontWeight: FontWeight.w800),
              )
            : Text('—', style: AppTextStyles.bodySmall.copyWith(color: AppColors.calcMuted)),
      );
}

class _DiffCell extends StatelessWidget {
  const _DiffCell(this.diff);
  final double? diff;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: diff != null
            ? Text(
                '${diff!.toStringAsFixed(2)}%',
                textDirection: TextDirection.ltr,
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.calcText, fontWeight: FontWeight.w700),
              )
            : Text('—', style: AppTextStyles.bodySmall.copyWith(color: AppColors.calcMuted)),
      );
}

class _VerdictCell extends StatelessWidget {
  const _VerdictCell(this.verdict);
  final _Verdict verdict;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          verdict.label,
          style: AppTextStyles.labelSmall.copyWith(color: verdict.color, fontWeight: FontWeight.w800),
        ),
      );
}

// ── Error Retry ───────────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 32),
        const SizedBox(height: AppDimensions.spacingMd),
        Text(message, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error), textAlign: TextAlign.center),
        const SizedBox(height: AppDimensions.spacingLg),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, color: AppColors.calcNeon, size: AppDimensions.iconMd),
          label: Text('إعادة المحاولة', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.calcNeon)),
        ),
      ]),
    );
  }
}
