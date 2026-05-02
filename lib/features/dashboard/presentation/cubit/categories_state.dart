import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/category_model.dart';

part 'categories_state.freezed.dart';

@freezed
class CategoriesState with _$CategoriesState {
  const factory CategoriesState.initial() = _Initial;
  const factory CategoriesState.loading() = _Loading;
  const factory CategoriesState.loaded({
    required List<CategoryModel> topLevel,
    required Map<String, List<CategoryModel>> subcategories,
    String? expandedId,
    @Default({}) Set<String> selectedIds,
    @Default(false) bool loadingSub,
  }) = _Loaded;
  const factory CategoriesState.error(String message) = _Error;
}
