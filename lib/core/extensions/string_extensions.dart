extension StringExtensions on String {
  bool get isNotBlank => trim().isNotEmpty;

  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
