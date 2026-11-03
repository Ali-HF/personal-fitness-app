import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/pace_calculator.dart';
import '../../../data/models/session.dart';
import '../../../data/models/workout_log.dart';
import '../../providers/logs_provider.dart';

class WorkoutFinishScreen extends ConsumerStatefulWidget {
  final PlannedSession session;
  final List<SetLog> sets;
  final double? runDistanceKm;
  final int? runDurationSeconds;
  final int? avgPaceSeconds;

  const WorkoutFinishScreen({
    super.key,
    required this.session,
    this.sets = const [],
    this.runDistanceKm,
    this.runDurationSeconds,
    this.avgPaceSeconds,
  });

  @override
  ConsumerState<WorkoutFinishScreen> createState() => _WorkoutFinishScreenState();
}

class _WorkoutFinishScreenState extends ConsumerState<WorkoutFinishScreen> {
  int _rpe = 7; // 1-10 slider
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    setState(() => _isSaving = true);
    AppHaptics.heavy();

    final workoutLogId = const Uuid().v4();
    final updatedSets = widget.sets
        .map((s) => s.copyWith(workoutLogId: workoutLogId))
        .toList();

    final log = WorkoutLog(
      id: workoutLogId,
      date: widget.session.date,
      sessionId: widget.session.id,
      sessionType: widget.session.type,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      rpe: _rpe,
      runDistanceKm: widget.runDistanceKm,
      runDurationSeconds: widget.runDurationSeconds,
      avgPaceSeconds: widget.avgPaceSeconds,
      sets: updatedSets,
    );

    await ref.read(logsProvider.notifier).saveWorkoutLog(log);

    if (mounted) {
      // Pop back to main scaffold
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRun = widget.runDistanceKm != null && widget.runDistanceKm! > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Hero Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.statusDone, width: 1.5),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0x1F4C9A5B),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppColors.statusDone, size: 36),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Session Completed!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.statusDone,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.session.title, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),

                    if (isRun) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem(
                            theme,
                            '${widget.runDistanceKm!.toStringAsFixed(2)} km',
                            'Distance',
                          ),
                          _statItem(
                            theme,
                            PaceCalculator.formatDuration(widget.runDurationSeconds ?? 0),
                            'Time',
                          ),
                          _statItem(
                            theme,
                            PaceCalculator.formatPace(widget.runDistanceKm!, widget.runDurationSeconds ?? 0),
                            'Pace',
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statItem(theme, '${widget.sets.length}', 'Sets Logged'),
                          _statItem(
                            theme,
                            '${widget.sets.where((s) => s.isCompleted).length}',
                            'Completed',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // RPE 1-10 Slider
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
                        Text('Effort (RPE 1-10)', style: theme.textTheme.titleSmall),
                        Text(
                          '$_rpe / 10 • ${_getRpeLabel(_rpe)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _rpe.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: theme.colorScheme.primary,
                      onChanged: (val) {
                        setState(() => _rpe = val.round());
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Notes field
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Session Notes',
                  hintText: 'e.g. Felt strong on pull-ups, left calf tight on mile 3',
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _isSaving ? null : _saveWorkout,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save & Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(ThemeData theme, String val, String label) {
    return Column(
      children: [
        Text(val, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }

  String _getRpeLabel(int rpe) {
    switch (rpe) {
      case 1:
      case 2:
        return 'Very Easy';
      case 3:
      case 4:
        return 'Easy';
      case 5:
      case 6:
        return 'Moderate';
      case 7:
        return 'Comfortably Hard';
      case 8:
        return 'Hard';
      case 9:
        return 'Very Hard';
      case 10:
        return 'Maximum Effort';
      default:
        return '';
    }
  }
}

