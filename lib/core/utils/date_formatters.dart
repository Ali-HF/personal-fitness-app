import 'package:intl/intl.dart';

class AppDateFormatters {
  static final DateFormat isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat dayMonth = DateFormat('EEE, d MMM');
  static final DateFormat fullDate = DateFormat('EEEE, MMMM d, yyyy');
  static final DateFormat shortDay = DateFormat('E');
  static final DateFormat dayNumber = DateFormat('d');
  static final DateFormat monthYear = DateFormat('MMMM yyyy');

  static String toIso(DateTime dt) => isoDate.format(dt);
  static DateTime fromIso(String str) => isoDate.parse(str);

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
