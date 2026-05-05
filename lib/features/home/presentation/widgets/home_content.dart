import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nesab/core/extensions/context_extensions.dart';
import 'package:nesab/core/routing/route_names.dart';
import 'package:nesab/core/theme/app_dimensions.dart';
import 'package:nesab/features/auth/data/models/user_model.dart';
import 'package:nesab/features/auth/domain/entities/user_entity.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nesab/features/auth/presentation/cubit/auth_state.dart';
import 'package:nesab/core/models/category_model.dart';
import 'package:nesab/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:nesab/features/categories/presentation/cubit/categories_state.dart';
import 'package:nesab/features/home/presentation/widgets/home_header.dart';
import 'package:nesab/features/home/presentation/widgets/service_categories_grid.dart';
import 'package:nesab/shared/widgets/custom_button.dart';
import 'package:nesab/shared/widgets/gradiant_widget.dart';
import 'package:nesab/shared/widgets/shimmer_loading.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(-1);

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(child: GradiantWidget(width: double.infinity)),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      return RefreshIndicator(
                        onRefresh: () => context
                            .read<CategoriesCubit>()
                            .loadTopLevelCategories(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal:
                                AppDimensions.screenPaddingHorizontal,
                            vertical: AppDimensions.screenPaddingVertical,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final user = state.maybeWhen(
                                    authenticated: (user) => user,
                                    orElse: () => UserModel(
                                      displayName: 'زائر',
                                      photoUrl: null,
                                      uid: '',
                                      authProvider: AppAuthProvider.guest,
                                    ),
                                  );
                                  return HomeHeader(user: user);
                                },
                              ),
                              const SizedBox(
                                  height: AppDimensions.spacingXxxl),
                              BlocBuilder<CategoriesCubit, CategoriesState>(
                                builder: (context, state) {
                                  if (state is CategoriesLoading ||
                                      state is CategoriesInitial) {
                                    return const ShimmerCategoriesGrid();
                                  }
                                  if (state is CategoriesError) {
                                    return Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(state.message),
                                          const SizedBox(height: 16),
                                          TextButton.icon(
                                            onPressed: () => context
                                                .read<CategoriesCubit>()
                                                .loadTopLevelCategories(),
                                            icon:
                                                const Icon(Icons.refresh),
                                            label: Text(
                                                context.l10n.retry),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  final categories =
                                      state is CategoriesLoaded
                                          ? state.categories
                                          : <CategoryModel>[];
                                  return ValueListenableBuilder<int>(
                                    valueListenable: _selectedIndex,
                                    builder:
                                        (context, selectedIndex, _) {
                                      return ServiceCategoriesGrid(
                                        categories: categories,
                                        selectedIndex: selectedIndex,
                                        onSelectionChanged: (index) {
                                          _selectedIndex.value = index;
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Bottom button — only rebuilds itself, body is untouched
                ValueListenableBuilder<int>(
                  valueListenable: _selectedIndex,
                  builder: (context, selectedIndex, _) {
                    if (selectedIndex <= -1) {
                      return const SizedBox.shrink();
                    }
                    return BlocBuilder<CategoriesCubit, CategoriesState>(
                      builder: (context, state) {
                        final categories = state is CategoriesLoaded
                            ? state.categories
                            : <CategoryModel>[];
                        if (categories.isEmpty ||
                            selectedIndex >= categories.length) {
                          return const SizedBox.shrink();
                        }
                        final categoryId = categories[selectedIndex].id;
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CustomButton(
                            onPressed: () {
                              context.pushNamed(
                                RouteNames.categoryDetailName,
                                pathParameters: {'id': categoryId},
                              );
                            },
                            text: context.l10n.next,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
