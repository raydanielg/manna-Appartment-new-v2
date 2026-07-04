import 'package:intl/intl.dart';

class DateFormatter {
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, HH:mm');
  static final _month = DateFormat('MMM yyyy');

  static String date(DateTime date) => _date.format(date);
  static String dateTime(DateTime date) => _dateTime.format(date);
  static String month(DateTime date) => _month.format(date);
  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return ' days ago';
    return _date.format(date);
  }
}
