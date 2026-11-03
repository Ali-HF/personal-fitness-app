import '../../data/models/session.dart';
import '../../data/models/session_change.dart';
import '../../data/models/workout_log.dart';

class MissedWeekAnalysis {
  final int weekNumber;
  final int totalScheduledSessions;
  final int skippedSessionsCount;
  final int completedSessionsCount;
  final bool shouldOfferRepeat;
  final String recommendation;

  const MissedWeekAnalysis({
    required this.weekNumber,
    required this.totalScheduledSessions,
    required this.skippedSessionsCount,
    required this.completedSessionsCount,
    required this.shouldOfferRepeat,
    required this.recommendation,
  });
}

class PlanAdjuster {
  /// Analyzes a week to detect missed sessions and determine if "Repeat this week" is recommended
  static MissedWeekAnalysis analyzeWeek({
    required int weekNumber,
    required List<PlannedSession> weekSessions,
    required Map<String, SessionChange> changes,
    required Map<String, WorkoutLog> logs,
  }) {
    int scheduled = 0;
    int skipped = 0;
    int completed = 0;

    for (final session in weekSessions) {
      if (session.category == 'rest') continue;
      scheduled++;

      final change = changes[session.date];
      final isLogged = logs.containsKey(session.date);

      if (change?.isSkipped == true) {
        skipped++;
      } else if (isLogged) {
        completed++;
      }
    }

    // Spec Part 4: "If 2 or more sessions are skipped in a week, offer 'Repeat this week'."
    final bool offerRepeat = skipped >= 2;

    String recommendation = 'On track. Keep following the weekly build.';
    if (skipped >= 3) {
      recommendation =
          'You missed 3+ sessions this week. Repeating this week is strongly recommended before advancing distance.';
    } else if (skipped == 2) {
      recommendation =
          'You missed 2 sessions this week. You can repeat this week or proceed gently.';
    }

    return MissedWeekAnalysis(
      weekNumber: weekNumber,
      totalScheduledSessions: scheduled,
      skippedSessionsCount: skipped,
      completedSessionsCount: completed,
      shouldOfferRepeat: offerRepeat,
      recommendation: recommendation,
    );
  }

  /// Calculates safely adjusted long run distances after a missed week
  /// so jumps stay within the 115% safety threshold.
  static double calculateAdjustedLongRun({
    required double plannedDistanceKm,
    required double lastCompletedLongRunKm,
  }) {
    if (lastCompletedLongRunKm <= 0) return plannedDistanceKm;

    final double maxSafeDistance = lastCompletedLongRunKm * 1.15;
    if (plannedDistanceKm > maxSafeDistance) {
      // Step up at 112% instead of full jump
      final adjusted = (lastCompletedLongRunKm * 1.12 * 2).round() / 2.0;
      return adjusted;
    }
    return plannedDistanceKm;
  }
}

