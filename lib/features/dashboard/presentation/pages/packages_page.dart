import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/services/audit_log_service.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// «الباقات» — هيكل باقات الاشتراك في مجموعة `packages`
/// (الهيكل فقط وفق الاتفاق — دون تنفيذ الدفع).
///
/// الحقول: nameAr/nameEn, description, price, currency, period
/// (monthly/yearly/once), features[], isActive, order.
/// القراءة عامة (لعرض الأسعار في التطبيق/الموقع لاحقاً)، الكتابة للأدمن.
class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _Package {
  const _Package({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.description,
    required this.price,
    required this.currency,
    required this.period,
    required this.features,
    required this.isActive,
    required this.order,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final String description;
  final double price;
  final String currency;
  final String period;
  final List<String> features;
  final bool isActive;
  final int order;

  factory _Package.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return _Package(
      id: doc.id,
      nameAr: d['nameAr']?.toString() ?? '',
      nameEn: d['nameEn']?.toString() ?? '',
      description: d['description']?.toString() ?? '',
      price: (d['price'] as num?)?.toDouble() ?? 0,
      currency: d['currency']?.toString() ?? 'SAR',
      period: d['period']?.toString() ?? 'monthly',
      features: (d['features'] is List)
          ? (d['features'] as List).whereType<String>().toList()
          : const [],
      isActive: d['isActive'] as bool? ?? true,
      order: (d['order'] as num?)?.toInt() ?? 99,
    );
  }
}

const Map<String, String> _periodLabels = {
  'monthly': 'شهري',
  'yearly': 'سنوي',
  'once': 'مرة واحدة',
};

class _PackagesPageState extends State<PackagesPage> {
  final _fs = FirebaseFirestore.instance;

