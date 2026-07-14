import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:nesab_dashboard/core/services/audit_log_service.dart';
import 'package:nesab_dashboard/core/utils/file_download.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

enum _Provider { google, apple, email, unknown }

enum _View { none, all, newOnly }

class _UsersPageState extends State<UsersPage> {
  _View _view = _View.none;
  bool _syncing = false;
  bool _exporting = false;
  final Set<String> _busyUsers = {}; // مستخدمون تجري عليهم عملية حظر/حذف
  int _webLogins = 0;
  int _webVisits = 0;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _statsSub;

  @override
  void initState() {
    super.initState();
    _statsSub = FirebaseFirestore.instance
        .collection('stats')
        .doc('web')
        .snapshots()
        .listen((snap) {
      if (mounted) {
        final data = snap.data();
        setState(() {
          _webLogins = (data?['loginCount'] as num?)?.toInt() ?? 0;
          _webVisits = (data?['visitCount'] as num?)?.toInt() ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _statsSub?.cancel();
    super.dispose();
  }

  Future<void> _syncFromAuth() async {
    setState(() => _syncing = true);
    try {
      final res = await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('syncAuthUsers')
          .call();
      final d = Map<String, dynamic>.from(res.data as Map);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'تمت المزامنة: إجمالي ${d['total']} • أُنشئ ${d['created']} • حُدّث ${d['updated']}'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشلت المزامنة: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدمين'),
        actions: [
          IconButton(
            tooltip: 'تصدير CSV',
            onPressed: _exporting ? null : _exportCsv,
            icon: _exporting
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded),
          ),
          IconButton(
            tooltip: 'مزامنة من Auth',
            onPressed: _syncing ? null : _syncFromAuth,
            icon: _syncing
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = [...?snapshot.data?.docs]..sort((a, b) {
            final ad = _parseDateTime(a.data()['createdAt']);
            final bd = _parseDateTime(b.data()['createdAt']);
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return bd.compareTo(ad);
          });

          final cutoff = DateTime.now().subtract(const Duration(hours: 72));
          final newDocs = allDocs.where((d) {
            final c = _parseDateTime(d.data()['createdAt']);
            return c != null && c.isAfter(cutoff);
          }).toList();

          final List<QueryDocumentSnapshot<Map<String, dynamic>>> displayed =
              switch (_view) {
            _View.all => allDocs,
            _View.newOnly => newDocs,
            _View.none => const [],
          };

          int google = 0, apple = 0, email = 0;
          for (final d in allDocs) {
            switch (_provider(d.data())) {
              case _Provider.google: google++; break;
              case _Provider.apple:  apple++;  break;
              case _Provider.email:  email++;  break;
              case _Provider.unknown: break;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _CountCard(
                        label: 'الكل',
                        count: allDocs.length,
                        color: Colors.blue,
                        selected: _view == _View.all,
                        onTap: () => setState(() => _view =
                            _view == _View.all ? _View.none : _View.all),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CountCard(
                        label: 'الجدد (72 ساعة)',
                        count: newDocs.length,
                        color: Colors.green,
                        selected: _view == _View.newOnly,
                        onTap: () => setState(() => _view =
                            _view == _View.newOnly ? _View.none : _View.newOnly),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CountCard(
                        label: 'Web',
                        count: _webLogins,
                        color: Colors.teal,
                        selected: false,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CountCard(
                        label: 'زيارات الويب',
                        count: _webVisits,
                        color: Colors.deepOrange,
                        selected: false,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ProviderStatsCard(
                  google: google,
                  apple: apple,
                  email: email,
                ),
                const SizedBox(height: 16),
                if (_view != _View.none) const SizedBox(height: 12),
                if (_view != _View.none)
                  Expanded(
                    child: displayed.isEmpty
                        ? const Center(child: Text('لا يوجد مستخدمين'))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      columnSpacing: 16,
                                      horizontalMargin: 12,
                                      headingRowHeight: 44,
                                      dataRowMinHeight: 44,
                                      dataRowMaxHeight: 56,
                                      columns: const [
                                        DataColumn(label: Text('الاسم')),
                                        DataColumn(label: Text('الوقت')),
                                        DataColumn(label: Text('التاريخ')),
                                        DataColumn(label: Text('الحالة')),
                                        DataColumn(label: Text('إجراءات')),
                                      ],
                                      rows: displayed.map((doc) {
                                        final d = doc.data();
                                        final em = (d['email'] ?? '').toString();
                                        final name =
                                            (d['name'] ?? d['displayName'] ?? em)
                                                .toString();
                                        final created =
                                            _parseDateTime(d['createdAt']);
                                        final p = _provider(d);
                                        final banned = d['isBanned'] == true;
                                        final busy = _busyUsers.contains(doc.id);
                                        return DataRow(cells: [
                                          DataCell(Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _ProviderIcon(provider: p, size: 18),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Text(
                                                  name.isNotEmpty ? name : 'بدون اسم',
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          )),
                                          DataCell(Text(_fmtTime(created))),
                                          DataCell(Text(_fmtDate(created))),
                                          DataCell(
                                            banned
                                                ? Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withValues(alpha: .12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: const Text('محظور',
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  )
                                                : const Text('نشط',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.green)),
                                          ),
                                          DataCell(busy
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2))
                                              : Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      tooltip: banned
                                                          ? 'فك الحظر'
                                                          : 'حظر',
                                                      iconSize: 18,
                                                      color: banned
                                                          ? Colors.green
                                                          : Colors.orange,
                                                      icon: Icon(banned
                                                          ? Icons
                                                              .lock_open_rounded
                                                          : Icons
                                                              .block_rounded),
                                                      onPressed: () =>
                                                          _setBanned(
                                                              doc.id,
                                                              em.isNotEmpty
                                                                  ? em
                                                                  : name,
                                                              !banned),
                                                    ),
                                                    IconButton(
                                                      tooltip: 'حذف نهائي',
                                                      iconSize: 18,
                                                      color: Colors.red,
                                                      icon: const Icon(Icons
                                                          .delete_forever_rounded),
                                                      onPressed: () =>
                                                          _deleteUser(
                                                              doc.id,
                                                              em.isNotEmpty
                                                                  ? em
                                                                  : name),
                                                    ),
                                                  ],
                                                )),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _snack(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  Future<bool> _confirm(String title, String content,
      {String confirmLabel = 'تأكيد'}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _setBanned(String uid, String label, bool banned) async {
    final ok = await _confirm(
      banned ? 'حظر المستخدم' : 'فك حظر المستخدم',
      banned
          ? 'سيُعطَّل حساب "$label" ولن يستطيع تسجيل الدخول.\nهل تريد المتابعة؟'
          : 'سيُعاد تفعيل حساب "$label".\nهل تريد المتابعة؟',
      confirmLabel: banned ? 'حظر' : 'فك الحظر',
    );
    if (!ok) return;

    setState(() => _busyUsers.add(uid));
    try {
      await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('setUserBanned')
          .call({'uid': uid, 'banned': banned});
      await AuditLogService.log(banned ? 'user.ban' : 'user.unban',
          target: label, details: {'uid': uid});
      _snack(banned ? 'تم حظر "$label"' : 'تم فك حظر "$label"');
    } catch (e) {
      _snack('فشلت العملية: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busyUsers.remove(uid));
    }
  }

  Future<void> _deleteUser(String uid, String label) async {
    final ok = await _confirm(
      'حذف المستخدم نهائياً',
      'سيُحذف حساب "$label" وبياناته نهائياً ولا يمكن التراجع.\nهل تريد المتابعة؟',
      confirmLabel: 'حذف نهائي',
    );
    if (!ok) return;

    setState(() => _busyUsers.add(uid));
    try {
      await FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('deleteAppUser')
          .call({'uid': uid});
      await AuditLogService.log('user.delete',
          target: label, details: {'uid': uid});
      _snack('تم حذف "$label" نهائياً');
    } catch (e) {
      _snack('فشل الحذف: $e', isError: true);
    } finally {
      if (mounted) setState(() => _busyUsers.remove(uid));
    }
  }

  String _csvCell(String v) => '"${v.replaceAll('"', '""')}"';

  Future<void> _exportCsv() async {
    setState(() => _exporting = true);
    try {
      final snap =
          await FirebaseFirestore.instance.collection('users').get();
      final buffer = StringBuffer('﻿'); // BOM ليقرأ Excel العربية سليمة
      buffer.writeln('uid,email,name,provider,createdAt,isBanned');
      for (final doc in snap.docs) {
        final d = doc.data();
        final created = _parseDateTime(d['createdAt']);
        buffer.writeln([
          _csvCell(doc.id),
          _csvCell((d['email'] ?? '').toString()),
          _csvCell((d['name'] ?? d['displayName'] ?? '').toString()),
          _csvCell((d['provider'] ?? '').toString()),
          _csvCell(created?.toIso8601String() ?? ''),
          _csvCell(d['isBanned'] == true ? 'yes' : 'no'),
        ].join(','));
      }
      final filename =
          'nesab-users-${DateTime.now().toIso8601String().substring(0, 10)}.csv';
      final done = downloadTextFile(filename, buffer.toString(),
          mime: 'text/csv;charset=utf-8');
      if (done) {
        await AuditLogService.log('users.export',
            details: {'count': snap.docs.length});
        _snack('تم تصدير ${snap.docs.length} مستخدماً إلى $filename');
      } else {
        _snack('التصدير متاح على نسخة الويب من الداشبورد', isError: true);
      }
    } catch (e) {
      _snack('فشل التصدير: $e', isError: true);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  DateTime? _parseDateTime(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  _Provider _provider(Map<String, dynamic> d) {
    final raw =
        (d['authProvider'] ?? d['provider'] ?? d['signInProvider'] ?? d['providerId'] ?? '')
            .toString()
            .toLowerCase();
    if (raw.contains('google')) return _Provider.google;
    if (raw.contains('apple')) return _Provider.apple;
    if (raw.contains('password') || raw.contains('email')) return _Provider.email;

    final email = (d['email'] ?? '').toString().toLowerCase();
    if (email.contains('privaterelay.appleid.com')) return _Provider.apple;
    if (email.endsWith('@gmail.com') || email.endsWith('@googlemail.com')) {
      return _Provider.google;
    }
    if (email.isNotEmpty) return _Provider.email;
    return _Provider.unknown;
  }

  String _fmtTime(DateTime? dt) {
    if (dt == null) return '—';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    final y = dt.year.toString();
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y/$mo/$d';
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.w900,
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderStatsCard extends StatelessWidget {
  const _ProviderStatsCard({
    required this.google,
    required this.apple,
    required this.email,
  });

  final int google;
  final int apple;
  final int email;

  @override
  Widget build(BuildContext context) {
    final maxCount = [google, apple, email].reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ProviderStat(
            provider: _Provider.google,
            count: google,
            isTop: maxCount > 0 && google == maxCount,
          ),
          _ProviderStat(
            provider: _Provider.apple,
            count: apple,
            isTop: maxCount > 0 && apple == maxCount,
          ),
          _ProviderStat(
            provider: _Provider.email,
            count: email,
            isTop: maxCount > 0 && email == maxCount,
          ),
        ],
      ),
    );
  }
}

class _ProviderStat extends StatelessWidget {
  const _ProviderStat({
    required this.provider,
    required this.count,
    required this.isTop,
  });

  final _Provider provider;
  final int count;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _ProviderIcon(provider: provider, size: 32),
            if (isTop)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isTop ? Colors.amber.shade800 : null,
          ),
        ),
      ],
    );
  }
}

class _ProviderIcon extends StatelessWidget {
  const _ProviderIcon({required this.provider, this.size = 24});

  final _Provider provider;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (provider) {
      case _Provider.google:
        return Image.network(
          'https://developers.google.com/identity/images/g-logo.png',
          width: size,
          height: size,
          errorBuilder: (_, _, _) =>
              Icon(Icons.g_mobiledata, size: size + 6, color: Colors.red),
        );
      case _Provider.apple:
        return Icon(Icons.apple, size: size, color: Colors.black87);
      case _Provider.email:
        return Icon(Icons.email_outlined, size: size, color: Colors.blueGrey);
      case _Provider.unknown:
        return Icon(Icons.help_outline, size: size, color: Colors.grey);
    }
  }
}
