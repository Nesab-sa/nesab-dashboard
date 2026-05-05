import 'package:nesab/core/models/category_model.dart';

sealed class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.categories);
  final List<CategoryModel> categories;
}

class CategoriesError extends CategoriesState {
  const CategoriesError(this.message);
  final String message;
}
