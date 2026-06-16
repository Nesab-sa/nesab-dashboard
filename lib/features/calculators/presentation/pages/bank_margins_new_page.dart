import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/profit_margin_model.dart';

// ── Saudi Theme Colors (matching profit_margins_page) ───────────────
const _bgColor = Color(0xFF0F1219);
const _cardColor = Color(0xFF1A1F2E);
const _borderColor = Color(0xFF242731);
const _greenPrimary = Color(0xFF006C35);
const _greenDark = Color(0xFF005528);
const _goldAccent = Color(0xFFC5A572);
const _rateLow = Color(0xFF10B981);
const _rateHigh = Color(0xFFEF4444);
const _textPrimary = Color(0xFFE5E7EB);
const _textSecondary = Color(0xFF9CA3AF);
const _textMuted = Color(0xFF6B7280);
const _amberBg = Color(0x1AF59E0B);
const _amberBorder = Color(0x80B45309);
const _amberText = Color(0xFFFBBF24);

// ── Category & Sub-section Definitions ──────────────────────────────
class _CategoryDef {
  final String id;
  final String shortLabel;
  final IconData icon;
  const _CategoryDef(this.id, this.shortLabel, this.icon);
}

const _categories = [
  _CategoryDef('تمويل شخصي', 'شخصي', Icons.trending_up_rounded),
  _CategoryDef('عقاري مدعوم', 'مدعوم', Icons.home_rounded),
  _CategoryDef('عقاري اعتيادي', 'اعتيادي', Icons.business_rounded),
  _CategoryDef('تأجيري', 'تأجيري', Icons.directions_car_rounded),
];

const _subSections = <String, List<String>>{
  'تمويل شخصي': ['جديد', 'زيادة', 'شراء مديونية'],
  'عقاري مدعوم': ['جاهز', 'على الخارطة', 'بناء ذاتي', 'رهن عقار'],
  'عقاري اعتيادي': ['عقاري اعتيادي'],
  'تأجيري': ['نظام 5 سنوات', 'نظام 50/50'],
};

const _subToProductType = <String, String>{
  'جديد': 'personal_new',
  'زيادة': 'personal_topup',
  'شراء مديونية': 'personal_buyout',
  'جاهز': 'realestate_subsidized_ready',
  'على الخارطة': 'realestate_subsidized_offplan',
  'بناء ذاتي': 'realestate_subsidized_construction',
  'رهن عقار': 'realestate_subsidized_mortgage',
  'عقاري اعتيادي': 'realestate_standard',
  'نظام 5 سنوات': 'lease_5yr',
  'نظام 50/50': 'lease_5050',
};

const _productLabels = <String, String>{
  'personal_new': 'التمويل الشخصي — جديد',
  'personal_topup': 'التمويل الشخصي — زيادة',
  'personal_buyout': 'التمويل الشخصي — شراء مديونية',
  'realestate_subsidized_ready': 'عقاري مدعوم — جاهز',
  'realestate_subsidized_offplan': 'عقاري مدعوم — على الخارطة',
  'realestate_subsidized_construction': 'عقاري مدعوم — بناء ذاتي',
  'realestate_subsidized_mortgage': 'عقاري مدعوم — رهن عقار',
  'realestate_standard': 'عقاري اعتيادي',
  'lease_5yr': 'تأجيري — نظام 5 سنوات',
  'lease_5050': 'تأجيري — نظام 50/50',
};

const _bankOrder = [
  'rajhi', 'snb', 'inma', 'riyadh', 'saab', 'fransi',
  'anb', 'bilad', 'jazira', 'saib', 'enbd',
];

// الاسم القانوني لكل بنك حسب المعرّف الثابت (نفس مرجع الصفحة الأصلية + Cloud Function).
// نعرض دائماً كل الـ11 بنكاً بهذا المرجع حتى لا يختفي بنك ولا يتكرّر.
const _bankIdToNameAr = <String, String>{
  'rajhi': 'مصرف الراجحي',
  'snb': 'البنك الأهلي السعودي',
  'inma': 'مصرف الإنماء',
  'riyadh': 'بنك الرياض',
  'saab': 'البنك السعودي الأول (ساب)',
  'fransi': 'البنك السعودي الفرنسي',
  'anb': 'البنك العربي الوطني',
  'bilad': 'بنك البلاد',
  'jazira': 'بنك الجزيرة',
  'saib': 'البنك السعودي للاستثمار',
  'enbd': 'بنك الإمارات دبي الوطني',
};

