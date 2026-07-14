import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:nesab_dashboard/core/services/audit_log_service.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class _NotificationMsg {
  final String id;
  final String title;
  final String message;
  final bool isMandatory;
  final String mandatoryText;
  final String attachmentUrl;
  final bool isActive;
  final DateTime? createdAt;

  // ── الاستهداف والجدولة ──
  // targetType: all | user | group — تقرؤها Cloud Function عند الإرسال.
  final String targetType;
  final String targetGroup;
  final List<String> targetUserIds;
  final String targetLabel; // وصف للعرض في السجل
  final DateTime? scheduledAt;
  final String pushStatus; // '' | scheduled | sent | cancelled

  const _NotificationMsg({
    required this.id,
    required this.title,
    required this.message,
    this.isMandatory = false,
    this.mandatoryText = '',
    this.attachmentUrl = '',
    this.isActive = true,
    this.createdAt,
    this.targetType = 'all',
    this.targetGroup = '',
    this.targetUserIds = const [],
    this.targetLabel = '',
    this.scheduledAt,
    this.pushStatus = '',
  });

  bool get isScheduled => pushStatus == 'scheduled';

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'message': message,
        'isMandatory': isMandatory,
        'mandatoryText': mandatoryText,
        'attachmentUrl': attachmentUrl,
        'isActive': isActive,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
        'targetType': targetType,
        'targetGroup': targetGroup,
        'targetUserIds': targetUserIds,
        'targetLabel': targetLabel,
        'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
        if (pushStatus.isNotEmpty) 'pushStatus': pushStatus,
      };

  factory _NotificationMsg.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return _NotificationMsg(
      id: doc.id,
      title: d['title']?.toString() ?? '',
      message: d['message']?.toString() ?? '',
      isMandatory: d['isMandatory'] as bool? ?? false,
      mandatoryText: d['mandatoryText']?.toString() ?? '',
      attachmentUrl: d['attachmentUrl']?.toString() ?? '',
      isActive: d['isActive'] as bool? ?? true,
      createdAt: d['createdAt'] is Timestamp ? (d['createdAt'] as Timestamp).toDate() : null,
      targetType: d['targetType']?.toString() ?? 'all',
      targetGroup: d['targetGroup']?.toString() ?? '',
      targetUserIds: (d['targetUserIds'] is List)
          ? (d['targetUserIds'] as List).whereType<String>().toList()
          : const [],
      targetLabel: d['targetLabel']?.toString() ?? '',
      scheduledAt: d['scheduledAt'] is Timestamp ? (d['scheduledAt'] as Timestamp).toDate() : null,
      pushStatus: d['pushStatus']?.toString() ?? '',
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _fs = FirebaseFirestore.instance;
  static const _collection = 'app_notifications';

  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _mandatoryTextCtrl = TextEditingController();
  final _attachmentCtrl = TextEditingController();

  bool _isMandatory = false;
  bool _sending = false;

  // ── الاستهداف ──
  String _targetType = 'all'; // all | user | group
  String _targetGroup = 'google';
  final Map<String, String> _selectedUsers = {}; // uid → email
  static const Map<String, String> _groupLabels = {
    'google': 'مستخدمو Google',
    'apple': 'مستخدمو Apple',
    'email': 'مستخدمو البريد الإلكتروني',
  };

  // ── الجدولة ──
  bool _isScheduled = false;
  DateTime? _scheduledAt;

  List<_NotificationMsg> _history = [];
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    _mandatoryTextCtrl.dispose();
    _attachmentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _loadingHistory = true);
    try {
      final snap = await _fs
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      setState(() {
        _history = snap.docs.map((d) => _NotificationMsg.fromDoc(d)).toList();
      });
    } catch (_) {}
    setState(() => _loadingHistory = false);
  }

  String get _targetDescription => switch (_targetType) {
        'user' => _selectedUsers.isEmpty
            ? 'مستخدمون محددون'
            : 'مستخدم محدد: ${_selectedUsers.values.join('، ')}',
        'group' => _groupLabels[_targetGroup] ?? _targetGroup,
        _ => 'جميع المستخدمين',
      };

  Future<void> _send() async {
    final title = _titleCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    if (title.isEmpty) {
      _snack('العنوان مطلوب', isError: true);
      return;
    }
    if (message.isEmpty) {
      _snack('نص الرسالة مطلوب', isError: true);
      return;
    }
    if (_isMandatory && _mandatoryTextCtrl.text.trim().isEmpty) {
      _snack('نص الرسالة الإجبارية مطلوب', isError: true);
      return;
    }
    if (_targetType == 'user' && _selectedUsers.isEmpty) {
      _snack('اختر مستخدماً واحداً على الأقل', isError: true);
      return;
    }
    if (_isScheduled &&
        (_scheduledAt == null || !_scheduledAt!.isAfter(DateTime.now()))) {
      _snack('حدد وقت جدولة في المستقبل', isError: true);
      return;
    }

    final when = _isScheduled
        ? 'سيُرسل مجدولاً في ${DateFormat('yyyy/MM/dd HH:mm').format(_scheduledAt!)}'
        : 'سيُرسل الآن فوراً';
    final confirmed = await _confirmDialog(
      title: _isScheduled ? 'جدولة الإشعار' : 'إرسال الإشعار',
      content: 'الاستهداف: $_targetDescription\n$when\nهل تريد المتابعة؟',
      confirmLabel: _isScheduled ? 'جدولة' : 'إرسال',
    );
    if (!confirmed) return;

    setState(() => _sending = true);
    try {
      final id = 'notif_${DateTime.now().millisecondsSinceEpoch}';
      final msg = _NotificationMsg(
        id: id,
        title: title,
        message: message,
        isMandatory: _isMandatory,
        mandatoryText: _isMandatory ? _mandatoryTextCtrl.text.trim() : '',
        attachmentUrl: _attachmentCtrl.text.trim(),
        // المجدول يبقى غير نشط داخل التطبيق حتى موعده (تفعّله Cloud Function)
        isActive: !_isScheduled,
        createdAt: DateTime.now(),
        targetType: _targetType,
        targetGroup: _targetType == 'group' ? _targetGroup : '',
        targetUserIds:
            _targetType == 'user' ? _selectedUsers.keys.toList() : const [],
        targetLabel: _targetDescription,
        scheduledAt: _isScheduled ? _scheduledAt : null,
        pushStatus: _isScheduled ? 'scheduled' : '',
      );

      final batch = _fs.batch();
      if (!_isScheduled) {
        // Deactivate all previous active notifications (immediate send only)
        final activeDocs = await _fs
            .collection(_collection)
            .where('isActive', isEqualTo: true)
            .get();
        for (final doc in activeDocs.docs) {
          batch.update(doc.reference, {'isActive': false});
        }
      }
      batch.set(_fs.collection(_collection).doc(id), msg.toMap());
      await batch.commit();

      final wasScheduled = _isScheduled;
      await AuditLogService.log(
        wasScheduled ? 'notification.schedule' : 'notification.send',
        target: title,
        details: {'استهداف': _targetDescription},
      );
      // Reset form
      _titleCtrl.clear();
      _messageCtrl.clear();
      _mandatoryTextCtrl.clear();
      _attachmentCtrl.clear();
      setState(() {
        _isMandatory = false;
        _targetType = 'all';
        _selectedUsers.clear();
        _isScheduled = false;
        _scheduledAt = null;
      });

      _snack(wasScheduled
          ? '⏰ تمت جدولة الإشعار بنجاح'
          : '✅ تم إرسال الإشعار بنجاح');
      await _loadHistory();
    } catch (e) {
      _snack('خطأ: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _cancelScheduled(_NotificationMsg msg) async {
    final confirmed = await _confirmDialog(
      title: 'إلغاء الجدولة',
      content: 'لن يُرسل "${msg.title}" في موعده المجدول.\nهل تريد المتابعة؟',
      confirmLabel: 'إلغاء الجدولة',
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await _fs
          .collection(_collection)
          .doc(msg.id)
          .update({'pushStatus': 'cancelled'});
      await AuditLogService.log('notification.cancelSchedule', target: msg.title);
      _snack('تم إلغاء الجدولة');
      await _loadHistory();
    } catch (e) {
      _snack('خطأ: ${e.toString()}', isError: true);
    }
  }

  Future<void> _pickScheduleTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          _scheduledAt ?? now.add(const Duration(hours: 1))),
    );
    if (time == null) return;
    setState(() => _scheduledAt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _pickUsers() async {
    // حمّل قائمة المستخدمين مرة واحدة داخل الحوار مع بحث نصي فوري
    List<MapEntry<String, String>> all = [];
    try {
      final snap = await _fs.collection('users').limit(500).get();
      all = snap.docs
          .map((d) => MapEntry(
              d.id,
              (d.data()['email'] ?? d.data()['displayName'] ?? d.id)
                  .toString()))
          .where((e) => e.value.isNotEmpty)
          .toList()
        ..sort((a, b) => a.value.compareTo(b.value));
    } catch (e) {
      _snack('تعذر تحميل المستخدمين: $e', isError: true);
      return;
    }
    if (!mounted) return;

    final picked = Map<String, String>.from(_selectedUsers);
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(builder: (ctx, setDialogState) {
          final filtered = query.isEmpty
              ? all
              : all
                  .where((e) =>
                      e.value.toLowerCase().contains(query.toLowerCase()))
                  .toList();
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text('اختيار المستخدمين (${picked.length})'),
              content: SizedBox(
                width: 420,
                height: 420,
                child: Column(children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'ابحث بالبريد الإلكتروني...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setDialogState(() => query = v.trim()),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('لا نتائج'))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (ctx, i) {
                              final e = filtered[i];
                              final checked = picked.containsKey(e.key);
                              return CheckboxListTile(
                                dense: true,
                                value: checked,
                                title: Text(e.value,
                                    style: const TextStyle(fontSize: 13)),
                                onChanged: (v) => setDialogState(() {
                                  if (v == true) {
                                    picked[e.key] = e.value;
                                  } else {
                                    picked.remove(e.key);
                                  }
                                }),
                              );
                            },
                          ),
                  ),
                ]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, picked),
                  child: const Text('اعتماد'),
                ),
              ],
            ),
          );
        });
      },
    );
    if (result != null) {
      setState(() {
        _selectedUsers
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _cancelActive() async {
    final active = _history.where((n) => n.isActive).toList();
    if (active.isEmpty) {
      _snack('لا يوجد إشعار نشط حالياً');
      return;
    }

    final confirmed = await _confirmDialog(
      title: 'تراجع عن الإرسال',
      content: 'سيتم إلغاء الإشعار النشط الحالي وإيقافه.\nهل تريد المتابعة؟',
      confirmLabel: 'تراجع',
      isDestructive: true,
    );
    if (!confirmed) return;

    setState(() => _sending = true);
    try {
      final batch = _fs.batch();
      for (final n in active) {
        batch.update(_fs.collection(_collection).doc(n.id), {'isActive': false});
      }
      await batch.commit();
      await AuditLogService.log('notification.cancelActive',
          target: active.first.title);
      _snack('✅ تم إيقاف الإشعار النشط');
      await _loadHistory();
    } catch (e) {
      _snack('خطأ: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _delete(_NotificationMsg msg) async {
    final confirmed = await _confirmDialog(
      title: 'حذف الإشعار',
      content: 'هل تريد حذف "${msg.title}"؟',
      confirmLabel: 'حذف',
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await _fs.collection(_collection).doc(msg.id).delete();
      await AuditLogService.log('notification.delete', target: msg.title);
      setState(() => _history.removeWhere((n) => n.id == msg.id));
      _snack('تم الحذف');
    } catch (e) {
      _snack('خطأ: ${e.toString()}', isError: true);
    }
  }

  void _snack(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      duration: const Duration(seconds: 3),
    ));
  }

  Future<bool> _confirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: Compose form ──────────────────────────────────────
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(children: [
                    const FaIcon(FontAwesomeIcons.bell, size: 18),
                    const SizedBox(width: 10),
                    Text('رسائل الإشعار',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: AppDimensions.spacingLg),

                  // Active badge
                  _buildActiveBadge(),
                  const SizedBox(height: AppDimensions.spacingMd),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.spacingLg),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.dashboardCard : AppColors.lightModeCard,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('إنشاء إشعار جديد',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppDimensions.spacingMd),

                        // Title
                        _buildField('العنوان *', _titleCtrl),
                        const SizedBox(height: AppDimensions.spacingMd),

                        // Message
                        _buildField('نص الرسالة *', _messageCtrl, maxLines: 4),
                        const SizedBox(height: AppDimensions.spacingMd),

                        // Mandatory toggle
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.spacingMd),
                          decoration: BoxDecoration(
                            color: _isMandatory
                                ? AppColors.blue.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            border: Border.all(
                              color: _isMandatory ? AppColors.blue.withValues(alpha: 0.4) : Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(children: [
                                Checkbox(
                                  value: _isMandatory,
                                  onChanged: (v) => setState(() => _isMandatory = v ?? false),
                                  activeColor: AppColors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('رسالة إجبارية للاطلاع والموافقة',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                      Text('يجب على المستخدم الموافقة قبل إغلاق الإشعار',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6))),
                                    ],
                                  ),
                                ),
                              ]),
                              if (_isMandatory) ...[
                                const SizedBox(height: AppDimensions.spacingMd),
                                _buildField('نص الرسالة الإجبارية *', _mandatoryTextCtrl, maxLines: 3),
                                const SizedBox(height: AppDimensions.spacingMd),
                                _buildField('رابط المرفق (اختياري — PDF أو صورة)', _attachmentCtrl),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),

                        // ── الاستهداف ──
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.spacingMd),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الاستهداف',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: AppDimensions.spacingSm),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment(value: 'all', label: Text('الكل'), icon: Icon(Icons.groups_rounded, size: 16)),
                                  ButtonSegment(value: 'group', label: Text('مجموعة'), icon: Icon(Icons.group_work_outlined, size: 16)),
                                  ButtonSegment(value: 'user', label: Text('مستخدم محدد'), icon: Icon(Icons.person_search_rounded, size: 16)),
                                ],
                                selected: {_targetType},
                                onSelectionChanged: (s) => setState(() => _targetType = s.first),
                                showSelectedIcon: false,
                              ),
                              if (_targetType == 'group') ...[
                                const SizedBox(height: AppDimensions.spacingMd),
                                DropdownButtonFormField<String>(
                                  initialValue: _targetGroup,
                                  decoration: const InputDecoration(
                                    labelText: 'المجموعة',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  items: [
                                    for (final e in _groupLabels.entries)
                                      DropdownMenuItem(value: e.key, child: Text(e.value)),
                                  ],
                                  onChanged: (v) => setState(() => _targetGroup = v ?? 'google'),
                                ),
                              ],
                              if (_targetType == 'user') ...[
                                const SizedBox(height: AppDimensions.spacingMd),
                                Row(children: [
                                  Expanded(
                                    child: Text(
                                      _selectedUsers.isEmpty
                                          ? 'لم يُختر أي مستخدم بعد'
                                          : _selectedUsers.values.join('، '),
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: _selectedUsers.isEmpty
                                            ? AppColors.error
                                            : Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: _pickUsers,
                                    icon: const Icon(Icons.person_add_alt, size: 16),
                                    label: Text(_selectedUsers.isEmpty ? 'اختيار' : 'تعديل (${_selectedUsers.length})'),
                                  ),
                                ]),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),

                        // ── الجدولة ──
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.spacingMd),
                          decoration: BoxDecoration(
                            color: _isScheduled ? AppColors.warning.withValues(alpha: 0.08) : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                            border: Border.all(
                              color: _isScheduled ? AppColors.warning.withValues(alpha: 0.4) : Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(children: [
                            Checkbox(
                              value: _isScheduled,
                              onChanged: (v) => setState(() => _isScheduled = v ?? false),
                              activeColor: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _isScheduled
                                    ? (_scheduledAt == null
                                        ? 'جدولة الإرسال — حدد الموعد'
                                        : 'مجدول: ${DateFormat('yyyy/MM/dd  HH:mm').format(_scheduledAt!)}')
                                    : 'إرسال فوري (فعّل للجدولة)',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            if (_isScheduled)
                              TextButton.icon(
                                onPressed: _pickScheduleTime,
                                icon: const Icon(Icons.schedule_rounded, size: 16),
                                label: const Text('الموعد'),
                              ),
                          ]),
                        ),
                        const SizedBox(height: AppDimensions.spacingLg),

                        // Buttons
                        Row(children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _sending ? null : _send,
                              icon: _sending
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : FaIcon(_isScheduled ? FontAwesomeIcons.clock : FontAwesomeIcons.paperPlane, size: 14),
                              label: Text(_isScheduled ? 'جدولة الإرسال' : 'إرسال'),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingMd),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _sending ? null : _cancelActive,
                              icon: const FaIcon(FontAwesomeIcons.ban, size: 14),
                              label: const Text('تراجع عن الإرسال'),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppDimensions.spacingLg),
            Container(width: 1, color: Theme.of(context).dividerColor),
            const SizedBox(width: AppDimensions.spacingLg),

            // ── Right: History ──────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 16),
                    const SizedBox(width: 8),
                    Text('سجل الإشعارات',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'تحديث',
                      onPressed: _loadHistory,
                    ),
                  ]),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Expanded(
                    child: _loadingHistory
                        ? const Center(child: CircularProgressIndicator())
                        : _history.isEmpty
                            ? Center(
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.notifications_none_rounded, size: 56, color: Colors.grey.withValues(alpha: 0.3)),
                                  const SizedBox(height: 12),
                                  Text('لا توجد إشعارات مرسلة بعد',
                                      style: TextStyle(color: Colors.grey.withValues(alpha: 0.5))),
                                ]),
                              )
                            : ListView.separated(
                                itemCount: _history.length,
                                separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.spacingSm),
                                itemBuilder: (ctx, i) => _NotifRow(
                                  msg: _history[i],
                                  isDark: isDark,
                                  onDelete: () => _delete(_history[i]),
                                  onCancelSchedule: _history[i].isScheduled
                                      ? () => _cancelScheduled(_history[i])
                                      : null,
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

  Widget _buildActiveBadge() {
    final active = _history.where((n) => n.isActive).toList();
    if (active.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Icon(Icons.circle, size: 10, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Text('لا يوجد إشعار نشط حالياً', style: TextStyle(fontSize: 13, color: Colors.grey.withValues(alpha: 0.7))),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success)),
        const SizedBox(width: 8),
        Expanded(child: Text('إشعار نشط: "${active.first.title}"',
            style: const TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        maxLines: maxLines,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      );
}

// ─── History Row ──────────────────────────────────────────────────────────────

class _NotifRow extends StatelessWidget {
  final _NotificationMsg msg;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback? onCancelSchedule;

  const _NotifRow({
    required this.msg,
    required this.isDark,
    required this.onDelete,
    this.onCancelSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = msg.createdAt != null
        ? DateFormat('yyyy/MM/dd  HH:mm').format(msg.createdAt!)
        : '—';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dashboardCard : AppColors.lightModeCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(
          color: msg.isActive
              ? AppColors.success.withValues(alpha: 0.5)
              : (isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder),
          width: msg.isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Delete icon on the left (RTL = start)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            iconSize: 18,
            color: AppColors.error,
            tooltip: 'حذف',
            onPressed: onDelete,
          ),
          if (onCancelSchedule != null)
            IconButton(
              icon: const Icon(Icons.alarm_off_rounded),
              iconSize: 18,
              color: AppColors.warning,
              tooltip: 'إلغاء الجدولة',
              onPressed: onCancelSchedule,
            ),
          const SizedBox(width: 6),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  if (msg.isActive) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('نشط', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  if (msg.isScheduled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        msg.scheduledAt != null
                            ? 'مجدول ${DateFormat('MM/dd HH:mm').format(msg.scheduledAt!)}'
                            : 'مجدول',
                        style: const TextStyle(fontSize: 10, color: AppColors.warning, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (msg.pushStatus == 'cancelled')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('أُلغيت جدولته', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ),
                  if (msg.targetType != 'all')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        msg.targetType == 'user'
                            ? 'مستهدف: ${msg.targetUserIds.length} مستخدم'
                            : 'مجموعة',
                        style: const TextStyle(fontSize: 10, color: AppColors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (msg.isMandatory)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('إجباري', style: TextStyle(fontSize: 10, color: AppColors.blue, fontWeight: FontWeight.bold)),
                    ),
                  Expanded(
                    child: Text(msg.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(msg.message,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8)),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.access_time_rounded, size: 11, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(dateStr, style: TextStyle(fontSize: 11, color: Colors.grey.withValues(alpha: 0.6))),
                  const SizedBox(width: 12),
                  Icon(Icons.check_circle_outline, size: 11, color: AppColors.success.withValues(alpha: 0.7)),
                  const SizedBox(width: 4),
                  FutureBuilder<AggregateQuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('app_notifications')
                        .doc(msg.id)
                        .collection('acknowledgments')
                        .count()
                        .get(),
                    builder: (ctx, snap) {
                      final n = snap.data?.count ?? 0;
                      return Text('$n موافقة',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.success.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600));
                    },
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
