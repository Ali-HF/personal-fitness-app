import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatters.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

          // Status indicator color
          Color dotColor;
          if (hasLog) {
            dotColor = AppColors.statusDone; // Green
          } else if (isSkipped) {
            dotColor = AppColors.statusHard; // Orange/red
          } else if (isRest) {
            dotColor = isDark ? AppColors.darkTextSecondary.withOpacity(0.4) : AppColors.lightDivider;
          } else if (session != null) {
            dotColor = theme.colorScheme.primary; // Yellow
          } else {
            dotColor = Colors.transparent;
          }

          return InkWell(
            onTap: () => onSelectDate(day),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 42,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isToday
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayLabels[index],
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? theme.colorScheme.onSurface : theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
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

