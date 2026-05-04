import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/app_config_model.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/page_block_model.dart';
import 'package:nesab_dashboard/features/dashboard/data/repositories/app_config_repository.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/app_pages_cubit.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/app_pages_state.dart';
import 'package:nesab_dashboard/shared/widgets/app_image.dart';

// ─── Page Gallery model ───────────────────────────────────────────────────────

class _PageItem {
  final String id, nameAr, nameEn, imageUrl, link, calculatorType;
  final bool isActive, isBuiltIn;
  final int order;
  const _PageItem({
    required this.id, required this.nameAr, required this.nameEn,
    this.imageUrl = '', this.link = '', this.calculatorType = '',
    this.isActive = true, this.isBuiltIn = true, this.order = 0,
  });
  _PageItem copyWith({String? nameAr, String? nameEn, String? imageUrl, String? link, bool? isActive, int? order}) =>
      _PageItem(
        id: id, nameAr: nameAr ?? this.nameAr, nameEn: nameEn ?? this.nameEn,
        imageUrl: imageUrl ?? this.imageUrl, link: link ?? this.link,
        calculatorType: calculatorType, isActive: isActive ?? this.isActive,
        isBuiltIn: isBuiltIn, order: order ?? this.order,
      );
  Map<String, dynamic> toMap() => {
    'id': id, 'nameAr': nameAr, 'nameEn': nameEn, 'imageUrl': imageUrl,
    'link': link, 'calculatorType': calculatorType,
    'isActive': isActive, 'isBuiltIn': isBuiltIn, 'order': order,
  };
  factory _PageItem.fromMap(Map<String, dynamic> d) => _PageItem(
    id: d['id']?.toString() ?? '', nameAr: d['nameAr']?.toString() ?? '',
    nameEn: d['nameEn']?.toString() ?? '', imageUrl: d['imageUrl']?.toString() ?? '',
    link: d['link']?.toString() ?? '', calculatorType: d['calculatorType']?.toString() ?? '',
    isActive: d['isActive'] as bool? ?? true, isBuiltIn: d['isBuiltIn'] as bool? ?? false,
    order: d['order'] as int? ?? 99,
  );
}

IconData _pageIcon(String id, [String calculatorType = '', String arabicName = '']) {
  // Built-in screen ids
  switch (id) {
    case 'splash':          return Icons.play_circle_outline;
    case 'onboarding':      return Icons.swipe_rounded;
    case 'login':           return Icons.login_rounded;
    case 'register':        return Icons.person_add_rounded;
    case 'forgot_password': return Icons.lock_reset_rounded;
    case 'home':            return Icons.home_rounded;
    case 'profile':         return Icons.person_rounded;
    case 'settings':        return Icons.settings_rounded;
  }
  // From calculatorType
  if (calculatorType.isNotEmpty) {
    final t = calculatorType.toLowerCase();
    if (t.contains('shakhsi') || t.contains('personal') || t.contains('madyoni')) return Icons.person_rounded;
    if (t.contains('aqari') || t.contains('real')) return Icons.home_work_rounded;
    if (t.contains('tajiri') || t.contains('leas')) return Icons.directions_car_rounded;
    if (t.contains('pos') || t.contains('niqat')) return Icons.point_of_sale_rounded;
    if (t.contains('himaya') || t.contains('protect')) return Icons.shield_rounded;
    if (t.contains('khayrat') || t.contains('khairat')) return Icons.savings_rounded;
    if (t.contains('umr') || t.contains('age')) return Icons.cake_rounded;
    if (t.contains('tarikh') || t.contains('date')) return Icons.calendar_today_rounded;
    if (t.contains('rusoom') || t.contains('fees')) return Icons.account_balance_rounded;
    if (t.contains('umla') || t.contains('currency')) return Icons.currency_exchange_rounded;
    if (t.contains('asham') || t.contains('stock')) return Icons.show_chart_rounded;
    if (t.contains('hawamish') || t.contains('margin')) return Icons.bar_chart_rounded;
    if (t.contains('istiqtaa') || t.contains('deduc')) return Icons.percent_rounded;
  }
  // From arabicName
  if (arabicName.contains('شخصي') || arabicName.contains('مديونية')) return Icons.person_rounded;
  if (arabicName.contains('عقاري')) return Icons.home_work_rounded;
  if (arabicName.contains('تأجيري')) return Icons.directions_car_rounded;
  if (arabicName.contains('نقاط البيع')) return Icons.point_of_sale_rounded;
  if (arabicName.contains('حماية') || arabicName.contains('ادخار')) return Icons.shield_rounded;
  if (arabicName.contains('خيرات') || arabicName.contains('وديعة')) return Icons.savings_rounded;
  if (arabicName.contains('عمر')) return Icons.cake_rounded;
  if (arabicName.contains('تاريخ')) return Icons.calendar_today_rounded;
  if (arabicName.contains('رسوم')) return Icons.account_balance_rounded;
  if (arabicName.contains('عملة')) return Icons.currency_exchange_rounded;
  if (arabicName.contains('أسهم') || arabicName.contains('سهم')) return Icons.show_chart_rounded;
  if (arabicName.contains('هامش') || arabicName.contains('ربح')) return Icons.bar_chart_rounded;
  if (arabicName.contains('استقطاع')) return Icons.percent_rounded;
  return Icons.calculate_rounded;
}

IconData _blockIcon(String type) {
  switch (type) {
    case 'banner':          return Icons.view_carousel_rounded;
    case 'card':            return Icons.credit_card_rounded;
    case 'button':          return Icons.smart_button_rounded;
    case 'text':            return Icons.text_fields_rounded;
    case 'image':           return Icons.image_rounded;
    case 'section_header':  return Icons.title_rounded;
    case 'spacer':          return Icons.space_bar_rounded;
    default:                return Icons.widgets_rounded;
  }
}

// ─── Entry ────────────────────────────────────────────────────────────────────

