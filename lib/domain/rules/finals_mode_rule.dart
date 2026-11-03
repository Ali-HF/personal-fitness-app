class FinalsModeRule {
  /// Checks whether a given date string (YYYY-MM-DD) falls within the finals date range.
  static bool isInFinalsMode({
    required String currentDate,
    required String finalsStart,
    required String finalsEnd,
  }) {
    try {
      final current = DateTime.parse(currentDate);
      final start = DateTime.parse(finalsStart);
      final end = DateTime.parse(finalsEnd);

      return (current.isAfter(start.subtract(const Duration(days: 1))) &&
          current.isBefore(end.add(const Duration(days: 1))));
    } catch (_) {
      return false;
    }
  }

  /// Whether a session type is restricted during finals mode (e.g. INT, TEMPO).
  static bool isRestrictedType(String sessionType) {
    return sessionType == 'INT' || sessionType == 'TEMPO';
  }

  /// Maximum session duration cap in minutes during finals mode.
  static const int maxSessionDurationMinutes = 30;
}

