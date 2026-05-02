import 'package:flutter/material.dart';
import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/shared/widgets/glass_card.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/category_model.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/categories_cubit.dart';
import 'category_form_panel.dart';
import 'category_card.dart';

/// Right-side panel: form for add/edit or empty state.
class CategoriesRightPanel extends StatelessWidget {
  const CategoriesRightPanel({
    super.key,
    this.category,
    this.parentId,
    required this.isAddMode,
    required this.isAddSubcategory,
    required this.topLevel,
    required this.cubit,
    required this.onSaved,
    required this.onClose,
  });

  final CategoryModel? category;
  final String? parentId;
  final bool isAddMode;
  final bool isAddSubcategory;
  final List<CategoryModel> topLevel;
  final CategoriesCubit cubit;
  final VoidCallback onSaved;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final showForm = category != null || isAddMode;
    if (!showForm) {
      return GlassCard(
        radius: categoryCardRadius,
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          child: Center(
            child: Text(
              'Select a category or click Add',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return GlassCard(
      radius: categoryCardRadius,
      child: CategoryFormPanel(
        key: ValueKey('${category?.id ?? "add"}_${isAddSubcategory ? "sub" : "cat"}'),
        category: category,
        parentId: parentId,
        isAddSubcategory: isAddSubcategory,
        topLevel: topLevel,
        cubit: cubit,
        onSaved: onSaved,
        onClose: onClose,
      ),
    );
  }
}
