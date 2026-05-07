import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

// ── Theme Colors (matches HTML design) ───────────────────────────────
const _bgColor      = Color(0xFF090A0F);
const _cardColor    = Color(0xFF12141D);
const _card2Color   = Color(0xFF1A1D29);
const _borderColor  = Color(0xFF242731);
const _border2Color = Color(0xFF2D313E);
const _neonColor    = Color(0xFF5D5FEF);
const _goldColor    = Color(0xFFFDE68A);
const _rateLow      = Color(0xFF00D68F);
const _rateHigh     = Color(0xFFEF4444);
const _muteColor    = Color(0xFF8E929D);
const _inputBg      = Color(0xFF050608);

// ── Data Model ────────────────────────────────────────────────────────
class _RateRow {
  final String id;
  final String sectionKey;
  final String bankName;
  final double? margin;
  final int sortOrder;

  const _RateRow({
    required this.id,
    required this.sectionKey,
    required this.bankName,
    this.margin,
    required this.sortOrder,
  });

  _RateRow copyWith({String? bankName, double? margin, bool clearMargin = false}) =>
      _RateRow(
        id: id,
        sectionKey: sectionKey,
        bankName: bankName ?? this.bankName,
        margin: clearMargin ? null : (margin ?? this.margin),
        sortOrder: sortOrder,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sectionKey': sectionKey,
        'bankName': bankName,
        'margin': margin,
        'sortOrder': sortOrder,
      };

  factory _RateRow.fromMap(Map<String, dynamic> d) => _RateRow(
        id: d['id']?.toString() ?? '',
        sectionKey: d['sectionKey']?.toString() ?? '',
        bankName: d['bankName']?.toString() ?? '',
        margin: (d['margin'] as num?)?.toDouble(),
        sortOrder: (d['sortOrder'] as num?)?.toInt() ?? 99,
      );
}

// ── Section / Group Definitions ───────────────────────────────────────
class _SectionDef {
  final String key;
  final String label;
  const _SectionDef(this.key, this.label);
}

class _GroupDef {
  final String title;
  final List<_SectionDef> sections;
  const _GroupDef(this.title, this.sections);
}

const _groups = <_GroupDef>[
  _GroupDef('التمويل الشخصي', [
    _SectionDef('personal_new',    'تمويل شخصي جديد'),
    _SectionDef('personal_top_up', 'تمويل شخصي تكميلي'),
    _SectionDef('debt_purchase',   'شراء مديونية'),
  ]),
  _GroupDef('التمويل العقاري المدعوم', [
    _SectionDef('subsidized_ready',      'شراء وحدة سكنية جاهزة'),
    _SectionDef('subsidized_offplan',    'شراء على الخارطة'),
    _SectionDef('subsidized_self_build', 'البناء الذاتي'),
    _SectionDef('subsidized_mortgage',   'رهن عقار'),
  ]),
  _GroupDef('التمويل العقاري الاعتيادي', [
    _SectionDef('regular_real_estate', 'التمويل العقاري الاعتيادي'),
  ]),
  _GroupDef('التمويل التأجيري', [
    _SectionDef('leasing_5y',    'نظام 5 سنوات'),
    _SectionDef('leasing_50_50', 'نظام 50/50'),
  ]),
];

const _defaultBanks = [
  'البنك الأهلي السعودي',
  'مصرف الراجحي',
  'بنك الرياض',
  'البنك السعودي الأول (ساب)',
  'البنك السعودي الفرنسي',
  'البنك العربي الوطني',
  'مصرف الإنماء',
  'بنك البلاد',
  'بنك الجزيرة',
  'البنك السعودي للاستثمار',
  'بنك الإمارات دبي الوطني',
];

// ── Inline Editable Cell ──────────────────────────────────────────────
class _EditableCell extends StatefulWidget {
  final String value;
  final String? displayValue;
  final bool isNumber;
  final Color textColor;
  final void Function(String) onSave;

