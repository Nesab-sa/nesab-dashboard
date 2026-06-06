import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/core/theme/app_text_styles.dart';

// ── Data models ────────────────────────────────────────────────────────────

class _BankMarginRow {
  const _BankMarginRow({
    required this.bankKey,
    required this.bankNameAr,
    required this.productType,
    required this.profitMarginRate,
    required this.marginType,
    required this.term,
    required this.confidence,
  });

  final String bankKey;
  final String bankNameAr;
  final String productType;
  final double? profitMarginRate;
  final String? marginType;
  final String? term;
  final String confidence; // HIGH | MEDIUM | UNAVAILABLE
}

class _MetaInfo {
  const _MetaInfo({
    this.lastUpdatedAt,
    this.nextUpdateDue,
    this.sourceNote,
  });

  final DateTime? lastUpdatedAt;
  final DateTime? nextUpdateDue;
  final String? sourceNote;
}

// ── Constants ──────────────────────────────────────────────────────────────

const _productLabels = <String, String>{
  'personal_new': 'التمويل الشخصي',
  'personal_topup': 'زيادة تمويل شخصي',
  'personal_buyout': 'شراء مديونية',
  'realestate_subsidized_ready': 'عقاري مدعوم — جاهز',
  'realestate_subsidized_offplan': 'عقاري مدعوم — على الخارطة',
  'realestate_subsidized_construction': 'عقاري مدعوم — بناء ذاتي',
  'realestate_subsidized_mortgage': 'عقاري مدعوم — رهن عقار',
  'realestate_standard': 'عقاري اعتيادي',
  'lease_5yr': 'تأجيري — نظام 5 سنوات',
  'lease_5050': 'تأجيري — نظام 50/50',
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

// ── Page ──────────────────────────────────────────────────────────────────

class BankMarginsNewPage extends StatefulWidget {
  const BankMarginsNewPage({super.key});

  @override
  State<BankMarginsNewPage> createState() => _BankMarginsNewPageState();
}

class _BankMarginsNewPageState extends State<BankMarginsNewPage> {
  bool _loading = true;
  String? _error;
  List<_BankMarginRow> _rows = [];
  _MetaInfo _meta = const _MetaInfo();

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
      final metaFuture = db.collection('scraper_meta').doc('last_run').get();
      final colFuture = db.collection('bank_margins').get();
      final results = await Future.wait([metaFuture, colFuture]);

      final metaSnap = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final colSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;

      final rows = colSnap.docs.map((d) {
        final data = d.data();
        final rate = data['profit_margin_rate'];
        return _BankMarginRow(
          bankKey: (data['bank_key'] as String?) ?? '',
          bankNameAr:
              (data['bank_name_ar'] as String?) ?? (data['bank_key'] as String?) ?? '',
          productType: (data['product_type'] as String?) ?? '',
          profitMarginRate: rate != null ? (rate as num).toDouble() : null,
          marginType: data['margin_type'] as String?,
          term: data['term'] as String?,
          confidence: (data['confidence'] as String?) ?? 'UNAVAILABLE',
        );
      }).toList();

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

      if (mounted) {
        setState(() {
          _rows = rows;
          _meta = meta;
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

  Map<String, List<_BankMarginRow>> _groupRows() {
    final groups = <String, List<_BankMarginRow>>{};
    for (final r in _rows) {
      groups.putIfAbsent(r.bankKey, () => []).add(r);
    }
    return groups;
  }

  List<String> _sortedBankKeys(Map<String, List<_BankMarginRow>> groups) {
    final keys = groups.keys.toList()
      ..sort((a, b) {
        final ai = _bankOrder.indexOf(a);
        final bi = _bankOrder.indexOf(b);
        return (ai == -1 ? 999 : ai).compareTo(bi == -1 ? 999 : bi);
      });
    return keys;
  }

  List<_BankMarginRow> _sortedProducts(List<_BankMarginRow> rows) {
    final available = rows.where((r) => r.confidence != 'UNAVAILABLE').toList();
    final display = available.isNotEmpty ? available : rows;
    display.sort((a, b) {
      final ai = _productOrder.indexOf(a.productType);
      final bi = _productOrder.indexOf(b.productType);
      return (ai == -1 ? 999 : ai).compareTo(bi == -1 ? 999 : bi);
    });
    return display;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Container(color: AppColors.calcBg),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.calcHeaderTop,
                    AppColors.calcBg.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(child: _buildBody()),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.calcNeon),
      );
    }
    if (_error != null) {
      return _ErrorRetry(message: _error!, onRetry: _load);
    }
    if (_rows.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بيانات لعرضها.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.calcMuted),
        ),
      );
    }

    final grouped = _groupRows();
    final bankKeys = _sortedBankKeys(grouped);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPaddingHorizontal,
            AppDimensions.spacingMd,
            AppDimensions.screenPaddingHorizontal,
            AppDimensions.spacingMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(),
              const SizedBox(height: AppDimensions.spacingMd),
              _MetaCard(meta: _meta, onRefresh: _load),
              const SizedBox(height: AppDimensions.spacingMd),
              _DisclaimerBar(),
            ],
          ),
        ),
        for (final bankKey in bankKeys)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPaddingHorizontal,
              0,
              AppDimensions.screenPaddingHorizontal,
              AppDimensions.spacingSm,
            ),
            child: _BankGroupCard(
              bankNameAr: grouped[bankKey]!.first.bankNameAr,
              rows: _sortedProducts(grouped[bankKey]!),
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.calcNeon2,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'هوامش الربح ومعدل النسبة السنوي للبنوك',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.calcText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Meta card ──────────────────────────────────────────────────────────────

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.meta, required this.onRefresh});

  final _MetaInfo meta;
  final VoidCallback onRefresh;

  String _formatDate(DateTime d) {
    final months = [
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'آخر تحديث للبيانات',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.calcMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lu != null ? _formatDate(lu) : '—',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.calcText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              Expanded(
                child: Text(
                  countdownText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: countdownColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppColors.calcGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    meta.sourceNote ?? 'جُمعت من المصادر الرسمية للبنوك',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.calcMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.calcNeon2.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.calcBorder2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 15,
                    color: AppColors.calcNeon,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'تحديث البيانات',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.calcNeon,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Disclaimer bar ────────────────────────────────────────────────────────

class _DisclaimerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: AppDimensions.iconSm,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              'النتائج تقريبية لأغراض توعوية فقط — لا تُشكّل نصيحة مالية. النِّسب من صفحات الإفصاح الرسمية وقد تتغيّر.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bank group card ───────────────────────────────────────────────────────

class _BankGroupCard extends StatelessWidget {
  const _BankGroupCard({
    required this.bankNameAr,
    required this.rows,
  });

  final String bankNameAr;
  final List<_BankMarginRow> rows;

  @override
  Widget build(BuildContext context) {
    final availableCount = rows.where((r) => r.confidence != 'UNAVAILABLE').length;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          decoration: BoxDecoration(
            color: AppColors.calcNeon2.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            border: Border.all(color: AppColors.calcBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  bankNameAr,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.calcText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$availableCount نسبة',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.calcMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.calcCard,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            border: Border(
              left: BorderSide(color: AppColors.calcBorder),
              right: BorderSide(color: AppColors.calcBorder),
              bottom: BorderSide(color: AppColors.calcBorder),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                _ProductRow(row: rows[i]),
                if (i < rows.length - 1)
                  Divider(
                    height: 1,
                    color: AppColors.calcBorder,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Product row ───────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.row});

  final _BankMarginRow row;

  @override
  Widget build(BuildContext context) {
    final label = _productLabels[row.productType] ?? row.productType;
    final hasRate = row.profitMarginRate != null && row.confidence != 'UNAVAILABLE';
    final rateTxt = hasRate
        ? '${row.profitMarginRate!.toStringAsFixed(2)}%'
        : 'غير متاح';

    final subParts = <String>[
      if (row.marginType == 'fixed')
        'ثابت'
      else if (row.marginType == 'variable')
        'متغير',
      if (row.term != null && row.term!.isNotEmpty) row.term!,
    ];
    final sub = subParts.join(' · ');

    Color confColor;
    Color confBg;
    String confLabel;
    switch (row.confidence) {
      case 'HIGH':
        confColor = AppColors.calcGreen;
        confBg = AppColors.calcGreen.withValues(alpha: 0.14);
        confLabel = 'موثّق';
      case 'MEDIUM':
        confColor = AppColors.warning;
        confBg = AppColors.warning.withValues(alpha: 0.14);
        confLabel = 'يحتاج تحقق';
      default:
        confColor = AppColors.calcMuted;
        confBg = AppColors.calcBorder.withValues(alpha: 0.3);
        confLabel = 'غير متاح';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: 11,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.calcText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.calcMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Text(
            rateTxt,
            style: AppTextStyles.labelMedium.copyWith(
              color: hasRate ? AppColors.calcGold : AppColors.calcMuted,
              fontWeight: hasRate ? FontWeight.w800 : FontWeight.w600,
            ),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: confBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: confColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              confLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: confColor,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error retry ───────────────────────────────────────────────────────────

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 32),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.calcNeon, size: AppDimensions.iconMd),
            label: Text(
              'إعادة المحاولة',
              style: AppTextStyles.buttonMedium
                  .copyWith(color: AppColors.calcNeon),
            ),
          ),
        ],
      ),
    );
  }
}
