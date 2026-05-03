import 'dart:math' show min, max;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/profit_margin_model.dart';

// ─────────────────────────────────────────────
// تعريف الفئات والمنتجات (ثابتة)
// ─────────────────────────────────────────────

class _ProductDef {
  final String key;
  final String label;
  const _ProductDef(this.key, this.label);
}

class _CategoryDef {
  final String title;
  final IconData icon;
  final List<_ProductDef> products;
  const _CategoryDef(this.title, this.icon, this.products);
}

const _categories = <_CategoryDef>[
  _CategoryDef('التمويل الشخصي', Icons.person_rounded, [
    _ProductDef('personalBasic', 'شخصي عادي'),
    _ProductDef('personalSpecial', 'مخصص'),
  ]),
  _CategoryDef('التمويل العقاري المدعوم', Icons.home_work_rounded, [
    _ProductDef('realEstateSupportedProgram', 'برنامج سكني'),
    _ProductDef('realEstateSupportedMinistry', 'وزارة الإسكان'),
  ]),
  _CategoryDef('التمويل العقاري الاعتيادي', Icons.apartment_rounded, [
    _ProductDef('realEstateCommercial', 'تجاري'),
    _ProductDef('realEstateResident', 'مقيم'),
  ]),
  _CategoryDef('التمويل التأجيري', Icons.directions_car_rounded, [
    _ProductDef('leasingVehicles', 'سيارات'),
    _ProductDef('leasingEquipment', 'معدات'),
  ]),
];

// ─────────────────────────────────────────────
// الصفحة الرئيسية
// ─────────────────────────────────────────────

class ProfitMarginsPage extends StatefulWidget {
  const ProfitMarginsPage({super.key});

  @override
  State<ProfitMarginsPage> createState() => _ProfitMarginsPageState();
}

class _ProfitMarginsPageState extends State<ProfitMarginsPage> {
  final _firestore = FirebaseFirestore.instance;
  static const _docPath = 'bank_rates/profit_margins';

  bool _loading = true;
  bool _saving = false;
  bool _saved = false;
  bool _triggering = false;
  String? _error;