  const _EditableCell({
    required this.value,
    required this.onSave,
    this.displayValue,
    this.isNumber = false,
    this.textColor = Colors.white,
  });

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  bool _editing = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_EditableCell old) {
    super.didUpdateWidget(old);
    if (!_editing) _ctrl.text = widget.value;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commit() {
    final val = _ctrl.text;
    setState(() => _editing = false);
    if (val != widget.value) widget.onSave(val);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return SizedBox(
        height: 38,
        child: TextField(
          controller: _ctrl,
          autofocus: true,
          keyboardType: widget.isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          textDirection: widget.isNumber ? TextDirection.ltr : TextDirection.rtl,
          style: TextStyle(color: widget.textColor, fontSize: 13),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            filled: true,
            fillColor: _inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _neonColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _neonColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _border2Color),
            ),
          ),
          onSubmitted: (_) => _commit(),
          onEditingComplete: _commit,
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _editing = true),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.transparent,
        ),
        child: Text(
          (widget.displayValue ?? widget.value).isEmpty ? '—' : (widget.displayValue ?? widget.value),
          style: TextStyle(
            color: (widget.displayValue ?? widget.value).isEmpty ? _muteColor : widget.textColor,
            fontSize: 13,
          ),
          textAlign: widget.isNumber ? TextAlign.left : TextAlign.right,
          textDirection: widget.isNumber ? TextDirection.ltr : TextDirection.rtl,
        ),
      ),
    );
  }
}

// ── Section Table (accordion) ─────────────────────────────────────────
class _SectionTable extends StatefulWidget {
  final String sectionKey;
  final String label;
  final List<_RateRow> rows;
  final void Function(String id, String bankName) onUpdateBank;
  final void Function(String id, double? margin) onUpdateMargin;
  final void Function(String sectionKey) onAddBank;
  final void Function(String id) onDelete;

  const _SectionTable({
    required this.sectionKey,
    required this.label,
    required this.rows,
    required this.onUpdateBank,
    required this.onUpdateMargin,
    required this.onAddBank,
    required this.onDelete,
  });

  @override
  State<_SectionTable> createState() => _SectionTableState();
}

class _SectionTableState extends State<_SectionTable> {
  bool _open = false;

