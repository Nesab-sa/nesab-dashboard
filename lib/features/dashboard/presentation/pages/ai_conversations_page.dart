import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ── Theme Colors (matches profit_margins_page) ────────────────────────
const _bgColor     = Color(0xFF090A0F);
const _cardColor   = Color(0xFF12141D);
const _card2Color  = Color(0xFF1A1D29);
const _borderColor = Color(0xFF242731);
const _neonColor   = Color(0xFF5D5FEF);
const _goldColor   = Color(0xFFFDE68A);
const _rateLow     = Color(0xFF00D68F);
const _rateHigh    = Color(0xFFEF4444);
const _muteColor   = Color(0xFF8E929D);

// ── Data Model ────────────────────────────────────────────────────────
class _ConvMsg {
  final String role;
  final String content;

  const _ConvMsg({required this.role, required this.content});

  factory _ConvMsg.fromMap(Map<String, dynamic> d) => _ConvMsg(
        role: d['role']?.toString() ?? 'user',
        content: d['content']?.toString() ?? '',
      );
}

class _Conversation {
  final String id;
  final String userId;
  final String source;
  final String pageContext;
  final List<_ConvMsg> messages;
  final int messageCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const _Conversation({
    required this.id,
    required this.userId,
    required this.source,
    required this.pageContext,
    required this.messages,
    required this.messageCount,
    this.createdAt,
    this.updatedAt,
  });

  factory _Conversation.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final rawMsgs = d['messages'] as List<dynamic>? ?? [];
    final msgs = rawMsgs
        .map((e) => _ConvMsg.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    DateTime? parseTs(dynamic ts) =>
        ts is Timestamp ? ts.toDate() : null;

    return _Conversation(
      id: doc.id,
      userId: d['userId']?.toString() ?? '',
      source: d['source']?.toString() ?? 'app',
      pageContext: d['pageContext']?.toString() ?? '',
      messages: msgs,
      messageCount: (d['messageCount'] as num?)?.toInt() ?? msgs.where((m) => m.role == 'user').length,
      createdAt: parseTs(d['createdAt']),
      updatedAt: parseTs(d['updatedAt']),
    );
  }
}

// ── Detect corrupted text (stored as ?/�/◆ due to encoding bug) ──────
bool _isCorrupted(String text) {
  if (text.isEmpty) return false;
  final stripped = text.replaceAll(RegExp(r'[\s?؟\u{FFFD}\u{25C6}\u{25C7}\u{FFFE}\u{FFFF}]', unicode: true), '');
  if (stripped.isEmpty) return true;
  final total = text.replaceAll(RegExp(r'\s'), '').length;
  if (total == 0) return false;
  final badChars = RegExp(r'[?\u{FFFD}\u{25C6}\u{25C7}]', unicode: true).allMatches(text).length;
  return badChars / total > 0.5;
}

// ── Markdown cleaner — strips common Grok formatting ─────────────────
String _cleanText(String raw) {
  if (_isCorrupted(raw)) return '⚠ رسالة تالفة — خطأ ترميز سابق';
  return raw
      .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*', dotAll: true), (m) => m.group(1) ?? '')
      .replaceAllMapped(RegExp(r'\*(.+?)\*',     dotAll: true), (m) => m.group(1) ?? '')
      .replaceAll(RegExp(r'#{1,6}\s*(?=[^\s])'),              '')
      .replaceAll(RegExp(r'`{1,3}'),                          '')
      .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true),   '• ')
      .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true),   '')
      .replaceAll(RegExp(r'\n{3,}'),                          '\n\n')
      .trim();
}

// ── Conversation Card ─────────────────────────────────────────────────
class _ConvCard extends StatefulWidget {
  final int index;
  final _Conversation conv;
  final VoidCallback onDelete;

  const _ConvCard({required this.index, required this.conv, required this.onDelete});

  @override
  State<_ConvCard> createState() => _ConvCardState();
}

class _ConvCardState extends State<_ConvCard> {
  bool _open = false;

