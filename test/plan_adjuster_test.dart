import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/data/models/session.dart';
import 'package:fitness_app/data/models/session_change.dart';
import 'package:fitness_app/data/models/workout_log.dart';
import 'package:fitness_app/domain/rules/plan_adjuster.dart';

void main() {
  group('PlanAdjuster Tests', () {
    test('Correctly triggers "Repeat this week" when 2 or more sessions are skipped', () {
      final sessions = [
        const PlannedSession(
          id: 's1',
          date: '2026-11-04',
          weekNumber: 1,
          type: 'UA',
          title: 'Upper A',
          category: 'strength',
          isHard: false,
        ),
        const PlannedSession(
          id: 's2',
          date: '2026-11-05',
          weekNumber: 1,
          type: 'RW1',
          title: 'Run Walk 1',
          category: 'run',
          isHard: false,
        ),
        const PlannedSession(
          id: 's3',
          date: '2026-11-06',
          weekNumber: 1,
          type: 'UB',
          title: 'Upper B',
          category: 'strength',
          isHard: false,
        ),
      ];

      final changes = {
        '2026-11-04': SessionChange(
          date: '2026-11-04',
          originalSessionId: 's1',
          isSkipped: true,
          reason: 'Sick',
        ),
        '2026-11-05': SessionChange(
          date: '2026-11-05',
          originalSessionId: 's2',
          isSkipped: true,
          reason: 'Work late',
        ),
      };

      final Map<String, WorkoutLog> logs = {};

      final analysis = PlanAdjuster.analyzeWeek(
        weekNumber: 1,
        weekSessions: sessions,
        changes: changes,
        logs: logs,
      );

      expect(analysis.skippedSessionsCount, 2);
      expect(analysis.shouldOfferRepeat, isTrue);
    });

    test('Adjusts long run distance downward after layoff to prevent injury jump', () {
      // Last completed was 6 km, planned is 8 km (which is 133% of 6km > 115%)
      final adjusted = PlanAdjuster.calculateAdjustedLongRun(
        plannedDistanceKm: 8.0,
        lastCompletedLongRunKm: 6.0,
      );

      // Should be scaled to safe increment (~6.5-7.0km)
      expect(adjusted, lessThan(8.0));
      expect(adjusted, greaterThanOrEqualTo(6.5));
    });
  });
}

