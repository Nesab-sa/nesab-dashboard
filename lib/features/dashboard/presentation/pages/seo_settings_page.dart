import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nesab_dashboard/core/services/audit_log_service.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// «إدارة SEO» — تحكم بعنوان الصفحة وMeta Description وKeywords
/// لكل صفحة من صفحات التطبيق والموقع دون تعديل أي كود.
///
/// يُخزَّن في `public_config/seo` بالشكل:
///   pages: { "<slug>": { title, description, keywords } }
/// ويطبّقه `nesab-live.js` على الصفحة المطابقة فور التحميل.
/// الحقل الفارغ = تبقى قيمة الصفحة الأصلية المدمجة.
class SeoSettingsPage extends StatefulWidget {
  const SeoSettingsPage({super.key});

  @override
  State<SeoSettingsPage> createState() => _SeoSettingsPageState();
}

/// الصفحات المتاحة (نفس قائمة nesab-live.js: التطبيق + الموقع).
const Map<String, String> _seoPages = {
  'index': 'الصفحة الرئيسية (التطبيق والموقع)',
  'shakhsi-mukhtasar': 'الشخصي المختصر',
  'shakhsi-plus': 'الشخصي Plus',
  'aqari-aadi': 'العقاري العادي',
  'aqari-plus': 'العقاري Plus',
  'tajiri-aadi': 'التأجيري العادي',
  'tajiri-makro': 'التأجيري ماكرو',
  'niqat-albay': 'تمويل نقاط البيع',
  'khayrat': 'خيرات الادخاري',
  'himaya-iddikhar': 'الحماية والادخار',
  'asham-saudia': 'الأسهم السعودية',
  'shira-madyoniya': 'شراء المديونية',
  'nisbat-alistiqtaa': 'نسبة الاستقطاع',
  'istiqtaa-naam-la': 'الاستقطاع نعم/لا',
  'hasibat-alumr': 'حاسبة العمر',
  'tahwil-altarikh': 'تحويل التاريخ',
  'tahwil-alumla': 'تحويل العملة',
  'alrusum-albankiya': 'الرسوم البنكية',
  'hawawem-arbach': 'هوامش الأرباح',
  'bank-margins': 'هوامش الربح الجديدة',
  'margins-compare': 'مقارنة هوامش الربح',
  'disclaimer': 'إخلاء المسؤولية',
  'privacy': 'سياسة الخصوصية (الموقع)',
  'terms': 'الشروط والأحكام (الموقع)',
};

class _SeoSettingsPageState extends State<SeoSettingsPage> {
  final _firestore = FirebaseFirestore.instance;
  static const _docPath = 'public_config/seo';

  bool _loading = true;
  bool _saving = false;
  String? _error;

  /// كل بيانات SEO المحفوظة: slug → {title, description, keywords}
  final Map<String, Map<String, String>> _pages = {};

