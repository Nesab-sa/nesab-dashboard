/// Identifies each service category for routing and data lookup.
enum CategoryType {
  personalFinance('personal-finance'),
  realEstate('real-estate'),
  leasing('leasing'),
  pos('pos'),
  charity('charity'),
  tools('tools');

  const CategoryType(this.value);

  /// URL-safe slug used in route paths.
  final String value;

  /// Parses a route parameter back into a [CategoryType].
  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere((e) => e.value == value);
  }
}
