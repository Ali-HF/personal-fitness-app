import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class WeekSummaryRow extends StatelessWidget {
  final int completedSessions;
  final int plannedSessions;
  final double totalKm;

  const WeekSummaryRow({
    super.key,
    required this.completedSessions,
    required this.plannedSessions,
    required this.totalKm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildTile(
            context,
            title: 'Sessions Done',
            value: '$completedSessions / $plannedSessions',
            icon: PhosphorIconsRegular.barbell,
            color: AppColors.statusDone,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTile(
            context,
            title: 'Distance Run',
            value: '${totalKm.toStringAsFixed(1)} km',
            icon: PhosphorIconsRegular.personSimpleRun,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