// معرّفات البيانات الافتراضية (نموذج profit_margin_model) → المعرّف القانوني.
// تختلف تسمية بنكين فقط، فنوحّدهما حتى يُستخدما كمؤشر تمثيلي للبنك الصحيح.
const _modelIdToCanonical = <String, String>{
  'sibc': 'saib',
  'gib': 'enbd',
};

// ── Mapping: Cloud Function product keys → new page product types ───
const _cfKeyToProductTypes = <String, List<String>>{
  'personalBasic': ['personal_new'],
  'personalSpecial': ['personal_topup', 'personal_buyout'],
  'realEstateSupportedProgram': [
    'realestate_subsidized_ready',
    'realestate_subsidized_offplan',
  ],
  'realEstateSupportedMinistry': [
    'realestate_subsidized_construction',
    'realestate_subsidized_mortgage',
  ],
  'realEstateCommercial': ['realestate_standard'],
  'leasingVehicles': ['lease_5yr', 'lease_5050'],
};

const _productTerms = <String, String>{
  'personal_new': 'حتى 5 سنوات',
  'personal_topup': 'حتى 5 سنوات',
  'personal_buyout': 'حتى 5 سنوات',
  'realestate_subsidized_ready': 'حتى 25 سنة',
  'realestate_subsidized_offplan': 'حتى 25 سنة',
  'realestate_subsidized_construction': 'حتى 25 سنة',
  'realestate_subsidized_mortgage': 'حتى 25 سنة',
  'realestate_standard': 'حتى 25 سنة',
  'lease_5yr': 'حتى 5 سنوات',
  'lease_5050': 'حتى 5 سنوات',
};

// ── Data Models ─────────────────────────────────────────────────────
class _BankMarginRow {
  const _BankMarginRow({
    required this.bankKey,
    required this.bankNameAr,
    required this.productType,
    required this.profitMarginRate,
    required this.marginType,
    required this.term,
    required this.confidence,
  });

  final String bankKey;
  final String bankNameAr;
  final String productType;
  final double? profitMarginRate;
  final String? marginType;
  final String? term;
  final String confidence;
}

class _MetaInfo {
  const _MetaInfo({
    this.lastUpdatedAt,
    this.sourceNote,
  });

  final DateTime? lastUpdatedAt;
  final String? sourceNote;
}

// =====================================================================
// MAIN PAGE
// =====================================================================
class BankMarginsNewPage extends StatefulWidget {
  const BankMarginsNewPage({super.key});

  @override
  State<BankMarginsNewPage> createState() => _BankMarginsNewPageState();
}

class _BankMarginsNewPageState extends State<BankMarginsNewPage> {
  bool _loading = true;
  bool _refreshing = false;
  bool _cloudUpdating = false;
  String? _error;
  List<_BankMarginRow> _rows = [];
  _MetaInfo _meta = const _MetaInfo();
  String? _toastMessage;

  String _activeCategory = 'تمويل شخصي';
  final Map<String, String> _activeSub = {
    'تمويل شخصي': 'جديد',
    'عقاري مدعوم': 'جاهز',
    'عقاري اعتيادي': 'عقاري اعتيادي',
    'تأجيري': 'نظام 5 سنوات',
  };

  String _searchQuery = '';
  String _bankFilter = '';
  String _marginSort = 'default';
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Load from Firestore ───────────────────────────────────────────
  // يقرأ من bank_rates/profit_margins (نفس المصدر الذي تُحدّثه Cloud Function).
  // يضمن: (1) ظهور كل الـ11 بنكاً مرة واحدة فقط لكل منتج (لا تكرار، لا اختفاء).
  //        (2) قيمة حيّة عند توفّرها، وإلا مؤشر تمثيلي حتى لا يبقى أي بنك فارغاً.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final db = FirebaseFirestore.instance;
      final doc = await db.doc('bank_rates/profit_margins').get();

      // (أ) فهرسة البيانات الحيّة حسب المعرّف القانوني — آخر إدخال يفوز فيزول التكرار.
      final liveByBank = <String, Map<String, dynamic>>{};
      _MetaInfo meta = const _MetaInfo();

