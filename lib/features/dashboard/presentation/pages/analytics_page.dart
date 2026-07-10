import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// صفحة «الإحصائية» في الداشبورد.
///
/// تعرض مربعين بنفس شكل مربعات صفحة المستخدمين:
///  1) عدد المستخدمين النشطين (يومي / شهري / سنوي) — يُحسب من مجموعة
///     [productActivityCollection] حيث يُخزَّن آخر فتح لصفحة منتج لكل مستخدم.
///  2) الصفحات الأكثر زيارة — يُحسب من مجموعة [productStatsCollection] حيث
///     يُخزَّن عدّاد الزيارات لكل صفحة/منتج.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائية')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // المربّعان الرئيسيان بنفس شكل صفحة المستخدمين.
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'المستخدمون النشطون',
                    icon: Icons.people_alt_rounded,
                    color: Colors.indigo,
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
            if (_panel == _Panel.activeUsers) const _ActiveUsersPanel(),
            if (_panel == _Panel.topPages) const _TopPagesPanel(),
          ],
        ),
      ),
    );
  }
}

/// ── لوحة المستخدمين النشطين: يومي / شهري / سنوي (خيارات منفصلة) ──────────
class _ActiveUsersPanel extends StatelessWidget {
  const _ActiveUsersPanel();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(productActivityCollection)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorBox('تعذّر جلب النشاط: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data?.docs ?? const [];
        final now = DateTime.now();
        final daily = _countWithin(docs, now, const Duration(days: 1));
        final monthly = _countWithin(docs, now, const Duration(days: 30));
        final yearly = _countWithin(docs, now, const Duration(days: 365));

        if (docs.isEmpty) {
          return const _EmptyBox(
            'لا توجد بيانات نشاط بعد.\n'
            'ستظهر الأرقام بمجرد أن يفتح المستخدمون صفحات المنتجات داخل التطبيق.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PanelTitle('كم شخص استخدم التطبيق'),
            Row(
              children: [
                Expanded(
                  child: _CountCard(
                    label: 'يومي',
                    count: daily,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CountCard(
                    label: 'شهري',
                    count: monthly,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CountCard(
                    label: 'سنوي',
                    count: yearly,
                    color: Colors.brown,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  int _countWithin(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    DateTime now,
    Duration window,
  ) {
    final cutoff = now.subtract(window);
    var count = 0;
    for (final d in docs) {
      final last = _parseDate(d.data()['lastOpenAt']);
      if (last != null && last.isAfter(cutoff)) count++;
    }
    return count;
  }
}

/// ── لوحة الصفحات الأكثر زيارة: الصفحة الأعلى + جدول بكل الصفحات ───────────
class _TopPagesPanel extends StatelessWidget {
  const _TopPagesPanel();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(productStatsCollection)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorBox('تعذّر جلب الإحصاء: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = [...?snapshot.data?.docs]..sort(
            (a, b) => _views(b.data()).compareTo(_views(a.data())),
          );

        if (docs.isEmpty) {
          return const _EmptyBox(
            'لا توجد زيارات مسجّلة بعد.\n'
            'ستظهر الصفحات الأكثر زيارة بمجرد أن يفتحها المستخدمون داخل التطبيق.',
          );
        }

        final top = docs.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PanelTitle('الصفحة الأكثر زيارة'),
            _TopPageCard(
              name: _name(top),
              views: _views(top.data()),
            ),
            const SizedBox(height: 16),
            const _PanelTitle('عدد زيارات كل الصفحات'),
            _PagesTable(docs: docs),
          ],
        );
      },
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
class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            Icon(icon, color: selected ? Colors.white : color, size: 34),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
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

class _ErrorBox extends StatelessWidget {
  const _ErrorBox(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red.shade700),
      ),
    );
  }
}

/// اسم الصفحة المعروض (عربي إن وُجد، وإلا معرّف المستند).
String _name(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  final ar = (data['nameAr'] ?? '').toString();
  if (ar.trim().isNotEmpty) return ar;
  final en = (data['nameEn'] ?? '').toString();
  if (en.trim().isNotEmpty) return en;
  return doc.id;
}

int _views(Map<String, dynamic> data) =>
    (data['views'] as num?)?.toInt() ?? 0;

DateTime? _parseDate(dynamic v) {
  if (v is Timestamp) return v.toDate();
  if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
  return null;
}