class AppPagesPage extends StatelessWidget {
  const AppPagesPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppPagesCubit(AppConfigRepository())..loadAll(),
      child: const _AppPagesView(),
    );
  }
}

// ─── Main View ────────────────────────────────────────────────────────────────

class _AppPagesView extends StatefulWidget {
  const _AppPagesView();
  @override
  State<_AppPagesView> createState() => _AppPagesViewState();
}

class _AppPagesViewState extends State<_AppPagesView> {
  final _fs = FirebaseFirestore.instance;
  final _st = FirebaseStorage.instance;

  // ── Level 1 state ──
  List<_PageItem> _pages = [];
  bool _loadingPages = true;
  _PageItem? _editingPage;

  // ── Level 2 state (drill-in) ──
  _PageItem? _viewingPage;
  List<PageBlock> _blocks = [];
  bool _loadingBlocks = false;
  PageBlock? _editingBlock;

  @override
  void initState() { super.initState(); _loadPages(); }

  // ── Gallery ──────────────────────────────────────────────────────────────

  Future<void> _loadPages() async {
    setState(() => _loadingPages = true);
    try {
      final snap = await _fs.collection('categories').get();
      final loaded = snap.docs.map((doc) {
        final d = doc.data();
        return _PageItem(
          id: doc.id,
          nameAr: d['arabicName']?.toString() ?? '',
          nameEn: d['englishName']?.toString() ?? '',
          imageUrl: d['imageUrl']?.toString() ?? '',
          link: d['calculatorLink']?.toString() ?? '',
          calculatorType: d['calculatorType']?.toString() ?? '',
          isActive: d['isActive'] as bool? ?? true,
          order: (d['orderNumber'] as num?)?.toInt() ?? 99,
          isBuiltIn: true,
        );
      }).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      setState(() { _pages = loaded; _loadingPages = false; });
    } catch (_) {
      setState(() { _pages = []; _loadingPages = false; });
    }
  }

