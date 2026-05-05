import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

enum _ProductType {
  personal,
  realEstate,
  leasing;

  String get label => switch (this) {
        personal => 'التمويل الشخصي',
        realEstate => 'التمويل العقاري',
        leasing => 'التمويل التأجيري',
      };

  String get firestoreKey => switch (this) {
        personal => 'personal',
        realEstate => 'realEstate',
        leasing => 'leasing',
      };

  IconData get icon => switch (this) {
        personal => Icons.person_outline_rounded,
        realEstate => Icons.home_outlined,
        leasing => Icons.directions_car_outlined,
      };
}

class _BankRow {
  const _BankRow({required this.name, required this.min, required this.max});
  final String name;
  final double min;
  final double max;
  String get range =>
      '${min.toStringAsFixed(2)}% - ${max.toStringAsFixed(2)}%';
}

String _formatDate(Timestamp ts) {
  const months = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
  ];
  final d = ts.toDate();
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

// ── Page ──────────────────────────────────────────────────────────────────

class ProfitMarginsComparePage extends StatefulWidget {
  const ProfitMarginsComparePage({super.key});

  @override
  State<ProfitMarginsComparePage> createState() =>
      _ProfitMarginsComparePageState();
}

class _ProfitMarginsComparePageState extends State<ProfitMarginsComparePage> {
  _ProductType? _activeProduct;

  // In-memory agreement — reset every session
  bool _agreed1 = false;
  bool _agreed2 = false;

  // Firestore
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;
  String _lastUpdated = '';

