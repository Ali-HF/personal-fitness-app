import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/data/models/session.dart';
import 'package:fitness_app/data/models/exercise.dart';

void main() {
  group('Plan Loader & Workouts Spec Verification', () {
    test('plan.json contains all 3 variants with correct sessions and dates', () async {
      final file = File('assets/plan.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = await file.readAsString();
      final Map<String, dynamic> data = json.decode(jsonContent);

      expect(data['version'], equals('2.0.0'));
      expect(data['variants'], isNotNull);

      final variants = data['variants'] as Map<String, dynamic>;
      expect(variants.containsKey('JAN_3'), isTrue);
      expect(variants.containsKey('JAN_17'), isTrue);
      expect(variants.containsKey('JAN_24'), isTrue);

      // Verify JAN_3 variant
      final jan3 = variants['JAN_3'] as Map<String, dynamic>;
      expect(jan3['raceDate'], equals('2027-01-03'));
      expect(jan3['totalWeeks'], equals(9));
      final jan3Sessions = (jan3['sessions'] as List<dynamic>)
          .map((s) => PlannedSession.fromJson(s as Map<String, dynamic>))
          .toList();
      expect(jan3Sessions.isNotEmpty, isTrue);

      // Verify race day is Jan 3, 2027
      final raceSession = jan3Sessions.firstWhere((s) => s.type == 'RACE');
      expect(raceSession.date, equals('2027-01-03'));
      expect(raceSession.distanceKm, equals(21.1));

      // Verify 5K test on Dec 17, 2026
      final test5kSession = jan3Sessions.firstWhere((s) => s.type == 'TEST5K');
      expect(test5kSession.date, equals('2026-12-17'));

      // Verify Option B: Jan 17, 2027
      final jan17 = variants['JAN_17'] as Map<String, dynamic>;
      expect(jan17['raceDate'], equals('2027-01-17'));
      expect(jan17['totalWeeks'], equals(11));

      // Verify Option C: Jan 24, 2027
      final jan24 = variants['JAN_24'] as Map<String, dynamic>;
      expect(jan24['raceDate'], equals('2027-01-24'));
      expect(jan24['totalWeeks'], equals(12));
    });

    test('workouts.json contains all required exercises, progressions & regressions', () async {
      final file = File('assets/workouts.json');
      expect(file.existsSync(), isTrue);

      final jsonContent = await file.readAsString();
      final Map<String, dynamic> data = json.decode(jsonContent);

      final rawExercises = data['exercises'] as List<dynamic>;
      final exercises = {
        for (final e in rawExercises)
          e['id'] as String: Exercise.fromJson(e as Map<String, dynamic>)
      };

      // Check key exercises from Part 3
      expect(exercises.containsKey('pull_ups'), isTrue);
      expect(exercises['pull_ups']!.regressions, contains('Chin-ups'));

      expect(exercises.containsKey('push_ups'), isTrue);
      expect(exercises['push_ups']!.progressions, contains('Feet-elevated Push-ups'));

      expect(exercises.containsKey('split_squat'), isTrue);
      expect(exercises['split_squat']!.pattern, contains('Single-Leg'));

      expect(exercises.containsKey('single_leg_rdl'), isTrue);
      expect(exercises.containsKey('glute_bridge'), isTrue);

      // Check templates
      final templates = data['templates'] as Map<String, dynamic>;
      expect(templates.containsKey('UA'), isTrue);
      expect(templates.containsKey('UB'), isTrue);
      expect(templates.containsKey('LEG_A'), isTrue);
      expect(templates.containsKey('LEG_B'), isTrue);
      expect(templates.containsKey('FINALS_MINI'), isTrue);
      expect(templates.containsKey('POSTURE'), isTrue);
    });
  });
}

