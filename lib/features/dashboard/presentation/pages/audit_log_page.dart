import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// «سجل العمليات» (Audit Log) — من فعل ماذا ومتى.
///
/// يقرأ مجموعة `audit_log` (إنشاء فقط — لا تعديل ولا حذف بموجب القواعد)،
/// مع فلترة بنوع العملية وبحث نصي بالمنفّذ/الهدف.
class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditEntry {
  const _AuditEntry({
    required this.action,
    required this.target,
    required this.admin,
    required this.at,
    required this.details,
  });

  final String action;
  final String target;
  final String admin;
  final DateTime? at;
  final Map<String, dynamic> details;

  factory _AuditEntry.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return _AuditEntry(
      action: d['action']?.toString() ?? '',
      target: d['target']?.toString() ?? '',
      admin: d['admin']?.toString() ?? '',
      at: d['at'] is Timestamp ? (d['at'] as Timestamp).toDate() : null,
      details: d['details'] is Map<String, dynamic>
          ? d['details'] as Map<String, dynamic>
          : const {},
    );
  }
}

/// تعريب الأفعال + ألوانها في السجل.
const Map<String, (String, Color)> _actionMeta = {
  'siteContent.save': ('حفظ محتوى الموقع', AppColors.blue),
  'header.save': ('حفظ الهيدر الإعلاني', AppColors.blue),
  'maintenance.save': ('حفظ وضع الصيانة', AppColors.warning),
  'seo.save': ('حفظ SEO', AppColors.blue),
  'seo.clear': ('إزالة تخصيص SEO', AppColors.warning),
  'notification.send': ('إرسال إشعار', AppColors.success),
  'notification.schedule': ('جدولة إشعار', AppColors.warning),
  'notification.cancelSchedule': ('إلغاء جدولة إشعار', AppColors.warning),
  'notification.cancelActive': ('إيقاف إشعار نشط', AppColors.warning),
  'notification.delete': ('حذف إشعار', AppColors.error),
  'user.ban': ('حظر مستخدم', AppColors.error),
  'user.unban': ('فك حظر مستخدم', AppColors.success),
  'user.delete': ('حذف مستخدم', AppColors.error),
  'users.export': ('تصدير المستخدمين', AppColors.blue),
  'tool.save': ('حفظ أداة', AppColors.blue),
  'tool.delete': ('حذف أداة', AppColors.error),
  'appContent.save': ('حفظ محتوى التطبيق', AppColors.blue),
  'aiSettings.save': ('حفظ إعدادات الذكاء الاصطناعي', AppColors.blue),
  'aiSettings.apiKey': ('تحديث مفتاح AI', AppColors.warning),
  'conversations.permissions': ('تعديل صلاحيات المحادثات', AppColors.warning),
  'package.create': ('إنشاء باقة', AppColors.success),
  'package.update': ('تعديل باقة', AppColors.blue),
  'package.delete': ('حذف باقة', AppColors.error),
};

class _AuditLogPageState extends State<AuditLogPage> {
  final _fs = FirebaseFirestore.instance;

  bool _loading = true;
  String? _error;
  List<_AuditEntry> _entries = [];
  String _actionFilter = '';
  String _search = '';

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
      final snap = await _fs
          .collection('audit_log')
          .orderBy('at', descending: true)
          .limit(200)
          .get();
      setState(() {
        _entries = snap.docs.map(_AuditEntry.fromDoc).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل السجل: $e';
      });
    }
  }

  List<_AuditEntry> get _filtered => _entries.where((e) {
        if (_actionFilter.isNotEmpty && e.action != _actionFilter) {
          return false;
        }
        if (_search.isNotEmpty) {
          final q = _search.toLowerCase();
          return e.admin.toLowerCase().contains(q) ||
              e.target.toLowerCase().contains(q);
        }
        return true;
      }).toList();

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

    final list = _filtered;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const FaIcon(FontAwesomeIcons.clipboardList, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('سجل العمليات',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    Text(
                      'كل تعديل من الداشبورد: من فعله، ماذا غيّر، ومتى — سجل غير قابل للتعديل أو الحذف.',
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'تحديث',
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ]),
            const SizedBox(height: AppDimensions.spacingMd),

            // ── الفلاتر ──
            Row(children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'بحث بالمنفّذ أو الهدف...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _search = v.trim()),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _actionFilter,
                  decoration: const InputDecoration(
                    labelText: 'نوع العملية',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: '', child: Text('كل العمليات')),
                    for (final e in _actionMeta.entries)
                      DropdownMenuItem(
                          value: e.key, child: Text(e.value.$1)),
                  ],
                  onChanged: (v) =>
                      setState(() => _actionFilter = v ?? ''),
                ),
              ),
            ]),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
                child: Text(_error!,
                    style: const TextStyle(color: AppColors.error)),
              ),
            const SizedBox(height: AppDimensions.spacingMd),

            // ── القائمة ──
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        _entries.isEmpty
                            ? 'لا عمليات مسجلة بعد — يبدأ التسجيل من أول تعديل عبر الداشبورد.'
                            : 'لا نتائج مطابقة للفلتر.',
                        style:
                            TextStyle(fontSize: 13.5, color: secondaryColor),
                      ),
                    )
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppDimensions.spacingSm),
                      itemBuilder: (ctx, i) {
                        final e = list[i];
                        final meta = _actionMeta[e.action] ??
                            (e.action, AppColors.blue);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusSm),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: meta.$2.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(meta.$1,
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      color: meta.$2,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: AppDimensions.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (e.target.isNotEmpty)
                                    Text(e.target,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: textColor),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  Text(e.admin,
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: secondaryColor)),
                                ],
                              ),
                            ),
                            Text(
                              e.at != null
                                  ? DateFormat('yyyy/MM/dd  HH:mm')
                                      .format(e.at!)
                                  : '—',
                              style: TextStyle(
                                  fontSize: 11.5, color: secondaryColor),
                            ),
                          ]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
