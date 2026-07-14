import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/services/audit_log_service.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// «محتوى التطبيق» — كل صفحات app.nesab.sa في قسم واحد (مثل «محتوى الموقع»):
///
///  1. جدول بجميع صفحات التطبيق: الرابط + الأداة المرتبطة بها في الداشبورد
///     وحالتها — بطاقات فهرس التطبيق تتبع قسم «الأدوات» تلقائياً
///     (الاسم/الوصف/الإخفاء تنعكس على https://app.nesab.sa خلال ثوانٍ).
///  2. تحرير عناوين أقسام فهرس التطبيق (site_content/appIndex).
class AppContentPage extends StatefulWidget {
  const AppContentPage({super.key});

  @override
  State<AppContentPage> createState() => _AppContentPageState();
}

/// صفحات التطبيق الـ 22 على app.nesab.sa (المرجع: index).
const Map<String, String> _appPages = {
  'index': 'الفهرس الرئيسي (المرجع)',
  'shakhsi-mukhtasar': 'التمويل الشخصي المختصر',
  'shakhsi-plus': 'الشخصي Plus',
  'shira-madyoniya': 'شراء المديونية',
  'tajiri-aadi': 'التمويل التأجيري',
  'tajiri-makro': 'التأجيري Plus',
  'aqari-aadi': 'التمويل العقاري',
  'aqari-plus': 'العقاري Plus',
  'niqat-albay': 'تمويل نقاط البيع',
  'himaya-iddikhar': 'الحماية والادخار',
  'khayrat': 'خيرات — الودائع',
  'nisbat-alistiqtaa': 'نسبة الاستقطاع',
  'istiqtaa-naam-la': 'الاستقطاع المتاح',
  'hasibat-alumr': 'حاسبة العمر',
  'tahwil-altarikh': 'تحويل التاريخ',
  'tahwil-alumla': 'محول العملات',
  'asham-saudia': 'الأسهم السعودية',
  'alrusum-albankiya': 'الرسوم البنكية',
  'hawawem-arbach': 'هوامش الأرباح',
  'bank-margins': 'هوامش الربح الجديدة',
  'margins-compare': 'مقارنة هوامش الربح',
  'disclaimer': 'إخلاء المسؤولية',
};

/// عناوين أقسام الفهرس القابلة للتحرير (تطابق data-live في index.html).
const List<(String, String, String)> _sectionFields = [
  ('s1', 'قسم 1', 'التمويل الشخصي'),
  ('s2', 'قسم 2', 'التمويل التأجيري'),
  ('s3', 'قسم 3', 'التمويل العقاري'),
  ('s4', 'قسم 4', 'منتجات أخرى'),
  ('s5', 'قسم 5', 'أدوات مساعدة'),
];

class _AppContentPageState extends State<AppContentPage> {
  final _fs = FirebaseFirestore.instance;
  static const _docPath = 'site_content/appIndex';

  bool _loading = true;
  bool _saving = false;
  String? _error;

  final Map<String, TextEditingController> _sections = {};

  /// slug → (اسم الأداة في الداشبورد، مفعّلة؟) من مجموعة categories.
  final Map<String, (String, bool)> _linkedTools = {};

  @override
  void initState() {
    super.initState();
    for (final (key, _, def) in _sectionFields) {
      _sections[key] = TextEditingController(text: def);
    }
    _load();
  }