  Future<void> _updatePage(_PageItem updated) async {
    final idx = _pages.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) {
      setState(() => _pages[idx] = updated);
    } else {
      setState(() => _pages.add(updated));
    }
    if (_editingPage?.id == updated.id) setState(() => _editingPage = updated);
    await _fs.doc('categories/${updated.id}').set({
      'arabicName': updated.nameAr,
      'englishName': updated.nameEn,
      'imageUrl': updated.imageUrl,
      'isActive': updated.isActive,
      'orderNumber': updated.order,
      'calculatorLink': updated.link,
    }, SetOptions(merge: true));
  }

  Future<void> _deletePage(_PageItem page) async {
    if (page.isBuiltIn) return;
    final ok = await _confirm('حذف الصفحة "${page.nameAr}"؟');
    if (ok) {
      setState(() {
        _pages.removeWhere((p) => p.id == page.id);
        if (_editingPage?.id == page.id) _editingPage = null;
      });
      await _fs.doc('categories/${page.id}').delete();
    }
  }

  Future<void> _addPage(String nameAr, String nameEn) async {
    final ref = await _fs.collection('categories').add({
      'arabicName': nameAr,
      'englishName': nameEn,
      'imageUrl': '',
      'calculatorLink': '',
      'calculatorType': '',
      'isActive': true,
      'orderNumber': _pages.length,
    });
    final p = _PageItem(
      id: ref.id, nameAr: nameAr, nameEn: nameEn,
      isBuiltIn: false, order: _pages.length,
    );
    setState(() { _pages.add(p); _editingPage = p; });
  }

  // ── Blocks (Level 2) ─────────────────────────────────────────────────────

  Future<void> _openPage(_PageItem page) async {
    setState(() { _viewingPage = page; _editingBlock = null; _loadingBlocks = true; _blocks = []; });
    try {
      final doc = await _fs.doc('page_blocks/${page.id}').get();
      if (doc.exists) {
        final list = (doc.data()?['blocks'] as List<dynamic>? ?? []);
        final loaded = list.map((e) => PageBlock.fromMap(e as Map<String, dynamic>)).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
        setState(() => _blocks = loaded);
      }
    } catch (_) {}
    setState(() => _loadingBlocks = false);
  }

  Future<void> _saveBlocks() async {
    await _fs.doc('page_blocks/${_viewingPage!.id}').set(
      {'blocks': _blocks.map((b) => b.toMap()).toList()});
  }

  Future<void> _saveBlock(PageBlock updated) async {
    final idx = _blocks.indexWhere((b) => b.id == updated.id);
    if (idx >= 0) {
      setState(() => _blocks[idx] = updated);
    } else {
      setState(() => _blocks.add(updated));
    }
    if (_editingBlock?.id == updated.id) setState(() => _editingBlock = updated);
    await _saveBlocks();
  }

  Future<void> _deleteBlock(PageBlock block) async {
    final ok = await _confirm('حذف البلوك "${block.nameAr}"؟');
    if (ok) {
      setState(() {
        _blocks.removeWhere((b) => b.id == block.id);
        if (_editingBlock?.id == block.id) _editingBlock = null;
      });
      await _saveBlocks();
    }
  }

  void _addBlock() {
    final newBlock = PageBlock(
      id: 'block_${DateTime.now().millisecondsSinceEpoch}',
      pageId: _viewingPage!.id,
      type: 'card',
      nameAr: 'بلوك جديد',
      order: _blocks.length,
    );
    setState(() { _blocks.add(newBlock); _editingBlock = newBlock; });
    _saveBlocks();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<String?> _upload(Uint8List bytes, String path) async {
    try {
      final ref = _st.ref().child(path);
      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (_) { return null; }
  }

  Future<bool> _confirm(String msg) async {
    final ok = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ));
    return ok == true;
  }

  Future<void> _showAddPageDialog() async {
    final arC = TextEditingController(), enC = TextEditingController();
    final ok = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة صفحة جديدة'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: arC, textDirection: TextDirection.rtl, decoration: const InputDecoration(labelText: 'الاسم بالعربية *')),
          const SizedBox(height: 12),
          TextField(controller: enC, decoration: const InputDecoration(labelText: 'الاسم بالإنجليزية')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () { if (arC.text.trim().isNotEmpty) Navigator.pop(ctx, true); }, child: const Text('إضافة')),
        ],
      ));
    if (ok == true && arC.text.trim().isNotEmpty) await _addPage(arC.text.trim(), enC.text.trim());
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppPagesCubit, AppPagesState>(
      listener: (context, state) {
        if (state.saved) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ تم الحفظ'), backgroundColor: AppColors.success, duration: Duration(seconds: 2)));
        }
        if (state.status == AppPagesStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage ?? 'خطأ'), backgroundColor: AppColors.error));
        }
      },
      child: _viewingPage == null ? _buildLevel1() : _buildLevel2(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Level 1 — Page Grid
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLevel1() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimensions.spacingLg, AppDimensions.spacingLg, AppDimensions.spacingLg, AppDimensions.spacingMd),
          child: Row(children: [
            const FaIcon(FontAwesomeIcons.mobileScreen, size: 18),
            const SizedBox(width: 10),
            Text('صفحات التطبيق', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Text('${_pages.length} صفحة', style: const TextStyle(fontSize: 12, color: AppColors.blue)),
            ),
            const Spacer(),
            FilledButton.icon(onPressed: _showAddPageDialog, icon: const Icon(Icons.add, size: 18), label: const Text('إضافة صفحة')),
          ]),
        ),
        const Divider(height: 1),
        Expanded(child: _loadingPages
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: LayoutBuilder(builder: (ctx, c) {
                final cols = (c.maxWidth / 180).floor().clamp(2, 8);
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols, crossAxisSpacing: AppDimensions.spacingMd,
                    mainAxisSpacing: AppDimensions.spacingMd, childAspectRatio: 0.82),
                  itemCount: _pages.length,
                  itemBuilder: (ctx, i) => _PageCard(
                    page: _pages[i],
                    isSelected: _editingPage?.id == _pages[i].id,
                    isDark: isDark,
                    onEdit: () => setState(() => _editingPage = _pages[i]),
                    onView: () => _openPage(_pages[i]),
                    onDelete: _pages[i].isBuiltIn ? null : () => _deletePage(_pages[i]),
                  ),
                );
              }),
            )),
      ])),
      // Right panel (page visual + config)
      if (_editingPage != null) ...[
        Container(width: 1, color: Theme.of(context).dividerColor),
        SizedBox(width: 400,
          child: _PageEditPanel(
            key: ValueKey(_editingPage!.id),
            page: _editingPage!,
            onClose: () => setState(() => _editingPage = null),
            onSaved: _updatePage,
            uploadFn: (bytes, id) => _upload(bytes, 'app_pages/$id/${DateTime.now().millisecondsSinceEpoch}_img'),
          )),
      ],
    ]);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Level 2 — Block Grid (drill-in)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildLevel2() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final page = _viewingPage!;
    return Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Breadcrumb header
        Padding(
          padding: const EdgeInsets.fromLTRB(AppDimensions.spacingLg, AppDimensions.spacingLg, AppDimensions.spacingLg, AppDimensions.spacingMd),
          child: Row(children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'رجوع',
              onPressed: () => setState(() { _viewingPage = null; _editingBlock = null; _blocks = []; }),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => setState(() { _viewingPage = null; _editingBlock = null; _blocks = []; }),
              child: Text('صفحات التطبيق', style: TextStyle(color: AppColors.blue.withValues(alpha: 0.7), fontSize: 14)),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.chevron_right, size: 18)),
            Icon(_pageIcon(page.id, page.calculatorType, page.nameAr), size: 16),
            const SizedBox(width: 6),
            Text(page.nameAr, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => setState(() { _editingPage = page; }),
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: const Text('إعدادات الصفحة'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _addBlock,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إضافة بلوك'),
            ),
          ]),
        ),
        const Divider(height: 1),
        Expanded(child: _loadingBlocks
          ? const Center(child: CircularProgressIndicator())
          : _blocks.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.widgets_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text('لا توجد بلوكات في هذه الصفحة', style: TextStyle(color: Colors.grey.withValues(alpha: 0.6))),
                const SizedBox(height: 12),
                FilledButton.icon(onPressed: _addBlock, icon: const Icon(Icons.add), label: const Text('إضافة أول بلوك')),
              ]))
            : Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: LayoutBuilder(builder: (ctx, c) {
                  final cols = (c.maxWidth / 180).floor().clamp(2, 8);
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols, crossAxisSpacing: AppDimensions.spacingMd,
                      mainAxisSpacing: AppDimensions.spacingMd, childAspectRatio: 0.82),
                    itemCount: _blocks.length,
                    itemBuilder: (ctx, i) => _BlockCard(
                      block: _blocks[i],
                      isSelected: _editingBlock?.id == _blocks[i].id,
                      isDark: isDark,
                      onTap: () => setState(() => _editingBlock = _blocks[i]),
                      onDelete: () => _deleteBlock(_blocks[i]),
                    ),
                  );
                }),
              )),
      ])),
      // Right panel (page config OR block editor)
      if (_editingPage != null || _editingBlock != null) ...[
        Container(width: 1, color: Theme.of(context).dividerColor),
        SizedBox(width: 400, child: _editingBlock != null
          ? _BlockEditPanel(
              key: ValueKey(_editingBlock!.id),
              block: _editingBlock!,
              onClose: () => setState(() => _editingBlock = null),
              onSaved: _saveBlock,
              uploadFn: (bytes, id) => _upload(bytes, 'page_blocks/${page.id}/$id/${DateTime.now().millisecondsSinceEpoch}_img'),
            )
          : _PageEditPanel(
              key: ValueKey('cfg_${_editingPage!.id}'),
              page: _editingPage!,
              onClose: () => setState(() => _editingPage = null),
              onSaved: _updatePage,
              uploadFn: (bytes, id) => _upload(bytes, 'app_pages/$id/${DateTime.now().millisecondsSinceEpoch}_img'),
            )),
      ],
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Page Card (Level 1)
// ═══════════════════════════════════════════════════════════════════════════

