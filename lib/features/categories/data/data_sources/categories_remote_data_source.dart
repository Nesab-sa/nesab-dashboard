import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nesab/core/models/category_model.dart';

/// Fetches categories from Firestore `categories` collection.
abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getTopLevelCategories();
  Future<List<CategoryModel>> getSubcategories(String parentId);
  Future<CategoryModel?> getCategoryById(String id);
}

class FirestoreCategoriesRemoteDataSource implements CategoriesRemoteDataSource {
  FirestoreCategoriesRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  static const String _collection = 'categories';

  @override
  Future<List<CategoryModel>> getTopLevelCategories() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('parentId', isEqualTo: '')
        .orderBy('orderNumber')
        .get();
    final list = snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
    list.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    return list;
  }

  @override
  Future<List<CategoryModel>> getSubcategories(String parentId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('parentId', isEqualTo: parentId)
        .orderBy('orderNumber')
        .get();
    final list = snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
    list.sort((a, b) => a.orderNumber.compareTo(b.orderNumber));
    return list;
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.data() == null) return null;
    return CategoryModel.fromFirestore(doc);
  }
}
