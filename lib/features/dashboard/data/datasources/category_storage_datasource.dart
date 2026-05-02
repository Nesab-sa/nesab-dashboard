import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Storage path prefix for category images.
const String categoriesStoragePrefix = 'categories';

/// Uploads a category image and returns the download URL.
/// Uses bytes so it works on web (Image.file is not supported on Flutter Web).
class CategoryStorageDatasource {
  CategoryStorageDatasource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads [bytes] to [path] (e.g. "categories/catId/image").
  /// Returns the download URL on success.
  Future<String> uploadBytes({
    required String path,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref().child(path);
    await ref.putData(bytes);
    final url = await ref.getDownloadURL();
    return url;
  }

  /// Builds a unique path for a category image: categories/{id}/{timestamp}_image
  String pathForCategoryImage(String categoryId) {
    final name = '${DateTime.now().millisecondsSinceEpoch}_image';
    return '$categoriesStoragePrefix/$categoryId/$name';
  }
}
