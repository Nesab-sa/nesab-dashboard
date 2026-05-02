import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nesab_dashboard/features/calculators/data/models/calculator_type.dart';

/// Defaults for optional display fields.
const double kDefaultTitleSize = 16.0;
const double kDefaultImageWidth = 0.8;
const double kDefaultImageHeight = 0.8;
const double kDefaultOpacity = 1.0;

/// Category or subcategory: Arabic name, English name, image URL, and display options.
/// [parentId] is null for top-level categories; non-null for subcategories.
/// [calculatorType] links a subcategory to a calculator enum value.
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.arabicName,
    required this.englishName,
    required this.imageUrl,
    this.parentId,
    required this.orderNumber,
    this.calculatorType,
    this.calculatorLink,
    this.titleSize = kDefaultTitleSize,
    this.imageWidth = kDefaultImageWidth,
    this.imageHeight = kDefaultImageHeight,
    this.opacity = kDefaultOpacity,
  });

  final String id;
  final String arabicName;
  final String englishName;
  final String imageUrl;
  /// Empty or null for top-level; category id for subcategories.
  final String? parentId;
  
  /// Order number used to sort categories in the client. Must be unique per level.
  final int orderNumber;
  /// For subcategories: calculator type enum. Null for top-level or when not set.
  final CalculatorType? calculatorType;
  /// Optional external link for the calculator (e.g. a web URL).
  final String? calculatorLink;
  /// Title font size (logical pixels).
  final double titleSize;
  /// Image width as fraction of card width (0..1).
  final double imageWidth;
  /// Image height as fraction of card height (0..1).
  final double imageHeight;
  /// Image/overlay opacity 0.0..1.0.
  final double opacity;

  bool get isTopLevel => parentId == null || parentId!.isEmpty;

  /// Label in the requested language; falls back to the other if empty.
  String displayLabel(bool useEnglish) => useEnglish
      ? (englishName.isNotEmpty ? englishName : arabicName)
      : (arabicName.isNotEmpty ? arabicName : englishName);

  double get clampedImageWidth => imageWidth.clamp(0.0, 1.0);
  double get clampedImageHeight => imageHeight.clamp(0.0, 1.0);
  double get clampedTitleSize => titleSize.clamp(10.0, 32.0);
  double get clampedOpacity => opacity.clamp(0.0, 1.0);

  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final parent = data[_parentIdKey];
    final calcType = data[_calculatorTypeKey];
    final calcLink = data[_calculatorLinkKey];
    return CategoryModel(
      id: doc.id,
      arabicName: (data[_arabicNameKey] ?? '').toString(),
      englishName: (data[_englishNameKey] ?? '').toString(),
      imageUrl: (data[_imageUrlKey] ?? '').toString(),
      parentId: parent == null || parent == '' ? null : parent.toString(),
      orderNumber: (data[_orderNumberKey] as int?) ?? 0,
      calculatorType: calcType == null || calcType.toString().isEmpty
          ? null
          : CalculatorType.fromValue(calcType.toString()),
      calculatorLink: calcLink == null || calcLink.toString().isEmpty
          ? null
          : calcLink.toString(),
      titleSize: _toDouble(data[_titleSizeKey], kDefaultTitleSize),
      imageWidth: _toDouble(data[_imageWidthKey], kDefaultImageWidth),
      imageHeight: _toDouble(data[_imageHeightKey], kDefaultImageHeight),
      opacity: _toDouble(data[_opacityKey], kDefaultOpacity),
    );
  }

  static double _toDouble(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    final d = double.tryParse(v.toString());
    return d ?? fallback;
  }

  Map<String, dynamic> toFirestore() {
    return {
      _arabicNameKey: arabicName,
      _englishNameKey: englishName,
      _imageUrlKey: imageUrl,
      _parentIdKey: parentId ?? '',
      _orderNumberKey: orderNumber,
      _calculatorTypeKey: calculatorType?.value ?? '',
      _calculatorLinkKey: calculatorLink ?? '',
      _titleSizeKey: titleSize,
      _imageWidthKey: imageWidth,
      _imageHeightKey: imageHeight,
      _opacityKey: opacity,
    };
  }
}

const String _arabicNameKey = 'arabicName';
const String _englishNameKey = 'englishName';
const String _imageUrlKey = 'imageUrl';
const String _parentIdKey = 'parentId';
const String _orderNumberKey = 'orderNumber';
const String _calculatorTypeKey = 'calculatorType';
const String _calculatorLinkKey = 'calculatorLink';
const String _titleSizeKey = 'titleSize';
const String _imageWidthKey = 'imageWidth';
const String _imageHeightKey = 'imageHeight';
const String _opacityKey = 'opacity';
