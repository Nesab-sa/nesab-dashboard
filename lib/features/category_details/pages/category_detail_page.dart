import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/app/dependency_injection.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/localization/cubit/locale_cubit.dart';
import 'package:nesab/core/models/category_model.dart';
import 'package:nesab/core/theme/app_colors.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/core/theme/app_text_styles.dart';
import 'package:nesab/core/models/calculator_type_pages.dart';
import 'package:nesab/core/utils/app_responsive.dart';
import 'package:nesab/features/categories/domain/repositories/categories_repository.dart';
import 'package:nesab/features/category_details/widgets/category_hero_header.dart';
import 'package:nesab/shared/widgets/app_image.dart';
import 'package:nesab/shared/widgets/base_screen.dart';
import 'package:nesab/shared/widgets/calculator_webview_page.dart';
import 'package:nesab/shared/widgets/glass_card.dart';
import 'package:nesab/shared/widgets/animated_layout_switcher.dart';
import 'package:nesab/shared/widgets/view_mode_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryDetailPage extends StatefulWidget {
  const CategoryDetailPage({required this.categoryId, super.key});

  final String categoryId;

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage>
    with SingleTickerProviderStateMixin {
  static const _viewModeKey = 'view_mode_is_grid';
  late final AnimationController _controller;
  CategoryModel? _category;
  List<CategoryModel> _subcategories = [];
  bool _loading = true;
  String? _loadedId;
  late bool _isGrid;

  @override
  void initState() {
    super.initState();
    _isGrid = getIt<SharedPreferences>().getBool(_viewModeKey) ?? true;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadedId != widget.categoryId) {
      _loadedId = widget.categoryId;
      _loadCategory();
    }
  }

  Future<void> _loadCategory() async {
    setState(() => _loading = true);
    try {
      final repo = getIt<CategoriesRepository>();
      final category = await repo.getCategoryById(widget.categoryId);
      final subs = await repo.getSubcategories(widget.categoryId);
      if (mounted) {
        setState(() {
          _category = category;
          _subcategories = subs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setViewMode(bool isGrid) {
    setState(() => _isGrid = isGrid);
    getIt<SharedPreferences>().setBool(_viewModeKey, isGrid);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useEnglish =
        context.read<LocaleCubit>().state.locale.languageCode == 'en';

    if (_loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_category == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.noData,),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _loadCategory,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final category = _category!;

    return BaseScreen(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: AppDimensions.screenPaddingVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryHeroHeader(
              categoryId: category.id,
              imagePath: category.imageUrl,
              title: category.displayLabel(useEnglish),
              description: '',
            ),
            const SizedBox(height: AppDimensions.spacingXxxl),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppDimensions.screenPaddingHorizontal,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.availableOptions,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  ViewModeToggle(isGrid: _isGrid, onChanged: _setViewMode),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppDimensions.screenPaddingHorizontal,
              ),
              child: AnimatedLayoutSwitcher(
                isGrid: _isGrid,
                gridAspectRatio: 1.0,
                gridCrossAxisCount: AppResponsive.numberOfGrid(context),
                itemCount: _subcategories.length,
                itemBuilder: (context, index, metrics) {
                  final begin = (index * 0.15).clamp(0.0, 0.7);
                  final stagger = CurvedAnimation(
                    parent: _controller,
                    curve: Interval(
                      begin,
                      (begin + 0.5).clamp(0.0, 1.0),
                      curve: Curves.easeOutCubic,
                    ),
                  );
                  return AnimatedBuilder(
                    animation: stagger,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, 20 * (1 - stagger.value)),
                      child: Opacity(opacity: stagger.value, child: child),
                    ),
                    child: _MorphingSubCategoryCard(
                      category: _subcategories[index],
                      useEnglish: useEnglish,
                      metrics: metrics,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MorphingSubCategoryCard extends StatelessWidget {
  const _MorphingSubCategoryCard({
    required this.category,
    required this.useEnglish,
    required this.metrics,
  });

  final CategoryModel category;
  final bool useEnglish;
  final LayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = metrics.t;
    final label = category.displayLabel(useEnglish);
    final titleSize = category.clampedTitleSize;

    final gridImageW = (metrics.gridWidth * category.clampedImageWidth).clamp(
      1.0,
      metrics.gridWidth,
    );
    final gridImageH = (metrics.gridHeight * category.clampedImageHeight).clamp(
      1.0,
      metrics.gridHeight,
    );
    const listImageSize = 56.0;
    final imageW = lerpDouble(gridImageW, listImageSize, t)!;
    final imageH = lerpDouble(gridImageH, listImageSize, t)!;

    final shaderOpacity = (1.0 - t * 1.5).clamp(0.0, 1.0);

    final opacityValue = category.clampedOpacity.clamp(0.01, 1.0);
    Widget image = AppImage(
      path: category.imageUrl,
      width: imageW,
      height: imageH,
      alignment: t < 0.5 ? Alignment.bottomLeft : Alignment.centerLeft,
    );
    if (opacityValue < 1) {
      image = Opacity(opacity: opacityValue, child: image);
    }
    if (shaderOpacity > 0.01) {
      image = ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Colors.transparent,
            Colors.blue.withValues(alpha: 0.8 * shaderOpacity),
          ],
          stops: const [0.0, 0.3],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: image,
      );
    }

    return GlassCard(
      onTap: () {
        final calcType = category.calculatorType;
        final calcUrl = category.calculatorLink;

        if (calcType != null && calcUrl != null && calcUrl.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CalculatorWebViewPage(url: calcUrl, title: label),
            ),
          );
        } else {
          final messenger = ScaffoldMessenger.of(context);
          messenger.removeCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(context.l10n.comingSoonMessage),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Align(
            alignment: AlignmentGeometry.lerp(
              Alignment.bottomLeft,
              const AlignmentDirectional(-1.0, 0.0),
              t,
            )!,
            child: Padding(
              padding: EdgeInsets.only(left: t < 0.5 ? 5 : 12, bottom: 5),
              child: RepaintBoundary(child: image),
            ),
          ),
          if (t < 0.6)
            Opacity(
              opacity: (1.0 - t * 2.5).clamp(0.0, 1.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10, top: 10),
                  child: Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: titleSize,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          if (t > 0.3)
            Opacity(
              opacity: ((t - 0.3) / 0.4).clamp(0.0, 1.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 32,
                    right: listImageSize + 24,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: titleSize,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: isDark
                            ? AppColors.textDisabledDark
                            : AppColors.textDisabledLight,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
