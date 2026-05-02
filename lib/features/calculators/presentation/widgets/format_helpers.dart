import 'package:intl/intl.dart';

/// Format a number as currency with SAR suffix.
String formatSar(double value) {
  final formatter = NumberFormat('#,##0.00', 'en_US');
  return '${formatter.format(value)} ريال';
}

/// Format a percentage value.
String formatPercent(double value) {
  return '${(value * 100).toStringAsFixed(2)}%';
}

/// Format months with Arabic label.
String formatMonths(int months) {
  return '$months شهر';
}

/// Format a number with commas.
String formatNumber(double value) {
  final formatter = NumberFormat('#,##0.00', 'en_US');
  return formatter.format(value);
}
