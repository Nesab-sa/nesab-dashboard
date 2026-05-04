import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/tool_item_model.dart';
import 'package:nesab_dashboard/shared/widgets/app_image.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});
  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  List<ToolItem> _tools = [];
  bool _loading = true;
  ToolItem? _selectedTool;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final snap = await _firestore.collection('categories').get();
      final loaded = snap.docs.map((doc) {
        final d = doc.data();
        return ToolItem(
          id: doc.id,
          nameAr: d['arabicName']?.toString() ?? '',
          nameEn: d['englishName']?.toString() ?? '',
          imageUrl: d['imageUrl']?.toString() ?? '',
          link: d['calculatorLink']?.toString() ?? '',
          calculatorType: d['calculatorType']?.toString() ?? '',
          order: (d['orderNumber'] as num?)?.toInt() ?? 99,
          isActive: d['isActive'] as bool? ?? true,
          isBuiltIn: true,
        );
      }).toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      setState(() { _tools = loaded; _loading = false; });
    } catch (_) {
      setState(() { _loading = false; });
    }
  }

  Future<String?> _uploadImage(Uint8List bytes, String toolId) async {
    try {
      final path = 'tools/$toolId/${DateTime.now().millisecondsSinceEpoch}_img';
      final ref = _storage.ref().child(path);
      await ref.putData(bytes);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveTool(ToolItem updated) async {
    final idx = _tools.indexWhere((t) => t.id == updated.id);
    if (idx >= 0) {
      setState(() => _tools[idx] = updated);
    } else {
      setState(() => _tools.add(updated));
    }
    if (_selectedTool?.id == updated.id) setState(() => _selectedTool = updated);
    await _firestore.doc('categories/${updated.id}').set({
      'arabicName': updated.nameAr,
      'englishName': updated.nameEn,
      'imageUrl': updated.imageUrl,
      'calculatorLink': updated.link,
      'isActive': updated.isActive,
      'orderNumber': updated.order,
    }, SetOptions(merge: true));
  }

  Future<void> _deleteTool(ToolItem tool) async {
    if (tool.isBuiltIn) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الأداة'),
        content: Text('هل تريد حذف "${tool.nameAr}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(style: TextButton.styleFrom(foregroundColor: AppColors.error), onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        _tools.removeWhere((t) => t.id == tool.id);
        if (_selectedTool?.id == tool.id) _selectedTool = null;
      });
      await _firestore.doc('categories/${tool.id}').delete();
    }
  }

  Future<void> _showAddDialog() async {
    final arCtrl = TextEditingController();
    final enCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة أداة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: arCtrl, textDirection: TextDirection.rtl, decoration: const InputDecoration(labelText: 'الاسم بالعربية *')),
            const SizedBox(height: 12),
            TextField(controller: enCtrl, decoration: const InputDecoration(labelText: 'الاسم بالإنجليزية')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          FilledButton(onPressed: () { if (arCtrl.text.trim().isNotEmpty) Navigator.pop(ctx, true); }, child: const Text('إضافة')),
        ],
      ),
    );
    if (ok == true && arCtrl.text.trim().isNotEmpty) {
      final ref = await _firestore.collection('categories').add({
        'arabicName': arCtrl.text.trim(),
        'englishName': enCtrl.text.trim(),
        'imageUrl': '',
        'calculatorLink': '',
        'calculatorType': '',
        'isActive': true,
        'orderNumber': _tools.length,
      });
      final newTool = ToolItem(
        id: ref.id,
        nameAr: arCtrl.text.trim(),
        nameEn: enCtrl.text.trim(),
        order: _tools.length,
        isBuiltIn: false,
      );
      setState(() { _tools.add(newTool); _selectedTool = newTool; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spacingLg, AppDimensions.spacingLg,
                    AppDimensions.spacingLg, AppDimensions.spacingMd),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.screwdriverWrench, size: 18),
                    const SizedBox(width: 10),
                    Text('إدارة الأدوات',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: Text('${_tools.length} أداة', style: const TextStyle(fontSize: 12, color: AppColors.blue)),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('إضافة أداة'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(AppDimensions.spacingLg),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = (constraints.maxWidth / 180).floor().clamp(2, 8);
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: AppDimensions.spacingMd,
                                mainAxisSpacing: AppDimensions.spacingMd,
                                childAspectRatio: 0.82,
                              ),
                              itemCount: _tools.length,
                              itemBuilder: (context, i) => _ToolCard(
                                tool: _tools[i],
                                isSelected: _selectedTool?.id == _tools[i].id,
                                isDark: isDark,
                                onTap: () => setState(() => _selectedTool = _tools[i]),
                                onDelete: _tools[i].isBuiltIn ? null : () => _deleteTool(_tools[i]),
                                onToggle: (v) async {
                                  await _saveTool(_tools[i].copyWith(isActive: v));
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
        // Right panel
        if (_selectedTool != null) ...[
          Container(width: 1, color: Theme.of(context).dividerColor),
          SizedBox(
            width: 400,
            child: _ToolEditPanel(
              key: ValueKey(_selectedTool!.id),
              tool: _selectedTool!,
              onClose: () => setState(() => _selectedTool = null),
              onSave: _saveTool,
              uploadImage: _uploadImage,
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Tool Card ────────────────────────────────────────────────────────────────

class _ToolCard extends StatefulWidget {
  final ToolItem tool;
  final bool isSelected, isDark;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final ValueChanged<bool> onToggle;

  const _ToolCard({
    required this.tool, required this.isSelected, required this.isDark,
    required this.onTap, this.onDelete, required this.onToggle,
  });

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hasImg = widget.tool.imageUrl.isNotEmpty;
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
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.blue
                  : _hovered ? AppColors.blue.withValues(alpha: 0.5)
                  : (widget.isDark ? AppColors.dashboardBorder : AppColors.lightModeBorder),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected || _hovered
                ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd - 1),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImg)
                  AppImage(path: widget.tool.imageUrl, fit: BoxFit.cover)
                else
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [AppColors.blue.withValues(alpha: 0.15), AppColors.blue.withValues(alpha: 0.05)],
                      ),
                    ),
                    child: Center(child: Icon(toolIcon(widget.tool.id, widget.tool.calculatorType), size: 48, color: AppColors.blue.withValues(alpha: 0.6))),
                  ),
                // Bottom gradient + name
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter, end: Alignment.topCenter,
                        colors: [Colors.black.withValues(alpha: hasImg ? 0.75 : 0.5), Colors.transparent],
                      ),
                    ),
                    child: Text(
                      widget.tool.nameAr,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)]),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Active dot
                Positioned(top: 8, right: 8,
                  child: Container(width: 10, height: 10,
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      color: widget.tool.isActive ? AppColors.success : AppColors.error,
                      border: Border.all(color: Colors.white, width: 1.5)),
                  ),
                ),
                // Quick toggle
                Positioned(
                  top: 6, left: 6,
                  child: GestureDetector(
                    onTap: () => widget.onToggle(!widget.tool.isActive),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        widget.tool.isActive ? Icons.visibility : Icons.visibility_off,
                        size: 13, color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Delete (custom)
                if (widget.onDelete != null && _hovered)
                  Positioned(
                    top: 30, left: 6,
                    child: GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                        child: const Icon(Icons.delete, size: 13, color: Colors.white),
                      ),
                    ),
                  ),
                if (_hovered)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.08),
                      child: const Center(child: Icon(Icons.edit_rounded, color: Colors.white, size: 26)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tool Edit Panel ──────────────────────────────────────────────────────────

class _ToolEditPanel extends StatefulWidget {
  final ToolItem tool;
  final VoidCallback onClose;
  final Future<void> Function(ToolItem) onSave;
  final Future<String?> Function(Uint8List, String) uploadImage;

  const _ToolEditPanel({super.key, required this.tool, required this.onClose, required this.onSave, required this.uploadImage});

  @override
  State<_ToolEditPanel> createState() => _ToolEditPanelState();
}

class _ToolEditPanelState extends State<_ToolEditPanel> {
  late final TextEditingController _arCtrl, _enCtrl, _descCtrl, _linkCtrl;
  late bool _isActive;
  Uint8List? _newImageBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _arCtrl = TextEditingController(text: widget.tool.nameAr);
    _enCtrl = TextEditingController(text: widget.tool.nameEn);
    _descCtrl = TextEditingController(text: widget.tool.description);
    _linkCtrl = TextEditingController(text: widget.tool.link);
    _isActive = widget.tool.isActive;
  }

  @override
  void dispose() { _arCtrl.dispose(); _enCtrl.dispose(); _descCtrl.dispose(); _linkCtrl.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
    if (p != null) setState(() async => _newImageBytes = await p.readAsBytes());
    if (p != null) {
      final bytes = await p.readAsBytes();
      setState(() => _newImageBytes = bytes);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      String imgUrl = widget.tool.imageUrl;
      if (_newImageBytes != null) {
        final url = await widget.uploadImage(_newImageBytes!, widget.tool.id);
        if (url != null) imgUrl = url;
      }
      await widget.onSave(widget.tool.copyWith(
        nameAr: _arCtrl.text.trim().isEmpty ? widget.tool.nameAr : _arCtrl.text.trim(),
        nameEn: _enCtrl.text.trim(),
        imageUrl: imgUrl,
        description: _descCtrl.text.trim(),
        link: _linkCtrl.text.trim(),
        isActive: _isActive,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ تم الحفظ'), backgroundColor: AppColors.success, duration: Duration(seconds: 2),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg, vertical: AppDimensions.spacingMd),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor))),
          child: Row(
            children: [
              Icon(toolIcon(widget.tool.id, widget.tool.calculatorType), size: 18, color: AppColors.blue),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.tool.nameAr, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
              if (widget.tool.isBuiltIn)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: const Text('مدمجة', style: TextStyle(fontSize: 10, color: AppColors.blue)),
                ),
              IconButton(icon: const Icon(Icons.close), onPressed: widget.onClose),
            ],
          ),
        ),
        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _newImageBytes != null
                        ? Stack(fit: StackFit.expand, children: [
                            Image.memory(_newImageBytes!, fit: BoxFit.cover),
                            const Positioned(bottom: 8, right: 8, child: _ChangeBadge()),
                          ])
                        : widget.tool.imageUrl.isNotEmpty
                            ? Stack(fit: StackFit.expand, children: [
                                AppImage(path: widget.tool.imageUrl, fit: BoxFit.cover),
                                const Positioned(bottom: 8, right: 8, child: _ChangeBadge()),
                              ])
                            : Center(
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(toolIcon(widget.tool.id, widget.tool.calculatorType), size: 48, color: AppColors.blue.withValues(alpha: 0.5)),
                                  const SizedBox(height: 8),
                                  const Text('اضغط لإضافة صورة'),
                                ]),
                              ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                // Fields
                _tf('اسم الأداة (عربي) *', _arCtrl, dir: TextDirection.rtl),
                _tf('Tool Name (English)', _enCtrl),
                _tf('الوصف (اختياري)', _descCtrl, dir: TextDirection.rtl, maxLines: 3),
                _tf('الرابط / Deep Link (اختياري)', _linkCtrl),
                SwitchListTile(
                  title: const Text('الأداة مفعّلة'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeThumbColor: AppColors.blue,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const FaIcon(FontAwesomeIcons.floppyDisk, size: 14),
                  label: const Text('حفظ التغييرات'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tf(String label, TextEditingController ctrl, {TextDirection dir = TextDirection.ltr, int maxLines = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: ctrl,
          maxLines: maxLines,
          textDirection: dir,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
        ),
      );
}

class _ChangeBadge extends StatelessWidget {
  const _ChangeBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(6)),
    child: const Text('تغيير', style: TextStyle(color: Colors.white, fontSize: 11)),
  );
}