      if (doc.exists) {
        final data = doc.data()!;
        final banks = data['banks'];
        if (banks is List) {
          for (final bankRaw in banks) {
            if (bankRaw is! Map) continue;
            final bankMap = Map<String, dynamic>.from(bankRaw);
            final rawId = (bankMap['bankId'] as String?) ?? '';
            final bankId = _modelIdToCanonical[rawId] ?? rawId;
            if (bankId.isEmpty) continue;
            final products = bankMap['products'];
            if (products is Map) {
              liveByBank[bankId] = Map<String, dynamic>.from(products);
            }
          }
        }
        final ts = data['lastUpdated'];
        final summary = data['aiSummary'] as String?;
        meta = _MetaInfo(
          lastUpdatedAt: ts is Timestamp ? ts.toDate() : null,
          sourceNote: summary,
        );
      }

      // (ب) مؤشر تمثيلي افتراضي من نموذج البيانات (مصدر مشترك مع الصفحة الأصلية).
      final fallbackByBank = <String, Map<String, double>>{};
      for (final b in ProfitMarginsConfig.defaultConfig().banks) {
        final canon = _modelIdToCanonical[b.bankId] ?? b.bankId;
        final m = <String, double>{};
        b.products.forEach((key, pm) {
          if (pm.available && (pm.min > 0 || pm.max > 0)) {
            m[key] = pm.min > 0 && pm.max > 0
                ? (pm.min + pm.max) / 2
                : (pm.min > 0 ? pm.min : pm.max);
          }
        });
        fallbackByBank[canon] = m;
      }

      // (ج) بناء صف لكل (بنك × منتج) عبر القائمة القانونية الثابتة.
      final rows = <_BankMarginRow>[];
      for (final bankId in _bankOrder) {
        final nameAr = _bankIdToNameAr[bankId] ?? bankId;
        final liveProducts = liveByBank[bankId];
        final fb = fallbackByBank[bankId];

        for (final entry in _cfKeyToProductTypes.entries) {
          final cfKey = entry.key;
          final targetTypes = entry.value;

          // القيمة الحيّة (إن وُجدت وصالحة)
          double? liveRate;
          final p = liveProducts?[cfKey];
          if (p is Map) {
            final prodMap = Map<String, dynamic>.from(p);
            final available = prodMap['available'] as bool? ?? false;
            final min = (prodMap['min'] as num?)?.toDouble() ?? 0;
            final max = (prodMap['max'] as num?)?.toDouble() ?? 0;
            if (available && (min > 0 || max > 0)) {
              liveRate =
                  min > 0 && max > 0 ? (min + max) / 2 : (min > 0 ? min : max);
            }
          }
          final fbRate = fb?[cfKey];

          for (final productType in targetTypes) {
            double? rate;
            String confidence;
            if (liveRate != null) {
              rate = liveRate;
              confidence = 'HIGH';
            } else if (fbRate != null) {
              rate = fbRate;
              confidence = 'MEDIUM';
            } else {
              rate = null;
              confidence = 'UNAVAILABLE';
            }

            rows.add(_BankMarginRow(
              bankKey: bankId,
              bankNameAr: nameAr,
              productType: productType,
              profitMarginRate: rate,
              marginType: null,
              term: _productTerms[productType],
              confidence: confidence,
            ));
          }
        }
      }

