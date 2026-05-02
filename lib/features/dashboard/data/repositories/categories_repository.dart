import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:nesab_dashboard/core/errors/failures.dart';
import 'package:nesab_dashboard/features/calculators/data/models/calculator_type.dart';

import '../datasources/categories_firestore_datasource.dart'
    show CategoriesFirestoreDatasource, categoriesCollection;
import '../datasources/category_storage_datasource.dart';
import '../models/category_model.dart';

typedef AddCategoryResult = Either<Failure, CategoryModel>;

class CategoriesRepository {
  CategoriesRepository({
    CategoriesFirestoreDatasource? firestore,
    CategoryStorageDatasource? storage,
    FirebaseFirestore? firestoreInstance,
  }) : _firestore =
           firestore ??
           CategoriesFirestoreDatasource(firestore: firestoreInstance),
       _storage = storage ?? CategoryStorageDatasource();

  final CategoriesFirestoreDatasource _firestore;
  final CategoryStorageDatasource _storage;

  Future<Either<Failure, List<CategoryModel>>> getTopLevelCategories() async {
    try {
      final result = await _firestore.getTopLevelCategories();
      return right(result);
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<CategoryModel>>> getSubcategories(String parentId) async {
    try {
      final result = await _firestore.getSubcategories(parentId);
      return right(result);
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }

  Future<bool> isOrderNumberTaken({
    required int orderNumber,
    String? parentId,
    String? excludeId,
  }) =>
      _firestore.isOrderNumberTaken(
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
    try {
      final docRef = FirebaseFirestore.instance
          .collection(categoriesCollection)
          .doc();
      final id = docRef.id;

      String finalImageUrl = imageUrl;
      if (imageBytes != null) {
        final path = _storage.pathForCategoryImage(id);
        finalImageUrl = await _storage.uploadBytes(
          path: path,
          bytes: imageBytes,
        );
      }

      await _firestore.addCategory(
        id: id,
        arabicName: arabicName.trim(),
        englishName: englishName.trim(),
        imageUrl: finalImageUrl,
        orderNumber: orderNumber,
        parentId: parentId,
        calculatorType: calculatorType,
        calculatorLink: calculatorLink,
        titleSize: titleSize,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        opacity: opacity,
      );

      final category = CategoryModel(
        id: id,
        arabicName: arabicName.trim(),
        englishName: englishName.trim(),
        imageUrl: finalImageUrl,
        parentId: parentId,
        orderNumber: orderNumber,
        calculatorType: calculatorType,
        calculatorLink: calculatorLink,
        titleSize: titleSize,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        opacity: opacity,
      );
      return right(category);
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
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
    try {
      String finalImageUrl = imageUrl;
      if (imageBytes != null) {
        final path = _storage.pathForCategoryImage(id);
        finalImageUrl = await _storage.uploadBytes(
          path: path,
          bytes: imageBytes,
        );
      } else if (imageUrl.trim().isEmpty) {
        final current = await _firestore.getCategoryById(id);
        finalImageUrl = current?.imageUrl ?? '';
      }
      await _firestore.updateCategory(
        id: id,
        arabicName: arabicName.trim(),
        englishName: englishName.trim(),
        imageUrl: finalImageUrl,
        orderNumber: orderNumber,
        parentId: parentId,
        calculatorType: calculatorType,
        calculatorLink: calculatorLink,
        titleSize: titleSize,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        opacity: opacity,
      );
      return right(CategoryModel(
        id: id,
        arabicName: arabicName.trim(),
        englishName: englishName.trim(),
        imageUrl: finalImageUrl,
        parentId: parentId,
        orderNumber: orderNumber,
        calculatorType: calculatorType,
        calculatorLink: calculatorLink,
        titleSize: titleSize,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        opacity: opacity,
      ));
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _firestore.deleteCategory(id);
      return right(null);
    } catch (e) {
      return left(GeneralFailure(message: e.toString()));
    }
  }
}
