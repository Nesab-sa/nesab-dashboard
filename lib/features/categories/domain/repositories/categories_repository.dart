import 'package:nesab/core/models/category_model.dart';

abstract class CategoriesRepository {
  Future<List<CategoryModel>> getTopLevelCategories();
  Future<List<CategoryModel>> getSubcategories(String parentId);
  Future<CategoryModel?> getCategoryById(String id);
}