class _PageCard extends StatefulWidget {
  final _PageItem page;
  final bool isSelected, isDark;
  final VoidCallback onEdit, onView;
  final VoidCallback? onDelete;
  const _PageCard({required this.page, required this.isSelected, required this.isDark,
    required this.onEdit, required this.onView, this.onDelete});
  @override State<_PageCard> createState() => _PageCardState();
}

class _PageCardState extends State<_PageCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final hasImg = widget.page.imageUrl.isNotEmpty;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E2433) : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: widget.isSelected ? AppColors.blue
            : _hovered ? AppColors.blue.withValues(alpha: 0.5)
            : widget.isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder,
            width: widget.isSelected ? 2 : 1),
          boxShadow: widget.isSelected || _hovered
            ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
            : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd - 1),
          child: Stack(fit: StackFit.expand, children: [
            // Background
            if (hasImg) AppImage(path: widget.page.imageUrl, fit: BoxFit.cover)
            else Container(
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [AppColors.blue.withValues(alpha: 0.15), AppColors.blue.withValues(alpha: 0.05)])),
              child: Center(child: Icon(
                _pageIcon(widget.page.id, widget.page.calculatorType, widget.page.nameAr),
                size: 52, color: AppColors.blue.withValues(alpha: 0.6),
              )),
            ),
            // Bottom name
            Positioned(left: 0, right: 0, bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: hasImg ? 0.75 : 0.5), Colors.transparent])),
                child: Text(widget.page.nameAr,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                  textDirection: TextDirection.rtl, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
            // Active dot
            Positioned(top: 8, right: 8, child: Container(width: 10, height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: widget.page.isActive ? AppColors.success : AppColors.error,
                border: Border.all(color: Colors.white, width: 1.5)))),
            // Hover actions
            if (_hovered) Positioned.fill(child: Container(
              color: Colors.black.withValues(alpha: 0.45),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                GestureDetector(
                  onTap: widget.onView,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(8)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: const [
                      Icon(Icons.visibility_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text('عرض المحتوى', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: widget.onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4))),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: const [
                      Icon(Icons.tune_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text('إعدادات', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
                if (widget.onDelete != null) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: const [
                        Icon(Icons.delete_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 5),
                        Text('حذف', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ],
              ]),
            )),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Block Card (Level 2)
// ═══════════════════════════════════════════════════════════════════════════

class _BlockCard extends StatefulWidget {
  final PageBlock block;
  final bool isSelected, isDark;
  final VoidCallback onTap, onDelete;
  const _BlockCard({required this.block, required this.isSelected, required this.isDark, required this.onTap, required this.onDelete});
  @override State<_BlockCard> createState() => _BlockCardState();
}

class _BlockCardState extends State<_BlockCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final hasImg = widget.block.imageUrl.isNotEmpty;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E2433) : const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: widget.isSelected ? AppColors.blue
              : _hovered ? AppColors.blue.withValues(alpha: 0.5)
              : widget.isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder,
              width: widget.isSelected ? 2 : 1),
            boxShadow: widget.isSelected || _hovered
              ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd - 1),
            child: Stack(fit: StackFit.expand, children: [
              if (hasImg) AppImage(path: widget.block.imageUrl, fit: BoxFit.cover)
              else Container(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Colors.teal.withValues(alpha: 0.15), Colors.teal.withValues(alpha: 0.05)])),
                child: Center(child: Icon(_blockIcon(widget.block.type), size: 44, color: Colors.teal.withValues(alpha: 0.6))),
              ),
              // Type badge
              Positioned(top: 8, left: 8, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(6)),
                child: Text(blockTypeLabel(widget.block.type), style: const TextStyle(color: Colors.white, fontSize: 10)),
              )),
              // Active dot
              Positioned(top: 8, right: 8, child: Container(width: 9, height: 9,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: widget.block.isActive ? AppColors.success : AppColors.error,
                  border: Border.all(color: Colors.white, width: 1.5)))),
              // Bottom name
              Positioned(left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                    colors: [Colors.black.withValues(alpha: hasImg ? 0.75 : 0.5), Colors.transparent])),
                  child: Text(widget.block.nameAr.isNotEmpty ? widget.block.nameAr : widget.block.nameEn,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                    textDirection: TextDirection.rtl, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ),
              // Delete hover
              if (_hovered) Positioned(
                bottom: 36, right: 6,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(5)),
                    child: const Icon(Icons.delete, size: 14, color: Colors.white),
                  ),
                ),
              ),
              if (_hovered) Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.08),
                child: const Center(child: Icon(Icons.edit_rounded, color: Colors.white, size: 26)))),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Page Edit Panel
// ═══════════════════════════════════════════════════════════════════════════

class _PageEditPanel extends StatefulWidget {
  final _PageItem page;
  final VoidCallback onClose;
  final Future<void> Function(_PageItem) onSaved;
  final Future<String?> Function(Uint8List, String) uploadFn;
  const _PageEditPanel({super.key, required this.page, required this.onClose, required this.onSaved, required this.uploadFn});
  @override State<_PageEditPanel> createState() => _PageEditPanelState();
}

