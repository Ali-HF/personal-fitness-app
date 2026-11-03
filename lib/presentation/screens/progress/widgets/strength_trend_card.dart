import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/workout_log.dart';

class StrengthTrendCard extends StatelessWidget {
  final List<WorkoutLog> logs;

  const StrengthTrendCard({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Extract best completed reps for pull_ups and push_ups
    final List<FlSpot> pullUpSpots = [];
    final List<FlSpot> pushUpSpots = [];

    // Sort logs chronologically
    final sortedLogs = List<WorkoutLog>.from(logs)
      ..sort((a, b) => a.date.compareTo(b.date));

    int index = 1;
    for (final log in sortedLogs) {
      int maxPullUps = 0;
      int maxPushUps = 0;

      for (final s in log.sets) {
        final exId = s.exerciseId.toLowerCase();
        final name = s.exerciseName.toLowerCase();

        if (exId.contains('pull') || name.contains('pull-up') || name.contains('chin')) {
          if (s.completedReps > maxPullUps) maxPullUps = s.completedReps;
        }
        if (exId.contains('push') || name.contains('push-up')) {
          if (s.completedReps > maxPushUps) maxPushUps = s.completedReps;
        }
      }

      if (maxPullUps > 0) {
        pullUpSpots.add(FlSpot(index.toDouble(), maxPullUps.toDouble()));
      }
      if (maxPushUps > 0) {
        pushUpSpots.add(FlSpot(index.toDouble(), maxPushUps.toDouble()));
      }
      if (maxPullUps > 0 || maxPushUps > 0) {
        index++;
      }
    }

    // Default baseline if no logs yet
    if (pullUpSpots.isEmpty) {
      pullUpSpots.addAll([const FlSpot(1, 4), const FlSpot(2, 5), const FlSpot(3, 6)]);
    }
    if (pushUpSpots.isEmpty) {
      pushUpSpots.addAll([const FlSpot(1, 12), const FlSpot(2, 14), const FlSpot(3, 16)]);
    }

    return Container(
      padding: const EdgeInsets.all(18),
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
                'Strength Maxes (Reps / Set)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _legendDot(theme.colorScheme.primary, 'Pull-ups'),
                  const SizedBox(width: 10),
                  _legendDot(AppColors.statusDone, 'Push-ups'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: theme.dividerColor,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) => Text(
                        '${val.toInt()}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) => Text(
                        'S${val.toInt()}',
                        style: theme.textTheme.labelSmall,
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: pullUpSpots,
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                  LineChartBarData(
                    spots: pushUpSpots,
                    isCurved: true,
                    color: AppColors.statusDone,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

