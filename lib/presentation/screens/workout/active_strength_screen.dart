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
      _restSecondsRemaining += seconds;
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
                    onPressed: () => _addSet(currentEx.id),
                    icon: const Icon(PhosphorIconsRegular.plus, size: 18),
                    label: const Text('Add Set'),
                  ),
                ],
              ),
            ),

            // Bottom Rest Timer Bar
            if (_isRestTimerActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(top: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(PhosphorIconsRegular.timer, color: AppColors.statusDone, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Rest Timer: ${_restSecondsRemaining ~/ 60}:${(_restSecondsRemaining % 60).toString().padLeft(2, '0')}',
                          style: AppTypography.tabular(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _addRestTime(30),
                          child: const Text('+30s'),
                        ),
                        TextButton(
                          onPressed: _skipRestTimer,
                          child: const Text('Skip'),
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

  Widget _buildSetRow(String exId, int index, SetLog setLog) {
    final theme = Theme.of(context);
    final isDone = setLog.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDone ? AppColors.statusDone.withOpacity(0.08) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone ? AppColors.statusDone.withOpacity(0.4) : theme.dividerColor,
        ),
      ),
      child: Row(
        children: [
          // Set #
          SizedBox(
            width: 44,
            child: Text(
              '${setLog.setNumber}',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),

          // Target
          Expanded(
            child: Text(
              '${setLog.targetReps} reps',
              style: theme.textTheme.bodySmall,
            ),
          ),

          // Kg Input
          SizedBox(
            width: 70,
            child: TextFormField(
              initialValue: setLog.completedWeightKg.toStringAsFixed(0),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              style: AppTypography.tabular(fontSize: 16, color: theme.colorScheme.onSurface),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                isDense: true,
              ),
              onChanged: (val) {
                final weight = double.tryParse(val) ?? setLog.completedWeightKg;
                setLog = setLog.copyWith(completedWeightKg: weight);
                _setsByExercise[exId]![index] = setLog;
              },
            ),
          ),

          const SizedBox(width: 8),

          // Reps Input
          SizedBox(
            width: 70,
            child: TextFormField(
              initialValue: '${setLog.completedReps}',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTypography.tabular(fontSize: 16, color: theme.colorScheme.onSurface),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                isDense: true,
              ),
              onChanged: (val) {
                final reps = int.tryParse(val) ?? setLog.completedReps;
                setLog = setLog.copyWith(completedReps: reps);
                _setsByExercise[exId]![index] = setLog;
              },
            ),
          ),

          const SizedBox(width: 12),

          // Check Button
          InkWell(
            onTap: () => _toggleSetCompleted(exId, index),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isDone ? AppColors.statusDone : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDone ? AppColors.statusDone : theme.dividerColor,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(PhosphorIconsBold.check, color: Colors.white, size: 20)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

