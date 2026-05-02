import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/profit_margin_model.dart';

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
  String? _error;

  ProfitMarginsConfig? _config;
  late List<BankProfitMargin> _banks;

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

  void _editMargin(int bankIndex, String product) {
    final bank = _banks[bankIndex];
    ProductMargin current;
    switch (product) {
      case 'personal':
        current = bank.personal;
        break;
      case 'realEstate':
        current = bank.realEstate;
        break;
      default:
        current = bank.leasing;
    }

    final minCtrl = TextEditingController(text: current.min.toString());
    final maxCtrl = TextEditingController(text: current.max.toString());
    bool available = current.available;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardColor =
            isDark ? AppColors.dashboardCard : AppColors.lightModeCard;
        final textPrimary = isDark
            ? AppColors.dashboardTextPrimary
            : AppColors.lightModeTextPrimary;
        final borderColor =
            isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder;

        String productLabel;
        switch (product) {
          case 'personal':
            productLabel = 'شخصي';
            break;
          case 'realEstate':
            productLabel = 'عقاري';
            break;
          default:
            productLabel = 'تأجيري';
        }

        return StatefulBuilder(
          builder: (ctx, setDialogState) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: cardColor,
              title: Text(
                '${bank.bankName} — $productLabel',
                style:
                    TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMarginField(
                      'الحد الأدنى %', minCtrl, textPrimary, borderColor),
                  const SizedBox(height: 12),
                  _buildMarginField(
                      'الحد الأقصى %', maxCtrl, textPrimary, borderColor),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('متاح', style: TextStyle(color: textPrimary)),
                      const Spacer(),
                      Switch(
                        value: available,
                        activeColor: AppColors.blue,
                        onChanged: (v) =>
                            setDialogState(() => available = v),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('إلغاء',
                      style: TextStyle(color: AppColors.dashboardTextSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    final min =
                        double.tryParse(minCtrl.text.trim()) ?? current.min;
                    final max =
                        double.tryParse(maxCtrl.text.trim()) ?? current.max;
                    final updated = ProductMargin(
                        min: min, max: max, available: available);
                    setState(() {
                      switch (product) {
                        case 'personal':
                          _banks[bankIndex] =
                              bank.copyWith(personal: updated);
                          break;
                        case 'realEstate':
                          _banks[bankIndex] =
                              bank.copyWith(realEstate: updated);
                          break;
                        default:
                          _banks[bankIndex] =
                              bank.copyWith(leasing: updated);
                      }
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

  Widget _buildMarginField(String label, TextEditingController ctrl,
      Color textColor, Color borderColor) {
    return TextField(
      controller: ctrl,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.dashboardBg : AppColors.lightModeBg;
    final cardColor =
        isDark ? AppColors.dashboardCard : AppColors.lightModeCard;
    final textPrimary = isDark
        ? AppColors.dashboardTextPrimary
        : AppColors.lightModeTextPrimary;
    final textSecondary = isDark
        ? AppColors.dashboardTextSecondary
        : AppColors.lightModeTextSecondary;
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
                    // Header
                    Row(
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            color: AppColors.blue, size: 28),
                        const SizedBox(width: AppDimensions.spacingMd),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'هوامش الربح',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary),
                            ),
                            if (_config?.lastUpdated != null)
                              Text(
                                'آخر تحديث: ${DateFormat('dd/MM/yyyy – hh:mm a', 'ar').format(_config!.lastUpdated!.toLocal())}  •  ${_config!.updatedBy == 'grok-scheduled' ? 'تلقائي بواسطة Grok' : 'يدوي'}',
                                style: TextStyle(
                                    color: textSecondary, fontSize: 12),
                              ),
                          ],
                        ),
                        const Spacer(),
                        if (_saved)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.success.withOpacity(0.3)),
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

                    // AI Summary
                    if (_config?.aiSummary.isNotEmpty == true)
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: AppDimensions.spacingMd),
                        padding: const EdgeInsets.all(AppDimensions.spacingMd),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.07),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
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

                    if (_error != null)
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: AppDimensions.spacingMd),
                        padding: const EdgeInsets.all(AppDimensions.spacingMd),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                          border: Border.all(
                              color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(_error!,
                            style: TextStyle(color: AppColors.error)),
                      ),

                    // Table
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          // Table header
                          Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.dashboardBg
                                  : AppColors.lightModeBg,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(AppDimensions.radiusLg)),
                            ),
                            child: _TableRow(
                              isHeader: true,
                              bankName: 'البنك',
                              personal: 'شخصي',
                              realEstate: 'عقاري',
                              leasing: 'تأجيري',
                              textColor: textSecondary,
                              borderColor: borderColor,
                            ),
                          ),
                          // Bank rows
                          ..._banks.asMap().entries.map((entry) {
                            final i = entry.key;
                            final bank = entry.value;
                            final isLast = i == _banks.length - 1;
                            return _BankRow(
                              bank: bank,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              borderColor: borderColor,
                              isLast: isLast,
                              onEditPersonal: () => _editMargin(i, 'personal'),
                              onEditRealEstate: () =>
                                  _editMargin(i, 'realEstate'),
                              onEditLeasing: () => _editMargin(i, 'leasing'),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),

                    // Info box
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingMd),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
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
                              style:
                                  TextStyle(color: textSecondary, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('حفظ التعديلات',
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
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.isHeader,
    required this.bankName,
    required this.personal,
    required this.realEstate,
    required this.leasing,
    required this.textColor,
    required this.borderColor,
  });

  final bool isHeader;
  final String bankName;
  final String personal;
  final String realEstate;
  final String leasing;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: textColor,
      fontSize: isHeader ? 12 : 13,
      fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(bankName, style: style)),
          Expanded(flex: 2, child: Text(personal, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(realEstate, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(leasing, style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _BankRow extends StatelessWidget {
  const _BankRow({
    required this.bank,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    required this.isLast,
    required this.onEditPersonal,
    required this.onEditRealEstate,
    required this.onEditLeasing,
  });

  final BankProfitMargin bank;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final bool isLast;
  final VoidCallback onEditPersonal;
  final VoidCallback onEditRealEstate;
  final VoidCallback onEditLeasing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(bank.bankName,
                style: TextStyle(
                    color: textPrimary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: _MarginCell(
              margin: bank.personal,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onTap: onEditPersonal,
            ),
          ),
          Expanded(
            flex: 2,
            child: _MarginCell(
              margin: bank.realEstate,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onTap: onEditRealEstate,
            ),
          ),
          Expanded(
            flex: 2,
            child: _MarginCell(
              margin: bank.leasing,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onTap: onEditLeasing,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarginCell extends StatelessWidget {
  const _MarginCell({
    required this.margin,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  final ProductMargin margin;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: margin.available
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${margin.min}% – ${margin.max}%',
                    style: TextStyle(
                        color: textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  Icon(Icons.edit, size: 11, color: textSecondary),
                ],
              )
            : Text('غير متاح',
                style: TextStyle(color: textSecondary, fontSize: 12)),
      ),
    );
  }
}