  ProfitMarginsConfig? _config;
  late List<BankProfitMargin> _banks;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── تحميل ────────────────────────────────────────

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final doc = await _firestore.doc(_docPath).get();
      if (doc.exists) {
        _config = ProfitMarginsConfig.fromDoc(doc.data()!);
        _banks = List.from(_config!.banks);
      } else {
        _config = ProfitMarginsConfig.defaultConfig();
        _banks = List.from(_config!.banks);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  // ── حفظ يدوي ─────────────────────────────────────

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _saved = false;
      _error = null;
    });
    try {
      await _firestore.doc(_docPath).set({
        'banks': _banks.map((b) => b.toMap()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedBy': 'dashboard-manual',
        'aiSummary': _config?.aiSummary ?? '',
      }, SetOptions(merge: true));
      setState(() => _saved = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _saved = false);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  // ── تحديث Grok ───────────────────────────────────

  Future<void> _triggerGrok() async {
    setState(() {
      _triggering = true;
      _error = null;
    });
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('triggerProfitMarginsUpdate');
      await callable.call();
      await _load();
    } on FirebaseFunctionsException catch (e) {
      setState(() => _error = 'خطأ من Grok: ${e.message}');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _triggering = false);
    }
  }

  // ── لون الخلية بناءً على الترتيب ─────────────────

  /// أقل min = أخضر، أعلى min = أحمر
  Color? _cellColor(String productKey, int bankIndex) {
    final bank = _banks[bankIndex];
    final margin = bank.product(productKey);
    if (!margin.available) return null;

    final availableMins = _banks
        .where((b) => b.product(productKey).available)
        .map((b) => b.product(productKey).min)
        .toList();

    if (availableMins.length < 2) return null;

    final globalMin = availableMins.reduce(min);
    final globalMax = availableMins.reduce(max);
    if (globalMin == globalMax) return null;

    if (margin.min == globalMin) return Colors.green.withOpacity(0.15);
    if (margin.min == globalMax) return Colors.red.withOpacity(0.15);
    return null;
  }

  // ── تعديل هامش ───────────────────────────────────

  void _editMarginDialog(int bankIndex, String productKey, String productLabel) {
    final bank = _banks[bankIndex];
    final current = bank.product(productKey);

    final minCtrl =
        TextEditingController(text: current.available ? current.min.toString() : '');
    final maxCtrl =
        TextEditingController(text: current.available ? current.max.toString() : '');
    bool available = current.available;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardColor =
            isDark ? AppColors.dashboardCard : AppColors.lightModeCard;
        final textPrimary =
            isDark ? AppColors.dashboardTextPrimary : AppColors.lightModeTextPrimary;
        final borderColor =
            isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder;

        return StatefulBuilder(
          builder: (ctx, setDialogState) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: cardColor,
              title: Text(
                '${bank.bankName} — $productLabel',
                style: TextStyle(
                    color: textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _marginField('الحد الأدنى %', minCtrl, textPrimary, borderColor),
                  const SizedBox(height: 12),
                  _marginField('الحد الأقصى %', maxCtrl, textPrimary, borderColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('متاح', style: TextStyle(color: textPrimary)),
                      const Spacer(),
                      Switch(
                        value: available,
                        activeColor: AppColors.blue,
                        onChanged: (v) => setDialogState(() => available = v),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('إلغاء',
                      style:
                          TextStyle(color: AppColors.dashboardTextSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    final minVal =
                        double.tryParse(minCtrl.text.trim()) ?? current.min;
                    final maxVal =
                        double.tryParse(maxCtrl.text.trim()) ?? current.max;
                    setState(() {
                      _banks[bankIndex] = bank.withProduct(
                        productKey,
                        ProductMargin(
                            min: minVal, max: maxVal, available: available),
                      );
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _marginField(String label, TextEditingController ctrl,
      Color textColor, Color borderColor) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: AppColors.dashboardTextSecondary, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  // ── إضافة بنك ────────────────────────────────────

  void _addBankDialog() {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardColor =
            isDark ? AppColors.dashboardCard : AppColors.lightModeCard;
        final textPrimary =
            isDark ? AppColors.dashboardTextPrimary : AppColors.lightModeTextPrimary;
        final borderColor =
            isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: cardColor,
            title: Text('إضافة بنك جديد',
                style: TextStyle(
                    color: textPrimary, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _marginField('اسم البنك', nameCtrl, textPrimary, borderColor),
                const SizedBox(height: 12),
                _marginField('معرّف البنك (بالإنجليزية)', idCtrl, textPrimary,
                    borderColor),
                const SizedBox(height: 8),
                Text(
                  'مثال: mybank — يُستخدم داخلياً فقط',
                  style: TextStyle(
                      color: AppColors.dashboardTextSecondary, fontSize: 11),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء',
                    style:
                        TextStyle(color: AppColors.dashboardTextSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final id = idCtrl.text.trim().replaceAll(' ', '_');
                  if (name.isEmpty || id.isEmpty) return;
                  // إنشاء منتجات افتراضية لكل المنتجات المعرّفة
                  final defaultProducts = <String, ProductMargin>{};
                  for (final cat in _categories) {
                    for (final prod in cat.products) {
                      defaultProducts[prod.key] =
                          const ProductMargin(min: 0, max: 0, available: false);
                    }
                  }
                  setState(() {
                    _banks.add(BankProfitMargin(
                      bankId: id,
                      bankName: name,
                      products: defaultProducts,
                    ));
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── حذف بنك ──────────────────────────────────────

  void _confirmDeleteBank(int index) {
    final bank = _banks[index];
    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardColor =
            isDark ? AppColors.dashboardCard : AppColors.lightModeCard;
        final textPrimary =
            isDark ? AppColors.dashboardTextPrimary : AppColors.lightModeTextPrimary;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: cardColor,
            title: Text('حذف ${bank.bankName}؟',
                style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
            content: Text(
              'سيُحذف هذا البنك من جميع الفئات. هل أنت متأكد؟',
              style: TextStyle(color: AppColors.dashboardTextSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('إلغاء',
                    style:
                        TextStyle(color: AppColors.dashboardTextSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white),
                onPressed: () {
                  setState(() => _banks.removeAt(index));
                  Navigator.pop(ctx);
                },
                child: const Text('حذف'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── بناء بطاقة فئة ───────────────────────────────

  Widget _buildCategoryCard(
    _CategoryDef category, {
    required bool isDark,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color borderColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الفئة
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.dashboardBg
                  : AppColors.lightModeBg,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimensions.radiusLg)),
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Icon(category.icon, color: AppColors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  category.title,
                  style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
          ),
          // رأس الجدول
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('البنك',
                      style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
                for (final product in category.products)
                  Expanded(
                    flex: 2,
                    child: Text(product.label,
                        style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center),
                  ),
                const SizedBox(width: 32), // مكان زر الحذف
              ],
            ),
          ),
          // صفوف البنوك
          ..._banks.asMap().entries.map((entry) {
            final i = entry.key;
            final bank = entry.value;
            final isLast = i == _banks.length - 1;
            return _buildBankRow(
              bank,
              i,
              category,
              isLast,
              textPrimary,
              textSecondary,
              borderColor,
            );
          }),
        ],
      ),
    );
  }

  // ── صف بنك داخل الفئة ────────────────────────────

  Widget _buildBankRow(
    BankProfitMargin bank,
    int bankIndex,
    _CategoryDef category,
    bool isLast,
    Color textPrimary,
    Color textSecondary,
    Color borderColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          // اسم البنك
          Expanded(
            flex: 3,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              child: Text(
                bank.bankName,
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
          // خلايا المنتجات
          for (final product in category.products)
            Expanded(
              flex: 2,
              child: _buildColoredCell(
                  bank, bankIndex, product.key, product.label,
                  textPrimary, textSecondary),
            ),
          // زر الحذف (صغير)
          SizedBox(
            width: 32,
            child: IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 15, color: textSecondary.withOpacity(0.4)),
              onPressed: () => _confirmDeleteBank(bankIndex),
              padding: EdgeInsets.zero,
              tooltip: 'حذف البنك',
            ),
          ),
        ],
      ),
    );
  }

  // ── خلية ملوّنة ───────────────────────────────────

  Widget _buildColoredCell(
    BankProfitMargin bank,
    int bankIndex,
    String productKey,
    String productLabel,
    Color textPrimary,
    Color textSecondary,
  ) {
    final margin = bank.product(productKey);
    final bgColor = _cellColor(productKey, bankIndex);

    return GestureDetector(
      onTap: () => _editMarginDialog(bankIndex, productKey, productLabel),
      child: Container(
        color: bgColor,
        padding:
            const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        child: Center(
          child: margin.available
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${margin.min}% – ${margin.max}%',
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Icon(Icons.edit, size: 10, color: textSecondary),
                  ],
                )
              : Text(
                  'غير متاح',
                  style:
                      TextStyle(color: textSecondary, fontSize: 10),
                ),
        ),
      ),
    );
  }

  // ── build ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.dashboardBg : AppColors.lightModeBg;
    final cardColor =
        isDark ? AppColors.dashboardCard : AppColors.lightModeCard;
    final textPrimary =
        isDark ? AppColors.dashboardTextPrimary : AppColors.lightModeTextPrimary;
    final textSecondary =
        isDark ? AppColors.dashboardTextSecondary : AppColors.lightModeTextSecondary;
    final borderColor =
        isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bgColor,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── الرأس ───────────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            color: AppColors.blue, size: 28),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'هوامش الربح',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary),
                              ),
                              if (_config?.lastUpdated != null) ...[
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 13,
                                        color: textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'آخر تحديث: ${DateFormat('dd/MM/yyyy – hh:mm a', 'ar').format(_config!.lastUpdated!.toLocal())}',
                                      style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _config!.updatedBy
                                                .startsWith('grok')
                                            ? AppColors.blue.withOpacity(0.1)
                                            : AppColors.success
                                                .withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _config!.updatedBy
                                                .startsWith('grok')
                                            ? 'تلقائي بواسطة Grok'
                                            : 'يدوي',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _config!.updatedBy
                                                  .startsWith('grok')
                                              ? AppColors.blue
                                              : AppColors.success,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        // مؤشر الحفظ
                        if (_saved)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color:
                                      AppColors.success.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: AppColors.success, size: 16),
                                const SizedBox(width: 6),
                                Text('تم الحفظ',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),

                    // ─── ملخص AI ─────────────────────────────────
                    if (_config?.aiSummary.isNotEmpty == true)
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: AppDimensions.spacingMd),
                        padding:
                            const EdgeInsets.all(AppDimensions.spacingMd),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd),
                          border: Border.all(
                              color: AppColors.blue.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.smart_toy_rounded,
                                color: AppColors.blue, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _config!.aiSummary,
                                style: TextStyle(
                                    color: textPrimary, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ─── خطأ ─────────────────────────────────────
                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: AppDimensions.spacingMd),
                        padding:
                            const EdgeInsets.all(AppDimensions.spacingMd),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd),
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(_error!,
                            style: TextStyle(color: AppColors.error)),
                      ),

                    // ─── مفتاح الألوان ────────────────────────────
                    Container(
                      margin: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMd),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _colorLegend(Colors.green, 'أقل هامش'),
                          const SizedBox(width: 16),
                          _colorLegend(Colors.red, 'أعلى هامش'),
                          const Spacer(),
                          // زر إضافة بنك
                          OutlinedButton.icon(
                            onPressed: _addBankDialog,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('إضافة بنك',
                                style: TextStyle(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.blue,
                              side: BorderSide(color: AppColors.blue),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── بطاقات الفئات ────────────────────────────
                    for (final cat in _categories)
                      _buildCategoryCard(
                        cat,
                        isDark: isDark,
                        cardColor: cardColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        borderColor: borderColor,
                      ),

                    // ─── صندوق معلومات ────────────────────────────
                    Container(
                      padding:
                          const EdgeInsets.all(AppDimensions.spacingMd),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: textSecondary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'يتم تحديث هوامش الربح تلقائياً يومياً الساعة 10:00 صباحاً بواسطة Grok AI. يمكنك التعديل اليدوي من هذه الصفحة.',
                              style: TextStyle(
                                  color: textSecondary, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),

                    // ─── زر Grok ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: (_triggering || _saving)
                            ? null
                            : _triggerGrok,
                        icon: _triggering
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome_rounded,
                                size: 18),
                        label: Text(
                          _triggering
                              ? 'جارٍ الاستعلام من Grok…'
                              : 'تحديث عبر Grok الآن',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.blue,
                          side: BorderSide(color: AppColors.blue),
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),

                    // ─── زر الحفظ اليدوي ──────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Text('حفظ التعديلات اليدوية',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _colorLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color.withOpacity(0.25),
            border: Border.all(color: color.withOpacity(0.6)),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: AppColors.dashboardTextSecondary, fontSize: 11)),
      ],
    );
  }
}