  ({String? minId, String? maxId}) _colorIds() {
    final withVal = widget.rows.where((r) => r.margin != null).toList();
    if (withVal.isEmpty) return (minId: null, maxId: null);
    _RateRow mn = withVal[0], mx = withVal[0];
    for (final r in withVal) {
      if (r.margin! < mn.margin!) mn = r;
      if (r.margin! > mx.margin!) mx = r;
    }
    return (
      minId: mn.id,
      maxId: mn.margin == mx.margin ? null : mx.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_open) {
      return GestureDetector(
        onTap: () => setState(() => _open = true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              Row(children: [
                Text('${widget.rows.length} بنك',
                    style: const TextStyle(color: _muteColor, fontSize: 12)),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down_rounded, color: _muteColor, size: 18),
              ]),
            ],
          ),
        ),
      );
    }

    final colors = _colorIds();

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header (collapse button) ──────────────────
          GestureDetector(
            onTap: () => setState(() => _open = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const Icon(Icons.keyboard_arrow_up_rounded, color: _muteColor, size: 18),
                ],
              ),
            ),
          ),
          // ── Column headers ────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _borderColor, width: 0.8)),
            ),
            child: const Row(children: [
              Expanded(
                flex: 5,
                child: Text('اسم البنك',
                    style: TextStyle(
                        color: _muteColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(
                flex: 3,
                child: Text('هامش الربح %',
                    style: TextStyle(
                        color: _muteColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              SizedBox(width: 44),
            ]),
          ),
          // ── Rows ──────────────────────────────────────
          ...widget.rows.map((r) {
            final isMin = r.id == colors.minId;
            final isMax = r.id == colors.maxId;
            final valueColor =
                isMin ? _rateLow : isMax ? _rateHigh : Colors.white;

            return Container(
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: _borderColor, width: 0.4)),
              ),
              child: Row(children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: _EditableCell(
                      value: r.bankName,
                      onSave: (v) => widget.onUpdateBank(r.id, v),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: _EditableCell(
                      value: r.margin == null ? '' : r.margin!.toStringAsFixed(2),
                      displayValue: r.margin == null ? '' : '${r.margin!.toStringAsFixed(2)}%',
                      isNumber: true,
                      textColor: valueColor,
                      onSave: (v) {
                        final parsed = double.tryParse(v.trim());
                        widget.onUpdateMargin(
                            r.id, v.trim().isEmpty ? null : parsed);
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: _muteColor),
                    onPressed: () => widget.onDelete(r.id),
                    hoverColor: _rateHigh.withOpacity(0.1),
                    tooltip: 'حذف',
                  ),
                ),
              ]),
            );
          }),
          // ── Add Bank ──────────────────────────────────
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: () => widget.onAddBank(widget.sectionKey),
              child: const Row(children: [
                Icon(Icons.add, color: _neonColor, size: 16),
                SizedBox(width: 6),
                Text('Add Bank',
                    style: TextStyle(
                        color: _neonColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main Page ─────────────────────────────────────────────────────────
class ProfitMarginsPage extends StatefulWidget {
  const ProfitMarginsPage({super.key});

  @override
  State<ProfitMarginsPage> createState() => _ProfitMarginsPageState();
}

class _ProfitMarginsPageState extends State<ProfitMarginsPage> {
  final _firestore = FirebaseFirestore.instance;
  static const _docPath = 'bank_rates/profit_margins';

  bool _loading = true;
  bool _saving = false;
  bool _saved = false;
  bool _triggering = false;
  String? _error;
  DateTime? _lastUpdated;
  int _grokAttempt = 0;

  List<_RateRow> _rates = [];
  final _notesCtrl = TextEditingController();

  int _idCounter = 0;
  String _genId() =>
      'r_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Build default rates ───────────────────────────────────────────
  List<_RateRow> _buildDefault() {
    final rows = <_RateRow>[];
    var counter = 0;
    for (final g in _groups) {
      for (final s in g.sections) {
        for (var i = 0; i < _defaultBanks.length; i++) {
          rows.add(_RateRow(
            id: 'r_${counter++}',
            sectionKey: s.key,
            bankName: _defaultBanks[i],
            sortOrder: i + 1,
          ));
        }
      }
    }
    return rows;
  }

  // ── Load ──────────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final doc = await _firestore.doc(_docPath).get();
      if (doc.exists) {
        final data = doc.data()!;
        // Try reading from 'banks' first (Grok format), then 'rates' (manual edits)
        if (data['banks'] != null) {
          _rates = _transformBanksToRates(data['banks'] as List<dynamic>);
        } else if (data['rates'] != null) {
          final raw = data['rates'] as List<dynamic>;
          _rates = raw
              .map((e) => _RateRow.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList();
        } else {
          _rates = _buildDefault();
        }
        _notesCtrl.text = data['notes'] as String? ?? '';
        final ts = data['lastUpdated'];
        if (ts is Timestamp) _lastUpdated = ts.toDate();
      } else {
        _rates = _buildDefault();
        _autoSaveDefaults();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  static const _bankAliases = <String, String>{
    'البنك السعودي': 'البنك الأهلي السعودي',
    'البنك الأهلي التجاري': 'البنك الأهلي السعودي',
  };

  static String _normalizeBankName(String name) =>
      _bankAliases[name.trim()] ?? name.trim();

  // Transform Grok's 'banks' format to '_RateRow' format for display
  List<_RateRow> _transformBanksToRates(List<dynamic> banksData) {
    final rows = <_RateRow>[];
    var counter = 0;

    // Iterate through sections (8 products) and banks
    for (final g in _groups) {
      for (final s in g.sections) {
        for (var bankIdx = 0; bankIdx < banksData.length; bankIdx++) {
          final bankMap = banksData[bankIdx] as Map<String, dynamic>;
          final bankName = _normalizeBankName(bankMap['bankName']?.toString() ?? '');
          final products = bankMap['products'] as Map<String, dynamic>? ?? {};
          final product = products[s.key] as Map<String, dynamic>?;

          // Use average of min/max, or null if product not available
          double? margin;
          if (product != null) {
            final minVal = (product['min'] as num?)?.toDouble();
            final maxVal = (product['max'] as num?)?.toDouble();
            final available = product['available'] as bool? ?? false;
            if (available && minVal != null && maxVal != null) {
              margin = (minVal + maxVal) / 2;
            }
          }

          rows.add(_RateRow(
            id: 'r_${counter++}',
            sectionKey: s.key,
            bankName: bankName,
            margin: margin,
            sortOrder: bankIdx + 1,
          ));
        }
      }
    }
    return rows;
  }

  Future<void> _autoSaveDefaults() async {
    try {
      final banksData = _ratesToBanks(_rates);
      await _firestore.doc(_docPath).set({
        'banks': banksData,
        'notes': '',
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedBy': 'dashboard-init',
      });
      final doc = await _firestore.doc(_docPath).get();
      if (doc.exists && mounted) {
        final ts = doc.data()?['lastUpdated'];
        if (ts is Timestamp) setState(() => _lastUpdated = ts.toDate());
      }
    } catch (_) {}
  }

  // Transform '_RateRow' format back to Grok's 'banks' format for saving
  List<Map<String, dynamic>> _ratesToBanks(List<_RateRow> rows) {
    final banksMap = <String, Map<String, dynamic>>{};

    for (final row in rows) {
      final bankName = row.bankName;
      if (!banksMap.containsKey(bankName)) {
        banksMap[bankName] = {
          'bankId': bankName.toLowerCase().replaceAll(' ', '_'),
          'bankName': bankName,
          'products': {},
        };
      }
      banksMap[bankName]!['products'][row.sectionKey] = {
        'min': row.margin,
        'max': row.margin,
        'available': row.margin != null,
      };
    }

    return banksMap.values.toList();
  }

  // ── Save ──────────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() {
      _saving = true;
      _saved = false;
      _error = null;
    });
    try {
      final banksData = _ratesToBanks(_rates);
      await _firestore.doc(_docPath).set({
        'banks': banksData,
        'notes': _notesCtrl.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedBy': 'dashboard-manual',
      }, SetOptions(merge: true));
      final doc = await _firestore.doc(_docPath).get();
      if (doc.exists && mounted) {
        final ts = doc.data()?['lastUpdated'];
        if (ts is Timestamp) setState(() => _lastUpdated = ts.toDate());
      }
      setState(() => _saved = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _saved = false);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  // ── Grok trigger with retry + timeout + error handling ───────────
  Future<void> _triggerGrok() async {
    const maxRetries = 3;
    const timeoutSeconds = 270;

    setState(() {
      _triggering = true;
      _error = null;
      _grokAttempt = 0;
    });

    final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
        .httpsCallable(
      'triggerProfitMarginsUpdate',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: timeoutSeconds),
      ),
    );

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      setState(() => _grokAttempt = attempt);
      try {
        await callable.call({'page': 'dashboard/profit_margins'});
        await _load();
        setState(() => _triggering = false);
        return; // نجح الطلب
      } on FirebaseFunctionsException catch (e) {
        final isDeadline  = e.code == 'deadline-exceeded';
        final isNotFound  = e.code == 'not-found' ||
            (e.message?.toLowerCase().contains('model not found') ?? false);
        final isRetryable = isDeadline ||
            e.code == 'internal' ||
            e.code == 'unavailable';

        if (isNotFound) {
          // خطأ في اسم الموديل — لا فائدة من إعادة المحاولة
          setState(() {
            _error = '❌ الموديل غير موجود: ${e.message}';
            _triggering = false;
          });
          return;
        }

        if (isRetryable && attempt < maxRetries) {
          final delaySeconds = attempt * 3;
          setState(() => _error =
              '⚠️ محاولة $attempt فشلت (${isDeadline ? "timeout" : e.code}). '
              'إعادة المحاولة بعد ${delaySeconds}s…');
          await Future.delayed(Duration(seconds: delaySeconds));
          continue;
        }

        // آخر محاولة أو خطأ غير قابل للتكرار
        setState(() {
          _error = _buildErrorMessage(e.code, e.message, attempt);
          _triggering = false;
        });
        return;
      } catch (e) {
        if (attempt < maxRetries) {
          setState(() => _error = '⚠️ محاولة $attempt فشلت. إعادة المحاولة…');
          await Future.delayed(Duration(seconds: attempt * 3));
          continue;
        }
        setState(() {
          _error = '❌ فشل الاتصال بعد $maxRetries محاولات: $e';
          _triggering = false;
        });
        return;
      }
    }
    setState(() => _triggering = false);
  }

  String _buildErrorMessage(String code, String? message, int attempts) {
    switch (code) {
      case 'deadline-exceeded':
        return '❌ انتهت مهلة الطلب بعد $attempts محاولات. '
            'تحقق من Firebase Console للمزيد.';
      case 'unauthenticated':
        return '❌ غير مصرح: يجب تسجيل الدخول أولاً.';
      case 'permission-denied':
        return '❌ ليس لديك صلاحية تشغيل هذه العملية.';
      case 'internal':
        return '❌ خطأ داخلي: ${message ?? "راجع Firebase logs"}';
      default:
        return '❌ خطأ ($code): ${message ?? "غير معروف"}';
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────
  void _updateBank(String id, String name) {
    setState(() {
      _rates = _rates
          .map((r) => r.id == id ? r.copyWith(bankName: name) : r)
          .toList();
    });
  }

  void _updateMargin(String id, double? margin) {
    setState(() {
      _rates = _rates.map((r) {
        if (r.id != id) return r;
        return margin == null
            ? r.copyWith(clearMargin: true)
            : r.copyWith(margin: margin);
      }).toList();
    });
  }

  void _addBank(String sectionKey) {
    final sectionRows =
        _rates.where((r) => r.sectionKey == sectionKey).toList();
    final nextOrder = sectionRows.isEmpty
        ? 1
        : sectionRows
                .map((r) => r.sortOrder)
                .reduce((a, b) => a > b ? a : b) +
            1;
    setState(() {
      _rates.add(_RateRow(
        id: _genId(),
        sectionKey: sectionKey,
        bankName: 'بنك جديد',
        sortOrder: nextOrder,
      ));
    });
  }

  void _deleteRow(String id) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _card2Color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('حذف البنك؟',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('هل أنت متأكد من الحذف؟',
              style: TextStyle(color: _muteColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء',
                  style: TextStyle(color: _muteColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _rateHigh,
                  foregroundColor: Colors.white),
              onPressed: () {
                setState(() => _rates.removeWhere((r) => r.id == id));
                Navigator.pop(ctx);
              },
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Date helpers ──────────────────────────────────────────────────
  static const _days = [
    'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء',
    'الخميس', 'الجمعة', 'السبت'
  ];

  String _fmtDate(DateTime d) =>
      '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}';

  String _fmtDay(DateTime d) => _days[d.weekday % 7];

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: _neonColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildNotesCard(),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      _buildError(),
                      const SizedBox(height: 16),
                    ],
                    // Groups
                    for (final group in _groups) ...[
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 10, right: 4),
                        child: Text(group.title,
                            style: const TextStyle(
                                color: _goldColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                      for (final section in group.sections) ...[
                        _SectionTable(
                          sectionKey: section.key,
                          label: section.label,
                          rows: _rates
                              .where((r) => r.sectionKey == section.key)
                              .toList()
                            ..sort((a, b) =>
                                a.sortOrder.compareTo(b.sortOrder)),
                          onUpdateBank: _updateBank,
                          onUpdateMargin: _updateMargin,
                          onAddBank: _addBank,
                          onDelete: _deleteRow,
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 14),
                    ],
                    // Grok
                    _buildGrokButton(),
                    const SizedBox(height: 12),
                    // Save
                    _buildSaveButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header widget ─────────────────────────────────────────────────
  Widget _buildHeader() {
    final d = _lastUpdated?.toLocal();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('هوامش الربح',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              if (_saved) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _rateLow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: _rateLow.withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: _rateLow, size: 14),
                      SizedBox(width: 5),
                      Text('تم الحفظ',
                          style:
                              TextStyle(color: _rateLow, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        // Last updated card
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            children: [
              const Text('آخر تحديث',
                  style: TextStyle(
                      color: _rateLow,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (d != null) ...[
                Text(_fmtDate(d),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Text(_fmtTime(d),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                Text(_fmtDay(d),
                    style: const TextStyle(
                        color: _muteColor, fontSize: 11)),
              ] else
                const Text('—',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Notes card ────────────────────────────────────────────────────
  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ملاحظة',
              style: TextStyle(
                  color: _goldColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            style:
                const TextStyle(color: Colors.white, fontSize: 13),
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'اكتب ملاحظة عامة تظهر أعلى الداشبورد…',
              hintStyle:
                  const TextStyle(color: _muteColor, fontSize: 12),
              filled: true,
              fillColor: _inputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: _border2Color),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: _border2Color),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                    color: _neonColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error banner ──────────────────────────────────────────────────
  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _rateHigh.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rateHigh.withOpacity(0.3)),
      ),
      child: Text(_error!,
          style: const TextStyle(color: _rateHigh, fontSize: 13)),
    );
  }

  // ── Grok button ───────────────────────────────────────────────────
  Widget _buildGrokButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: (_triggering || _saving) ? null : _triggerGrok,
        icon: _triggering
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: _neonColor))
            : const Icon(Icons.auto_awesome_rounded,
                size: 16, color: _neonColor),
        label: Text(
          _triggering
              ? 'جارٍ الاستعلام من Grok… (محاولة $_grokAttempt/3)'
              : 'تحديث عبر Grok الآن',
          style: const TextStyle(
              color: _neonColor,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _neonColor),
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: _neonColor.withOpacity(0.05),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // ── Save button ───────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: _neonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: _saving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Text('حفظ التعديلات',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
