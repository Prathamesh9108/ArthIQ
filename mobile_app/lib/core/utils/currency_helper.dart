import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _inrFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _inrDecimalFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Formats amount into Indian currency format (e.g., ₹ 28,450 or ₹ 1,200)
  static String format(double amount, {bool showDecimals = false, bool spaceAfterSymbol = true}) {
    String formatted = showDecimals ? _inrDecimalFormatter.format(amount) : _inrFormatter.format(amount);
    if (spaceAfterSymbol) {
      formatted = formatted.replaceFirst('₹', '₹ ');
    }
    return formatted;
  }

  /// Compact format for large numbers (e.g. ₹ 25k, ₹ 1.2L)
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return '₹ ${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹ ${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹ ${(amount / 1000).toStringAsFixed(0)}k';
    }
    return format(amount);
  }
}
