import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:nesab_dashboard/features/calculators/data/models/calculator_type.dart';

import '../models/category_model.dart';

const String categoriesCollection = 'categories';

/// Firestore field used to query by parent (null = top-level).
const String parentIdField = 'parentId';
const String orderNumberField = 'orderNumber';

class CategoriesFirestoreDatasource {
  CategoriesFirestoreDatasource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Fetches top-level categories (parentId empty).
  Future<List<CategoryModel>> getTopLevelCategories() async {
    final snapshot = await _firestore
        .collection(categoriesCollection)
        .where(parentIdField, isEqualTo: '')
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  /// Fetches a category by [id]. Returns null if not found.
  Future<CategoryModel?> getCategoryById(String id) async {
    final doc = await _firestore.collection(categoriesCollection).doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return CategoryModel.fromFirestore(
      doc as DocumentSnapshot<Map<String, dynamic>>,
    );
  }

  /// Fetches subcategories of [parentId].
  Future<List<CategoryModel>> getSubcategories(String parentId) async {
    final snapshot = await _firestore
        .collection(categoriesCollection)
        .where(parentIdField, isEqualTo: parentId)
        .get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  /// Adds a category (or subcategory if [parentId] is set).
  /// [id] can be a new document ID (e.g. from [DocumentReference.id] before set).
  /// Checks whether [orderNumber] is already used by another category
  /// at the same level (same [parentId]). Optionally excludes [excludeId]
  /// (useful when updating a category to keep its own number).
  Future<bool> isOrderNumberTaken({
    required int orderNumber,
    String? parentId,
    String? excludeId,
  }) async {
    final snapshot = await _firestore
        .collection(categoriesCollection)
        .where(parentIdField, isEqualTo: parentId ?? '')
        .where(orderNumberField, isEqualTo: orderNumber)
        .get();
    if (snapshot.docs.isEmpty) return false;
    if (excludeId != null) {
      return snapshot.docs.any((doc) => doc.id != excludeId);
    }
    return true;
  }

  Future<void> addCategory({
    required String id,
    required String arabicName,
    required String englishName,
    required String imageUrl,
    required int orderNumber,
    String? parentId,
    CalculatorType? calculatorType,
    String? calculatorLink,
    double titleSize = 16.0,
    double imageWidth = 0.8,
    double imageHeight = 0.8,
    double opacity = 1.0,
  }) async {
    final doc = _firestore.collection(categoriesCollection).doc(id);
    final data = CategoryModel(
      id: id,
      arabicName: arabicName,
      englishName: englishName,
      imageUrl: imageUrl,
      parentId: parentId,
      orderNumber: orderNumber,
      calculatorType: calculatorType,
      calculatorLink: calculatorLink,
      titleSize: titleSize,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      opacity: opacity,
    ).toFirestore();
    await doc.set(data);
  }

  /// Updates an existing category.
  Future<void> updateCategory({
    required String id,
    required String arabicName,
    required String englishName,
    required String imageUrl,
    required int orderNumber,
    String? parentId,
    CalculatorType? calculatorType,
    String? calculatorLink,
    double titleSize = 16.0,
    double imageWidth = 0.8,
    double imageHeight = 0.8,
    double opacity = 1.0,
  }) async {
    final doc = _firestore.collection(categoriesCollection).doc(id);
    final data = CategoryModel(
      id: id,
      arabicName: arabicName,
      englishName: englishName,
      imageUrl: imageUrl,
      parentId: parentId,
      orderNumber: orderNumber,
      calculatorType: calculatorType,
      calculatorLink: calculatorLink,
      titleSize: titleSize,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      opacity: opacity,
    ).toFirestore();
    await doc.update(data);
  }

  /// Deletes a category by [id].
  Future<void> deleteCategory(String id) async {
    final doc = _firestore.collection(categoriesCollection).doc(id);
    await doc.delete();
  }
}