  bool get _bothAgreed => _agreed1 && _agreed2;

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
      final snap = await FirebaseFirestore.instance
          .collection('bank_rates')
          .doc('profit_margins')
          .get();
      if (!snap.exists || snap.data() == null) {
        throw Exception('لم يُعثر على البيانات');
      }
      final data = snap.data()!;
      final ts = data['lastUpdated'];
      final dateStr = ts is Timestamp ? _formatDate(ts) : '';
      if (mounted) {
        setState(() {
          _data = data;
          _lastUpdated = dateStr;
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

  List<_BankRow> _rowsFor(_ProductType product) {
    final banks = (_data?['banks'] as List<dynamic>?) ?? [];
    final key = product.firestoreKey;
    final rows = <_BankRow>[];
    for (final b in banks) {
      final m = b as Map<String, dynamic>;
      final p = m[key] as Map<String, dynamic>?;
      if (p == null || p['available'] != true) continue;
      rows.add(_BankRow(
        name: (m['bankName'] as String?) ?? '',
        min: (p['min'] as num?)?.toDouble() ?? 0,
        max: (p['max'] as num?)?.toDouble() ?? 0,
      ));
    }
    rows.sort((a, b) => a.min.compareTo(b.min));
    return rows;
  }

  void _onProductTap(_ProductType product) {
    if (!_bothAgreed) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('يرجى الموافقة على التنبيهات أولاً'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    setState(() => _activeProduct = product);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          // Background
          Container(color: AppColors.calcBg),
          Positioned(
            top: 0, left: 0, right: 0,
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
            appBar: _activeProduct != null
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    leading: BackButton(
                      color: AppColors.calcText,
                      onPressed: () =>
                          setState(() => _activeProduct = null),
                    ),
                    title: Text(
                      _activeProduct!.label,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.calcText,
                      ),
                    ),
                  )
                : null,
            body: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: _activeProduct == null
                    ? _DisclaimerScreen(
                        key: const ValueKey('disclaimer'),
                        loading: _loading,
                        error: _error,
                        lastUpdated: _lastUpdated,
                        agreed1: _agreed1,
                        agreed2: _agreed2,
                        bothAgreed: _bothAgreed,
                        onChanged1: (v) =>
                            setState(() => _agreed1 = v ?? false),
                        onChanged2: (v) =>
                            setState(() => _agreed2 = v ?? false),
                        onProductTap: _onProductTap,
                        onRetry: _load,
                      )
                    : _ResultsScreen(
                        key: ValueKey(_activeProduct),
                        product: _activeProduct!,
                        rows: _data != null ? _rowsFor(_activeProduct!) : [],
                        loading: _loading,
                        error: _error,
                        lastUpdated: _lastUpdated,
                        onRetry: _load,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Warning bar ────────────────────────────────────────────────────────────

class _WarningBar extends StatelessWidget {
  const _WarningBar({required this.lastUpdated});
  final String lastUpdated;

  @override
  Widget build(BuildContext context) {
    final text = lastUpdated.isEmpty
        ? 'نسبة تقريبية — مصدرها: الموقع الرسمي للبنك / القناة الرسمية. راجع البنك للنسبة الفعلية.'
        : 'نسبة تقريبية — مصدرها: الموقع الرسمي للبنك / القناة الرسمية.  '
            'آخر تحديث: $lastUpdated. راجع البنك للنسبة الفعلية.';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: AppDimensions.iconMd,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Text(
              text,
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

// ── Disclaimer screen ─────────────────────────────────────────────────────

class _DisclaimerScreen extends StatelessWidget {
  const _DisclaimerScreen({
    super.key,
    required this.loading,
    required this.error,
    required this.lastUpdated,
    required this.agreed1,
    required this.agreed2,
    required this.bothAgreed,
    required this.onChanged1,
    required this.onChanged2,
    required this.onProductTap,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final String lastUpdated;
  final bool agreed1;
  final bool agreed2;
  final bool bothAgreed;
  final ValueChanged<bool?> onChanged1;
  final ValueChanged<bool?> onChanged2;
  final ValueChanged<_ProductType> onProductTap;
  final VoidCallback onRetry;

  static const _bullets = [
    'المعلومات المعروضة مُحدَّثة دورياً ولا تضمن نِسَب دقتها في كل وقت.',
    'المقارنة لا تشمل بالضرورة جميع البنوك أو جميع المنتجات المتاحة في السوق.',
    'ترتيب البنوك أو إبراز "الأقل" هو لأغراض المقارنة فقط ولا يُعدّ توصية أو تفضيلاً.',
    'ذكر أسماء البنوك لا يعني وجود شراكة أو وكالة أو اعتماد رسمي من أي منها.',
    'تواصل مع البنك مباشرة للتحقق من: النسبة الفعلية، الرسوم الإدارية، التأمين، الغرامات، وشروط السداد المبكر.',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.screenPaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Warning bar (loading skeleton or actual date)
          if (loading)
            _SkeletonBar()
          else if (error != null)
            _ErrorRetry(message: error!, onRetry: onRetry)
          else
            _WarningBar(lastUpdated: lastUpdated),

          const SizedBox(height: AppDimensions.spacingXl),

          // Product cards (greyed out until agreed)
          _SectionLabel(label: 'اختر نوع التمويل'),
          const SizedBox(height: AppDimensions.spacingMd),
          for (final product in _ProductType.values) ...[
            _ProductCard(
              product: product,
              enabled: bothAgreed,
              onTap: () => onProductTap(product),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
          ],

          const SizedBox(height: AppDimensions.spacingXl),

          // Agreement checkboxes
          _SectionLabel(label: 'يجب الموافقة على التنبيهين أولاً'),
          const SizedBox(height: AppDimensions.spacingMd),
          _AgreementBox(
            label: 'تنبيه مهم',
            bullets: _bullets,
            checked: agreed1,
            onChanged: onChanged1,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _AgreementBox(
            label: 'تنبيه 2',
            bullets: _bullets,
            checked: agreed2,
            onChanged: onChanged2,
          ),
          const SizedBox(height: AppDimensions.spacingXxxl),
        ],
      ),
    );
  }
}

// ── Results screen ────────────────────────────────────────────────────────

class _ResultsScreen extends StatelessWidget {
  const _ResultsScreen({
    super.key,
    required this.product,
    required this.rows,
    required this.loading,
    required this.error,
    required this.lastUpdated,
    required this.onRetry,
  });

  final _ProductType product;
  final List<_BankRow> rows;
  final bool loading;
  final String? error;
  final String lastUpdated;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPaddingHorizontal,
            AppDimensions.spacingMd,
            AppDimensions.screenPaddingHorizontal,
            AppDimensions.spacingMd,
          ),
          child: _WarningBar(lastUpdated: lastUpdated),
        ),
        Expanded(
          child: _buildBody(context),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.calcNeon),
      );
    }
    if (error != null) {
      return _ErrorRetry(message: error!, onRetry: onRetry);
    }
    if (rows.isEmpty) {
      return Center(
        child: Text(
          'لا توجد بنوك متاحة لهذا المنتج حالياً',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.calcMuted),
        ),
      );
    }

    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingHorizontal,
            vertical: AppDimensions.spacingSm,
          ),
          color: AppColors.calcCard.withValues(alpha: 0.6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'اسم البنك',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.calcMuted),
                ),
              ),
              Text(
                'هامش الربح',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.calcMuted),
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          color: AppColors.calcBorder,
        ),
        // Bank rows
        Expanded(
          child: ListView.separated(
            itemCount: rows.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              color: AppColors.calcBorder,
              indent: AppDimensions.screenPaddingHorizontal,
              endIndent: AppDimensions.screenPaddingHorizontal,
            ),
            itemBuilder: (context, index) {
              final row = rows[index];
              final isLowest = index == 0;
              return Container(
                color: isLowest
                    ? AppColors.calcGreen.withValues(alpha: 0.07)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenPaddingHorizontal,
                  vertical: AppDimensions.spacingMd,
                ),
                child: Row(
                  children: [
                    if (isLowest) ...[
                      const Icon(
                        Icons.star_rounded,
                        size: AppDimensions.iconSm,
                        color: AppColors.calcGreen,
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                    ],
                    Expanded(
                      child: Text(
                        row.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isLowest
                              ? AppColors.calcText
                              : AppColors.textPrimaryDark,
                          fontWeight: isLowest
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    Text(
                      row.range,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.calcGold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Product card ──────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.enabled,
    required this.onTap,
  });

  final _ProductType product;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingMd,
          ),
          decoration: BoxDecoration(
            color: AppColors.calcCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: AppColors.calcBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.calcNeon2.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(
                    color: AppColors.calcNeon2.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  product.icon,
                  color: AppColors.calcNeon,
                  size: AppDimensions.iconMd,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: Text(
                  product.label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.calcText,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.calcMuted,
                size: AppDimensions.iconLg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Agreement checkbox ────────────────────────────────────────────────────

class _AgreementBox extends StatelessWidget {
  const _AgreementBox({
    required this.label,
    required this.bullets,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final List<String> bullets;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.calcCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(
            color: checked
                ? AppColors.accent.withValues(alpha: 0.6)
                : AppColors.calcBorder,
            width: checked ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: checked,
                    onChanged: onChanged,
                    activeColor: AppColors.accent,
                    checkColor: AppColors.primary,
                    side: BorderSide(color: AppColors.calcMuted),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: checked
                        ? AppColors.accent
                        : AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            for (final bullet in bullets)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppDimensions.spacingXs,
                  bottom: AppDimensions.spacingXs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.calcMuted,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        bullet,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.calcMuted,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(color: AppColors.calcMuted),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.calcCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.calcBorder),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.calcNeon,
          ),
        ),
      ),
    );
  }
}

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
