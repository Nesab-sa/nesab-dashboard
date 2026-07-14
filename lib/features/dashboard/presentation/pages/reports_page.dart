import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';

/// «التقارير الموحدة» — نظرة واحدة تجمع البيانات المبعثرة:
/// المستخدمون · الإيرادات · توكنز AI · أكثر الأدوات استخداماً · نشاط الويب.
///
/// المصادر: users (عدّ) · payments (مجموع — جاهز للتفعيل مع الدفع) ·
/// stats/ai (توكنز/طلبات، تكتبه aiChatProxy) · ai_conversations (عدّ) ·
/// product_stats (مشاهدات لكل أداة) · stats/web (زيارات/دخول).
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ToolStat {
  const _ToolStat(this.name, this.views);
  final String name;
  final int views;
}

class _ReportsPageState extends State<ReportsPage> {
  final _fs = FirebaseFirestore.instance;

  bool _loading = true;
  String? _error;

  int _usersCount = 0;
  int _conversationsCount = 0;
  int _totalTokens = 0;
  int _totalAiRequests = 0;
  double _revenue = 0;
  int _paymentsCount = 0;
  int _webVisits = 0;
  int _webLogins = 0;
  List<_ToolStat> _topTools = [];

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
      final results = await Future.wait<dynamic>([
        _fs.collection('users').count().get(),
        _fs.collection('ai_conversations').count().get(),
        _fs.doc('stats/ai').get(),
        _fs.collection('payments').get(),
        _fs.doc('stats/web').get(),
        _fs
            .collection('product_stats')
            .orderBy('views', descending: true)
            .limit(10)
            .get(),
      ]);

      final ai = (results[2] as DocumentSnapshot).data()
              as Map<String, dynamic>? ??
          {};
      final web = (results[4] as DocumentSnapshot).data()
              as Map<String, dynamic>? ??
          {};

      double revenue = 0;
      final payments = results[3] as QuerySnapshot;
      for (final doc in payments.docs) {
        final d = doc.data() as Map<String, dynamic>;
        revenue += (d['amount'] as num?)?.toDouble() ?? 0;
      }

      final tools = (results[5] as QuerySnapshot).docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return _ToolStat(
          (d['nameAr'] ?? d['nameEn'] ?? doc.id).toString(),
          (d['views'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      setState(() {
        _usersCount = (results[0] as AggregateQuerySnapshot).count ?? 0;
        _conversationsCount =
            (results[1] as AggregateQuerySnapshot).count ?? 0;
        _totalTokens = (ai['totalTokens'] as num?)?.toInt() ?? 0;
        _totalAiRequests = (ai['totalRequests'] as num?)?.toInt() ?? 0;
        _revenue = revenue;
        _paymentsCount = payments.docs.length;
        _webVisits = (web['visitCount'] as num?)?.toInt() ?? 0;
        _webLogins = (web['loginCount'] as num?)?.toInt() ?? 0;
        _topTools = tools;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل التقارير: $e';
      });
    }
  }

  String _fmt(num n) {
    final s = n.toStringAsFixed(n is int || n == n.roundToDouble() ? 0 : 2);
    // فواصل الآلاف
    final parts = s.split('.');
    final buf = StringBuffer();
    final digits = parts[0];
    for (var i = 0; i < digits.length; i++) {
      buf.write(digits[i]);
      final left = digits.length - i - 1;
      if (left > 0 && left % 3 == 0) buf.write(',');
    }
    return parts.length > 1 ? '$buf.${parts[1]}' : buf.toString();
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

    if (_loading) return const Center(child: CircularProgressIndicator());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          children: [
            Row(children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التقارير الموحدة',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 4),
                    Text(
                      'الإيرادات، استهلاك الذكاء الاصطناعي، وأكثر الأدوات استخداماً — في مكان واحد.',
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
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
                child: Text(_error!,
                    style: const TextStyle(color: AppColors.error)),
              ),
            const SizedBox(height: AppDimensions.spacingLg),

            // ── بطاقات المؤشرات ──
            Wrap(
              spacing: AppDimensions.spacingMd,
              runSpacing: AppDimensions.spacingMd,
              children: [
                _statCard(
                  icon: FontAwesomeIcons.sackDollar,
                  color: AppColors.success,
                  label: 'الإيرادات',
                  value: '${_fmt(_revenue)} ر.س',
                  sub: _paymentsCount == 0
                      ? 'لا مدفوعات بعد — يتفعّل مع بوابة الدفع'
                      : '$_paymentsCount عملية دفع',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryColor: secondaryColor,
                ),
                _statCard(
                  icon: FontAwesomeIcons.microchip,
                  color: AppColors.blue,
                  label: 'توكنز AI',
                  value: _fmt(_totalTokens),
                  sub: _totalAiRequests == 0
                      ? 'يبدأ العد من أول محادثة بعد التحديث'
                      : '${_fmt(_totalAiRequests)} طلب',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryColor: secondaryColor,
                ),
                _statCard(
                  icon: FontAwesomeIcons.users,
                  color: AppColors.warning,
                  label: 'المستخدمون',
                  value: _fmt(_usersCount),
                  sub: '${_fmt(_conversationsCount)} محادثة AI',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryColor: secondaryColor,
                ),
                _statCard(
                  icon: FontAwesomeIcons.globe,
                  color: AppColors.accent,
                  label: 'الموقع',
                  value: _fmt(_webVisits),
                  sub: '${_fmt(_webLogins)} تسجيل دخول',
                  cardColor: cardColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  secondaryColor: secondaryColor,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingLg),

            // ── أكثر الأدوات استخداماً ──
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
                    Icon(Icons.leaderboard_rounded,
                        size: 20,
                        color: isDark ? AppColors.blue : AppColors.blue600),
                    const SizedBox(width: 8),
                    Text('أكثر الأدوات استخداماً',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textColor)),
                  ]),
                  const SizedBox(height: AppDimensions.spacingMd),
                  if (_topTools.isEmpty)
                    Text(
                      'لا بيانات استخدام بعد — تُجمع تلقائياً من صفحات الأدوات.',
                      style: TextStyle(fontSize: 13, color: secondaryColor),
                    )
                  else
                    for (final (i, tool) in _topTools.indexed)
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.spacingSm),
                        child: Row(children: [
                          SizedBox(
                            width: 22,
                            child: Text('${i + 1}.',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryColor)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(tool.name,
                                style: TextStyle(
                                    fontSize: 13.5, color: textColor),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Expanded(
                            flex: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _topTools.first.views == 0
                                    ? 0
                                    : tool.views / _topTools.first.views,
                                minHeight: 8,
                                backgroundColor:
                                    borderColor.withValues(alpha: .4),
                                valueColor: AlwaysStoppedAnimation(
                                    isDark ? AppColors.blue : AppColors.blue600),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(_fmt(tool.views),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textColor)),
                          ),
                        ]),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required FaIconData icon,
    required Color color,
    required String label,
    required String value,
    required String sub,
    required Color cardColor,
    required Color borderColor,
    required Color textColor,
    required Color secondaryColor,
  }) {
    return Container(
      width: 235,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: FaIcon(icon, size: 18, color: color)),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12.5, color: secondaryColor)),
              Text(value,
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
              Text(sub,
                  style: TextStyle(fontSize: 10.5, color: secondaryColor),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ]),
    );
  }
}
