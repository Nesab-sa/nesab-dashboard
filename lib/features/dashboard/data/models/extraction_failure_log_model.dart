/// Model for a row in [extraction_failure_logs] table.
///
/// Auto-logged when a product page is detected but the add-to-cart button
/// cannot be shown (missing price or extraction failure).
class ExtractionFailureLogModel {
  const ExtractionFailureLogModel({
    required this.id,
    required this.url,
    this.marketplace,
    required this.titleFound,
    this.titleValue,
    required this.priceFound,
    this.priceValue,
    required this.colorFound,
    this.colorValue,
    required this.sizeFound,
    this.sizeValue,
    required this.hasColorSelector,
    required this.hasSizeSelector,
    required this.buttonShown,
    this.userId,
    required this.createdAt,
  });

  final String id;
  final String url;
  final String? marketplace;
  final bool titleFound;
  final String? titleValue;
  final bool priceFound;
  final num? priceValue;
  final bool colorFound;
  final String? colorValue;
  final bool sizeFound;
  final String? sizeValue;
  final bool hasColorSelector;
  final bool hasSizeSelector;
  final bool buttonShown;
  final String? userId;
  final DateTime createdAt;

  factory ExtractionFailureLogModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'];
    final createdAt = createdAtRaw is String
        ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
        : createdAtRaw != null
            ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now()
            : DateTime.now();

    return ExtractionFailureLogModel(
      id: json['id'] as String,
      url: json['url'] as String,
      marketplace: json['marketplace'] as String?,
      titleFound: json['title_found'] as bool? ?? false,
      titleValue: json['title_value'] as String?,
      priceFound: json['price_found'] as bool? ?? false,
      priceValue: (json['price_value'] as num?)?.toDouble(),
      colorFound: json['color_found'] as bool? ?? false,
      colorValue: json['color_value'] as String?,
      sizeFound: json['size_found'] as bool? ?? false,
      sizeValue: json['size_value'] as String?,
      hasColorSelector: json['has_color_selector'] as bool? ?? false,
      hasSizeSelector: json['has_size_selector'] as bool? ?? false,
      buttonShown: json['button_shown'] as bool? ?? false,
      userId: json['user_id'] as String?,
      createdAt: createdAt,
    );
  }
}
