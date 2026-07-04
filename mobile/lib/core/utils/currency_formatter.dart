import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);
  static String format(num amount) => _formatter.format(amount);
  static String formatShort(num amount) => 'TZS ';
}
