import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/calculators/data/models/calculator_type.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/category_model.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/categories_cubit.dart';
import 'package:nesab_dashboard/shared/widgets/app_image.dart';

class CategoryFormPanel extends StatefulWidget {
  const CategoryFormPanel({
    super.key,
    required this.cubit,
    this.category,
    this.parentId,
    required this.isAddSubcategory,
    required this.topLevel,
    required this.onSaved,
    required this.onClose,
  });

  final CategoriesCubit cubit;
  final CategoryModel? category;
  final String? parentId;
  final bool isAddSubcategory;
  final List<CategoryModel> topLevel;
  final VoidCallback onSaved;
  final VoidCallback onClose;

  @override
  State<CategoryFormPanel> createState() => _CategoryFormPanelState();
}

class _CategoryFormPanelState extends State<CategoryFormPanel> {
  final _arabicController = TextEditingController();
  final _englishController = TextEditingController();
  final _calculatorLinkController = TextEditingController();
  final _orderController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageUrl;
  CalculatorType? _selectedCalculatorType;
  String? _selectedParentId;
  bool _saving = false;

  double _titleSize = kDefaultTitleSize;
  double _imageWidth = kDefaultImageWidth;
  double _imageHeight = kDefaultImageHeight;
  double _opacity = kDefaultOpacity;

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    if (cat != null) {
      _arabicController.text = cat.arabicName;
      _englishController.text = cat.englishName;
      _calculatorLinkController.text = cat.calculatorLink ?? '';
      _orderController.text = cat.orderNumber.toString();
      _imageUrl = cat.imageUrl;
      _selectedCalculatorType = cat.calculatorType;
      _selectedParentId = cat.parentId;
      _titleSize = cat.titleSize;
      _imageWidth = cat.imageWidth;
      _imageHeight = cat.imageHeight;
      _opacity = cat.opacity;
    } else {
      _orderController.text = '0';
      _selectedParentId = widget.parentId;
    }
  }

  @override
  void dispose() {
    _arabicController.dispose();
    _englishController.dispose();
    _calculatorLinkController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageUrl = null;
      });
    }
  }

  Future<void> _save() async {
    if (_arabicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arabic name is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_englishController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('English name is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if ((widget.isAddSubcategory || widget.category?.parentId != null) && _selectedParentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parent category is required for subcategories'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final orderNumber = int.tryParse(_orderController.text) ?? 0;
      final isAdd = widget.category == null;

      final result = isAdd
          ? await widget.cubit
              .addCategory(
                arabicName: _arabicController.text.trim(),
                englishName: _englishController.text.trim(),
                imageUrl: '',
                orderNumber: orderNumber,
                imageBytes: _imageBytes,
                parentId: widget.isAddSubcategory ? _selectedParentId : null,
                calculatorType: _selectedCalculatorType,
                calculatorLink: _calculatorLinkController.text.trim().isEmpty
                    ? null
                    : _calculatorLinkController.text.trim(),
                titleSize: _titleSize,
                imageWidth: _imageWidth,
                imageHeight: _imageHeight,
                opacity: _opacity,
              )
          : await widget.cubit.updateCategory(
              id: widget.category!.id,
              arabicName: _arabicController.text.trim(),
              englishName: _englishController.text.trim(),
              imageUrl: _imageBytes == null ? widget.category!.imageUrl : '',
              orderNumber: orderNumber,
              imageBytes: _imageBytes,
              parentId: widget.isAddSubcategory || widget.category?.parentId != null ? _selectedParentId : null,
              calculatorType: _selectedCalculatorType,
              calculatorLink: _calculatorLinkController.text.trim().isEmpty
                  ? null
                  : _calculatorLinkController.text.trim(),
              titleSize: _titleSize,
              imageWidth: _imageWidth,
              imageHeight: _imageHeight,
              opacity: _opacity,
            );

      if (!mounted) return;
      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        ),
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.categorySaved),
              backgroundColor: AppColors.success,
            ),
          );
          widget.onSaved();
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.category == null ? 'Add Category' : 'Edit Category',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          if (widget.isAddSubcategory || widget.category?.parentId != null) ...[
            _buildParentCategoryDropdown(),
            const SizedBox(height: AppDimensions.spacingMd),
          ],
          _buildTextField(
            controller: _arabicController,
            label: 'Arabic Name',
            required: true,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildTextField(
            controller: _englishController,
            label: 'English Name',
            required: true,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildTextField(
            controller: _orderController,
            label: 'Order Number',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildCalculatorTypeDropdown(),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildTextField(
            controller: _calculatorLinkController,
            label: 'Calculator Link (optional)',
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildImagePicker(),
          const SizedBox(height: AppDimensions.spacingLg),
          _buildSlider(
            label: 'Title Size',
            value: _titleSize,
            min: 10,
            max: 32,
            displayValue: _titleSize.toStringAsFixed(0),
            onChanged: (v) => setState(() => _titleSize = v),
          ),
          _buildSlider(
            label: 'Image Width',
            value: _imageWidth,
            min: 0,
            max: 1,
            displayValue: '${(_imageWidth * 100).toStringAsFixed(0)}%',
            onChanged: (v) => setState(() => _imageWidth = v),
          ),
          _buildSlider(
            label: 'Image Height',
            value: _imageHeight,
            min: 0,
            max: 1,
            displayValue: '${(_imageHeight * 100).toStringAsFixed(0)}%',
            onChanged: (v) => setState(() => _imageHeight = v),
          ),
          _buildSlider(
            label: 'Opacity',
            value: _opacity,
            min: 0,
            max: 1,
            displayValue: '${(_opacity * 100).toStringAsFixed(0)}%',
            onChanged: (v) => setState(() => _opacity = v),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _buildPreview(),
          const SizedBox(height: AppDimensions.spacingLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : widget.onClose,
                  child: Text(context.l10n.cancel),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(context.l10n.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
      ),
    );
  }

  Widget _buildCalculatorTypeDropdown() {
    return DropdownButtonFormField<CalculatorType?>(
      value: _selectedCalculatorType,
      decoration: const InputDecoration(labelText: 'Calculator Type'),
      items: [
        const DropdownMenuItem(value: null, child: Text('None')),
        ...CalculatorType.values.map(
          (type) => DropdownMenuItem(
            value: type,
            child: Text(type.name),
          ),
        ),
      ],
      onChanged: (value) => setState(() => _selectedCalculatorType = value),
    );
  }

  Widget _buildParentCategoryDropdown() {
    return DropdownButtonFormField<String?>(
      value: _selectedParentId,
      decoration: const InputDecoration(labelText: 'Parent Category *'),
      items: widget.topLevel.map((cat) {
        return DropdownMenuItem<String?>(
          value: cat.id,
          child: Text(cat.displayLabel(true)), // fallback to english for now
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedParentId = value),
      validator: (value) => value == null ? 'Parent category is required' : null,
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(displayValue, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
        const SizedBox(height: AppDimensions.spacingSm),
      ],
    );
  }

  Widget _buildPreview() {
    final imageSource = _imageBytes != null
        ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover, opacity: _opacity)
        : (_imageUrl != null && _imageUrl!.isNotEmpty)
            ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover, opacity: _opacity)
            : null;

    final arabicName = _arabicController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preview', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Container(
          width: double.infinity * _imageWidth,
          height: 120 * _imageHeight,
          constraints: BoxConstraints(
            maxWidth: double.infinity,
            minHeight: 60,
            maxHeight: 200,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            image: imageSource,
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.all(8),
          child: Text(
            arabicName.isEmpty ? 'اسم الفئة' : arabicName,
            style: TextStyle(
              fontSize: _titleSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: _imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.cover,
                ),
              )
            : _imageUrl != null && _imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: AppImage(
                      path: _imageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 48),
                        SizedBox(height: 8),
                        Text('Tap to select an image'),
                      ],
                    ),
                  ),
      ),
    );
  }
}
