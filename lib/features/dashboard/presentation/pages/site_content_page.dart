import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nesab_dashboard/core/services/audit_log_service.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// «محتوى الموقع» — تحرير نصوص الصفحة الرئيسية للموقع الرسمي nesab.sa
/// مباشرةً من الداشبورد دون أي نشر جديد.
///
/// يُخزَّن المحتوى في مستند `site_content/landing` كخرائط متداخلة
/// (hero / about / features / products / reviews / vision / demo)،
/// ويقرؤه الموقع عبر `js/live-content.js` بقراءة عامة.
/// الحقل الفارغ = يعود النص الأصلي المدمج في الموقع تلقائياً.
class SiteContentPage extends StatefulWidget {
  const SiteContentPage({super.key});

  @override
  State<SiteContentPage> createState() => _SiteContentPageState();
}

/// وصف حقل واحد قابل للتحرير.
class _FieldSpec {
  const _FieldSpec(this.key, this.label, this.defaultValue,
      {this.multiline = false});

  final String key;
  final String label;
  final String defaultValue;
  final bool multiline;
}

/// وصف قسم من أقسام الصفحة الرئيسية.
class _SectionSpec {
  const _SectionSpec(this.key, this.title, this.icon, this.fields);

  final String key;
  final String title;
  final IconData icon;
  final List<_FieldSpec> fields;
}

