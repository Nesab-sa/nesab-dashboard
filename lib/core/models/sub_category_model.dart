/// A sub-item within a service category.
class SubCategoryModel {
  const SubCategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    this.isComingSoon = false,
  });

  final int id;
  final String name;
  final String description;
  final String imagePath;
  final bool isComingSoon;
}