  String _fmtDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final conv = widget.conv;
    final date = conv.createdAt?.toLocal();
    final isApp = conv.source == 'app';
    final sourceColor = isApp ? _rateLow : _neonColor;
    final sourceLabel = isApp ? 'App' : 'Web';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _open ? _neonColor.withValues(alpha: 0.5) : _borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Card Header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Number badge + Info — قابل للنقر لفتح/إغلاق
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _open = !_open),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _neonColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _neonColor.withValues(alpha: 0.3)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${widget.index}',
                            style: const TextStyle(
                              color: _neonColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'محادثة #${widget.index}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: sourceColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: sourceColor.withValues(alpha: 0.35)),
                                    ),
                                    child: Text(
                                      sourceLabel,
                                      style: TextStyle(
                                        color: sourceColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (date != null)
                                Text(
                                  '${_fmtDate(date)}  ${_fmtTime(date)}',
                                  style: const TextStyle(color: _muteColor, fontSize: 11),
                                ),
                              if (conv.pageContext.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    conv.pageContext,
                                    style: const TextStyle(color: _muteColor, fontSize: 10),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Message count + actions — معزولة عن نقر الفتح/الإغلاق
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _goldColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${conv.messageCount} رسائل',
                        style: const TextStyle(color: _goldColor, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: widget.onDelete,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _rateHigh.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _rateHigh.withValues(alpha: 0.2)),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: _rateHigh, size: 14),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _open = !_open),
                          child: Icon(
                            _open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: _muteColor,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
            // ── Messages Panel ────────────────────────────────────
            if (_open) ...[
              const Divider(height: 1, color: _borderColor),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final msg in conv.messages) _buildMessage(msg),
                    if (conv.messages.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('لا توجد رسائل', style: TextStyle(color: _muteColor, fontSize: 12)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
    );
  }

  Widget _buildMessage(_ConvMsg msg) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _neonColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.smart_toy_rounded, color: _neonColor, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser
                    ? _neonColor.withValues(alpha: 0.08)
                    : _card2Color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isUser
                      ? _neonColor.withValues(alpha: 0.2)
                      : _borderColor,
                ),
              ),
              child: Text(
                _cleanText(msg.content),
                style: TextStyle(
                  color: isUser ? const Color(0xFFA0C0FF) : Colors.white,
                  fontSize: 12,
                  height: 1.5,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _neonColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.person_rounded, color: _neonColor, size: 14),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Main Page ─────────────────────────────────────────────────────────
class AiConversationsPage extends StatefulWidget {
  const AiConversationsPage({super.key});

  @override
  State<AiConversationsPage> createState() => _AiConversationsPageState();
}

class _AiConversationsPageState extends State<AiConversationsPage> {
  final _firestore = FirebaseFirestore.instance;
  static const _collection = 'ai_conversations';

  bool _loading = true;
  String? _error;
  List<_Conversation> _convs = [];

  String _filterSource = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _deleteConv(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('حذف المحادثة', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          content: const Text('هل أنت متأكد من حذف هذه المحادثة؟ لا يمكن التراجع.', style: TextStyle(color: _muteColor, fontSize: 13)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء', style: TextStyle(color: _muteColor)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف', style: TextStyle(color: _rateHigh, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      await _firestore.collection(_collection).doc(id).delete();
      setState(() => _convs.removeWhere((c) => c.id == id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحذف: $e'), backgroundColor: _rateHigh),
        );
      }
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final snap = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      _convs = snap.docs.map(_Conversation.fromDoc).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  List<_Conversation> get _filtered {
    if (_filterSource == 'all') return _convs;
    return _convs.where((c) => c.source == _filterSource).toList();
  }

  int get _appCount => _convs.where((c) => c.source == 'app').length;
  int get _webCount => _convs.where((c) => c.source == 'web').length;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _neonColor))
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildFilterBar(),
                        const SizedBox(height: 20),
                        if (_error != null) ...[
                          _buildError(),
                          const SizedBox(height: 16),
                        ],
                        if (_filtered.isEmpty)
                          _buildEmpty()
                        else
                          for (var i = 0; i < _filtered.length; i++) ...[
                            _ConvCard(
                              index: i + 1,
                              conv: _filtered[i],
                              onDelete: () => _deleteConv(_filtered[i].id),
                            ),
                            const SizedBox(height: 10),
                          ],
                      ],
                    ),
                  ),
                  // ── Fixed Bottom Stats ─────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomBar(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'محادثات الـ AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'محادثات المستخدمين مع المستشار الذكي من التطبيق والويب',
                style: TextStyle(color: _muteColor, fontSize: 12),
              ),
            ],
          ),
        ),
        // Refresh button
        GestureDetector(
          onTap: _load,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, color: _neonColor, size: 16),
                SizedBox(width: 6),
                Text('تحديث', style: TextStyle(color: _neonColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Row(
      children: [
        _FilterChip(
          label: 'الكل',
          count: _convs.length,
          active: _filterSource == 'all',
          onTap: () => setState(() => _filterSource = 'all'),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'App',
          count: _appCount,
          active: _filterSource == 'app',
          color: _rateLow,
          onTap: () => setState(() => _filterSource = 'app'),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Web',
          count: _webCount,
          active: _filterSource == 'web',
          color: _neonColor,
          onTap: () => setState(() => _filterSource = 'web'),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _rateHigh.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rateHigh.withValues(alpha: 0.3)),
      ),
      child: Text(_error!, style: const TextStyle(color: _rateHigh, fontSize: 13)),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.chat_bubble_outline_rounded, color: _muteColor.withValues(alpha: 0.4), size: 52),
          const SizedBox(height: 12),
          const Text('لا توجد محادثات بعد', style: TextStyle(color: _muteColor, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('ستظهر محادثات المستخدمين هنا عند بدء استخدام المستشار الذكي',
              style: TextStyle(color: _muteColor, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        border: const Border(top: BorderSide(color: _borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(label: 'إجمالي المحادثات', value: '${_convs.length}', color: _neonColor),
          const SizedBox(width: 24),
          _StatItem(label: 'من التطبيق', value: '$_appCount', color: _rateLow),
          const SizedBox(width: 24),
          _StatItem(label: 'من الويب', value: '$_webCount', color: _neonColor),
          const Spacer(),
          Text(
            'آخر تحديث: ${_convs.isNotEmpty && _convs.first.createdAt != null ? _fmtDateTime(_convs.first.createdAt!) : "—"}',
            style: const TextStyle(color: _muteColor, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _fmtDateTime(DateTime d) {
    final local = d.toLocal();
    return '${local.year}/${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.color = _neonColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : _cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.5) : _borderColor,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? color : _muteColor,
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: active ? color.withValues(alpha: 0.2) : _borderColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: active ? color : _muteColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: _muteColor, fontSize: 10)),
      ],
    );
  }
}
