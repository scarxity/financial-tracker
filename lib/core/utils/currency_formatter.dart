import 'package:intl/intl.dart';

/// Formats numbers as Indonesian Rupiah (IDR).
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format a number as IDR currency string.
  /// Example: 150000 → "Rp 150.000"
  static String format(double amount) {
    return _formatter.format(amount);
  }

  /// Format with sign prefix for transaction display.
  /// Income: "+Rp 150.000", Expense: "-Rp 150.000"
  static String formatSigned(double amount, {required bool isIncome}) {
    final prefix = isIncome ? '+' : '-';
    return '$prefix${_formatter.format(amount.abs())}';
  }

  /// Parse a currency-formatted string back to double.
  static double? tryParse(String text) {
    try {
      final cleaned = text
          .replaceAll('Rp', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      return double.tryParse(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Compact format for charts: 1.5jt, 500rb, etc.
  static String compact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}rb';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