const List<_SectionSpec> _sections = [
  _SectionSpec('hero', 'الواجهة الرئيسية (Hero)', Icons.rocket_launch_outlined, [
    _FieldSpec('eyebrow', 'السطر العلوي', 'Download the App حمل التطبيق الان'),
    _FieldSpec('titlePre', 'العنوان — قبل اسم العلامة', 'نقدم لكم '),
    _FieldSpec('titleBrand', 'العنوان — اسم العلامة (بالأبيض)', 'NESAB'),
    _FieldSpec('titlePost', 'العنوان — بعد اسم العلامة',
        ' حليفك الذكي لخدمة عملائك'),
    _FieldSpec(
      'lead',
      'الفقرة التعريفية',
      '"نِسَب" ليس مجرد تطبيق حسابي، بل هو شريكك في الميدان. صُمم بذكاء ليمنحك الدقة المتناهية في ثوانٍ معدودة، مما يتيح لك خدمة عملائك بلمسة احترافية وثقة كاملة، وفي كل الأوقات. تميز عن غيرك بامتلاك الأداة الأسرع. مع "نِسَب"، نختصر عليك التعقيد ونمنحك السهولة في الوصول للنتائج الدقيقة، لتتفرغ لما هو أهم: بناء علاقة متينة مع عملائك وتقديم خدمة تليق بهم.',
      multiline: true,
    ),
    _FieldSpec('btnPrimary', 'نص الزر الأساسي', 'أفضل مميزات التطبيق'),
    _FieldSpec('btnSecondary', 'نص الزر الثانوي', 'آراء المستخدمين'),
  ]),
  _SectionSpec('about', 'عن التطبيق', Icons.info_outline, [
    _FieldSpec('kicker', 'العنوان التمهيدي', 'أفضل مميزات التطبيق'),
    _FieldSpec('heading', 'العنوان الرئيسي',
        'واجهة ذكية، نتائج فورية، ودقة حسابية'),
    _FieldSpec(
      'lead',
      'الفقرة التعريفية',
      'صُمم التطبيق خصيصاً ليناسب طبيعة عملك السريعة والميدانية في البنك، ويمنحك سهولة الوصول إلى النتائج الدقيقة في ثوانٍ.',
      multiline: true,
    ),
    _FieldSpec('point1Title', 'النقطة 1 — العنوان', 'واجهة ذكية'),
    _FieldSpec(
        'point1Body',
        'النقطة 1 — النص',
        'تصميم بسيط وسهل صُمم خصيصاً ليناسب طبيعة عملك السريعة والميدانية في البنك.',
        multiline: true),
    _FieldSpec('point2Title', 'النقطة 2 — العنوان', 'نتائج فورية'),
    _FieldSpec(
        'point2Body',
        'النقطة 2 — النص',
        'اختصر وقتك وجهدك واحصل على النتائج في ثوانٍ، لتركز أكثر على احتياجات عميلك.',
        multiline: true),
    _FieldSpec('point3Title', 'النقطة 3 — العنوان', 'الدقة الحسابية'),
    _FieldSpec(
        'point3Body',
        'النقطة 3 — النص',
        'حسابات بنكية دقيقة تضمن لك ولعميلك الموثوقية التامة وتتجنب الأخطاء البشرية.',
        multiline: true),
  ]),
  _SectionSpec('features', 'المميزات', Icons.star_outline, [
    _FieldSpec('kicker', 'العنوان التمهيدي', 'أفضل مميزات التطبيق'),
    _FieldSpec(
        'heading',
        'العنوان الرئيسي',
        'الأداة الأفضل لكل موظف بنك يبحث عن الاحترافية والتميز في خدمة العملاء',
        multiline: true),
    _FieldSpec('subtitle', 'العنوان الفرعي', 'السرعة والدقة في تطبيق واحد.'),
    _FieldSpec('card1Title', 'البطاقة 1 — العنوان', 'واجهة ذكية'),
    _FieldSpec(
        'card1Body',
        'البطاقة 1 — النص',
        'تصميم بسيط وسهل صُمم خصيصاً ليناسب طبيعة عملك السريعة والميدانية في البنك.',
        multiline: true),
    _FieldSpec('card2Title', 'البطاقة 2 — العنوان', 'نتائج فورية'),
    _FieldSpec(
        'card2Body',
        'البطاقة 2 — النص',
        'اختصر وقتك وجهدك واحصل على النتائج في ثوانٍ، لتركز أكثر على احتياجات عميلك.',
        multiline: true),
    _FieldSpec('card3Title', 'البطاقة 3 — العنوان', 'الدقة الحسابية'),
    _FieldSpec(
        'card3Body',
        'البطاقة 3 — النص',
        'حسابات بنكية دقيقة تضمن لك ولعميلك الموثوقية التامة وتتجنب الأخطاء البشرية.',
        multiline: true),
  ]),
  _SectionSpec('products', 'الأدوات المالية', Icons.grid_view_outlined, [
    _FieldSpec('heading', 'العنوان الرئيسي', 'جميع الأدوات المالية'),
    _FieldSpec('subtitle', 'العنوان الفرعي',
        'اختر الأداة المناسبة من الأقسام التالية'),
    _FieldSpec('cat1', 'قسم 1', 'التمويل الشخصي'),
    _FieldSpec('cat2', 'قسم 2', 'التمويل العقاري'),
    _FieldSpec('cat3', 'قسم 3', 'التمويل التأجيري'),
    _FieldSpec('cat4', 'قسم 4', 'تمويل نقاط البيع'),
    _FieldSpec('cat5', 'قسم 5', 'خيرات الادخاري'),
    _FieldSpec('cat6', 'قسم 6', 'برنامج الحماية والادخار'),
  ]),
  _SectionSpec('reviews', 'آراء المستخدمين', Icons.reviews_outlined, [
    _FieldSpec('kicker', 'العنوان التمهيدي', 'آراء المستخدمين'),
    _FieldSpec('heading', 'العنوان الرئيسي', 'آراء المستخدمين'),
    _FieldSpec(
        'rev1Text',
        'الرأي 1 — النص',
        '"تطبيق نِسَب غيّر طريقتي في التعامل مع العميل، صرت أقدر أعطي أرقام دقيقة في ثوانٍ وسط الفرع بدون ما أحتاج أرجع للمكتب وخارج اوقات العمل"',
        multiline: true),
    _FieldSpec('rev1Author', 'الرأي 1 — الصفة', 'موظف مبيعات'),
    _FieldSpec(
        'rev2Text',
        'الرأي 2 — النص',
        '"الأداة الأفضل لكل موظف بنك يبحث عن الاحترافية والتميز في خدمة العملاء. السرعة والدقة في تطبيق واحد"',
        multiline: true),
    _FieldSpec('rev2Author', 'الرأي 2 — الصفة', 'مدير علاقة'),
    _FieldSpec(
        'rev3Text',
        'الرأي 3 — النص',
        '"وفر عليّ الكثير من الوقت في حساب النسب والاستقطاعات المعقدة. تطبيق بسيط وعملي جداً."',
        multiline: true),
    _FieldSpec('rev3Author', 'الرأي 3 — الصفة', 'مستشار تمويل / عقاري'),
  ]),
  _SectionSpec('vision', 'رؤية نِسَب', Icons.visibility_outlined, [
    _FieldSpec('kicker', 'العنوان التمهيدي', 'رؤية نِسَب'),
    _FieldSpec('heading', 'العنوان الرئيسي', 'رؤية نِسَب للحلول التقنية'),
    _FieldSpec(
      'lead',
      'الفقرة التعريفية',
      'ولدت فكرة "نِسَب" من قلب الميدان المصرفي، لنكون الذراع التقني الذي يسند الموظف في أدق تفاصيل عمله. نحن لا نقدم مجرد أرقام، بل نقدم السرعة التي تمنحك التميز، والدقة التي تمنحك الثقة أمام عميلك. هدفنا هو تحويل العمليات الحسابية المعقدة إلى لمسة واحدة بسيطة، لنتيح لك التركيز على بناء علاقات مستدامة مع عملائك.',
      multiline: true,
    ),
    _FieldSpec('card1Title', 'البطاقة 1 — العنوان', 'السرعة التي تمنحك التميز'),
    _FieldSpec(
        'card1Body',
        'البطاقة 1 — النص',
        'نحوّل العمليات الحسابية المعقدة إلى لمسة واحدة بسيطة تدعم أداءك داخل الميدان.',
        multiline: true),
    _FieldSpec('card2Title', 'البطاقة 2 — العنوان', 'الدقة التي تمنحك الثقة'),
    _FieldSpec(
        'card2Body',
        'البطاقة 2 — النص',
        'نسند الموظف في أدق تفاصيل عمله ليقدم أرقاماً موثوقة أمام العميل بثبات واحترافية.',
        multiline: true),
    _FieldSpec('card3Title', 'البطاقة 3 — العنوان', 'علاقات مستدامة مع العملاء'),
    _FieldSpec(
        'card3Body',
        'البطاقة 3 — النص',
        'نمنحك مساحة أكبر للتركيز على الخدمة وبناء علاقة متينة ومستدامة مع عملائك.',
        multiline: true),
  ]),
  _SectionSpec('demo', 'العرض التجريبي', Icons.play_circle_outline, [
    _FieldSpec('heading', 'عنوان القسم',
        'شاهد التجربة داخل نِسَب كما تظهر للمستخدم.'),
  ]),
];

