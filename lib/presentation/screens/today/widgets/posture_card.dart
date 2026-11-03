import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../data/datasources/plan_repository.dart';
import '../../../../data/models/posture_log.dart';

class PostureCard extends StatelessWidget {
  final PostureLog? postureLog;
  final Function(bool) onToggle;

  const PostureCard({
    super.key,
    required this.postureLog,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = postureLog?.routineDone == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDone
            ? (theme.brightness == Brightness.dark
                ? AppColors.darkSurfaceAlt
                : AppColors.lightSurfaceAlt)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? AppColors.statusDone : theme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              AppHaptics.medium();
              onToggle(!isDone);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
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
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              onTap: () => _showPostureRoutineModal(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Daily Posture Routine (8-10 min)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(PhosphorIconsRegular.info, size: 16, color: theme.colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Fix hunched posture, chin tucks, wall slides & pec stretch',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostureRoutineModal(BuildContext context) {
    final theme = Theme.of(context);
    final postureTemplate = PlanRepository.instance.getWorkoutTemplate('POSTURE');
    final steps = (postureTemplate?['steps'] as List<dynamic>?) ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: controller,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Posture Routine (8-10 min)',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(PhosphorIconsRegular.x),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Do daily. Fixes forward head posture and hunched back. Check weekly side-view photo reminder.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  ...steps.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final step = entry.value as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                            child: Text(
                              '$idx',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['name'] as String,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  step['detail'] as String,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Habits', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          '• Stand and reset every 30-45 minutes\n• Raise laptop/phone toward eye level\n• Take a weekly side-view photo to track alignment',
                          style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      onToggle(true);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Mark Routine Completed'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

