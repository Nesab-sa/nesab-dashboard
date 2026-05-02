import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab_dashboard/core/errors/failures.dart';
import 'package:nesab_dashboard/features/calculators/data/models/calculator_type.dart';

import '../../data/models/category_model.dart';
import '../../data/repositories/categories_repository.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit([CategoriesRepository? repository])
    : _repo = repository ?? CategoriesRepository(),
      super(const CategoriesState.initial());

  final CategoriesRepository _repo;

  /// Loads top-level categories.
  /// Preserves existing [subcategories] so subcategory lists are not wiped.
  Future<void> loadTopLevel() async {
    if (isClosed) return;
    final previous = state.mapOrNull(loaded: (s) => s.subcategories);
    emit(const CategoriesState.loading());
    final result = await _repo.getTopLevelCategories();
    if (isClosed) return;
    switch (result) {
      case Left(value: final failure):
        emit(CategoriesState.error(failure.message));
      case Right(value: final topLevel):
        emit(CategoriesState.loaded(
          topLevel: topLevel,
          subcategories: previous ?? const {},
        ));
    }
  }

  /// Loads subcategories for [parentId].
  /// When [forceRefresh] is true, refetches even if already loaded (e.g. after add/update/delete).
  Future<void> loadSubcategories(String parentId, {bool forceRefresh = false}) async {
    final current = state;
    final loaded = current.mapOrNull(loaded: (s) => s);
    if (loaded == null) return;
    if (!forceRefresh && loaded.subcategories.containsKey(parentId)) {
      return;
    }
    if (isClosed) return;
    emit(loaded.copyWith(loadingSub: true));
    final result = await _repo.getSubcategories(parentId);
    if (isClosed) return;
    switch (result) {
      case Left(value: final failure):
        emit(loaded.copyWith(loadingSub: false));
        emit(CategoriesState.error(failure.message));
      case Right(value: final list):
        final updated = Map<String, List<CategoryModel>>.from(
          loaded.subcategories,
        )..[parentId] = list;
        emit(loaded.copyWith(subcategories: updated, loadingSub: false));
    }
  }

  /// Toggles expanded state for category [id].
  void toggleExpanded(String id) {
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded == null) return;
    final newExpanded = loaded.expandedId == id ? null : id;
    emit(loaded.copyWith(expandedId: newExpanded));
    if (newExpanded != null) {
      loadSubcategories(newExpanded);
    }
  }

  /// Toggles selection for category [id].
  void toggleSelection(String id) {
    final loaded = state.mapOrNull(loaded: (s) => s);
    if (loaded == null) return;
    final newSet = Set<String>.from(loaded.selectedIds);
    if (newSet.contains(id)) {
      newSet.remove(id);
    } else {
      newSet.add(id);
    }
    emit(loaded.copyWith(selectedIds: newSet));
  }

  /// Checks whether [orderNumber] is already used at the same category level.
  Future<bool> isOrderNumberTaken({
    required int orderNumber,
    String? parentId,
    String? excludeId,
  }) =>
      _repo.isOrderNumberTaken(
        orderNumber: orderNumber,
        parentId: parentId,
        excludeId: excludeId,
      );

  Future<Either<Failure, CategoryModel>> addCategory({
    required String arabicName,
    required String englishName,
    required String imageUrl,
    required int orderNumber,
    Uint8List? imageBytes,
    String? parentId,
    CalculatorType? calculatorType,
    String? calculatorLink,
    double titleSize = 16.0,
    double imageWidth = 0.8,
    double imageHeight = 0.8,
    double opacity = 1.0,
  }) async {
    final result = await _repo.addCategory(
      arabicName: arabicName,
      englishName: englishName,
      imageUrl: imageUrl,
      orderNumber: orderNumber,
      imageBytes: imageBytes,
      parentId: parentId,
      calculatorType: calculatorType,
      calculatorLink: calculatorLink,
      titleSize: titleSize,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      opacity: opacity,
    );
    if (result is Right && !isClosed) {
      if (parentId != null) {
        await loadSubcategories(parentId, forceRefresh: true);
      } else {
        await loadTopLevel();
      }
    }
    return result;
  }

  Future<Either<Failure, CategoryModel>> updateCategory({
    required String id,
    required String arabicName,
    required String englishName,
    required String imageUrl,
    required int orderNumber,
    Uint8List? imageBytes,
    String? parentId,
    CalculatorType? calculatorType,
    String? calculatorLink,
    double titleSize = 16.0,
    double imageWidth = 0.8,
    double imageHeight = 0.8,
    double opacity = 1.0,
  }) async {
    final result = await _repo.updateCategory(
      id: id,
      arabicName: arabicName,
      englishName: englishName,
      imageUrl: imageUrl,
      orderNumber: orderNumber,
      imageBytes: imageBytes,
      parentId: parentId,
      calculatorType: calculatorType,
      calculatorLink: calculatorLink,
      titleSize: titleSize,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      opacity: opacity,
    );
    if (result is Right && !isClosed) {
      if (parentId != null) {
        await loadSubcategories(parentId, forceRefresh: true);
      } else {
        await loadTopLevel();
      }
    }
    return result;
  }

  Future<void> deleteCategory(String id, {String? parentId}) async {
    await _repo.deleteCategory(id);
    if (!isClosed) {
      if (parentId != null && parentId.isNotEmpty) {
        await loadSubcategories(parentId, forceRefresh: true);
      } else {
        await loadTopLevel();
      }
    }
  }
}
