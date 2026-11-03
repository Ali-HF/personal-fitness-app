class WorkoutLog {
  final String id;
  final String date; // YYYY-MM-DD
  final String sessionId;
  final String sessionType;
  final String? notes;
  final int? rpe; // 1-10
  final double? runDistanceKm;
  final int? runDurationSeconds;
  final int? avgPaceSeconds;
  final String? routeJson;
  final List<SetLog> sets;
  final DateTime createdAt;

  WorkoutLog({
    required this.id,
    required this.date,
    required this.sessionId,
    required this.sessionType,
    this.notes,
    this.rpe,
    this.runDistanceKm,
    this.runDurationSeconds,
    this.avgPaceSeconds,
    this.routeJson,
    this.sets = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'session_id': sessionId,
      'session_type': sessionType,
      'notes': notes,
      'rpe': rpe,
      'run_distance_km': runDistanceKm,
      'run_duration_seconds': runDurationSeconds,
      'avg_pace_seconds': avgPaceSeconds,
      'route_json': routeJson,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WorkoutLog.fromMap(Map<String, dynamic> map, [List<SetLog> sets = const []]) {
    return WorkoutLog(
      id: map['id'] as String,
      date: map['date'] as String,
      sessionId: map['session_id'] as String,
      sessionType: map['session_type'] as String,
      notes: map['notes'] as String?,
      rpe: map['rpe'] as int?,
      runDistanceKm: (map['run_distance_km'] as num?)?.toDouble(),
      runDurationSeconds: map['run_duration_seconds'] as int?,
      avgPaceSeconds: map['avg_pace_seconds'] as int?,
      routeJson: map['route_json'] as String?,
      sets: sets,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class SetLog {
  final String id;
  final String workoutLogId;
  final String exerciseId;
  final String exerciseName;
  final int setNumber;
  final int targetReps;
  final double targetWeightKg;
  final int completedReps;
  final double completedWeightKg;
  final bool isCompleted;

  SetLog({
    required this.id,
    required this.workoutLogId,
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    required this.targetReps,
    required this.targetWeightKg,
    required this.completedReps,
    required this.completedWeightKg,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_log_id': workoutLogId,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'set_number': setNumber,
      'target_reps': targetReps,
      'target_weight_kg': targetWeightKg,
      'completed_reps': completedReps,
      'completed_weight_kg': completedWeightKg,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory SetLog.fromMap(Map<String, dynamic> map) {
    return SetLog(
      id: map['id'] as String,
      workoutLogId: map['workout_log_id'] as String,
      exerciseId: map['exercise_id'] as String,
      exerciseName: map['exercise_name'] as String,
      setNumber: map['set_number'] as int,
      targetReps: map['target_reps'] as int? ?? 0,
      targetWeightKg: (map['target_weight_kg'] as num?)?.toDouble() ?? 0.0,
      completedReps: map['completed_reps'] as int? ?? 0,
      completedWeightKg: (map['completed_weight_kg'] as num?)?.toDouble() ?? 0.0,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    );
  }

  SetLog copyWith({
    String? id,
    String? workoutLogId,
    String? exerciseId,
    String? exerciseName,
    int? setNumber,
    int? targetReps,
    double? targetWeightKg,
    int? completedReps,
    double? completedWeightKg,
    bool? isCompleted,
  }) {
    return SetLog(
      id: id ?? this.id,
      workoutLogId: workoutLogId ?? this.workoutLogId,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      setNumber: setNumber ?? this.setNumber,
      targetReps: targetReps ?? this.targetReps,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      completedReps: completedReps ?? this.completedReps,
      completedWeightKg: completedWeightKg ?? this.completedWeightKg,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