class _PageEditPanelState extends State<_PageEditPanel> {
  late final TextEditingController _arC, _enC, _linkC, _orderC;
  late bool _active;
  Uint8List? _imgBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _arC = TextEditingController(text: widget.page.nameAr);
    _enC = TextEditingController(text: widget.page.nameEn);
    _linkC = TextEditingController(text: widget.page.link);
    _orderC = TextEditingController(text: widget.page.order.toString());
    _active = widget.page.isActive;
  }
  @override void dispose() { _arC.dispose(); _enC.dispose(); _linkC.dispose(); _orderC.dispose(); super.dispose(); }

  Future<void> _pickImg() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (p != null) { final b = await p.readAsBytes(); setState(() => _imgBytes = b); }
  }

  Future<void> _saveVisual() async {
    setState(() => _saving = true);
    try {
      String url = widget.page.imageUrl;
      if (_imgBytes != null) {
        final u = await widget.uploadFn(_imgBytes!, widget.page.id);
        if (u != null) url = u;
      }
      await widget.onSaved(widget.page.copyWith(
        nameAr: _arC.text.trim().isEmpty ? widget.page.nameAr : _arC.text.trim(),
        nameEn: _enC.text.trim(),
        imageUrl: url,
        isActive: _active,
        link: _linkC.text.trim(),
        order: int.tryParse(_orderC.text) ?? widget.page.order,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ تم الحفظ'), backgroundColor: AppColors.success, duration: Duration(seconds: 2)));
      }
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _panelHeader(context, _pageIcon(widget.page.id, widget.page.calculatorType, widget.page.nameAr), widget.page.nameAr, widget.onClose),
      Expanded(child: BlocBuilder<AppPagesCubit, AppPagesState>(
        builder: (context, state) {
          if (state.status == AppPagesStatus.loading) return const Center(child: CircularProgressIndicator());
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _secHeader(context, 'المظهر والصورة', Icons.image_rounded),
              const SizedBox(height: 12),
              GestureDetector(onTap: _pickImg,
                child: Container(height: 150,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: Theme.of(context).colorScheme.outline)),
                  clipBehavior: Clip.antiAlias,
                  child: _imgBytes != null
                    ? Stack(fit: StackFit.expand, children: [Image.memory(_imgBytes!, fit: BoxFit.cover), const Positioned(bottom:6,right:6,child:_SmallBadge('تغيير'))])
                    : widget.page.imageUrl.isNotEmpty
                      ? Stack(fit: StackFit.expand, children: [AppImage(path: widget.page.imageUrl, fit: BoxFit.cover), const Positioned(bottom:6,right:6,child:_SmallBadge('تغيير'))])
                      : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.add_photo_alternate, size: 36), SizedBox(height:6), Text('إضافة صورة')])),
                ),
              ),
              const SizedBox(height: 12),
              _tf('اسم الصفحة (عربي)', _arC, dir: TextDirection.rtl),
              _tf('Page Name (English)', _enC),
              _tf('الرابط / calculatorLink', _linkC),
              _tf('الترتيب', _orderC, keyboardType: TextInputType.number),
              SwitchListTile(title: const Text('الصفحة مفعّلة'), value: _active,
                onChanged: (v) => setState(() => _active = v), activeThumbColor: AppColors.blue, contentPadding: EdgeInsets.zero),
              FilledButton.icon(
                onPressed: _saving ? null : _saveVisual,
                icon: _saving ? const SizedBox(width:14,height:14,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white))
                  : const FaIcon(FontAwesomeIcons.floppyDisk, size:13),
                label: const Text('حفظ التغييرات'),
              ),
            ]),
          );
        },
      )),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Block Edit Panel
// ═══════════════════════════════════════════════════════════════════════════

class _BlockEditPanel extends StatefulWidget {
  final PageBlock block;
  final VoidCallback onClose;
  final Future<void> Function(PageBlock) onSaved;
  final Future<String?> Function(Uint8List, String) uploadFn;
  const _BlockEditPanel({super.key, required this.block, required this.onClose, required this.onSaved, required this.uploadFn});
  @override State<_BlockEditPanel> createState() => _BlockEditPanelState();
}

class _BlockEditPanelState extends State<_BlockEditPanel> {
  late final TextEditingController _arC, _enC, _contentC, _subtitleC, _linkC, _orderC;
  late bool _active;
  late String _type;
  Uint8List? _imgBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _arC = TextEditingController(text: widget.block.nameAr);
    _enC = TextEditingController(text: widget.block.nameEn);
    _contentC = TextEditingController(text: widget.block.content);
    _subtitleC = TextEditingController(text: widget.block.subtitle);
    _linkC = TextEditingController(text: widget.block.link);
    _orderC = TextEditingController(text: widget.block.order.toString());
    _active = widget.block.isActive;
    _type = widget.block.type;
  }
  @override void dispose() {
    _arC.dispose(); _enC.dispose(); _contentC.dispose(); _subtitleC.dispose(); _linkC.dispose(); _orderC.dispose();
    super.dispose();
  }

  Future<void> _pickImg() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (p != null) { final b = await p.readAsBytes(); setState(() => _imgBytes = b); }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      String url = widget.block.imageUrl;
      if (_imgBytes != null) {
        final u = await widget.uploadFn(_imgBytes!, widget.block.id);
        if (u != null) url = u;
      }
      await widget.onSaved(widget.block.copyWith(
        type: _type, nameAr: _arC.text.trim(), nameEn: _enC.text.trim(),
        imageUrl: url, link: _linkC.text.trim(), content: _contentC.text.trim(),
        subtitle: _subtitleC.text.trim(), isActive: _active,
        order: int.tryParse(_orderC.text) ?? widget.block.order));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ تم الحفظ'), backgroundColor: AppColors.success, duration: Duration(seconds: 2)));
      }
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _panelHeader(context, _blockIcon(_type), 'تحرير البلوك', widget.onClose),
      Expanded(child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Type selector
          _secHeader(context, 'نوع البلوك', Icons.widgets_rounded),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8,
            children: kBlockTypes.map((t) {
              final sel = _type == t['id'];
              return GestureDetector(
                onTap: () => setState(() => _type = t['id']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.blue : Colors.transparent,
                    border: Border.all(color: sel ? AppColors.blue : Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(t['ar']!, style: TextStyle(fontSize: 12, color: sel ? Colors.white : null, fontWeight: sel ? FontWeight.bold : null)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          const Divider(),
          const SizedBox(height: AppDimensions.spacingMd),

          if (['banner','card','image'].contains(_type)) ...[
            _secHeader(context, 'الصورة', Icons.image_rounded),
            const SizedBox(height: 10),
            GestureDetector(onTap: _pickImg,
              child: Container(height: 130,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: Theme.of(context).colorScheme.outline)),
                clipBehavior: Clip.antiAlias,
                child: _imgBytes != null
                  ? Stack(fit: StackFit.expand, children: [Image.memory(_imgBytes!, fit: BoxFit.cover), const Positioned(bottom:6,right:6,child:_SmallBadge('تغيير'))])
                  : widget.block.imageUrl.isNotEmpty
                    ? Stack(fit: StackFit.expand, children: [AppImage(path: widget.block.imageUrl, fit: BoxFit.cover), const Positioned(bottom:6,right:6,child:_SmallBadge('تغيير'))])
                    : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.add_photo_alternate, size: 32), SizedBox(height:6), Text('إضافة صورة', style: TextStyle(fontSize:12))])),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (_type != 'spacer') ...[
            _secHeader(context, 'النص والمحتوى', Icons.text_fields_rounded),
            const SizedBox(height: 10),
            _tf('الاسم / العنوان (عربي)', _arC, dir: TextDirection.rtl),
            _tf('Name / Title (English)', _enC),
            if (['banner','card'].contains(_type))
              _tf('العنوان الفرعي (عربي)', _subtitleC, dir: TextDirection.rtl),
            if (['text','button'].contains(_type))
              _tf('المحتوى النصي', _contentC, dir: TextDirection.rtl, maxLines: 4),
          ],

          if (_type != 'spacer' && _type != 'text') ...[
            _tf('الرابط / Deep Link', _linkC),
          ],

          _tf('الترتيب', _orderC, keyboardType: TextInputType.number),
          SwitchListTile(title: const Text('البلوك مفعّل'), value: _active,
            onChanged: (v) => setState(() => _active = v), activeThumbColor: AppColors.blue, contentPadding: EdgeInsets.zero),

          const SizedBox(height: AppDimensions.spacingMd),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving ? const SizedBox(width:14,height:14,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white))
              : const FaIcon(FontAwesomeIcons.floppyDisk, size:13),
            label: const Text('حفظ البلوك'),
          ),
        ]),
      )),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared helpers