  @override
  void dispose() {
    for (final c in _sections.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _linkTail(String url) {
    final last = url.split('?').first.split('#').first.split('/').last;
    return last.replaceAll(RegExp(r'\.html?$'), '');
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _fs.doc(_docPath).get(),
        _fs.collection('categories').get(),
      ]);

      final content =
          (results[0] as DocumentSnapshot).data() as Map<String, dynamic>?;
      final sections = content?['sections'];
      if (sections is Map<String, dynamic>) {
        for (final (key, _, _) in _sectionFields) {
          final v = sections[key];
          if (v is String && v.trim().isNotEmpty) {
            _sections[key]!.text = v;
          }
        }
      }

      for (final doc in (results[1] as QuerySnapshot).docs) {
        final d = doc.data() as Map<String, dynamic>;
        final link = (d['calculatorLink'] ?? '').toString();
        if (link.isEmpty) continue;
        final slug = _linkTail(link);
        if (_appPages.containsKey(slug)) {
          _linkedTools[slug] = (
            (d['arabicName'] ?? '').toString(),
            d['isActive'] as bool? ?? true,
          );
        }
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذر التحميل: $e';
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _fs.doc(_docPath).set({
        'sections': {
          for (final (key, _, _) in _sectionFields)
            key: _sections[key]!.text.trim(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'unknown',
      }, SetOptions(merge: true));
      await AuditLogService.log('appContent.save',
          target: 'عناوين أقسام فهرس التطبيق');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم الحفظ — يظهر في التطبيق خلال ثوانٍ'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشل الحفظ: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          Text('محتوى التطبيق',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(
            'جميع صفحات app.nesab.sa (المرجع: index) — بطاقات الفهرس تتبع قسم '
            '«الأدوات» تلقائياً: الاسم والوصف والإخفاء تنعكس خلال ثوانٍ دون نشر.',
            style: TextStyle(fontSize: 13, color: secondaryColor),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
              child:
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
            ),
          const SizedBox(height: AppDimensions.spacingLg),

          // ── عناوين أقسام الفهرس ──
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.title_rounded,
                      color: isDark ? AppColors.blue : AppColors.blue600),
                  const SizedBox(width: 8),
                  Text('عناوين أقسام الفهرس',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                ]),
                const SizedBox(height: AppDimensions.spacingMd),
                for (final (key, label, def) in _sectionFields)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: AppDimensions.spacingMd),
                    child: TextField(
                      controller: _sections[key],
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: label,
                        helperText: 'الأصلي: $def',
                        helperStyle:
                            TextStyle(fontSize: 11, color: secondaryColor),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save_outlined, size: 18),
                    label: const Text('حفظ العناوين'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),

          // ── جدول صفحات التطبيق ──
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const FaIcon(FontAwesomeIcons.mobileScreenButton, size: 16),
                  const SizedBox(width: 8),
                  Text('صفحات التطبيق (${_appPages.length})',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor)),
                ]),
                const SizedBox(height: 4),
                Text(
                  'لتعديل اسم/وصف/إخفاء أي أداة: قسم «الأدوات» — يتحدث الفهرس تلقائياً.',
                  style: TextStyle(fontSize: 12, color: secondaryColor),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                for (final entry in _appPages.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Expanded(
                        flex: 3,
                        child: Text(entry.value,
                            style:
                                TextStyle(fontSize: 13.5, color: textColor)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('app.nesab.sa/${entry.key}',
                            style: TextStyle(
                                fontSize: 12, color: secondaryColor),
                            textDirection: TextDirection.ltr),
                      ),
                      Expanded(
                        flex: 3,
                        child: Builder(builder: (_) {
                          final linked = _linkedTools[entry.key];
                          if (entry.key == 'index') {
                            return Text('المرجع — عناوينه أعلاه',
                                style: TextStyle(
                                    fontSize: 11.5, color: secondaryColor));
                          }
                          if (linked == null) {
                            return Text('غير مرتبطة بأداة',
                                style: TextStyle(
                                    fontSize: 11.5, color: secondaryColor));
                          }
                          return Row(children: [
                            Icon(Icons.link_rounded,
                                size: 13,
                                color: linked.$2
                                    ? AppColors.success
                                    : AppColors.error),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${linked.$1}${linked.$2 ? '' : ' (موقوفة)'}',
                                style: TextStyle(
                                    fontSize: 11.5,
                                    color: linked.$2
                                        ? AppColors.success
                                        : AppColors.error),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]);
                        }),
                      ),
                    ]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