  bool _loading = true;
  String? _error;
  List<_Package> _packages = [];

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
      final snap = await _fs.collection('packages').get();
      final list = snap.docs.map(_Package.fromDoc).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      setState(() {
        _packages = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل الباقات: $e';
      });
    }
  }

  void _snack(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ));
  }

  Future<void> _edit([_Package? existing]) async {
    final nameAr = TextEditingController(text: existing?.nameAr ?? '');
    final nameEn = TextEditingController(text: existing?.nameEn ?? '');
    final description =
        TextEditingController(text: existing?.description ?? '');
    final price =
        TextEditingController(text: existing?.price.toStringAsFixed(0) ?? '');
    final features =
        TextEditingController(text: existing?.features.join('\n') ?? '');
    var period = existing?.period ?? 'monthly';
    var isActive = existing?.isActive ?? true;
    final orderCtrl =
        TextEditingController(text: '${existing?.order ?? _packages.length}');

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(existing == null ? 'باقة جديدة' : 'تعديل الباقة'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: nameAr,
                        decoration: const InputDecoration(
                            labelText: 'الاسم بالعربية *', isDense: true)),
                    const SizedBox(height: 10),
                    TextField(
                        controller: nameEn,
                        decoration: const InputDecoration(
                            labelText: 'الاسم بالإنجليزية', isDense: true)),
                    const SizedBox(height: 10),
                    TextField(
                        controller: description,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            labelText: 'الوصف', isDense: true)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: price,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'السعر (ر.س) *', isDense: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: period,
                          decoration: const InputDecoration(
                              labelText: 'الدورة', isDense: true),
                          items: [
                            for (final e in _periodLabels.entries)
                              DropdownMenuItem(
                                  value: e.key, child: Text(e.value)),
                          ],
                          onChanged: (v) => setDialogState(
                              () => period = v ?? 'monthly'),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    TextField(
                      controller: features,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'المزايا (سطر لكل ميزة)',
                        isDense: true,
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: TextField(
                          controller: orderCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'الترتيب', isDense: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(children: [
                        Switch(
                            value: isActive,
                            onChanged: (v) =>
                                setDialogState(() => isActive = v)),
                        const Text('نشطة'),
                      ]),
                    ]),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('إلغاء')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('حفظ')),
            ],
          ),
        );
      }),
    );

    if (saved != true) return;
    if (nameAr.text.trim().isEmpty) {
      _snack('اسم الباقة مطلوب', isError: true);
      return;
    }
    final parsedPrice = double.tryParse(price.text.trim());
    if (parsedPrice == null || parsedPrice < 0) {
      _snack('سعر غير صالح', isError: true);
      return;
    }

    try {
      final id = existing?.id ??
          'pkg_${DateTime.now().millisecondsSinceEpoch}';
      await _fs.collection('packages').doc(id).set({
        'nameAr': nameAr.text.trim(),
        'nameEn': nameEn.text.trim(),
        'description': description.text.trim(),
        'price': parsedPrice,
        'currency': 'SAR',
        'period': period,
        'features': features.text
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList(),
        'isActive': isActive,
        'order': int.tryParse(orderCtrl.text.trim()) ?? 99,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await AuditLogService.log(
          existing == null ? 'package.create' : 'package.update',
          target: nameAr.text.trim());
      _snack('تم حفظ الباقة «${nameAr.text.trim()}»');
      await _load();
    } catch (e) {
      _snack('فشل الحفظ: $e', isError: true);
    }
  }

  Future<void> _delete(_Package pkg) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الباقة'),
        content: Text('هل تريد حذف باقة "${pkg.nameAr}"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _fs.collection('packages').doc(pkg.id).delete();
      await AuditLogService.log('package.delete', target: pkg.nameAr);
      _snack('تم حذف «${pkg.nameAr}»');
      await _load();
    } catch (e) {
      _snack('فشل الحذف: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.dashboardTextPrimary
        : AppColors.lightModeTextPrimary;
    final secondaryColor = isDark
        ? AppColors.dashboardTextSecondary
        : AppColors.lightModeTextSecondary;
    final cardColor =
        isDark ? AppColors.dashboardCard : AppColors.lightModeCard;
    final borderColor =
        isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder;

    if (_loading) return const Center(child: CircularProgressIndicator());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('باقات الاشتراك',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor)),
                  const SizedBox(height: 4),
                  Text(
                    'هيكل الباقات (شهري/سنوي/مرة واحدة) وربطها بالأدوات المدفوعة — الدفع نفسه مرحلة لاحقة.',
                    style: TextStyle(fontSize: 13, color: secondaryColor),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => _edit(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('باقة جديدة'),
            ),
          ]),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
              child:
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
            ),
          const SizedBox(height: AppDimensions.spacingLg),
          if (_packages.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingLg * 2),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: borderColor),
              ),
              child: Column(children: [
                FaIcon(FontAwesomeIcons.boxOpen,
                    size: 40, color: secondaryColor.withValues(alpha: .5)),
                const SizedBox(height: 12),
                Text('لا باقات بعد — أنشئ أول باقة (مثال: أساسية شهرية 29 ر.س)',
                    style: TextStyle(fontSize: 13.5, color: secondaryColor)),
              ]),
            )
          else
            Wrap(
              spacing: AppDimensions.spacingMd,
              runSpacing: AppDimensions.spacingMd,
              children: [
                for (final pkg in _packages)
                  Container(
                    width: 280,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                          color: pkg.isActive
                              ? AppColors.success.withValues(alpha: .45)
                              : borderColor),
                    ),
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(pkg.nameAr,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textColor)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: (pkg.isActive
                                      ? AppColors.success
                                      : Colors.grey)
                                  .withValues(alpha: .13),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(pkg.isActive ? 'نشطة' : 'موقوفة',
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: pkg.isActive
                                        ? AppColors.success
                                        : Colors.grey)),
                          ),
                        ]),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(pkg.price.toStringAsFixed(0),
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                  'ر.س / ${_periodLabels[pkg.period] ?? pkg.period}',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: secondaryColor)),
                            ),
                          ],
                        ),
                        if (pkg.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(pkg.description,
                              style: TextStyle(
                                  fontSize: 12.5, color: secondaryColor),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                        if (pkg.features.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          for (final f in pkg.features.take(4))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(children: [
                                const Icon(Icons.check,
                                    size: 14, color: AppColors.success),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(f,
                                      style: TextStyle(
                                          fontSize: 12, color: textColor),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ]),
                            ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _delete(pkg),
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: const Text('حذف'),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error),
                            ),
                            TextButton.icon(
                              onPressed: () => _edit(pkg),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('تعديل'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
