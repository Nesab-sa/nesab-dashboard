import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// صفحة «الإحصائية» في الداشبورد.
///
/// تعرض مربعين بنفس شكل مربعات صفحة المستخدمين:
///  1) عدد المستخدمين النشطين (يومي / شهري / سنوي) — يُحسب من مجموعة
///     [productStatsCollection] حيث يُخزَّن إجمالي الزيارات لكل صفحة/منتج.
///  2) الصفحات الأكثر زيارة — يُحسب أيضاً من مجموعة [productStatsCollection]
///     حيث يُخزَّن عدّاد الزيارات لكل صفحة/منتج.
///
/// عند الضغط على أحد المربعين تظهر تفاصيله تحته.
///
/// البيانات تُكتب من *داخل التطبيق* عند فتح رابط المنتج (مشروع تطبيق العميل).
/// هذا الطلب يخص التطبيق فقط؛ إحصاءات الويب معروضة في صفحة المستخدمين.
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

/// اسم مجموعة نشاط المستخدمين داخل التطبيق (مستند لكل مستخدم).
const String productActivityCollection = 'product_activity';

/// اسم مجموعة عدّادات زيارات الصفحات/المنتجات (مستند لكل صفحة).
const String productStatsCollection = 'product_stats';

enum _Panel { none, activeUsers, topPages }

class _AnalyticsPageState extends State<AnalyticsPage> {
  _Panel _panel = _Panel.none;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _activityDocs = const [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _statsDocs = const [];
  DateTime? _lastUpdated;
  bool _loading = true;
  bool _refreshing = false;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activitySub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _statsSub;

  @override
  void initState() {
    super.initState();
    _activitySub = FirebaseFirestore.instance
        .collection(productActivityCollection)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() {
        _activityDocs = snap.docs;
        _lastUpdated = DateTime.now();
        _loading = false;
      });
    });
    _statsSub = FirebaseFirestore.instance
        .collection(productStatsCollection)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      setState(() {
        _statsDocs = snap.docs;
        _lastUpdated = DateTime.now();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _activitySub?.cancel();
    _statsSub?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      final results = await Future.wait([
        FirebaseFirestore.instance
            .collection(productActivityCollection)
            .get(const GetOptions(source: Source.server)),
        FirebaseFirestore.instance
            .collection(productStatsCollection)
            .get(const GetOptions(source: Source.server)),
      ]);
      if (!mounted) return;
      setState(() {
        _activityDocs = results[0].docs;
        _statsDocs = results[1].docs;
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تعذّر التحديث: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائية'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_lastUpdated != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12, right: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              'آخر تحديث: ${_fmtDateTime(_lastUpdated!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // المربّعان الرئيسيان بنفس شكل صفحة المستخدمين.
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          label: 'المستخدمون النشطون',
                          icon: Icons.people_alt_rounded,
                          color: Colors.indigo,
                          count: _statsDocs.fold<int>(
                            0,
                            (sum, doc) => sum + _views(doc.data()),
                          ),
                          selected: _panel == _Panel.activeUsers,
                          onTap: () => setState(() => _panel =
                              _panel == _Panel.activeUsers
                                  ? _Panel.none
                                  : _Panel.activeUsers),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          label: 'الصفحات الأكثر زيارة',
                          icon: Icons.bar_chart_rounded,
                          color: Colors.deepPurple,
                          selected: _panel == _Panel.topPages,
                          onTap: () => setState(() => _panel =
                              _panel == _Panel.topPages
                                  ? _Panel.none
                                  : _Panel.topPages),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_panel == _Panel.activeUsers)
                    _ActiveUsersPanel(docs: _activityDocs),
                  if (_panel == _Panel.topPages)
                    _TopPagesPanel(docs: _statsDocs),
                ],
              ),
            ),
    );
  }
}

