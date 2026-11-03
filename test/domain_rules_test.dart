import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/data/models/session.dart';
import 'package:fitness_app/data/models/workout_log.dart';
import 'package:fitness_app/data/models/readiness_checkin.dart';
import 'package:fitness_app/data/models/session_change.dart';
import 'package:fitness_app/data/models/user_settings.dart';
import 'package:fitness_app/domain/rules/swap_rules.dart';
import 'package:fitness_app/domain/rules/long_run_cap_rule.dart';
import 'package:fitness_app/domain/rules/readiness_rules.dart';
import 'package:fitness_app/domain/rules/finals_mode_rule.dart';
import 'package:fitness_app/domain/rules/export_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Swap Rules', () {
    test('blocks two hard days back-to-back', () {
      final sessions = {
        '2026-11-19': const PlannedSession(
          id: 's1',
          date: '2026-11-19',
          weekNumber: 3,
          type: 'INT',
          title: 'INT-1',
          category: 'run',
          isHard: true,
        ),
      };

      // Trying to swap 2026-11-20 to TEMPO (which is directly after INT on 19th)
      final validation = SwapRules.validateSwap(
        targetDate: '2026-11-20',
        targetType: 'TEMPO',
        allSessionsByDate: sessions,
      );

      expect(validation.isAllowed, isFalse);
      expect(validation.message, contains('Two hard days back-to-back are blocked'));
    });

    test('allows swapping run to easy or rest without conflict', () {
      final sessions = {
        '2026-11-19': const PlannedSession(
          id: 's1',
          date: '2026-11-19',
          weekNumber: 3,
          type: 'INT',
          title: 'INT-1',
          category: 'run',
          isHard: true,
        ),
      };

      final validation = SwapRules.validateSwap(
        targetDate: '2026-11-20',
        targetType: 'EASY',
        allSessionsByDate: sessions,
      );

      expect(validation.isAllowed, isTrue);
      expect(validation.hasWarning, isFalse);
    });

    test('warns when LONG is scheduled within 2 days of Leg A', () {
      final sessions = {
        '2026-11-18': const PlannedSession(
          id: 's_leg',
          date: '2026-11-18',
          weekNumber: 3,
          type: 'LEG_A',
          title: 'Leg A Strength',
          category: 'strength',
          isHard: false,
        ),
      };

      final validation = SwapRules.validateSwap(
        targetDate: '2026-11-19',
        targetType: 'LONG',
        allSessionsByDate: sessions,
      );

      expect(validation.isAllowed, isTrue);
      expect(validation.hasWarning, isTrue);
      expect(validation.message, contains('Leg A'));
    });
  });

  group('Long Run Cap Rule', () {
    test('does not warn when proposed run is within 115% of longest run in last 30 days', () {
      final pastRuns = [
        WorkoutLog(
          id: 'w1',
          date: '2026-11-05',
          sessionId: 's1',
          sessionType: 'LONG',
          runDistanceKm: 6.0,
        ),
      ];

      // 6.0 * 1.15 = 6.9 km. 6.5 km should pass clean.
      final result = LongRunCapRule.evaluate(
        proposedDistanceKm: 6.5,
        runLogsLast30Days: pastRuns,
      );

      expect(result.isWarningTriggered, isFalse);
    });

    test('warns when proposed run exceeds 115% threshold', () {
      final pastRuns = [
        WorkoutLog(
          id: 'w1',
          date: '2026-11-05',
          sessionId: 's1',
          sessionType: 'LONG',
          runDistanceKm: 5.0,
        ),
      ];

      // 5.0 * 1.15 = 5.75 km. 7.0 km should trigger warning.
      final result = LongRunCapRule.evaluate(
        proposedDistanceKm: 7.0,
        runLogsLast30Days: pastRuns,
      );

      expect(result.isWarningTriggered, isTrue);
      expect(result.warningMessage, contains('Long-run cap warning'));
      expect(result.allowedCapKm, equals(5.8));
    });
  });

  group('Readiness Rules', () {
    test('sharp pain suggests rest immediately', () {
      const checkIn = ReadinessCheckIn(
        date: '2026-11-10',
        sleepHours: 8.0,
        legSoreness: 2,
        pain: 'sharp',
        stress: 1,
      );

      final eval = ReadinessRules.evaluate(checkIn: checkIn);
      expect(eval.flag, equals(ReadinessFlag.danger));
      expect(eval.shouldSwap, isTrue);
      expect(eval.suggestedType, equals('REST'));
    });

    test('soreness >= 7 or sleep < 6 downgrades interval/tempo to easy', () {
      const checkIn = ReadinessCheckIn(
        date: '2026-11-19',
        sleepHours: 5.0,
        legSoreness: 7,
        pain: 'none',
        stress: 3,
      );

      const session = PlannedSession(
        id: 's_int',
        date: '2026-11-19',
        weekNumber: 3,
        type: 'INT',
        title: 'INT-1',
        category: 'run',
        isHard: true,
      );

      final eval = ReadinessRules.evaluate(checkIn: checkIn, currentSession: session);
      expect(eval.flag, equals(ReadinessFlag.warning));
      expect(eval.shouldSwap, isTrue);
      expect(eval.suggestedType, equals('EASY'));
    });
  });

  group('Finals Mode Rule', () {
    test('correctly identifies dates within finals window', () {
      expect(
        FinalsModeRule.isInFinalsMode(
          currentDate: '2026-12-05',
          finalsStart: '2026-12-01',
          finalsEnd: '2026-12-15',
        ),
        isTrue,
      );

      expect(
        FinalsModeRule.isInFinalsMode(
          currentDate: '2026-11-20',
          finalsStart: '2026-12-01',
          finalsEnd: '2026-12-15',
        ),
        isFalse,
      );
    });
  });

  group('Export Generator', () {
    test('generates markdown summary and JSON without errors', () {
      final dates = ['2026-11-04', '2026-11-05'];
      final planned = {
        '2026-11-04': const PlannedSession(
          id: 's1',
          date: '2026-11-04',
          weekNumber: 1,
          type: 'UA',
          title: 'Upper A',
          category: 'strength',
          isHard: false,
        ),
        '2026-11-05': const PlannedSession(
          id: 's2',
          date: '2026-11-05',
          weekNumber: 1,
          type: 'RW',
          title: 'Run Walk 1',
          category: 'run',
          isHard: false,
        ),
      };

      final workoutLogs = {
        '2026-11-05': WorkoutLog(
          id: 'w1',
          date: '2026-11-05',
          sessionId: 's2',
          sessionType: 'RW',
          runDistanceKm: 4.0,
          runDurationSeconds: 1800,
          avgPaceSeconds: 450,
          rpe: 6,
        ),
      };

      final md = ExportGenerator.generateMarkdownSummary(
        dateRange: dates,
        plannedSessions: planned,
        workoutLogs: workoutLogs,
        readinessLogs: {},
        sessionChanges: {},
        bodyLogs: {},
        postureLogs: {},
        settings: const UserSettings(),
        past30DaysRunLogs: [],
      );

      expect(md, contains('# Weekly Fitness Training Summary'));
      expect(md, contains('Run Walk 1'));
      expect(md, contains('4.0 km'));

      final jsonStr = ExportGenerator.generateFullJson(
        appVersion: '1.0.0',
        planVersion: '2.0.0',
        settings: const UserSettings(),
        workoutLogs: workoutLogs.values.toList(),
        readinessLogs: [],
        sessionChanges: [],
        bodyLogs: [],
        postureLogs: [],
      );

      expect(jsonStr, contains('"app_version": "1.0.0"'));
      expect(jsonStr, contains('"workout_logs"'));
    });
  });
}
