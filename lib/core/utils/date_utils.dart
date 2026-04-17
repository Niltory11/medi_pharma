import 'package:intl/intl.dart';

class AppDateUtils {
  static String format(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String formatWithTime(DateTime date) =>
      DateFormat('dd MMM yyyy – hh:mm a').format(date);

  static int daysUntilExpiry(DateTime expiry) =>
      expiry.difference(DateTime.now()).inDays;
}