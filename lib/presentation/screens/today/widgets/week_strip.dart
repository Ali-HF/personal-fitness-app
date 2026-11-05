import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../data/models/session.dart';
import '../../../../data/models/workout_log.dart';
import '../../../../data/models/session_change.dart';

class WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onSelectDate;
  final Map<String, PlannedSession> plannedSessions;
  final Map<String, WorkoutLog> workoutLogs;
  final Map<String, SessionChange> sessionChanges;

  const WeekStrip({
    super.key,
    required this.selectedDate,
    required this.onSelectDate,
    required this.plannedSessions,
    required this.workoutLogs,
    required this.sessionChanges,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine current Monday of the week
    final now = DateTime.now();
    final monday = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final day = weekDays[index];
          final dateStr = AppDateFormatters.toIso(day);
          final isSelected = AppDateFormatters.isSameDay(day, selectedDate);
          final isToday = AppDateFormatters.isSameDay(day, now);

          final hasLog = workoutLogs.containsKey(dateStr);
          final change = sessionChanges[dateStr];
          final session = plannedSessions[dateStr];
          final isSkipped = change?.isSkipped == true;
          final isRest = session?.type == 'REST';

          // Status indicator widget
          Widget statusIndicator;
          if (hasLog) {
            statusIndicator = Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.statusDone,
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsBold.check, size: 10, color: Colors.white),
            );
          } else if (isSkipped) {
            statusIndicator = Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppColors.statusHard,
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsBold.x, size: 10, color: Colors.white),
            );
          } else if (isRest) {
            statusIndicator = Icon(
              PhosphorIconsRegular.moon,
              size: 13,
              color: isDark ? AppColors.darkTextSecondary.withOpacity(0.5) : AppColors.lightDivider,
            );
          } else if (session != null) {
            statusIndicator = Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          } else {
            statusIndicator = const SizedBox(width: 16, height: 16);
          }

          return InkWell(
            onTap: () {
              AppHaptics.selection();
              onSelectDate(day);
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isToday
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : isSelected
                        ? Border.all(color: theme.dividerColor, width: 1)
                        : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayLabels[index],
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 16,
                    child: Center(child: statusIndicator),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

