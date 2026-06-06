import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/core/theme/app_text_styles.dart';

// ── Verdict ───────────────────────────────────────────────────────────────────

enum _Verdict { match, slight, conflict, single }

_Verdict _computeVerdict(double? grok, double? official) {
  if (grok == null || official == null) return _Verdict.single;
  final diff = (grok - official).abs();
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

// ── Data models ───────────────────────────────────────────────────────────────

class _CompareRow {
  const _CompareRow({
    required this.bankKey,
    required this.bankNameAr,
    required this.productType,
    this.grokRate,
    this.officialRate,
    required this.verdict,
  });

  final String bankKey;
  final String bankNameAr;
  final String productType;
  final double? grokRate;
  final double? officialRate;
  final _Verdict verdict;

  double? get diff => (grokRate != null && officialRate != null)
      ? (grokRate! - officialRate!).abs()
      : null;
}

class _MetaInfo {
  const _MetaInfo({this.lastUpdatedAt, this.nextUpdateDue, this.sourceNote});
  final DateTime? lastUpdatedAt;
  final DateTime? nextUpdateDue;
  final String? sourceNote;
}

// ── Constants ─────────────────────────────────────────────────────────────────

const _productLabels = <String, String>{
  'personal_new':                       'التمويل الشخصي',
  'personal_topup':                     'زيادة تمويل شخصي',
  'personal_buyout':                    'شراء مديونية',
  'realestate_subsidized_ready':        'عقاري مدعوم — جاهز',
  'realestate_subsidized_offplan':      'عقاري مدعوم — على الخارطة',
  'realestate_subsidized_construction': 'عقاري مدعوم — بناء ذاتي',
  'realestate_subsidized_mortgage':     'عقاري مدعوم — رهن عقار',
  'realestate_standard':                'عقاري اعتيادي',
  'lease_5yr':                          'تأجيري — نظام 5 سنوات',
  'lease_5050':                         'تأجيري — نظام 50/50',
};

const _bankOrder = [
  'sab', 'alrajhi', 'snb', 'riyad', 'bsf', 'anb',
  'alinma', 'albilad', 'aljazira', 'saib', 'enbd',
];

const _productOrder = [
  'personal_new', 'personal_topup', 'personal_buyout',
  'realestate_subsidized_ready', 'realestate_subsidized_offplan',
  'realestate_subsidized_construction', 'realestate_subsidized_mortgage',
  'realestate_standard', 'lease_5yr', 'lease_5050',
];

// ── Page ──────────────────────────────────────────────────────────────────────

class MarginsComparePage extends StatefulWidget {
  const MarginsComparePage({super.key});

  @override
  State<MarginsComparePage> createState() => _MarginsComparePageState();
}

class _MarginsComparePageState extends State<MarginsComparePage> {
  bool _loading = true;
  String? _error;
  List<_CompareRow> _allRows = [];
  _MetaInfo _meta = const _MetaInfo();
  bool _grokEmpty = false;

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
      final db = FirebaseFirestore.instance;
      final results = await Future.wait([
        db.collection('scraper_meta').doc('last_run').get(),
        db.collection('bank_margins').get(),
        db.collection('grok_margins').get(),
      ]);

      final metaSnap     = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final officialSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final grokSnap     = results[2] as QuerySnapshot<Map<String, dynamic>>;

      _MetaInfo meta = const _MetaInfo();
      if (metaSnap.exists) {
        final md = metaSnap.data()!;
        final lu = md['last_updated_at'];
        final nu = md['next_update_due'];
        meta = _MetaInfo(
          lastUpdatedAt: lu is Timestamp ? lu.toDate() : null,
          nextUpdateDue: nu is Timestamp ? nu.toDate() : null,
          sourceNote: md['source_note'] as String?,
        );
      }

      final officialMap = <String, Map<String, dynamic>>{};
      for (final d in officialSnap.docs) {
        final data = d.data();
        final k = '${data['bank_name_ar'] ?? ''}__${data['product_type'] ?? ''}';
        officialMap[k] = data;
      }

      final grokMap = <String, Map<String, dynamic>>{};
      for (final d in grokSnap.docs) {
        final data = d.data();
        final k = '${data['bank_name_ar'] ?? ''}__${data['product_type'] ?? ''}';
        grokMap[k] = data;
      }

      final allKeys = {...officialMap.keys, ...grokMap.keys};
      final rows = <_CompareRow>[];

      for (final k in allKeys) {
        final o = officialMap[k];
        final g = grokMap[k];

        final bankKey     = (o?['bank_key'] as String?) ?? '';
        final bankNameAr  = (o?['bank_name_ar'] as String?) ??
                            (g?['bank_name_ar'] as String?) ?? '';
        final productType = (o?['product_type'] as String?) ??
                            (g?['product_type'] as String?) ?? '';

        double? officialRate;
        if (o != null) {
          final conf = (o['confidence'] as String?) ?? 'UNAVAILABLE';
          final r    = o['profit_margin_rate'];
          if (conf != 'UNAVAILABLE' && r != null) {
            officialRate = (r as num).toDouble();
          }
        }

        double? grokRate;
        if (g != null) {
          final r = g['rate'];
          if (r != null) grokRate = (r as num).toDouble();
        }

        rows.add(_CompareRow(
          bankKey: bankKey,
          bankNameAr: bankNameAr,
          productType: productType,
          grokRate: grokRate,
          officialRate: officialRate,
          verdict: _computeVerdict(grokRate, officialRate),
        ));
      }

      rows.sort((a, b) {
        final ai = _bankOrder.indexOf(a.bankKey);
        final bi = _bankOrder.indexOf(b.bankKey);
        final bc = (ai < 0 ? 999 : ai) - (bi < 0 ? 999 : bi);
        if (bc != 0) return bc;
        final pi = _productOrder.indexOf(a.productType);
        final qi = _productOrder.indexOf(b.productType);
        return (pi < 0 ? 999 : pi) - (qi < 0 ? 999 : qi);
      });

      if (mounted) {
        setState(() {
          _allRows = rows;
          _meta = meta;
          _grokEmpty = grokSnap.docs.isEmpty;
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
    if (_filterBank != null)    rows = rows.where((r) => r.bankNameAr  == _filterBank).toList();
    if (_filterProduct != null) rows = rows.where((r) => r.productType == _filterProduct).toList();
    if (_conflictOnly)          rows = rows.where((r) => r.verdict     == _Verdict.conflict).toList();
    return rows;
  }

  List<String> get _banks => _allRows
      .map((r) => r.bankNameAr)
      .where((b) => b.isNotEmpty)
      .toSet()
      .toList()
    ..sort();

  List<String> get _products {
    final list = _allRows
        .map((r) => r.productType)
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();
    list.sort((a, b) {
      final ai = _productOrder.indexOf(a), bi = _productOrder.indexOf(b);
      return (ai < 0 ? 999 : ai) - (bi < 0 ? 999 : bi);
    });
    return list;
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
            _MetaCard(meta: _meta, onRefresh: _load),
            if (_grokEmpty) ...[
              const SizedBox(height: AppDimensions.spacingMd),
              _GrokFallbackBanner(),
            ],
            const SizedBox(height: AppDimensions.spacingMd),
            _SummaryCards(rows: _allRows),
            const SizedBox(height: AppDimensions.spacingMd),
            _FilterBar(
              banks: _banks,
              products: _products,
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
        child: _CompareTable(rows: rows),
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
          'مقارنة بين بيانات Grok والمصادر الرسمية',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.calcMuted),
        ),
      ),
    ]);
  }
}