// ═══════════════════════════════════════════════════════════════════════════

Widget _panelHeader(BuildContext context, IconData icon, String title, VoidCallback onClose) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingMd),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.blue),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
        IconButton(icon: const Icon(Icons.close), onPressed: onClose),
      ]),
    );

Widget _secHeader(BuildContext context, String title, IconData icon) =>
    Row(children: [
      Icon(icon, size: 15, color: AppColors.blue),
      const SizedBox(width: 6),
      Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
    ]);

Widget _tf(String label, TextEditingController ctrl,
    {TextDirection dir = TextDirection.ltr, int maxLines = 1, TextInputType? keyboardType}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(controller: ctrl, maxLines: maxLines, textDirection: dir, keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true)),
    );

Widget _saveBtn(BuildContext context, VoidCallback onSave, AppPagesStatus status) =>
    Padding(
      padding: const EdgeInsets.only(top: 10),
      child: FilledButton.icon(
        onPressed: status == AppPagesStatus.saving ? null : onSave,
        icon: status == AppPagesStatus.saving
          ? const SizedBox(width:14,height:14,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white))
          : const FaIcon(FontAwesomeIcons.floppyDisk, size:13),
        label: const Text('حفظ الإعدادات'),
      ),
    );

Widget _swTile(String label, bool val, ValueChanged<bool> onChanged) =>
    SwitchListTile(title: Text(label, style: const TextStyle(fontSize: 13)),
      value: val, onChanged: onChanged, activeThumbColor: AppColors.blue,
      contentPadding: EdgeInsets.zero, dense: true);

class _SmallBadge extends StatelessWidget {
  final String text;
  const _SmallBadge(this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(5)),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)));
}

// ═══════════════════════════════════════════════════════════════════════════
// Page-specific config forms (unchanged)
// ═══════════════════════════════════════════════════════════════════════════

// ── Splash ───────────────────────────────────────────────────────────────────
class _SplashForm extends StatefulWidget {
  final SplashConfig config;
  const _SplashForm({required this.config});
  @override State<_SplashForm> createState() => _SplashFormState();
}
class _SplashFormState extends State<_SplashForm> {
  late final TextEditingController _ar, _en;
  late int _dur;
  @override void initState() { super.initState(); _ar = TextEditingController(text: widget.config.taglineAr); _en = TextEditingController(text: widget.config.taglineEn); _dur = widget.config.durationSeconds; }
  @override void dispose() { _ar.dispose(); _en.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => BlocBuilder<AppPagesCubit, AppPagesState>(
    builder: (ctx, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _tf('الشعار النصي (عربي)', _ar, dir: TextDirection.rtl),
      _tf('الشعار النصي (إنجليزي)', _en),
      Text('مدة الانتظار: $_dur ثانية', style: const TextStyle(fontSize: 12)),
      Slider(value: _dur.toDouble(), min: 1, max: 10, divisions: 9, label: '$_dur', onChanged: (v) => setState(() => _dur = v.round())),
      _saveBtn(ctx, () => ctx.read<AppPagesCubit>().saveSplash(widget.config.copyWith(taglineAr: _ar.text.trim(), taglineEn: _en.text.trim(), durationSeconds: _dur)), s.status),
    ]));
}

