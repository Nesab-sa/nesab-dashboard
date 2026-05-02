import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nesab_dashboard/core/extensions/context_extensions.dart';
import 'package:nesab_dashboard/core/theme/app_colors.dart';
import 'package:nesab_dashboard/core/theme/app_dimensions.dart';
import 'package:nesab_dashboard/features/dashboard/data/models/category_model.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/categories_cubit.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/categories_state.dart';
import 'category_card.dart';
import 'categories_right_panel.dart';

class CategoriesListView extends StatefulWidget {
  const CategoriesListView({super.key});

  @override
  State<CategoriesListView> createState() => _CategoriesListViewState();
}

class _CategoriesListViewState extends State<CategoriesListView> {
  bool _showEnglish = true;
  String? _lastLocale;
  CategoryModel? _panelCategory;
  String? _panelParentId;
  bool _panelIsAdd = false;
  bool _panelIsAddSubcategory = false;
  String? _selectedParentIdForView;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (_lastLocale != locale) {
      _lastLocale = locale;
      final isEn = locale.toLowerCase() == 'en';
      if (_showEnglish != isEn) {
        setState(() => _showEnglish = isEn);
      }
    }
  }

  static const double _rightPanelWidth = 420;
  static const double _mobileBreakpoint = 720;

  void _openAddCategory(BuildContext context, {String? parentId}) {
    setState(() {
      _panelCategory = null;
      _panelParentId = parentId;
      _panelIsAdd = true;
      _panelIsAddSubcategory = false;
    });
  }

  void _openAddSubcategory(BuildContext context) {
    setState(() {
      _panelCategory = null;
      _panelParentId = null;
      _panelIsAdd = true;
      _panelIsAddSubcategory = true;
    });
  }

  void _openEditCategory(CategoryModel category) {
    setState(() {
      _panelCategory = category;
      _panelParentId = category.parentId;
      _panelIsAdd = false;
    });
  }

  void _closePanel() {
    setState(() {
      _panelCategory = null;
      _panelParentId = null;
      _panelIsAdd = false;
      _panelIsAddSubcategory = false;
    });
  }

  Future<void> _deleteSelected(BuildContext context, Set<String> selectedIds) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Categories'),
        content: Text('Are you sure you want to delete ${selectedIds.length} item(s)?\nThis cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      final cubit = context.read<CategoriesCubit>();
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      
      for (final id in selectedIds) {
        await cubit.deleteCategory(id, parentId: _selectedParentIdForView);
        cubit.toggleSelection(id); // unselect after delete
      }
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Items deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < _mobileBreakpoint;
        if (isMobile) {
          if (_panelCategory != null || _panelIsAdd) {
            return _buildRightPanel(context);
          }
          return _buildMainContent(context, isMobile: true);
        }
        return _buildMainContent(context, isMobile: false);
      },
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        final topLevel = state.mapOrNull(loaded: (s) => s.topLevel) ?? [];
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _closePanel,
            ),
            title: Text(_panelIsAdd ? context.l10n.addCategory : 'Edit'),
          ),
          body: CategoriesRightPanel(
            category: _panelCategory,
            parentId: _panelParentId,
            isAddMode: _panelIsAdd,
            isAddSubcategory: _panelIsAddSubcategory,
            topLevel: topLevel,
            cubit: context.read<CategoriesCubit>(),
            onSaved: _closePanel,
            onClose: _closePanel,
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, {required bool isMobile}) {
    final panelWidget = BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        final topLevel = state.mapOrNull(loaded: (s) => s.topLevel) ?? [];
        return CategoriesRightPanel(
          category: _panelCategory,
          parentId: _panelParentId,
          isAddMode: _panelIsAdd,
          isAddSubcategory: _panelIsAddSubcategory,
          topLevel: topLevel,
          cubit: context.read<CategoriesCubit>(),
          onSaved: _closePanel,
          onClose: _closePanel,
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppDimensions.spacingMd,
                  runSpacing: AppDimensions.spacingMd,
                  children: [
                    Text(
                      context.l10n.categoriesTitle,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    Wrap(
                      spacing: AppDimensions.spacingSm,
                      runSpacing: AppDimensions.spacingSm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        BlocBuilder<CategoriesCubit, CategoriesState>(
                          builder: (context, state) {
                            final s = state.mapOrNull(loaded: (s) => s.selectedIds);
                            if (s == null || s.isEmpty) return const SizedBox.shrink();
                            return IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.trash,
                                color: AppColors.error,
                                size: AppDimensions.iconSm,
                              ),
                              onPressed: () => _deleteSelected(context, s),
                              tooltip: 'Delete Selected',
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                          onPressed: () => _openAddCategory(context),
                          icon: const FaIcon(
                            FontAwesomeIcons.plus,
                            size: AppDimensions.iconSm,
                          ),
                          label: Text(context.l10n.addCategory),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(minimumSize: const Size(0, 48)),
                          onPressed: () => _openAddSubcategory(context),
                          icon: const FaIcon(
                            FontAwesomeIcons.plus,
                            size: AppDimensions.iconSm,
                          ),
                          label: Text(context.l10n.addSubCategory),
                        ),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: true, label: Text('EN')),
                            ButtonSegment(value: false, label: Text('AR')),
                          ],
                          selected: {_showEnglish},
                          onSelectionChanged: (Set<bool> s) =>
                              setState(() => _showEnglish = s.first),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                _buildViewDropdown(),
                const SizedBox(height: AppDimensions.spacingXl),
                Expanded(child: _buildCategoryGrid()),
              ],
            ),
          ),
          if (!isMobile && (_panelCategory != null || _panelIsAdd))
            SizedBox(width: _rightPanelWidth, child: panelWidget),
        ],
      ),
    );
  }

  Widget _buildViewDropdown() {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        return state.maybeWhen(
          loaded: (topLevel, subcategories, expandedId, selectedIds, loadingSub) {
            if (topLevel.isEmpty) return const SizedBox.shrink();
            return Wrap(
              spacing: AppDimensions.spacingSm,
              runSpacing: AppDimensions.spacingSm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'View:',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                DropdownButton<String?>(
                  value: _selectedParentIdForView,
                  hint: const Text('Top-level'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Top-level'),
                    ),
                    ...topLevel.map(
                      (c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text(
                          c.displayLabel(_showEnglish),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (id) {
                    setState(() => _selectedParentIdForView = id);
                    if (id != null) {
                      context.read<CategoriesCubit>().loadSubcategories(id);
                    }
                  },
                ),
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildCategoryGrid() {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: SizedBox.shrink()),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (topLevel, subcategories, expandedId, selectedIds, loadingSub) {
            final displayList = _selectedParentIdForView == null
                ? topLevel
                : (subcategories[_selectedParentIdForView] ?? []);
            if (topLevel.isEmpty) {
              return Center(
                child: Text(
                  context.l10n.addCategory,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            if (_selectedParentIdForView != null && loadingSub) {
              return const Center(child: CircularProgressIndicator());
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                const minCardSize = 100.0;
                final availableWidth = constraints.maxWidth;
                final crossCount = (availableWidth / (categoryCardSize + spacing))
                    .floor()
                    .clamp(2, 6);
                final cardSize = ((availableWidth -
                            spacing * (crossCount - 1)) /
                        crossCount)
                    .clamp(minCardSize, categoryCardSize);
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: displayList.map((cat) {
                        return SizedBox(
                          width: cardSize,
                          height: cardSize,
                          child: CategoryGridCard(
                            category: cat,
                            showEnglish: _showEnglish,
                            isSelected: selectedIds.contains(cat.id),
                            onTap: () => _openEditCategory(cat),
                            onCheckChanged: () => context
                                .read<CategoriesCubit>()
                                .toggleSelection(cat.id),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          },
          error: (msg) => Center(
            child: Text(
              msg,
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        );
      },
    );
  }
}
