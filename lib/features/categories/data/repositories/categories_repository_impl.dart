import 'package:nesab/core/models/category_model.dart';
import 'package:nesab/features/categories/data/data_sources/categories_remote_data_source.dart';
import 'package:nesab/features/categories/domain/repositories/categories_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl(this._remote);

  final CategoriesRemoteDataSource _remote;

  @override
  Future<List<CategoryModel>> getTopLevelCategories() async {
    try {
      final list = await _remote.getTopLevelCategories();
      return list;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<CategoryModel>> getSubcategories(String parentId) async {
    try {
      return await _remote.getSubcategories(parentId);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      return await _remote.getCategoryById(id);
    } catch (_) {
      return null;
    }
  }
}