// ── Onboarding ────────────────────────────────────────────────────────────────
class _OnboardingForm extends StatelessWidget {
  final List<OnboardingSlide> slides;
  const _OnboardingForm({required this.slides});
  @override
  Widget build(BuildContext ctx) => BlocBuilder<AppPagesCubit, AppPagesState>(
    builder: (ctx, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${s.slides.length} شريحة', style: const TextStyle(fontSize: 12)),
        TextButton.icon(onPressed: () => _slideDialog(ctx, null, s.slides), icon: const Icon(Icons.add, size: 15), label: const Text('إضافة', style: TextStyle(fontSize: 12))),
      ]),
      const SizedBox(height: 8),
      ...s.slides.map((sl) => Card(margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(dense: true,
          leading: sl.imageUrl.isNotEmpty ? ClipRRect(borderRadius: BorderRadius.circular(4), child: AppImage(path: sl.imageUrl, width: 36, height: 36, fit: BoxFit.cover)) : const Icon(Icons.image_not_supported_outlined, size: 20),
          title: Text(sl.titleAr.isNotEmpty ? sl.titleAr : sl.titleEn, style: const TextStyle(fontSize: 12)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.edit, size: 15), onPressed: () => _slideDialog(ctx, sl, [])),
            IconButton(icon: Icon(Icons.delete, size: 15, color: AppColors.error), onPressed: () => ctx.read<AppPagesCubit>().deleteSlide(sl.id)),
          ]),
        ))),
    ]));
}

void _slideDialog(BuildContext ctx, OnboardingSlide? sl, List<OnboardingSlide> current) {
  final arC = TextEditingController(text: sl?.titleAr ?? '');
  final enC = TextEditingController(text: sl?.titleEn ?? '');
  final dArC = TextEditingController(text: sl?.descAr ?? '');
  final dEnC = TextEditingController(text: sl?.descEn ?? '');
  final ordC = TextEditingController(text: (sl?.order ?? current.length).toString());
  showDialog(context: ctx, builder: (dCtx) => AlertDialog(
    title: Text(sl == null ? 'إضافة شريحة' : 'تعديل شريحة'),
    content: SizedBox(width: 340, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: arC, textDirection: TextDirection.rtl, decoration: const InputDecoration(labelText: 'العنوان (عربي)')),
      const SizedBox(height: 8),
      TextField(controller: enC, decoration: const InputDecoration(labelText: 'Title (English)')),
      const SizedBox(height: 8),
      TextField(controller: dArC, textDirection: TextDirection.rtl, maxLines: 2, decoration: const InputDecoration(labelText: 'الوصف (عربي)')),
      const SizedBox(height: 8),
      TextField(controller: dEnC, maxLines: 2, decoration: const InputDecoration(labelText: 'Description (English)')),
      const SizedBox(height: 8),
      TextField(controller: ordC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الترتيب')),
    ]))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('إلغاء')),
      FilledButton(onPressed: () {
        ctx.read<AppPagesCubit>().saveSlide(OnboardingSlide(id: sl?.id ?? 'slide_${DateTime.now().millisecondsSinceEpoch}',
          titleAr: arC.text.trim(), titleEn: enC.text.trim(), descAr: dArC.text.trim(), descEn: dEnC.text.trim(),
          imageUrl: sl?.imageUrl ?? '', order: int.tryParse(ordC.text) ?? 0, isActive: sl?.isActive ?? true));
        Navigator.pop(dCtx);
      }, child: const Text('حفظ')),
    ],
  ));
}

// ── Login ─────────────────────────────────────────────────────────────────────
class _LoginForm extends StatefulWidget {
  final LoginConfig config;
  const _LoginForm({required this.config});
  @override State<_LoginForm> createState() => _LoginFormState();
}
class _LoginFormState extends State<_LoginForm> {
  late bool _g, _a, _e;
  late final TextEditingController _tC, _pC;
  @override void initState() { super.initState(); _g=widget.config.showGoogleLogin; _a=widget.config.showAppleLogin; _e=widget.config.showEmailLogin; _tC=TextEditingController(text:widget.config.termsUrl); _pC=TextEditingController(text:widget.config.privacyUrl); }
  @override void dispose() { _tC.dispose(); _pC.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => BlocBuilder<AppPagesCubit, AppPagesState>(
    builder: (ctx, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _swTile('Google', _g, (v) => setState(() => _g = v)),
      _swTile('Apple', _a, (v) => setState(() => _a = v)),
      _swTile('البريد الإلكتروني', _e, (v) => setState(() => _e = v)),
      _tf('رابط الشروط', _tC),
      _tf('رابط الخصوصية', _pC),
      _saveBtn(ctx, () => ctx.read<AppPagesCubit>().saveLogin(widget.config.copyWith(showGoogleLogin:_g, showAppleLogin:_a, showEmailLogin:_e, termsUrl:_tC.text.trim(), privacyUrl:_pC.text.trim())), s.status),
    ]));
}

// ── Register ──────────────────────────────────────────────────────────────────
class _RegisterForm extends StatefulWidget {
  final RegisterConfig config;
  const _RegisterForm({required this.config});
  @override State<_RegisterForm> createState() => _RegisterFormState();
}
class _RegisterFormState extends State<_RegisterForm> {
  late bool _fn, _ph;
  late final TextEditingController _tC, _pC;
  @override void initState() { super.initState(); _fn=widget.config.requireFullName; _ph=widget.config.requirePhone; _tC=TextEditingController(text:widget.config.termsUrl); _pC=TextEditingController(text:widget.config.privacyUrl); }
  @override void dispose() { _tC.dispose(); _pC.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => BlocBuilder<AppPagesCubit, AppPagesState>(
    builder: (ctx, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _swTile('اشتراط الاسم الكامل', _fn, (v) => setState(() => _fn = v)),
      _swTile('اشتراط رقم الجوال', _ph, (v) => setState(() => _ph = v)),
      _tf('رابط الشروط', _tC),
      _tf('رابط الخصوصية', _pC),
      _saveBtn(ctx, () => ctx.read<AppPagesCubit>().saveRegister(widget.config.copyWith(requireFullName:_fn, requirePhone:_ph, termsUrl:_tC.text.trim(), privacyUrl:_pC.text.trim())), s.status),
    ]));
}

// ── Forgot Password ───────────────────────────────────────────────────────────
class _ForgotPasswordForm extends StatefulWidget {
  final ForgotPasswordConfig config;
  const _ForgotPasswordForm({required this.config});
  @override State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}
