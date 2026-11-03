import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/datasources/plan_repository.dart';
import '../../data/models/session.dart';
import '../../data/models/session_change.dart';
import '../../data/models/exercise.dart';
import 'settings_provider.dart';

class PlanState {
  final bool isLoading;
  final List<PlannedSession> sessions;
  final Map<String, SessionChange> changes;
  final Map<String, Exercise> exercises;
  final String activeVariant;

  const PlanState({
    required this.isLoading,
    required this.sessions,
    required this.changes,
    required this.exercises,
    required this.activeVariant,
  });

  PlanState copyWith({
    bool? isLoading,
    List<PlannedSession>? sessions,
    Map<String, SessionChange>? changes,
    Map<String, Exercise>? exercises,
    String? activeVariant,
  }) {
    return PlanState(
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      changes: changes ?? this.changes,
      exercises: exercises ?? this.exercises,
      activeVariant: activeVariant ?? this.activeVariant,
    );
  }
}

final planProvider = StateNotifierProvider<PlanNotifier, PlanState>((ref) {
  final settings = ref.watch(settingsProvider);
  return PlanNotifier(settings.planVariant);
});

class PlanNotifier extends StateNotifier<PlanState> {
  final String initialVariant;

  PlanNotifier(this.initialVariant)
      : super(PlanState(
          isLoading: true,
          sessions: const [],
          changes: const {},
          exercises: const {},
          activeVariant: initialVariant,
        )) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    await PlanRepository.instance.load();
    final rawSessions = PlanRepository.instance.getSessionsForVariant(state.activeVariant);
    final changesList = await DatabaseHelper.instance.getAllSessionChanges();
    final changesMap = {for (final c in changesList) c.date: c};

    state = state.copyWith(
      isLoading: false,
      sessions: rawSessions,
      changes: changesMap,
      exercises: PlanRepository.instance.exercises,
    );
  }

  Future<void> switchVariant(String variantKey) async {
    state = state.copyWith(activeVariant: variantKey, isLoading: true);
    final rawSessions = PlanRepository.instance.getSessionsForVariant(variantKey);
    state = state.copyWith(
      isLoading: false,
      sessions: rawSessions,
    );
  }

  /// Get effective session for a specific date, accounting for swaps
  PlannedSession? getSessionForDate(String dateStr) {
    PlannedSession? base;
    try {
      base = state.sessions.firstWhere((s) => s.date == dateStr);
    } catch (_) {
      base = null;
    }

    final change = state.changes[dateStr];
    if (change == null) return base;

    if (change.isSkipped) {
      if (base != null) {
        return base.copyWith(title: '[Skipped] ${base.title}');
      }
      return null;
    }

    if (change.replacementType != null && base != null) {
      return base.copyWith(
        type: change.replacementType!,
        title: '[Swapped] ${change.reason ?? change.replacementType!}',
        isHard: ['INT', 'TEMPO', 'LONG', 'TEST5K', 'RACE'].contains(change.replacementType!),
      );
    }

    return base;
  }

  /// Swap session on a specific date
  Future<void> swapSession({
    required String dateStr,
    required String originalSessionId,
    required String replacementType,
    required String reason,
  }) async {
    final change = SessionChange(
      date: dateStr,
      originalSessionId: originalSessionId,
      replacementType: replacementType,
      isSkipped: false,
      reason: reason,
    );
    await DatabaseHelper.instance.saveSessionChange(change);
    final newChanges = Map<String, SessionChange>.from(state.changes);
    newChanges[dateStr] = change;
    state = state.copyWith(changes: newChanges);
  }

  /// Mark a session skipped
  Future<void> skipSession({
    required String dateStr,
    required String originalSessionId,
    String? reason,
  }) async {
    final change = SessionChange(
      date: dateStr,
      originalSessionId: originalSessionId,
      isSkipped: true,
      reason: reason ?? 'Skipped by user',
    );
    await DatabaseHelper.instance.saveSessionChange(change);
    final newChanges = Map<String, SessionChange>.from(state.changes);
    newChanges[dateStr] = change;
    state = state.copyWith(changes: newChanges);
  }

  /// Undo a swap or skip on a date
  Future<void> resetSessionChange(String dateStr) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('session_changes', where: 'date = ?', whereArgs: [dateStr]);
    final newChanges = Map<String, SessionChange>.from(state.changes);
    newChanges.remove(dateStr);
    state = state.copyWith(changes: newChanges);
  }

  /// Repeat this week: removes skips and restores base week sessions
  Future<void> repeatWeek(int weekNumber) async {
    final weekSessions = state.sessions.where((s) => s.weekNumber == weekNumber).toList();
    for (final s in weekSessions) {
      await resetSessionChange(s.date);
    }
  }

  /// Count skipped sessions for a given week
  int getSkippedCountForWeek(int weekNumber) {
    final weekSessions = state.sessions.where((s) => s.weekNumber == weekNumber).toList();
    int skipped = 0;
    for (final s in weekSessions) {
      if (state.changes[s.date]?.isSkipped == true) {
        skipped++;
      }
    }
    return skipped;
  }
}
