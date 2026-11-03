import 'dart:convert';
import '../../data/models/session.dart';
import '../../data/models/workout_log.dart';
import '../../data/models/readiness_checkin.dart';
import '../../data/models/session_change.dart';
import '../../data/models/body_log.dart';
import '../../data/models/posture_log.dart';
import '../../data/models/user_settings.dart';
import '../../core/utils/pace_calculator.dart';
import 'long_run_cap_rule.dart';

class ExportGenerator {
  /// Generates the human-readable Markdown summary as specified in Part 4.
  static String generateMarkdownSummary({
    required List<String> dateRange, // sorted list of date strings (YYYY-MM-DD)
    required Map<String, PlannedSession> plannedSessions,
    required Map<String, WorkoutLog> workoutLogs,
    required Map<String, ReadinessCheckIn> readinessLogs,
    required Map<String, SessionChange> sessionChanges,
    required Map<String, BodyLog> bodyLogs,
    required Map<String, PostureLog> postureLogs,
    required UserSettings settings,
    required List<WorkoutLog> past30DaysRunLogs,
  }) {
    final buffer = StringBuffer();
    final startDate = dateRange.isNotEmpty ? dateRange.first : 'N/A';
    final endDate = dateRange.isNotEmpty ? dateRange.last : 'N/A';

    buffer.writeln('# Weekly Fitness Training Summary ($startDate to $endDate)');
    buffer.writeln();
    buffer.writeln('**Plan Variant:** ${settings.planVariant} | **Race Date:** ${settings.raceDate}');
    buffer.writeln();

    // 1. Per-day table
    buffer.writeln('## Daily Session Breakdown');
    buffer.writeln('| Date | Planned | Status | Logged / Details | Swap / Skip Reason |');
    buffer.writeln('|---|---|---|---|---|');

    double totalKmRun = 0.0;
    int plannedSessionCount = 0;
    int completedSessionCount = 0;
    final flags = <String>[];

    for (final date in dateRange) {
      final planned = plannedSessions[date];
      final log = workoutLogs[date];
      final change = sessionChanges[date];

      final plannedTitle = planned?.title ?? 'None';
      if (planned != null && planned.type != 'REST') {
        plannedSessionCount++;
      }

      String status = 'Pending';
      String loggedDetails = '-';
      String reason = change?.reason ?? '-';

      if (change?.isSkipped == true) {
        status = 'Skipped';
        loggedDetails = 'Skipped by user';
        if (planned != null && planned.isHard) {
          flags.add('Warning: Hard session ($plannedTitle on $date) was skipped.');
        }
      } else if (log != null) {
        status = change?.replacementType != null ? 'Swapped & Done' : 'Done';
        completedSessionCount++;

        if (log.runDistanceKm != null && log.runDistanceKm! > 0) {
          totalKmRun += log.runDistanceKm!;
          final paceStr = log.avgPaceSeconds != null
              ? PaceCalculator.formatPace(log.runDistanceKm!, log.runDurationSeconds ?? 0)
              : '';
          loggedDetails =
              '${log.runDistanceKm!.toStringAsFixed(1)} km in ${PaceCalculator.formatDuration(log.runDurationSeconds ?? 0)} ($paceStr), RPE ${log.rpe ?? '-'}';

          // Long run cap check
          final capCheck = LongRunCapRule.evaluate(
            proposedDistanceKm: log.runDistanceKm!,
            runLogsLast30Days: past30DaysRunLogs,
          );
          if (capCheck.isWarningTriggered) {
            flags.add('Cap Warning: ${log.runDistanceKm} km on $date exceeded 115% threshold.');
          }
        } else if (log.sets.isNotEmpty) {
          final topSets = log.sets
              .map((s) => '${s.exerciseName}: ${s.completedWeightKg}kg x ${s.completedReps}')
              .take(3)
              .join('; ');
          loggedDetails = 'Strength ($topSets), RPE ${log.rpe ?? '-'}';
        } else {
          loggedDetails = 'Completed (RPE ${log.rpe ?? '-'})';
        }
      } else if (change?.replacementType != null) {
        status = 'Swapped';
        loggedDetails = 'Swapped to ${change!.replacementType}';
      }

      buffer.writeln('| $date | $plannedTitle | $status | $loggedDetails | $reason |');
    }

    buffer.writeln();

    // 2. Weekly Totals
    final completionRate = plannedSessionCount > 0
        ? ((completedSessionCount / plannedSessionCount) * 100).round()
        : 100;

    buffer.writeln('## Weekly Totals & Adherence');
    buffer.writeln('- **Total Distance Run:** ${totalKmRun.toStringAsFixed(1)} km');
    buffer.writeln('- **Sessions Done:** $completedSessionCount / $plannedSessionCount ($completionRate%)');

    // Posture adherence
    int postureDoneCount = 0;
    for (final date in dateRange) {
      if (postureLogs[date]?.routineDone == true) postureDoneCount++;
    }
    buffer.writeln('- **Daily Posture Routine:** $postureDoneCount / ${dateRange.length} days completed');
    buffer.writeln();

    // 3. Readiness Overview
    buffer.writeln('## Readiness & Recovery Logs');
    buffer.writeln('| Date | Sleep (hrs) | Soreness (0-10) | Pain | Stress (1-5) | Note |');
    buffer.writeln('|---|---|---|---|---|---|');
    for (final date in dateRange) {
      final r = readinessLogs[date];
      if (r != null) {
        buffer.writeln(
            '| $date | ${r.sleepHours}h | ${r.legSoreness}/10 | ${r.pain} | ${r.stress}/5 | ${r.note ?? '-'} |');
      }
    }
    buffer.writeln();

    // 4. Body & Weight Trend
    buffer.writeln('## Body Metrics');
    final recordedWeights = <double>[];
    for (final date in dateRange) {
      final b = bodyLogs[date];
      if (b?.weightKg != null) {
        recordedWeights.add(b!.weightKg!);
      }
    }
    if (recordedWeights.isNotEmpty) {
      final avgWeight = (recordedWeights.reduce((a, b) => a + b) / recordedWeights.length);
      buffer.writeln('- **7-Day Average Weight:** ${avgWeight.toStringAsFixed(2)} kg');
      final latestWaist = bodyLogs.values
          .where((b) => b.waistCm != null)
          .map((b) => b.waistCm!)
          .lastOrNull;
      if (latestWaist != null) {
        buffer.writeln('- **Latest Waist Measurement:** ${latestWaist.toStringAsFixed(1)} cm');
      }
    } else {
      buffer.writeln('- *No body weight logs in this period.*');
    }
    buffer.writeln();

    // 5. Training Flags & Guidance
    buffer.writeln('## Training Flags & Notes');
    if (flags.isEmpty) {
      buffer.writeln('- No training cap violations or missed hard sessions detected. Great consistency!');
    } else {
      for (final flag in flags) {
        buffer.writeln('- $flag');
      }
    }

    return buffer.toString();
  }

  /// Generates the full structured JSON for export/backup.
  static String generateFullJson({
    required String appVersion,
    required String planVersion,
    required UserSettings settings,
    required List<WorkoutLog> workoutLogs,
    required List<ReadinessCheckIn> readinessLogs,
    required List<SessionChange> sessionChanges,
    required List<BodyLog> bodyLogs,
    required List<PostureLog> postureLogs,
  }) {
    final data = {
      'exported_at': DateTime.now().toIso8601String(),
      'app_version': appVersion,
      'plan_version': planVersion,
      'settings': settings.toMap(),
      'workout_logs': workoutLogs
          .map((w) => {
                ...w.toMap(),
                'sets': w.sets.map((s) => s.toMap()).toList(),
              })
          .toList(),
      'readiness_logs': readinessLogs.map((r) => r.toMap()).toList(),
      'session_changes': sessionChanges.map((c) => c.toMap()).toList(),
      'body_logs': bodyLogs.map((b) => b.toMap()).toList(),
      'posture_logs': postureLogs.map((p) => p.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }
}