class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  late final TextEditingController _ar, _en;
  @override void initState() { super.initState(); _ar=TextEditingController(text:widget.config.successMessageAr); _en=TextEditingController(text:widget.config.successMessageEn); }
  @override void dispose() { _ar.dispose(); _en.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => BlocBuilder<AppPagesCubit, AppPagesState>(
    builder: (ctx, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _tf('رسالة النجاح (عربي)', _ar, dir: TextDirection.rtl),
      _tf('Success Message (English)', _en),
      _saveBtn(ctx, () => ctx.read<AppPagesCubit>().saveForgotPassword(widget.config.copyWith(successMessageAr:_ar.text.trim(), successMessageEn:_en.text.trim())), s.status),
    ]));
}

// ── Home ──────────────────────────────────────────────────────────────────────
class _HomeForm extends StatefulWidget {
  final HomeConfig config;
  const _HomeForm({required this.config});
  @override State<_HomeForm> createState() => _HomeFormState();
}
class _HomeFormState extends State<_HomeForm> {
  late final TextEditingController _tAr, _tEn, _sAr, _sEn;
  late String _vm;
  @override void initState() { super.initState(); _tAr=TextEditingController(text:widget.config.welcomeTitleAr); _tEn=TextEditingController(text:widget.config.welcomeTitleEn); _sAr=TextEditingController(text:widget.config.welcomeSubtitleAr); _sEn=TextEditingController(text:widget.config.welcomeSubtitleEn); _vm=widget.config.defaultViewMode; }
  @override void dispose() { _tAr.dispose(); _tEn.dispose(); _sAr.dispose(); _sEn.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => BlocBuilder<AppPagesCubit, AppPagesState>(
    builder: (ctx, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _tf('عنوان الترحيب (عربي)', _tAr, dir: TextDirection.rtl),
      _tf('Welcome Title (English)', _tEn),
      _tf('العنوان الفرعي (عربي)', _sAr, dir: TextDirection.rtl),
      _tf('Subtitle (English)', _sEn),
      Padding(padding: const EdgeInsets.only(bottom: 10),
        child: DropdownButtonFormField<String>(initialValue: _vm,
          decoration: const InputDecoration(labelText: 'طريقة العرض', border: OutlineInputBorder(), isDense: true),
          items: const [DropdownMenuItem(value:'grid', child: Text('شبكة')), DropdownMenuItem(value:'list', child: Text('قائمة'))],
          onChanged: (v) { if (v != null) setState(() => _vm = v); })),
      _saveBtn(ctx, () => ctx.read<AppPagesCubit>().saveHome(widget.config.copyWith(welcomeTitleAr:_tAr.text.trim(), welcomeTitleEn:_tEn.text.trim(), welcomeSubtitleAr:_sAr.text.trim(), welcomeSubtitleEn:_sEn.text.trim(), defaultViewMode:_vm)), s.status),
    ]));
}

// ── Profile ───────────────────────────────────────────────────────────────────
class _ProfileForm extends StatefulWidget {
  final ProfileConfig config;
  const _ProfileForm({required this.config});
  @override State<_ProfileForm> createState() => _ProfileFormState();
}
class _ProfileFormState extends State<_ProfileForm> {
  late bool _sig, _lang, _theme, _del;
  @override void initState() { super.initState(); _sig=widget.config.showSignature; _lang=widget.config.showLanguageOption; _theme=widget.config.showThemeOption; _del=widget.config.showDeleteAccount; }
  @override
  Widget build(BuildContext ctx) => BlocBuilder<AppPagesCubit, AppPagesState>(
    builder: (ctx, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _swTile('التوقيع', _sig, (v) => setState(() => _sig = v)),
      _swTile('تغيير اللغة', _lang, (v) => setState(() => _lang = v)),
      _swTile('تغيير المظهر', _theme, (v) => setState(() => _theme = v)),
      _swTile('حذف الحساب', _del, (v) => setState(() => _del = v)),
      _saveBtn(ctx, () => ctx.read<AppPagesCubit>().saveProfile(widget.config.copyWith(showSignature:_sig, showLanguageOption:_lang, showThemeOption:_theme, showDeleteAccount:_del)), s.status),
    ]));
}

// ── Settings ──────────────────────────────────────────────────────────────────
class _SettingsForm extends StatefulWidget {
  final SettingsConfig config;
  const _SettingsForm({required this.config});
  @override State<_SettingsForm> createState() => _SettingsFormState();
}
class _SettingsFormState extends State<_SettingsForm> {
  late bool _notif, _del;
  late final TextEditingController _emailC, _waC, _tC, _pC;
  @override void initState() { super.initState(); _notif=widget.config.showNotifications; _del=widget.config.showDeleteAccount; _emailC=TextEditingController(text:widget.config.supportEmail); _waC=TextEditingController(text:widget.config.supportWhatsapp); _tC=TextEditingController(text:widget.config.termsUrl); _pC=TextEditingController(text:widget.config.privacyUrl); }
  @override void dispose() { _emailC.dispose(); _waC.dispose(); _tC.dispose(); _pC.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx) => BlocBuilder<AppPagesCubit, AppPagesState>(
    builder: (ctx, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _swTile('الإشعارات', _notif, (v) => setState(() => _notif = v)),
      _swTile('حذف الحساب', _del, (v) => setState(() => _del = v)),
      _tf('بريد الدعم', _emailC),
      _tf('واتساب الدعم', _waC),
      _tf('رابط الشروط', _tC),
      _tf('رابط الخصوصية', _pC),
      _saveBtn(ctx, () => ctx.read<AppPagesCubit>().saveSettings(widget.config.copyWith(showNotifications:_notif, showDeleteAccount:_del, supportEmail:_emailC.text.trim(), supportWhatsapp:_waC.text.trim(), termsUrl:_tC.text.trim(), privacyUrl:_pC.text.trim())), s.status),
    ]));
}
