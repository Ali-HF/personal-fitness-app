import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/models/workout_log.dart';
import '../../data/models/readiness_checkin.dart';
import '../../data/models/body_log.dart';
import '../../data/models/posture_log.dart';

class LogsState {
  final bool isLoading;
  final Map<String, WorkoutLog> logsByDate;
  final Map<String, ReadinessCheckIn> readinessByDate;
  final Map<String, BodyLog> bodyLogsByDate;
  final Map<String, PostureLog> postureLogsByDate;

  const LogsState({
    required this.isLoading,
    required this.logsByDate,
    required this.readinessByDate,
    required this.bodyLogsByDate,
    required this.postureLogsByDate,
  });

  LogsState copyWith({
    bool? isLoading,
    Map<String, WorkoutLog>? logsByDate,
    Map<String, ReadinessCheckIn>? readinessByDate,
    Map<String, BodyLog>? bodyLogsByDate,
    Map<String, PostureLog>? postureLogsByDate,
  }) {
    return LogsState(
      isLoading: isLoading ?? this.isLoading,
      logsByDate: logsByDate ?? this.logsByDate,
      readinessByDate: readinessByDate ?? this.readinessByDate,
      bodyLogsByDate: bodyLogsByDate ?? this.bodyLogsByDate,
      postureLogsByDate: postureLogsByDate ?? this.postureLogsByDate,
    );
  }
}

final logsProvider = StateNotifierProvider<LogsNotifier, LogsState>((ref) {
  return LogsNotifier();
});

class LogsNotifier extends StateNotifier<LogsState> {
  LogsNotifier()
      : super(const LogsState(
          isLoading: true,
          logsByDate: {},
          readinessByDate: {},
          bodyLogsByDate: {},
          postureLogsByDate: {},
        )) {
    loadAllLogs();
  }

  Future<void> loadAllLogs() async {
    state = state.copyWith(isLoading: true);
    final workouts = await DatabaseHelper.instance.getAllWorkoutLogs();
    final readiness = await DatabaseHelper.instance.getAllReadiness();
    final body = await DatabaseHelper.instance.getAllBodyLogs();
    final posture = await DatabaseHelper.instance.getAllPostureLogs();

    state = state.copyWith(
      isLoading: false,
      logsByDate: {for (final w in workouts) w.date: w},
      readinessByDate: {for (final r in readiness) r.date: r},
      bodyLogsByDate: {for (final b in body) b.date: b},
      postureLogsByDate: {for (final p in posture) p.date: p},
    );
  }

  Future<void> saveWorkoutLog(WorkoutLog log) async {
    await DatabaseHelper.instance.saveWorkoutLog(log);
    final newLogs = Map<String, WorkoutLog>.from(state.logsByDate);
    newLogs[log.date] = log;
    state = state.copyWith(logsByDate: newLogs);
  }

  Future<void> saveReadiness(ReadinessCheckIn checkIn) async {
    await DatabaseHelper.instance.saveReadiness(checkIn);
    final newReadiness = Map<String, ReadinessCheckIn>.from(state.readinessByDate);
    newReadiness[checkIn.date] = checkIn;
    state = state.copyWith(readinessByDate: newReadiness);
  }

  Future<void> saveBodyLog(BodyLog log) async {
    await DatabaseHelper.instance.saveBodyLog(log);
    final newBody = Map<String, BodyLog>.from(state.bodyLogsByDate);
    newBody[log.date] = log;
    state = state.copyWith(bodyLogsByDate: newBody);
  }

  Future<void> togglePosture(String dateStr, bool done, [int minutes = 10]) async {
    final log = PostureLog(date: dateStr, routineDone: done, minutes: minutes);
    await DatabaseHelper.instance.savePostureLog(log);
    final newPosture = Map<String, PostureLog>.from(state.postureLogsByDate);
    newPosture[dateStr] = log;
    state = state.copyWith(postureLogsByDate: newPosture);
  }

  List<WorkoutLog> getPast30DaysRunLogs(DateTime fromDate) {
    final startDate = fromDate.subtract(const Duration(days: 30));
    return state.logsByDate.values.where((log) {
      if (log.runDistanceKm == null || log.runDistanceKm! <= 0) return false;
      try {
        final d = DateTime.parse(log.date);
        return d.isAfter(startDate.subtract(const Duration(days: 1))) &&
            d.isBefore(fromDate.add(const Duration(days: 1)));
      } catch (_) {
        return false;
      }
    }).toList();
  }
}