      if (mounted) {
        setState(() {
          _rows = rows;
          _meta = meta;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _refreshing = true);
    await _load();
    if (mounted) {
      setState(() => _refreshing = false);
      if (_error == null) _showToast('تم تحديث البيانات بنجاح');
    }
  }

  Future<void> _triggerCloudUpdate() async {
    setState(() => _cloudUpdating = true);
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('triggerProfitMarginsUpdate',
              options: HttpsCallableOptions(timeout: const Duration(minutes: 9)));
      await callable.call();
      await _load();
      if (mounted) _showToast('تم تحديث البيانات من المصادر الرسمية بنجاح');
    } catch (e) {
      if (mounted) {
        _showToast('فشل التحديث: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      if (mounted) setState(() => _cloudUpdating = false);
    }
  }

  // ── Toast ─────────────────────────────────────────────────────────
  void _showToast(String msg) {
    setState(() => _toastMessage = msg);
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _toastMessage = null);
    });
  }

  // ── Filtered Data ─────────────────────────────────────────────────
  List<_BankMarginRow> get _filteredData {
    final sub = _activeSub[_activeCategory] ?? '';
    final productType = _subToProductType[sub] ?? '';
    var data = _rows
        .where((r) =>
            r.productType == productType && r.confidence != 'UNAVAILABLE')
        .toList();

    if (data.isEmpty) {
      data = _rows.where((r) => r.productType == productType).toList();
    }

    if (_searchQuery.isNotEmpty) {
      data = data.where((r) => r.bankNameAr.contains(_searchQuery)).toList();
    }
    if (_bankFilter.isNotEmpty) {
      data = data.where((r) => r.bankNameAr == _bankFilter).toList();
    }

    data.sort((a, b) {
      final ai = _bankOrder.indexOf(a.bankKey);
      final bi = _bankOrder.indexOf(b.bankKey);
      return (ai == -1 ? 999 : ai).compareTo(bi == -1 ? 999 : bi);
    });

    if (_marginSort == 'lowest') {
      data.sort((a, b) {
        final ar = a.profitMarginRate ?? 999;
        final br = b.profitMarginRate ?? 999;
        return ar.compareTo(br);
      });
    }

    return data;
  }

  List<String> get _bankNames {
    final seen = <String>{};
    final result = <String>[];
    for (final key in _bankOrder) {
      final match = _rows.where((r) => r.bankKey == key);
      if (match.isNotEmpty && seen.add(match.first.bankNameAr)) {
        result.add(match.first.bankNameAr);
      }
    }
    for (final r in _rows) {
      if (r.bankNameAr.isNotEmpty && seen.add(r.bankNameAr)) {
        result.add(r.bankNameAr);
      }
    }
    return result;
  }

  bool get _isMortgage =>
      _activeCategory == 'عقاري مدعوم' || _activeCategory == 'عقاري اعتيادي';

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Stack(
          children: [
            if (_loading)
              const Center(
                child: CircularProgressIndicator(color: _greenPrimary),
              )
            else
              RefreshIndicator(
                color: _greenPrimary,
                onRefresh: _refreshData,
                child: CustomScrollView(
                  slivers: [
                    _buildHeroSliver(),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 32 : 12,
                        vertical: 16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          if (_error != null) ...[
                            _buildErrorBanner(),
                            const SizedBox(height: 12),
                          ],
                          _buildSearchBar(),
                          if (_showFilters) ...[
                            const SizedBox(height: 8),
                            _buildFiltersPanel(),
                          ],
                          const SizedBox(height: 16),
                          _buildCategoryTabs(),
                          const SizedBox(height: 12),
                          _buildSubTabs(),
                          const SizedBox(height: 12),
                          _buildSectionHeader(),
                          const SizedBox(height: 8),
                          ..._buildRateCards(),
                          if (_isMortgage) ...[
                            const SizedBox(height: 12),
                            _buildMortgageNote(),
                          ],
                          const SizedBox(height: 20),
                          _buildRefreshButton(),
                          const SizedBox(height: 20),
                          _buildStatsCards(),
                          const SizedBox(height: 24),
                          _buildFooter(),
                          const SizedBox(height: 80),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            if (_toastMessage != null) _buildToast(),
          ],
        ),
      ),
    );
  }

  // ── Hero Section ──────────────────────────────────────────────────
  Widget _buildHeroSliver() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0x4D006C35), _bgColor],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, color: _goldAccent, size: 16),
                  SizedBox(width: 6),
                  Text('بيانات من صفحات الإفصاح الرسمية',
                      style: TextStyle(color: _textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'هوامش الربح ومعدل '),
                  TextSpan(
                    text: 'النسبة السنوي',
                    style: TextStyle(color: _goldAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'بيانات البنوك السعودية من المصادر الرسمية | محدّث دورياً',
              style: TextStyle(color: _textMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _rateLow.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _rateLow.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_rounded, color: _rateLow, size: 14),
                  SizedBox(width: 6),
                  Text('تحديث تلقائي — بداية كل شهر ميلادي',
                      style: TextStyle(color: _rateLow, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_cloudUpdating || _refreshing) ? null : _triggerCloudUpdate,
                icon: _cloudUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.cloud_sync_rounded, size: 20),
                label: Text(
                  _cloudUpdating
                      ? 'جارٍ جلب البيانات من البنوك...'
                      : 'تحديث البيانات الآن',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _greenPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
              ),
            ),
            if (_cloudUpdating)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'يتم جلب البيانات من صفحات البنوك الرسمية — قد يستغرق دقيقة',
                  style: TextStyle(color: _amberText, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_meta.lastUpdatedAt != null && !_cloudUpdating) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: _textMuted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'آخر تحديث: ${_formatDateTime(_meta.lastUpdatedAt!)}',
                    style: const TextStyle(color: _textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
            if (_meta.lastUpdatedAt == null && !_cloudUpdating)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'اضغط "تحديث البيانات الآن" لجلب أحدث البيانات',
                  style: TextStyle(color: _textMuted, fontSize: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: _textPrimary, fontSize: 14),
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'ابحث عن بنك...',
                hintStyle: TextStyle(color: _textMuted, fontSize: 13),
                prefixIcon:
                    Icon(Icons.search_rounded, color: _textMuted, size: 20),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: _showFilters
              ? _greenPrimary.withValues(alpha: 0.15)
              : _cardColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showFilters ? _greenPrimary : _borderColor,
                ),
              ),
              child: Icon(Icons.filter_list_rounded,
                  color: _showFilters ? _rateLow : _textMuted, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  // ── Filters Panel ─────────────────────────────────────────────────
  Widget _buildFiltersPanel() {
    final banks = _bankNames;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          _buildDropdown(
            label: 'فلتر حسب البنك',
            value: _bankFilter.isEmpty ? null : _bankFilter,
            items: [
              const DropdownMenuItem(value: '', child: Text('جميع البنوك')),
              ...banks
                  .map((b) => DropdownMenuItem(value: b, child: Text(b))),
            ],
            onChanged: (v) => setState(() => _bankFilter = v ?? ''),
          ),
          const SizedBox(height: 10),
          _buildDropdown(
            label: 'ترتيب الهامش',
            value: _marginSort,
            items: const [
              DropdownMenuItem(
                  value: 'default', child: Text('الترتيب الافتراضي')),
              DropdownMenuItem(
                  value: 'lowest', child: Text('الأقل هامشاً أولاً')),
            ],
            onChanged: (v) => setState(() => _marginSort = v ?? 'default'),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() {
                _bankFilter = '';
                _marginSort = 'default';
                _searchQuery = '';
              }),
              icon: const Icon(Icons.clear_rounded, size: 16, color: _rateHigh),
              label: const Text('مسح الفلاتر',
                  style: TextStyle(color: _rateHigh, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: _cardColor,
              style: const TextStyle(color: _textPrimary, fontSize: 13),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: _textMuted),
            ),
          ),
        ),
      ],
    );
  }

  // ── Category Tabs ─────────────────────────────────────────────────
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isActive = _activeCategory == cat.id;
          return GestureDetector(
            onTap: () => setState(() => _activeCategory = cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive ? _greenPrimary : _cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? _greenPrimary : _borderColor,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: _greenPrimary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(cat.icon,
                      size: 16,
                      color: isActive ? Colors.white : _textMuted),
                  const SizedBox(width: 6),
                  Text(
                    cat.shortLabel,
                    style: TextStyle(
                      color: isActive ? Colors.white : _textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Sub Tabs ──────────────────────────────────────────────────────
  Widget _buildSubTabs() {
    final subs = _subSections[_activeCategory] ?? [];
    if (subs.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: subs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final sub = subs[i];
          final isActive = _activeSub[_activeCategory] == sub;
          return GestureDetector(
            onTap: () => setState(() => _activeSub[_activeCategory] = sub),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? _goldAccent : _cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive ? _goldAccent : _borderColor,
                ),
              ),
              child: Center(
                child: Text(
                  sub,
                  style: TextStyle(
                    color: isActive ? Colors.white : _textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_activeCategory — ${_activeSub[_activeCategory]}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _meta.lastUpdatedAt != null
                        ? 'من المصادر الرسمية | ${_formatDateTime(_meta.lastUpdatedAt!)}'
                        : 'اضغط تحديث لتحميل البيانات',
                    style: const TextStyle(color: _textMuted, fontSize: 11),
                  ),
                  const SizedBox(width: 10),
                  _legendDot(_rateLow, 'الأقل'),
                  const SizedBox(width: 8),
                  _legendDot(_rateHigh, 'الأعلى'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(color: color, fontSize: 10)),
      ],
    );
  }

  // ── Rate Cards ────────────────────────────────────────────────────
  List<Widget> _buildRateCards() {
    final data = _filteredData;
    if (data.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: const Text('لا توجد بيانات',
              style: TextStyle(color: _textMuted, fontSize: 14)),
        ),
      ];
    }

    final rates = data
        .where((r) => r.profitMarginRate != null)
        .map((r) => r.profitMarginRate!)
        .toList();
    final minRate = rates.isNotEmpty
        ? rates.reduce((a, b) => a < b ? a : b)
        : 0.0;
    final maxRate = rates.isNotEmpty
        ? rates.reduce((a, b) => a > b ? a : b)
        : 0.0;

    return data.map((r) {
      final hasRate = r.profitMarginRate != null;
      final val = r.profitMarginRate ?? 0;
      final rateTxt =
          hasRate ? '${r.profitMarginRate!.toStringAsFixed(2)}%' : '—';

      final isMin =
          hasRate && val == minRate && rates.length > 1;
      final isMax = hasRate &&
          val == maxRate &&
          rates.length > 1 &&
          minRate != maxRate;

      Color marginColor = _textPrimary;
      Color borderCol = _borderColor;
      if (isMin) {
        marginColor = _rateLow;
        borderCol = _rateLow.withValues(alpha: 0.5);
      } else if (isMax) {
        marginColor = _rateHigh;
        borderCol = _rateHigh.withValues(alpha: 0.5);
      }

      final marginTypeLabel = r.marginType == 'fixed'
          ? 'ثابت'
          : r.marginType == 'variable'
              ? 'متغير'
              : null;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showBankModal(r.bankKey, r.bankNameAr),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.business_rounded,
                          color: _goldAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          r.bankNameAr,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: marginColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: marginColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              rateTxt,
                              style: TextStyle(
                                color: marginColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (isMin)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.arrow_downward_rounded,
                                    color: _rateLow, size: 14),
                              ),
                            if (isMax)
                              const Padding(
                                padding: EdgeInsets.only(right: 4),
                                child: Icon(Icons.arrow_upward_rounded,
                                    color: _rateHigh, size: 14),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (r.term != null && r.term!.isNotEmpty) ...[
                        const Icon(Icons.access_time_rounded,
                            color: _textMuted, size: 14),
                        const SizedBox(width: 4),
                        Text(r.term!,
                            style: const TextStyle(
                                color: _textMuted, fontSize: 12)),
                        const SizedBox(width: 12),
                      ],
                      if (marginTypeLabel != null) ...[
                        _infoChip(marginTypeLabel),
                        const SizedBox(width: 8),
                      ],
                      _confidenceChip(r.confidence),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x26374151),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: const TextStyle(color: _textSecondary, fontSize: 10)),
    );
  }

  Widget _confidenceChip(String confidence) {
    Color bg;
    Color fg;
    String label;
    switch (confidence) {
      case 'HIGH':
        bg = const Color(0x2610B981);
        fg = _rateLow;
        label = 'موثّق';
      case 'MEDIUM':
        bg = _amberBg;
        fg = _amberText;
        label = 'يحتاج تحقق';
      default:
        bg = const Color(0x26374151);
        fg = _textMuted;
        label = 'غير متاح';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10)),
    );
  }

  // ── Bank Detail Modal ─────────────────────────────────────────────
  void _showBankModal(String bankKey, String bankName) {
    final bankRows = _rows
        .where((r) => r.bankKey == bankKey && r.confidence != 'UNAVAILABLE')
        .toList();
    if (bankRows.isEmpty) return;

    bankRows.sort((a, b) {
      final ai = [
        'personal_new', 'personal_topup', 'personal_buyout',
        'realestate_subsidized_ready', 'realestate_subsidized_offplan',
        'realestate_subsidized_construction', 'realestate_subsidized_mortgage',
        'realestate_standard', 'lease_5yr', 'lease_5050',
      ].indexOf(a.productType);
      final bi = [
        'personal_new', 'personal_topup', 'personal_buyout',
        'realestate_subsidized_ready', 'realestate_subsidized_offplan',
        'realestate_subsidized_construction', 'realestate_subsidized_mortgage',
        'realestate_standard', 'lease_5yr', 'lease_5050',
      ].indexOf(b.productType);
      return (ai == -1 ? 999 : ai).compareTo(bi == -1 ? 999 : bi);
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(
                    color: _textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_greenPrimary, _greenDark],
                    ),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bankName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            const SizedBox(height: 2),
                            const Text('جميع المنتجات التمويلية',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.all(14),
                    itemCount: bankRows.length,
                    itemBuilder: (_, i) {
                      final r = bankRows[i];
                      final label =
                          _productLabels[r.productType] ?? r.productType;
                      final rateTxt = r.profitMarginRate != null
                          ? '${r.profitMarginRate!.toStringAsFixed(2)}%'
                          : '—';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _rateLow.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                        color: _rateLow,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  rateTxt,
                                  style: const TextStyle(
                                    color: _goldAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _detailItem(
                                    'النوع',
                                    r.marginType == 'fixed'
                                        ? 'ثابت'
                                        : r.marginType == 'variable'
                                            ? 'متغير'
                                            : '—'),
                                const SizedBox(width: 16),
                                _detailItem('الثقة', r.confidence),
                              ],
                            ),
                            if (r.term != null && r.term!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              _detailItem('المدة', r.term!),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailItem(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12),
        children: [
          TextSpan(
              text: '$label: ',
              style: const TextStyle(color: _textMuted)),
          TextSpan(
              text: value,
              style: const TextStyle(color: _textSecondary)),
        ],
      ),
    );
  }

  // ── Mortgage Note ─────────────────────────────────────────────────
  Widget _buildMortgageNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _amberBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _amberBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: _amberText, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'النتائج تقريبية لأغراض توعوية فقط — النِّسب من صفحات الإفصاح الرسمية وقد تتغيّر.',
              style: TextStyle(color: _amberText, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ── Refresh Button ────────────────────────────────────────────────
  Widget _buildRefreshButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: (_cloudUpdating || _refreshing) ? null : _triggerCloudUpdate,
        icon: _cloudUpdating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: _greenPrimary),
              )
            : const Icon(Icons.cloud_sync_rounded,
                size: 16, color: _greenPrimary),
        label: Text(
          _cloudUpdating ? 'جارٍ جلب البيانات...' : 'تحديث البيانات الآن',
          style: const TextStyle(
            color: _greenPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _greenPrimary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: _greenPrimary.withValues(alpha: 0.05),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── Stats Cards ───────────────────────────────────────────────────
  Widget _buildStatsCards() {
    final uniqueBanks =
        _rows.map((r) => r.bankKey).toSet().length;
    final availableRates =
        _rows.where((r) => r.confidence != 'UNAVAILABLE').length;

    final stats = [
      {'val': '$uniqueBanks', 'label': 'بنك سعودي', 'isGold': false},
      {'val': '$availableRates', 'label': 'نسبة متاحة', 'isGold': true},
      {'val': '4', 'label': 'فئات تمويلية', 'isGold': false},
      {'val': 'رسمي', 'label': 'مصادر الإفصاح', 'isGold': true},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: stats.map((s) {
        final isGold = s['isGold'] as bool;
        return Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                s['val'] as String,
                style: TextStyle(
                  color: isGold ? _goldAccent : _rateLow,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s['label'] as String,
                style: const TextStyle(color: _textMuted, fontSize: 11),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0D14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _greenPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 6),
              const Text('NESAB',
                  style: TextStyle(
                      color: _goldAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _meta.sourceNote ??
                'بيانات من صفحات الإفصاح الرسمية للبنوك السعودية. النِّسب تقريبية لأغراض توعوية فقط — تحقق دائماً من البنك قبل التقديم.',
            style: const TextStyle(color: _textMuted, fontSize: 11, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text('© 2024 NESAB',
              style: TextStyle(color: _textMuted, fontSize: 10)),
        ],
      ),
    );
  }

  // ── Error Banner ──────────────────────────────────────────────────
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rateHigh.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rateHigh.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: _rateHigh, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_error!,
                style: const TextStyle(color: _rateHigh, fontSize: 12)),
          ),
          IconButton(
            onPressed: () => setState(() => _error = null),
            icon: const Icon(Icons.close_rounded, color: _rateHigh, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Toast ─────────────────────────────────────────────────────────
  Widget _buildToast() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _rateLow,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _rateLow.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _toastMessage!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _toastMessage = null),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white70, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
  String _formatDateTime(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
