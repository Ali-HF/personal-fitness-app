import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/datasources/plan_repository.dart';
import '../../../data/models/session.dart';
import '../../../data/models/exercise.dart';
import '../../../data/models/workout_log.dart';
import 'workout_finish_screen.dart';

class ActiveStrengthScreen extends StatefulWidget {
  final PlannedSession session;
  final Map<String, String> customNames;

  const ActiveStrengthScreen({
    super.key,
    required this.session,
    this.customNames = const {},
  });

  @override
  State<ActiveStrengthScreen> createState() => _ActiveStrengthScreenState();
}

class _ActiveStrengthScreenState extends State<ActiveStrengthScreen> {
  late List<Exercise> _exercises;
  int _currentExerciseIndex = 0;
  final Map<String, List<SetLog>> _setsByExercise = {};

  // Rest Timer
  Timer? _restTimer;
  int _restSecondsRemaining = 0;
  int _restTotalSeconds = 90;
  bool _isRestTimerActive = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable().catchError((_) {});
    final repo = PlanRepository.instance;
    _exercises = widget.session.exerciseIds
        .map((id) => repo.getExercise(id))
        .whereType<Exercise>()
        .toList();

    // Fallback if no specific exercise IDs were mapped (e.g. Finals Mini or custom)
    if (_exercises.isEmpty) {
      final template = repo.getWorkoutTemplate(widget.session.type);
      final tIds = (template?['exerciseIds'] as List<dynamic>?) ?? [];
      _exercises = tIds.map((id) => repo.getExercise(id.toString())).whereType<Exercise>().toList();
    }

    if (_exercises.isEmpty) {
      // Default basic exercises
      _exercises = [
        repo.getExercise('pull_ups')!,
        repo.getExercise('push_ups')!,
        repo.getExercise('split_squat')!,
      ];
    }

    // Initialize set rows for each exercise
    for (final ex in _exercises) {
      final sets = <SetLog>[];
      for (int i = 1; i <= ex.defaultSets; i++) {
        sets.add(SetLog(
          id: const Uuid().v4(),
          workoutLogId: '',
          exerciseId: ex.id,
          exerciseName: widget.customNames[ex.id] ?? ex.name,
          setNumber: i,
          targetReps: ex.defaultReps,
          targetWeightKg: ex.defaultWeightKg,
          completedReps: ex.defaultReps,
          completedWeightKg: ex.defaultWeightKg,
          isCompleted: false,
        ));
      }
      _setsByExercise[ex.id] = sets;
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
  }

