import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nesab_dashboard/core/services/audit_log_service.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// «الهيدر والصيانة» — إدارة العرض العابر لكل الصفحات دون أي نشر جديد:
///
///  1. الهيدر الإعلاني  → `public_config/header`
///     نص / لون / رابط / جدولة (من–إلى) / استهداف (تطبيق/موقع) / لكل صفحة
///  2. وضع الصيانة      → `public_config/maintenance`
///     رسالة + وقت انتهاء تلقائي + استهداف (تطبيق/موقع)
///
/// تقرأها صفحات التطبيق والموقع عبر `nesab-live.js` بقراءة عامة، وتتصفّر
/// آثارها بالكامل عند الإيقاف (لا مساس بالتصميم القائم).
class DisplaySettingsPage extends StatefulWidget {
  const DisplaySettingsPage({super.key});

  @override
  State<DisplaySettingsPage> createState() => _DisplaySettingsPageState();
}

/// صفحات التطبيق والموقع المتاحة للاستهداف عند اختيار «صفحات محددة».
const Map<String, String> _pageLabels = {
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

/// ألوان جاهزة لخلفية الهيدر.
const List<String> _presetColors = [
  '#7c3aed', '#2563eb', '#059669', '#d97706', '#dc2626', '#0f172a',
];

class _DisplaySettingsPageState extends State<DisplaySettingsPage> {
  final _firestore = FirebaseFirestore.instance;
  static const _headerPath = 'public_config/header';
  static const _maintenancePath = 'public_config/maintenance';

  bool _loading = true;
  String? _error;
  bool _savingHeader = false;
  bool _savingMaintenance = false;

  // ── حالة الهيدر الإعلاني ────────────────────────────────────────────────
  bool _headerEnabled = false;
  final _headerText = TextEditingController();
  final _headerLink = TextEditingController();
  final _headerBgColor = TextEditingController(text: '#7c3aed');
  final _headerTextColor = TextEditingController(text: '#ffffff');
  DateTime? _headerStart;
  DateTime? _headerEnd;
  bool _headerOnApp = true;
  bool _headerOnWeb = true;
  bool _headerDismissible = true;
  bool _headerAllPages = true;
  final Set<String> _headerPages = {};

  // ── حالة وضع الصيانة ────────────────────────────────────────────────────
  bool _maintenanceEnabled = false;
  final _maintenanceMessage = TextEditingController();
  DateTime? _maintenanceEnd;
  bool _maintenanceOnApp = true;
  bool _maintenanceOnWeb = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _headerText.dispose();
    _headerLink.dispose();
    _headerBgColor.dispose();
    _headerTextColor.dispose();
    _maintenanceMessage.dispose();
    super.dispose();
  }

  // ── التحميل والحفظ ──────────────────────────────────────────────────────

  DateTime? _asDate(dynamic value) =>
      value is Timestamp ? value.toDate() : null;

  Future<void> _load() async {
    try {
      final snaps = await Future.wait([
        _firestore.doc(_headerPath).get(),
        _firestore.doc(_maintenancePath).get(),
      ]);

      final h = snaps[0].data();
      if (h != null) {
        _headerEnabled = h['enabled'] == true;
        _headerText.text = h['text']?.toString() ?? '';
        _headerLink.text = h['link']?.toString() ?? '';
        if (h['bgColor'] is String) _headerBgColor.text = h['bgColor'] as String;
        if (h['textColor'] is String) {
          _headerTextColor.text = h['textColor'] as String;
        }
        _headerStart = _asDate(h['startAt']);
        _headerEnd = _asDate(h['endAt']);
        _headerOnApp = h['showOnApp'] != false;
        _headerOnWeb = h['showOnWeb'] != false;
        _headerDismissible = h['dismissible'] != false;
        _headerAllPages = h['allPages'] != false;
        final pages = h['pages'];
        if (pages is List) {
          _headerPages
            ..clear()
            ..addAll(pages.whereType<String>());
        }
      }

      final m = snaps[1].data();
      if (m != null) {
        _maintenanceEnabled = m['enabled'] == true;
        _maintenanceMessage.text = m['message']?.toString() ?? '';
        _maintenanceEnd = _asDate(m['endAt']);
        _maintenanceOnApp = m['showOnApp'] != false;
        _maintenanceOnWeb = m['showOnWeb'] != false;
      }

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل الإعدادات: $e';
      });
    }
  }

  Map<String, dynamic> _auditStamp() => {
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': FirebaseAuth.instance.currentUser?.email ?? 'unknown',
      };

  Future<void> _saveHeader() async {
    final bg = _headerBgColor.text.trim();
    final fg = _headerTextColor.text.trim();
    final hex = RegExp(r'^#[0-9a-fA-F]{6}$');
    if (!hex.hasMatch(bg) || !hex.hasMatch(fg)) {
      _showSnack('صيغة اللون يجب أن تكون #RRGGBB مثل #7c3aed', error: true);
      return;
    }
    if (_headerEnabled && _headerText.text.trim().isEmpty) {
      _showSnack('اكتب نص الهيدر قبل التفعيل', error: true);
      return;
    }

    setState(() => _savingHeader = true);
    try {
      await _firestore.doc(_headerPath).set({
        'enabled': _headerEnabled,
        'text': _headerText.text.trim(),
        'link': _headerLink.text.trim(),
        'bgColor': bg,
        'textColor': fg,
        'startAt':
            _headerStart == null ? null : Timestamp.fromDate(_headerStart!),
        'endAt': _headerEnd == null ? null : Timestamp.fromDate(_headerEnd!),
        'showOnApp': _headerOnApp,
        'showOnWeb': _headerOnWeb,
        'dismissible': _headerDismissible,
        'allPages': _headerAllPages,
        'pages': _headerPages.toList()..sort(),
        ..._auditStamp(),
      });
      await AuditLogService.log('header.save',
          target: _headerEnabled ? 'مفعّل: ${_headerText.text.trim()}' : 'موقوف');
      _showSnack('تم حفظ الهيدر الإعلاني — يظهر في الصفحات خلال ثوانٍ');
    } catch (e) {
      _showSnack('فشل الحفظ: $e', error: true);
    } finally {
      if (mounted) setState(() => _savingHeader = false);
    }
  }

  Future<void> _saveMaintenance() async {
    setState(() => _savingMaintenance = true);
    try {
      await _firestore.doc(_maintenancePath).set({
        'enabled': _maintenanceEnabled,
        'message': _maintenanceMessage.text.trim(),
        'endAt': _maintenanceEnd == null
            ? null
            : Timestamp.fromDate(_maintenanceEnd!),
        'showOnApp': _maintenanceOnApp,
        'showOnWeb': _maintenanceOnWeb,
        ..._auditStamp(),
      });
      await AuditLogService.log('maintenance.save',
          target: _maintenanceEnabled ? 'مفعّل' : 'موقوف');
      _showSnack(_maintenanceEnabled
          ? 'تم تفعيل وضع الصيانة — الصفحات المستهدفة محجوبة الآن'
          : 'تم حفظ إعدادات الصيانة (غير مفعّلة)');
    } catch (e) {
      _showSnack('فشل الحفظ: $e', error: true);
    } finally {
      if (mounted) setState(() => _savingMaintenance = false);
    }
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.error : AppColors.success,
    ));
  }

  Future<void> _pickDateTime({
    required DateTime? current,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current ?? now),
    );
    if (time == null) return;
    onPicked(
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'غير محدد';
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${dt.year}/${two(dt.month)}/${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}';
  }

  Color? _parseHex(String value) {
    final v = value.trim();
    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(v)) return null;
    return Color(int.parse('ff${v.substring(1)}', radix: 16));
  }

  // ── الواجهة ─────────────────────────────────────────────────────────────

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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          Text('الهيدر والصيانة',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 4),
          Text(
            'شريط إعلاني عابر لكل صفحات التطبيق والموقع + وضع صيانة بوقت انتهاء '
            'تلقائي — التغييرات تظهر خلال ثوانٍ دون أي نشر جديد.',
            style: TextStyle(fontSize: 13, color: secondaryColor),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          _buildHeaderCard(isDark, textColor, secondaryColor),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildMaintenanceCard(isDark, textColor, secondaryColor),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
              child:
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
            ),
        ],
      ),
    );
  }

  Widget _card({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dashboardCard : AppColors.lightModeCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
            color:
                isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _dateRow({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
    required Color textColor,
    required Color secondaryColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text('$label: ${_formatDateTime(value)}',
              style: TextStyle(fontSize: 13.5, color: textColor)),
        ),
        TextButton.icon(
          onPressed: () =>
              _pickDateTime(current: value, onPicked: onChanged),
          icon: const Icon(Icons.calendar_month, size: 18),
          label: const Text('تحديد'),
        ),
        if (value != null)
          IconButton(
            tooltip: 'مسح',
            onPressed: () => onChanged(null),
            icon: Icon(Icons.clear, size: 18, color: secondaryColor),
          ),
      ],
    );
  }

  Widget _buildHeaderCard(bool isDark, Color textColor, Color secondaryColor) {
    final bgPreview = _parseHex(_headerBgColor.text);
    final fgPreview = _parseHex(_headerTextColor.text);

    return _card(isDark: isDark, children: [
      Row(children: [
        Icon(Icons.campaign_outlined,
            color: isDark ? AppColors.blue : AppColors.blue600),
        const SizedBox(width: 8),
        Expanded(
          child: Text('الهيدر الإعلاني',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: textColor)),
        ),
        Switch(
          value: _headerEnabled,
          onChanged: (v) => setState(() => _headerEnabled = v),
        ),
      ]),
      const SizedBox(height: AppDimensions.spacingMd),

      // معاينة حية للشريط
      if (bgPreview != null && _headerText.text.trim().isNotEmpty)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: bgPreview,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _headerText.text.trim(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: fgPreview ?? Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              decoration: _headerLink.text.trim().isEmpty
                  ? TextDecoration.none
                  : TextDecoration.underline,
            ),
          ),
        ),

      TextField(
        controller: _headerText,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: textColor, fontSize: 14),
        decoration: const InputDecoration(
          labelText: 'نص الشريط',
          hintText: 'مثال: خصم 20٪ على الباقة السنوية حتى نهاية الشهر 🎉',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: AppDimensions.spacingMd),
      TextField(
        controller: _headerLink,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: textColor, fontSize: 14),
        decoration: const InputDecoration(
          labelText: 'الرابط عند الضغط (اختياري)',
          hintText: 'https://...',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: AppDimensions.spacingMd),

      Row(children: [
        Expanded(
          child: TextField(
            controller: _headerBgColor,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'لون الخلفية',
              hintText: '#7c3aed',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: TextField(
            controller: _headerTextColor,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: textColor, fontSize: 14),
            decoration: const InputDecoration(
              labelText: 'لون النص',
              hintText: '#ffffff',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ]),
      const SizedBox(height: AppDimensions.spacingSm),
      Wrap(
        spacing: 8,
        children: [
          for (final hex in _presetColors)
            InkWell(
              onTap: () => setState(() => _headerBgColor.text = hex),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _parseHex(hex),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: _headerBgColor.text.trim() == hex
                          ? textColor
                          : Colors.transparent,
                      width: 2),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: AppDimensions.spacingMd),

      _dateRow(
        label: 'يبدأ',
        value: _headerStart,
        onChanged: (v) => setState(() => _headerStart = v),
        textColor: textColor,
        secondaryColor: secondaryColor,
      ),
      _dateRow(
        label: 'ينتهي',
        value: _headerEnd,
        onChanged: (v) => setState(() => _headerEnd = v),
        textColor: textColor,
        secondaryColor: secondaryColor,
      ),
      const Divider(height: AppDimensions.spacingLg),

      Wrap(
        spacing: AppDimensions.spacingLg,
        runSpacing: 4,
        children: [
          _labeledSwitch('يظهر في التطبيق', _headerOnApp,
              (v) => setState(() => _headerOnApp = v), textColor),
          _labeledSwitch('يظهر في الموقع', _headerOnWeb,
              (v) => setState(() => _headerOnWeb = v), textColor),
          _labeledSwitch('يمكن للزائر إغلاقه', _headerDismissible,
              (v) => setState(() => _headerDismissible = v), textColor),
          _labeledSwitch('كل الصفحات', _headerAllPages,
              (v) => setState(() => _headerAllPages = v), textColor),
        ],
      ),

      if (!_headerAllPages) ...[
        const SizedBox(height: AppDimensions.spacingSm),
        Text('اختر الصفحات المستهدفة:',
            style: TextStyle(fontSize: 13, color: secondaryColor)),
        const SizedBox(height: AppDimensions.spacingSm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in _pageLabels.entries)
              FilterChip(
                label: Text(entry.value,
                    style: const TextStyle(fontSize: 12)),
                selected: _headerPages.contains(entry.key),
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _headerPages.add(entry.key);
                  } else {
                    _headerPages.remove(entry.key);
                  }
                }),
              ),
          ],
        ),
      ],

      const SizedBox(height: AppDimensions.spacingMd),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          onPressed: _savingHeader ? null : _saveHeader,
          icon: _savingHeader
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save_outlined, size: 18),
          label: const Text('حفظ الهيدر'),
        ),
      ),
    ]);
  }

  Widget _buildMaintenanceCard(
      bool isDark, Color textColor, Color secondaryColor) {
    return _card(isDark: isDark, children: [
      Row(children: [
        Icon(Icons.build_circle_outlined,
            color: _maintenanceEnabled ? AppColors.error : AppColors.warning),
        const SizedBox(width: 8),
        Expanded(
          child: Text('وضع الصيانة',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: textColor)),
        ),
        Switch(
          value: _maintenanceEnabled,
          activeTrackColor: AppColors.error,
          onChanged: (v) => setState(() => _maintenanceEnabled = v),
        ),
      ]),
      if (_maintenanceEnabled)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: AppDimensions.spacingSm),
          padding: const EdgeInsets.all(AppDimensions.spacingSm),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '⚠️ عند الحفظ ستُحجب الصفحات المستهدفة عن الزوار فوراً حتى '
            'الإيقاف أو انتهاء الوقت المحدد.',
            style: TextStyle(fontSize: 12.5, color: AppColors.error),
          ),
        ),
      const SizedBox(height: AppDimensions.spacingMd),
      TextField(
        controller: _maintenanceMessage,
        maxLines: 3,
        style: TextStyle(color: textColor, fontSize: 14),
        decoration: const InputDecoration(
          labelText: 'رسالة الصيانة',
          hintText: 'نعمل حالياً على تحسين الخدمة — نعود إليكم قريباً بإذن الله.',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: AppDimensions.spacingMd),
      _dateRow(
        label: 'تنتهي تلقائياً',
        value: _maintenanceEnd,
        onChanged: (v) => setState(() => _maintenanceEnd = v),
        textColor: textColor,
        secondaryColor: secondaryColor,
      ),
      const Divider(height: AppDimensions.spacingLg),
      Wrap(
        spacing: AppDimensions.spacingLg,
        runSpacing: 4,
        children: [
          _labeledSwitch('تشمل التطبيق', _maintenanceOnApp,
              (v) => setState(() => _maintenanceOnApp = v), textColor),
          _labeledSwitch('تشمل الموقع', _maintenanceOnWeb,
              (v) => setState(() => _maintenanceOnWeb = v), textColor),
        ],
      ),
      const SizedBox(height: AppDimensions.spacingMd),
      Align(
        alignment: Alignment.centerLeft,
        child: FilledButton.icon(
          style: _maintenanceEnabled
              ? FilledButton.styleFrom(backgroundColor: AppColors.error)
              : null,
          onPressed: _savingMaintenance ? null : _saveMaintenance,
          icon: _savingMaintenance
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save_outlined, size: 18),
          label: Text(_maintenanceEnabled
              ? 'حفظ وتفعيل الصيانة'
              : 'حفظ إعدادات الصيانة'),
        ),
      ),
    ]);
  }

  Widget _labeledSwitch(
      String label, bool value, ValueChanged<bool> onChanged, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: value, onChanged: onChanged),
        Text(label, style: TextStyle(fontSize: 13.5, color: textColor)),
      ],
    );
  }
}
