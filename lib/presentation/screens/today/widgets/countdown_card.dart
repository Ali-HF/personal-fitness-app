import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';

class CountdownCard extends StatelessWidget {
  final String raceDateStr; // YYYY-MM-DD
  final String test5kDateStr; // YYYY-MM-DD

  const CountdownCard({
    super.key,
    required this.raceDateStr,
    this.test5kDateStr = '2026-12-17',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    int daysToRace = 0;
    try {
      final raceDate = DateTime.parse(raceDateStr);
      daysToRace = raceDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    } catch (_) {
      daysToRace = 0;
    }

    int daysTo5k = 0;
    try {
      final testDate = DateTime.parse(test5kDateStr);
      daysTo5k = testDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    } catch (_) {
      daysTo5k = 0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem(
            context,
            count: daysToRace > 0 ? '$daysToRace' : '0',
            label: 'days to Half Marathon',
            target: raceDateStr,
          ),
          Container(width: 1, height: 40, color: theme.dividerColor),
          _buildItem(
            context,
            count: daysTo5k > 0 ? '$daysTo5k' : 'Done',
            label: 'days to 5K Test',
            target: test5kDateStr,
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, {required String count, required String label, required String target}) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          count,
          style: AppTypography.tabular(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
