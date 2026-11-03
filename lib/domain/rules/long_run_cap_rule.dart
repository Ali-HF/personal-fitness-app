import '../../data/models/workout_log.dart';

class LongRunCapRule {
  static const double capMultiplier = 1.15; // 115%

  /// Evaluates whether a proposed run distance triggers the 115% spike warning.
  /// [proposedDistanceKm]: the distance of the run being logged or planned.
  /// [runLogsLast30Days]: list of run logs completed within the last 30 days.
  /// [fallbackBaselineKm]: fallback if no runs recorded in last 30 days (default 4.0 km).
  static LongRunCapResult evaluate({
    required double proposedDistanceKm,
    required List<WorkoutLog> runLogsLast30Days,
    double fallbackBaselineKm = 4.0,
  }) {
    double longestRunLast30Days = 0.0;

    for (final log in runLogsLast30Days) {
      final d = log.runDistanceKm ?? 0.0;
      if (d > longestRunLast30Days) {
        longestRunLast30Days = d;
      }
    }

    if (longestRunLast30Days <= 0.0) {
      longestRunLast30Days = fallbackBaselineKm;
    }

    final allowedCapKm = (longestRunLast30Days * capMultiplier);
    final isExceeded = proposedDistanceKm > allowedCapKm + 0.01; // small float tolerance

    if (isExceeded) {
      final percentage = ((proposedDistanceKm / longestRunLast30Days) * 100).round();
      return LongRunCapResult(
        isWarningTriggered: true,
        proposedDistanceKm: proposedDistanceKm,
        longestRecentRunKm: longestRunLast30Days,
        allowedCapKm: double.parse(allowedCapKm.toStringAsFixed(1)),
        warningMessage:
            'Long-run cap warning: $proposedDistanceKm km is $percentage% of your longest recent run ($longestRunLast30Days km). Single-run jumps >115% (${allowedCapKm.toStringAsFixed(1)} km cap) carry elevated overuse risk. Keep the pace strictly easy and take walk breaks.',
      );
    }

    return LongRunCapResult(
      isWarningTriggered: false,
      proposedDistanceKm: proposedDistanceKm,
      longestRecentRunKm: longestRunLast30Days,
      allowedCapKm: double.parse(allowedCapKm.toStringAsFixed(1)),
    );
  }
}

class LongRunCapResult {
  final bool isWarningTriggered;
  final double proposedDistanceKm;
  final double longestRecentRunKm;
  final double allowedCapKm;
  final String? warningMessage;

  const LongRunCapResult({
    required this.isWarningTriggered,
    required this.proposedDistanceKm,
    required this.longestRecentRunKm,
    required this.allowedCapKm,
    this.warningMessage,
  });
}