class _SiteContentPageState extends State<SiteContentPage> {
  final _firestore = FirebaseFirestore.instance;
  static const _docPath = 'site_content/landing';

  final Map<String, TextEditingController> _controllers = {};
  bool _loading = true;
  String? _error;
  final Set<String> _savingSections = {};

  @override
  void initState() {
    super.initState();
    for (final section in _sections) {
      for (final field in section.fields) {
        _controllers['${section.key}.${field.key}'] =
            TextEditingController(text: field.defaultValue);
      }
    }
    _load();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final doc = await _firestore.doc(_docPath).get();
      final data = doc.data();
      if (data != null) {
        for (final section in _sections) {
          final sectionMap = data[section.key];
          if (sectionMap is Map<String, dynamic>) {
            for (final field in section.fields) {
              final value = sectionMap[field.key];
              if (value is String && value.trim().isNotEmpty) {
                _controllers['${section.key}.${field.key}']!.text = value;
              }
            }
          }
        }
      }
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل المحتوى: $e';
      });
    }
  }

  Future<void> _saveSection(_SectionSpec section) async {
    setState(() => _savingSections.add(section.key));
    try {
      final Map<String, dynamic> sectionMap = {};
      for (final field in section.fields) {
        sectionMap[field.key] =
            _controllers['${section.key}.${field.key}']!.text.trim();
      }
      await _firestore.doc(_docPath).set({
        section.key: sectionMap,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'unknown',
      }, SetOptions(merge: true));
      await AuditLogService.log('siteContent.save', target: section.title);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ قسم «${section.title}» — سيظهر في الموقع فوراً'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الحفظ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingSections.remove(section.key));
    }
  }

  Future<void> _saveAll() async {
    for (final section in _sections) {
      await _saveSection(section);
    }
  }

  void _resetSection(_SectionSpec section) {
    setState(() {
      for (final field in section.fields) {
        _controllers['${section.key}.${field.key}']!.text = field.defaultValue;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'أُعيد قسم «${section.title}» للنص الأصلي — اضغط حفظ لاعتماده'),
      ),
    );
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

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'محتوى الموقع الرسمي',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تحرير نصوص الصفحة الرئيسية nesab.sa — أي حفظ يظهر في الموقع فوراً دون نشر جديد. الحقل الفارغ يعيد النص الأصلي.',
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              FilledButton.icon(
                onPressed:
                    _savingSections.isEmpty ? _saveAll : null,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('حفظ الكل'),
              ),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
              child: Text(_error!,
                  style: const TextStyle(color: AppColors.error)),
            ),
          const SizedBox(height: AppDimensions.spacingLg),
          for (final section in _sections)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.spacingMd),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: borderColor),
                ),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Icon(section.icon,
                        color: isDark ? AppColors.blue : AppColors.blue600),
                    title: Text(
                      section.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    childrenPadding:
                        const EdgeInsets.all(AppDimensions.spacingMd),
                    children: [
                      for (final field in section.fields)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.spacingMd),
                          child: TextField(
                            controller: _controllers[
                                '${section.key}.${field.key}'],
                            maxLines: field.multiline ? 4 : 1,
                            style:
                                TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: field.label,
                              labelStyle: TextStyle(
                                  color: secondaryColor, fontSize: 13),
                              helperText: field.defaultValue.length > 60
                                  ? null
                                  : 'الأصلي: ${field.defaultValue}',
                              helperStyle: TextStyle(
                                  color: secondaryColor, fontSize: 11),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd),
                              ),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _resetSection(section),
                            icon: const Icon(Icons.restore, size: 18),
                            label: const Text('النص الأصلي'),
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          FilledButton.icon(
                            onPressed: _savingSections.contains(section.key)
                                ? null
                                : () => _saveSection(section),
                            icon: _savingSections.contains(section.key)
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.save_outlined, size: 18),
                            label: const Text('حفظ القسم'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
