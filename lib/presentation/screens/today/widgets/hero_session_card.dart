import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../data/datasources/plan_repository.dart';
import '../../../../data/models/session.dart';
import '../../../../data/models/workout_log.dart';
import '../../../../data/models/session_change.dart';

class HeroSessionCard extends StatelessWidget {
  final PlannedSession? session;
  final WorkoutLog? log;
  final SessionChange? change;
  final VoidCallback onStart;
  final VoidCallback onSwap;
  final VoidCallback onSkip;
  final VoidCallback onViewDetails;

  const HeroSessionCard({
    super.key,
    required this.session,
    this.log,
    this.change,
    required this.onStart,
    required this.onSwap,
    required this.onSkip,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (session == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Center(
          child: Text('No planned session for this date.', style: theme.textTheme.bodyMedium),
        ),
      );
    }

    final isDone = log != null;
    final isSkipped = change?.isSkipped == true;
    final isRest = session!.type == 'REST';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone
              ? AppColors.statusDone
              : session!.isHard
                  ? AppColors.statusHard
                  : theme.dividerColor,
          width: isDone || session!.isHard ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header & Chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: session!.isHard
                            ? AppColors.statusHard.withOpacity(0.15)
                            : isDone
                                ? AppColors.statusDone.withOpacity(0.15)
                                : theme.colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        session!.type,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: session!.isHard
                              ? AppColors.statusHard
                              : isDone
                                  ? AppColors.statusDone
                                  : (isDark ? AppColors.darkPrimary : AppColors.lightOnPrimary),
                        ),
                      ),
                    ),
                    // Distance or Duration badge
                    if (session!.distanceKm != null || session!.durationMinutes != null || session!.estimatedMinutes != null)
                      Row(
                        children: [
                          Icon(
                            session!.category == 'run'
                                ? PhosphorIconsRegular.personSimpleRun
                                : PhosphorIconsRegular.clock,
                            size: 16,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session!.distanceKm != null
                                ? '${session!.distanceKm} km'
                                : '${session!.durationMinutes ?? session!.estimatedMinutes} min',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  session!.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: isSkipped ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (change?.reason != null && !isSkipped) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Swap note: ${change!.reason}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Exercise / Detail Previews
          if (session!.details.isNotEmpty || session!.exerciseIds.isNotEmpty) ...[
            const Divider(height: 1),
            InkWell(
              onTap: onViewDetails,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._buildPreviewLines(theme),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'View full session details & regressions',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(PhosphorIconsRegular.arrowRight, size: 12, color: theme.colorScheme.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const Divider(height: 1),

          // Bottom Action Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: isDone
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.statusDone.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(PhosphorIconsFill.checkCircle, color: AppColors.statusDone, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Completed! (Logged)',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: AppColors.statusDone,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : isSkipped
                    ? Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onSwap,
                              child: const Text('Un-skip / Swap'),
                            ),
                          ),
                        ],
                      )
                    : isRest
                        ? Center(
                            child: Text(
                              'Rest and recovery day. Walk or stretch lightly.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          )
                        : Row(
                            children: [
                              // Secondary Swap button
                              Expanded(
                                flex: 2,
                                child: OutlinedButton(
                                  onPressed: () {
                                    AppHaptics.light();
                                    onSwap();
                                  },
                                  child: const Text('Swap'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Big Yellow Start Button (56px high)
                              Expanded(
                                flex: 3,
                                child: ElevatedButton(
                                  onPressed: () {
                                    AppHaptics.medium();
                                    onStart();
                                  },
                                  child: Text(session!.category == 'run' ? 'Log Run' : 'Start Workout'),
                                ),
                              ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPreviewLines(ThemeData theme) {
    if (session!.exerciseIds.isNotEmpty) {
      final repo = PlanRepository.instance;
      final previewNames = session!.exerciseIds
          .take(3)
          .map((id) => repo.getExercise(id)?.name ?? id)
          .toList();
      return previewNames.map((name) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        );
      }).toList();
    } else {
      return session!.details.take(3).map((detail) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(detail, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        );
      }).toList();
    }
  }
}