/// ── لوحة المستخدمين النشطين: يومي / شهري / سنوي (خيارات منفصلة) ──────────
class _ActiveUsersPanel extends StatelessWidget {
  const _ActiveUsersPanel({required this.docs});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const _EmptyBox(
        'لا توجد بيانات نشاط بعد.\n'
        'ستظهر الأرقام بمجرد أن يفتح المستخدمون صفحات المنتجات داخل التطبيق.',
      );
    }

    final now = DateTime.now();
    final daily = _sumViewsWithin(docs, now, const Duration(days: 1));
    final monthly = _sumViewsWithin(docs, now, const Duration(days: 30));
    final yearly = _sumViewsWithin(docs, now, const Duration(days: 365));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PanelTitle('عدد الزيارات'),
        Row(
          children: [
            Expanded(
              child: _CountCard(label: 'يومي', count: daily, color: Colors.teal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CountCard(label: 'شهري', count: monthly, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CountCard(label: 'سنوي', count: yearly, color: Colors.brown),
            ),
          ],
        ),
      ],
    );
  }

  int _sumViewsWithin(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime now,
    Duration window,
  ) {
    final cutoff = now.subtract(window);
    var sum = 0;
    for (final d in docs) {
      final last = _parseDate(d.data()['lastOpenAt']);
      if (last != null && last.isAfter(cutoff)) {
        sum += _views(d.data());
      }
    }
    return sum;
  }
}

/// ── لوحة الصفحات الأكثر زيارة: الصفحة الأعلى + جدول بكل الصفحات ───────────
class _TopPagesPanel extends StatelessWidget {
  const _TopPagesPanel({required this.docs});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return const _EmptyBox(
        'لا توجد زيارات مسجّلة بعد.\n'
        'ستظهر الصفحات الأكثر زيارة بمجرد أن يفتحها المستخدمون داخل التطبيق.',
      );
    }

    final sorted = [...docs]
      ..sort((a, b) => _views(b.data()).compareTo(_views(a.data())));
    final top = sorted.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PanelTitle('الصفحة الأكثر زيارة'),
        _TopPageCard(name: _name(top), views: _views(top.data())),
        const SizedBox(height: 16),
        const _PanelTitle('عدد زيارات كل الصفحات'),
        _PagesTable(docs: sorted),
      ],
    );
  }
}

class _PagesTable extends StatelessWidget {
  const _PagesTable({required this.docs});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 16,
          headingRowHeight: 44,
          dataRowMinHeight: 44,
          dataRowMaxHeight: 56,
          columns: const [
            DataColumn(label: Text('#')),
            DataColumn(label: Text('الصفحة')),
            DataColumn(label: Text('عدد الزيارات')),
          ],
          rows: [
            for (var i = 0; i < docs.length; i++)
              DataRow(cells: [
                DataCell(Text('${i + 1}')),
                DataCell(Text(_name(docs[i]))),
                DataCell(Text('${_views(docs[i].data())}')),
              ]),
          ],
        ),
      ),
    );
  }
}

class _TopPageCard extends StatelessWidget {
  const _TopPageCard({required this.name, required this.views});

  final String name;
  final int views;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade700, width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$views',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.amber.shade800,
                ),
              ),
              const Text('زيارة', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

/// ── عناصر مساعدة مشتركة ─────────────────────────────────────────────────

/// المربّع الرئيسي القابل للنقر (نفس منطق مربّعات صفحة المستخدمين).
/// [count] اختياري: إن وُجد يظهر داخل إطار المربع نفسه.
class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: fg, size: 34),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (count != null) ...[
              const SizedBox(height: 6),
              Text(
                '$count',
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// بطاقة رقمية بنفس شكل بطاقات صفحة المستخدمين.
class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade500, size: 32),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// نمط اسم الصفحة الخام (من <title> الصفحة) هو "الاسم - نسب"، مثل
/// "التمويل الشخصي - نسب". نحذف اللاحقة الفاصلة + كلمة "نسب" فقط لعرض
/// اسم الصفحة نظيفاً، مثل "التمويل الشخصي".
final RegExp _brandSuffix = RegExp(r'\s*[-—–]\s*نسب\s*$');

String _cleanName(String raw) => raw.replaceAll(_brandSuffix, '').trim();

/// اسم الصفحة المعروض (عربي إن وُجد، وإلا معرّف المستند).
String _name(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  final ar = (data['nameAr'] ?? '').toString();
  if (ar.trim().isNotEmpty) return _cleanName(ar);
  final en = (data['nameEn'] ?? '').toString();
  if (en.trim().isNotEmpty) return _cleanName(en);
  return doc.id;
}

int _views(Map<String, dynamic> data) =>
    (data['views'] as num?)?.toInt() ?? 0;

DateTime? _parseDate(dynamic v) {
  if (v is Timestamp) return v.toDate();
  if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
  return null;
}

String _fmtDateTime(DateTime dt) {
  final y = dt.year.toString();
  final mo = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$y/$mo/$d - $h:$m';
}