// ── Meta Card ─────────────────────────────────────────────────────────────────

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.meta, required this.onRefresh});
  final _MetaInfo meta;
  final VoidCallback onRefresh;

  String _fmt(DateTime d) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.day)} ${months[d.month - 1]} ${d.year}  ${p(d.hour)}:${p(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final lu = meta.lastUpdatedAt;
    final nu = meta.nextUpdateDue;
    final now = DateTime.now();
    String countdownText = 'موعد التحديث غير محدّد';
    Color countdownColor = AppColors.calcMuted;
    bool isOverdue = false;
    if (nu != null) {
      final days = nu.difference(now).inDays;
      if (days > 0) {
        countdownText = 'التحديث القادم خلال $days يوم';
        countdownColor = AppColors.calcGreen;
      } else {
        countdownText = 'تجاوز موعد التحديث بـ ${days.abs()} يوم';
        countdownColor = AppColors.warning;
        isOverdue = true;
      }
    }
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.calcCard2,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.calcBorder2),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('آخر تحديث للمصادر الرسمية', style: AppTextStyles.labelSmall.copyWith(color: AppColors.calcMuted)),
            const SizedBox(height: 2),
            Text(
              lu != null ? _fmt(lu) : '—',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.calcText, fontWeight: FontWeight.w700),
            ),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isOverdue
                  ? AppColors.warning.withValues(alpha: 0.14)
                  : AppColors.calcGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isOverdue
                    ? AppColors.warning.withValues(alpha: 0.45)
                    : AppColors.calcGreen.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              isOverdue ? 'يُنصح بالتحديث' : 'البيانات حديثة',
              style: AppTextStyles.labelSmall.copyWith(
                color: isOverdue ? AppColors.warning : AppColors.calcGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ]),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(countdownText, style: AppTextStyles.bodySmall.copyWith(color: countdownColor, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppDimensions.spacingSm),
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
              Text('تحديث البيانات', style: AppTextStyles.bodySmall.copyWith(color: AppColors.calcNeon, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Grok Fallback Banner ──────────────────────────────────────────────────────

class _GrokFallbackBanner extends StatelessWidget {
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
            'بيانات Grok غير متوفرة بعد — ستظهر المقارنة الكاملة بعد أول تشغيل لـ Grok. البيانات الرسمية معروضة مع حكم ⚪ مصدر واحد.',
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
    required this.products,
    required this.selectedBank,
    required this.selectedProduct,
    required this.conflictOnly,
    required this.onBankChanged,
    required this.onProductChanged,
    required this.onConflictToggled,
  });

  final List<String> banks;
  final List<String> products;
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
      _FilterDropdown(
        hint: 'الكل — المنتجات',
        value: selectedProduct,
        items: products,
        labelOf: (p) => _productLabels[p] ?? p,
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

// ── Comparison Table ──────────────────────────────────────────────────────────

class _CompareTable extends StatelessWidget {
  const _CompareTable({required this.rows});
  final List<_CompareRow> rows;

  @override
  Widget build(BuildContext context) {
    final headerStyle = AppTextStyles.labelSmall.copyWith(color: AppColors.calcMuted, fontWeight: FontWeight.w700);
    const headerDecor = BoxDecoration(color: Color(0x145D5FEF));

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
            1: FlexColumnWidth(2),
            2: IntrinsicColumnWidth(),
            3: IntrinsicColumnWidth(),
            4: IntrinsicColumnWidth(),
            5: IntrinsicColumnWidth(),
          },
          children: [
            TableRow(
              decoration: headerDecor,
              children: [
                _HeaderCell('البنك',           style: headerStyle),
                _HeaderCell('المنتج',          style: headerStyle),
                _HeaderCell('نسبة Grok',       style: headerStyle),
                _HeaderCell('الموقع الرسمي',   style: headerStyle),
                _HeaderCell('الفرق',           style: headerStyle),
                _HeaderCell('الحكم',           style: headerStyle),
              ],
            ),
            ...rows.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              final isLast = i == rows.length - 1;
              return TableRow(
                decoration: BoxDecoration(
                  color: i.isOdd ? AppColors.calcCard.withValues(alpha: 0.4) : Colors.transparent,
                  border: isLast
                      ? null
                      : Border(bottom: BorderSide(color: AppColors.calcBorder, width: 0.5)),
                ),
                children: [
                  _DataCell(r.bankNameAr,                              bold: true),
                  _DataCell(_productLabels[r.productType] ?? r.productType),
                  _RateCell(r.grokRate,    color: const Color(0xFFa5b4fc)),
                  _RateCell(r.officialRate, color: AppColors.calcGold),
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