  String _selectedSlug = 'index';
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _keywordsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _keywordsCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final doc = await _firestore.doc(_docPath).get();
      final pages = doc.data()?['pages'];
      if (pages is Map<String, dynamic>) {
        for (final entry in pages.entries) {
          final v = entry.value;
          if (v is Map<String, dynamic>) {
            _pages[entry.key] = {
              'title': v['title']?.toString() ?? '',
              'description': v['description']?.toString() ?? '',
              'keywords': v['keywords']?.toString() ?? '',
            };
          }
        }
      }
      _fillFields(_selectedSlug);
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل إعدادات SEO: $e';
      });
    }
  }

  void _fillFields(String slug) {
    final p = _pages[slug];
    _titleCtrl.text = p?['title'] ?? '';
    _descriptionCtrl.text = p?['description'] ?? '';
    _keywordsCtrl.text = p?['keywords'] ?? '';
  }

  bool get _selectedHasData {
    final p = _pages[_selectedSlug];
    return p != null && p.values.any((v) => v.trim().isNotEmpty);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final page = {
        'title': _titleCtrl.text.trim(),
        'description': _descriptionCtrl.text.trim(),
        'keywords': _keywordsCtrl.text.trim(),
      };
      _pages[_selectedSlug] = page;
      await _firestore.doc(_docPath).set({
        'pages': {_selectedSlug: page},
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'unknown',
      }, SetOptions(mergeFields: [
        'pages.$_selectedSlug',
        'updatedAt',
        'updatedBy',
      ]));
      await AuditLogService.log('seo.save',
          target: _seoPages[_selectedSlug] ?? _selectedSlug);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'تم حفظ SEO لصفحة «${_seoPages[_selectedSlug]}» — يُطبق فوراً'),
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

  Future<void> _clearPage() async {
    setState(() => _saving = true);
    try {
      _pages.remove(_selectedSlug);
      await _firestore.doc(_docPath).update({
        'pages.$_selectedSlug': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'unknown',
      });
      await AuditLogService.log('seo.clear',
          target: _seoPages[_selectedSlug] ?? _selectedSlug);
      _fillFields(_selectedSlug);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'أُزيل تخصيص «${_seoPages[_selectedSlug]}» — تعود القيم الأصلية'),
          backgroundColor: AppColors.success,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشل الحذف: $e'),
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

    final customized = _seoPages.keys
        .where((slug) =>
            _pages[slug] != null &&
            _pages[slug]!.values.any((v) => v.trim().isNotEmpty))
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          Text('إدارة SEO',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(
            'عنوان الصفحة + الوصف + الكلمات المفتاحية لكل صفحة — دون تعديل كود، '
            'ويُطبق خلال ثوانٍ. الحقل الفارغ يُبقي قيمة الصفحة الأصلية.',
            style: TextStyle(fontSize: 13, color: secondaryColor),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
              child:
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
            ),
          const SizedBox(height: AppDimensions.spacingLg),
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
                DropdownButtonFormField<String>(
                  initialValue: _selectedSlug,
                  decoration: const InputDecoration(
                    labelText: 'الصفحة',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final e in _seoPages.entries)
                      DropdownMenuItem(
                        value: e.key,
                        child: Text(
                          customized.contains(e.key)
                              ? '● ${e.value}'
                              : e.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                  onChanged: (slug) {
                    if (slug == null) return;
                    setState(() {
                      _selectedSlug = slug;
                      _fillFields(slug);
                    });
                  },
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                TextField(
                  controller: _titleCtrl,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'عنوان الصفحة (Title)',
                    hintText: 'مثال: نِسَب — حاسبة التمويل الشخصي الأدق في السعودية',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                TextField(
                  controller: _descriptionCtrl,
                  maxLines: 3,
                  maxLength: 170,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'الوصف (Meta Description)',
                    hintText: 'وصف يظهر في نتائج البحث — يُفضّل 150-160 حرفاً',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                TextField(
                  controller: _keywordsCtrl,
                  style: TextStyle(color: textColor, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'الكلمات المفتاحية (Keywords)',
                    hintText: 'حاسبة تمويل, قرض شخصي, نسبة استقطاع (مفصولة بفواصل)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_selectedHasData)
                      TextButton.icon(
                        onPressed: _saving ? null : _clearPage,
                        icon: const Icon(Icons.restore, size: 18),
                        label: const Text('إزالة التخصيص'),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.error),
                      ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save_outlined, size: 18),
                      label: const Text('حفظ'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          if (customized.isNotEmpty) ...[
            Text('صفحات مخصصة (${customized.length}):',
                style: TextStyle(fontSize: 13, color: secondaryColor)),
            const SizedBox(height: AppDimensions.spacingSm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slug in customized)
                  ActionChip(
                    label: Text(_seoPages[slug] ?? slug,
                        style: const TextStyle(fontSize: 12)),
                    avatar: const Icon(Icons.check_circle,
                        size: 15, color: AppColors.success),
                    onPressed: () => setState(() {
                      _selectedSlug = slug;
                      _fillFields(slug);
                    }),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
