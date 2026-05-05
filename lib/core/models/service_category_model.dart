import 'package:flutter/material.dart';

import 'package:nesab/core/models/sub_category_model.dart';

/// Holds all display data for a service category, including its sub-categories.
class ServiceCategoryModel {
  const ServiceCategoryModel({
    required this.iconPath,
    required this.imagePath,
    required this.label,
    required this.description,
    required this.color,
    required this.colorLight,
    required this.subCategories,
    this.imageWidth,
    this.imageHeight,
  });

  /// SVG icon path (used in detail hero header).
  final String iconPath;

  /// Illustration image path (used in home grid card).
  final String imagePath;

  final String label;
  final String description;
  final Color color;
  final Color colorLight;
  final List<SubCategoryModel> subCategories;

  /// Optional custom image width (as a fraction of card width).
  final double? imageWidth;

  /// Optional custom image height (as a fraction of card width).
  final double? imageHeight;
}
