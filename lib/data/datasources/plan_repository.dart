import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/session.dart';
import '../models/exercise.dart';

class PlanRepository {
  static final PlanRepository instance = PlanRepository._init();
  PlanRepository._init();

  Map<String, Exercise>? _exercisesCache;
  Map<String, dynamic>? _workoutsJsonCache;
  Map<String, dynamic>? _planJsonCache;

  Future<void> load() async {
    if (_exercisesCache != null && _planJsonCache != null) return;

    final workoutsString = await rootBundle.loadString('assets/workouts.json');
    _workoutsJsonCache = json.decode(workoutsString) as Map<String, dynamic>;

    final rawExercises = _workoutsJsonCache!['exercises'] as List<dynamic>;
    _exercisesCache = {
      for (final e in rawExercises)
        e['id'] as String: Exercise.fromJson(e as Map<String, dynamic>)
    };

    final planString = await rootBundle.loadString('assets/plan.json');
    _planJsonCache = json.decode(planString) as Map<String, dynamic>;
  }

  Map<String, Exercise> get exercises => _exercisesCache ?? {};

  Exercise? getExercise(String id) => _exercisesCache?[id];

  Map<String, dynamic>? getWorkoutTemplate(String templateId) {
    if (_workoutsJsonCache == null) return null;
    final templates = _workoutsJsonCache!['templates'] as Map<String, dynamic>?;
    return templates?[templateId] as Map<String, dynamic>?;
  }

  List<PlannedSession> getSessionsForVariant(String variantKey) {
    if (_planJsonCache == null) return [];
    final variants = _planJsonCache!['variants'] as Map<String, dynamic>?;
    if (variants == null || !variants.containsKey(variantKey)) {
      variantKey = 'JAN_3'; // fallback default
    }
    final variantData = variants![variantKey] as Map<String, dynamic>;
    final rawSessions = variantData['sessions'] as List<dynamic>;

    return rawSessions
        .map((s) => PlannedSession.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  PlannedSession? getSessionForDate(String variantKey, String date) {
    final list = getSessionsForVariant(variantKey);
    try {
      return list.firstWhere((s) => s.date == date);
    } catch (_) {
      return null;
    }
  }
}

