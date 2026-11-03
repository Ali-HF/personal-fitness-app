import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/plan_repository.dart';
import '../../../data/models/session.dart';
import '../../../data/models/exercise.dart';
import 'exercise_swap_modal.dart';
import 'active_strength_screen.dart';
import 'log_run_screen.dart';
import 'live_run_screen.dart';

class SessionDetailScreen extends StatefulWidget {
  final PlannedSession session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late List<String> _exerciseIds;
  final Map<String, String> _customExerciseNames = {};

  @override
  void initState() {
    super.initState();
    _exerciseIds = List.from(widget.session.exerciseIds);
  }

  void _openSwapModal(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExerciseSwapModal(
        exercise: exercise,
        onSelectAlternative: (altName) {
          setState(() {
            _customExerciseNames[exercise.id] = altName;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = PlanRepository.instance;
    final isRun = widget.session.category == 'run';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.title),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.session.isHard
                  ? AppColors.statusHard.withOpacity(0.15)
                  : theme.colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.session.type,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: widget.session.isHard ? AppColors.statusHard : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Session Overview Card
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
                        Text(
                          'Date: ${widget.session.date} • Week ${widget.session.weekNumber}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.session.title,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (widget.session.distanceKm != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(PhosphorIconsRegular.personSimpleRun, size: 16),
                              const SizedBox(width: 6),
                              Text('Target: ${widget.session.distanceKm} km', style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Run steps or exercises list
                  if (isRun) ...[
                    Text('Structured Steps', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 10),
                    ...widget.session.details.map((detail) => _buildRunStepTile(detail)),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Exercises & Targets', style: theme.textTheme.titleSmall),
                        Text(
                          'Tap exercise to regress/progress',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_exerciseIds.isEmpty)
                      ...widget.session.details.map((detail) => _buildRunStepTile(detail))
                    else
                      ..._exerciseIds.map((exId) {
                        final ex = repo.getExercise(exId);
                        if (ex == null) return const SizedBox.shrink();
                        final displayName = _customExerciseNames[exId] ?? ex.name;
                        return _buildExerciseCard(ex, displayName);
                      }),
                  ],
                ],
              ),
            ),

            // Bottom Start / Log Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: isRun
                  ? Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LogRunScreen(session: widget.session),
                                ),
                              );
                            },
                            child: const Text('Manual Log'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(PhosphorIconsBold.personSimpleRun),
                            label: const Text('Live GPS Run'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LiveRunScreen(session: widget.session),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActiveStrengthScreen(
                              session: widget.session,
                              customNames: _customExerciseNames,
                            ),
                          ),
                        );
                      },
                      child: const Text('Start Strength Workout'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunStepTile(String step) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(step, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise ex, String displayName) {
    final theme = Theme.of(context);
    final isCustomized = displayName != ex.name;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _openSwapModal(ex),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCustomized ? theme.colorScheme.primary : theme.dividerColor,
              width: isCustomized ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (isCustomized) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Swapped',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Target: ${ex.target}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(PhosphorIconsRegular.caretRight, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