  void _startRestTimer([int durationSeconds = 90]) {
    _restTimer?.cancel();
    setState(() {
      _restTotalSeconds = durationSeconds;
      _restSecondsRemaining = durationSeconds;
      _isRestTimerActive = true;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining <= 1) {
        timer.cancel();
        AppHaptics.heavy();
        SystemSound.play(SystemSoundType.alert);
        setState(() {
          _restSecondsRemaining = 0;
          _isRestTimerActive = false;
        });
      } else {
        setState(() {
          _restSecondsRemaining--;
        });
      }
    });
  }

  void _addRestTime(int seconds) {
    AppHaptics.light();
    setState(() {
      _restSecondsRemaining = (_restSecondsRemaining + seconds).clamp(0, 600);
      if (_restSecondsRemaining > _restTotalSeconds) {
        _restTotalSeconds = _restSecondsRemaining;
      }
    });
  }

  void _skipRestTimer() {
    AppHaptics.light();
    _restTimer?.cancel();
    setState(() {
      _restSecondsRemaining = 0;
      _isRestTimerActive = false;
    });
  }

  void _toggleSetCompleted(String exId, int index) {
    final list = _setsByExercise[exId] ?? [];
    if (index >= list.length) return;

    final current = list[index];
    final newState = !current.isCompleted;

    if (newState) {
      AppHaptics.medium();
      // Start rest timer on set check
      _startRestTimer(90);
    } else {
      AppHaptics.light();
    }

    setState(() {
      list[index] = current.copyWith(isCompleted: newState);
    });
  }

  void _addSet(String exId) {
    AppHaptics.light();
    final list = _setsByExercise[exId] ?? [];
    final ex = _exercises.firstWhere((e) => e.id == exId);
    final nextSetNum = list.length + 1;
    final lastSet = list.isNotEmpty ? list.last : null;

    setState(() {
      list.add(SetLog(
        id: const Uuid().v4(),
        workoutLogId: '',
        exerciseId: ex.id,
        exerciseName: widget.customNames[ex.id] ?? ex.name,
        setNumber: nextSetNum,
        targetReps: lastSet?.completedReps ?? ex.defaultReps,
        targetWeightKg: lastSet?.completedWeightKg ?? ex.defaultWeightKg,
        completedReps: lastSet?.completedReps ?? ex.defaultReps,
        completedWeightKg: lastSet?.completedWeightKg ?? ex.defaultWeightKg,
        isCompleted: false,
      ));
    });
  }

  void _finishWorkout() {
    AppHaptics.medium();
    final allSets = _setsByExercise.values.expand((element) => element).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutFinishScreen(
          session: widget.session,
          sets: allSets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentEx = _exercises[_currentExerciseIndex];
    final sets = _setsByExercise[currentEx.id] ?? [];
    final displayName = widget.customNames[currentEx.id] ?? currentEx.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.title),
        actions: [
          TextButton(
            onPressed: _finishWorkout,
            child: Text(
              'Finish',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Exercise selector pills
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _exercises.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (ctx, index) {
                  final ex = _exercises[index];
                  final isSelected = index == _currentExerciseIndex;
                  final exSets = _setsByExercise[ex.id] ?? [];
                  final isAllDone = exSets.isNotEmpty && exSets.every((s) => s.isCompleted);

                  return ChoiceChip(
                    label: Text(
                      '${index + 1}. ${widget.customNames[ex.id] ?? ex.name}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.lightOnPrimary : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    avatar: isAllDone
                        ? const Icon(PhosphorIconsBold.check, size: 14, color: AppColors.statusDone)
                        : null,
                    onSelected: (val) {
                      if (val) {
                        AppHaptics.selection();
                        setState(() => _currentExerciseIndex = index);
                      }
                    },
                  );
                },
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Current Exercise Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Exercise ${_currentExerciseIndex + 1} of ${_exercises.length}',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(currentEx.pattern, style: theme.textTheme.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayName,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text('Target: ${currentEx.target}', style: theme.textTheme.bodySmall),
                        if (currentEx.cues != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            currentEx.cues!,
                            style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sets Table Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text('SET', style: theme.textTheme.labelSmall),
                        ),
                        Expanded(
                          child: Text('PREV / TARGET', style: theme.textTheme.labelSmall),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text('KG', style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
                        ),
                        SizedBox(
                          width: 70,
                          child: Text('REPS', style: theme.textTheme.labelSmall, textAlign: TextAlign.center),
                        ),
                        const SizedBox(width: 48), // Check button width
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Set Rows
                  ...sets.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final setLog = entry.value;
                    return _buildSetRow(currentEx.id, idx, setLog);
                  }),

                  const SizedBox(height: 12),

                  // Add Set Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: theme.dividerColor, width: 1.5),
                    ),
                    onPressed: () => _addSet(currentEx.id),
                    icon: const Icon(PhosphorIconsBold.plus, size: 18),
                    label: Text(
                      'Add Set',
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Rest Timer Floating Pill
            if (_isRestTimerActive)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.statusDone.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Circular progress ring
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _restTotalSeconds > 0
                                ? _restSecondsRemaining / _restTotalSeconds
                                : 0,
                            strokeWidth: 3.5,
                            backgroundColor: AppColors.statusDone.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.statusDone),
                          ),
                          const Icon(
                            PhosphorIconsFill.timer,
                            color: AppColors.statusDone,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'REST TIMER',
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                              color: AppColors.statusDone,
                            ),
                          ),
                          Text(
                            '${_restSecondsRemaining ~/ 60}:${(_restSecondsRemaining % 60).toString().padLeft(2, '0')}',
                            style: AppTypography.tabular(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quick adjustment pills
                    Wrap(
                      spacing: 6,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(40, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: theme.dividerColor),
                          ),
                          onPressed: () => _addRestTime(-15),
                          child: Text(
                            '-15s',
                            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: const Size(40, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: theme.dividerColor),
                          ),
                          onPressed: () => _addRestTime(30),
                          child: Text(
                            '+30s',
                            style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            minimumSize: const Size(36, 36),
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          ),
                          onPressed: _skipRestTimer,
                          icon: const Icon(PhosphorIconsBold.x, size: 16),
                          tooltip: 'Skip rest',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _adjustWeight(String exId, int index, double delta) {
    AppHaptics.light();
    final list = _setsByExercise[exId];
    if (list == null || index >= list.length) return;
    final current = list[index];
    final newWeight = (current.completedWeightKg + delta).clamp(0.0, 200.0);
    setState(() {
      list[index] = current.copyWith(completedWeightKg: newWeight);
    });
  }

  void _adjustReps(String exId, int index, int delta) {
    AppHaptics.light();
    final list = _setsByExercise[exId];
    if (list == null || index >= list.length) return;
    final current = list[index];
    final newReps = (current.completedReps + delta).clamp(0, 100);
    setState(() {
      list[index] = current.copyWith(completedReps: newReps);
    });
  }

  Widget _buildSetRow(String exId, int index, SetLog setLog) {
    final theme = Theme.of(context);
    final isDone = setLog.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDone ? AppColors.statusDone.withOpacity(0.08) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppColors.statusDone.withOpacity(0.5) : theme.dividerColor,
          width: isDone ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Set Number Capsule
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.statusDone.withOpacity(0.18)
                  : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${setLog.setNumber}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDone ? AppColors.statusDone : theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Target
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${setLog.targetReps} reps',
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  setLog.targetWeightKg > 0 ? '${setLog.targetWeightKg} kg' : 'Bodyweight',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),

          // KG Stepper Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _adjustWeight(exId, index, -2.5),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(PhosphorIconsBold.minus, size: 14),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${setLog.completedWeightKg.toStringAsFixed(setLog.completedWeightKg % 1 == 0 ? 0 : 1)}k',
                    textAlign: TextAlign.center,
                    style: AppTypography.tabular(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _adjustWeight(exId, index, 2.5),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(PhosphorIconsBold.plus, size: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Reps Stepper Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _adjustReps(exId, index, -1),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(PhosphorIconsBold.minus, size: 14),
                  ),
                ),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${setLog.completedReps}',
                    textAlign: TextAlign.center,
                    style: AppTypography.tabular(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _adjustReps(exId, index, 1),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(PhosphorIconsBold.plus, size: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // High-End Tactile Check Button (46x46px)
          InkWell(
            onTap: () => _toggleSetCompleted(exId, index),
            borderRadius: BorderRadius.circular(23),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDone ? AppColors.statusDone : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? AppColors.statusDone : theme.dividerColor,
                  width: 2,
                ),
                boxShadow: isDone
                    ? [
                        BoxShadow(
                          color: AppColors.statusDone.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                PhosphorIconsBold.check,
                color: isDone ? Colors.white : theme.dividerColor.withOpacity(0.5),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

