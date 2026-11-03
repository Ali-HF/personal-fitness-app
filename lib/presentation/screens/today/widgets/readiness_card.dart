import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/readiness_checkin.dart';

class ReadinessCard extends StatelessWidget {
  final ReadinessCheckIn? checkIn;
  final VoidCallback onTap;

  const ReadinessCard({
    super.key,
    required this.checkIn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (checkIn == null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.primary, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsRegular.heartbeat,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Readiness Check-in',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '30 sec to check sleep, soreness & injury flags',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(PhosphorIconsRegular.caretRight, size: 20),
            ],
          ),
        ),
      );
    }

    final isSevere = checkIn!.pain == 'sharp' || checkIn!.legSoreness >= 7;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSevere ? AppColors.statusHard : theme.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isSevere ? PhosphorIconsFill.warning : PhosphorIconsFill.checkCircle,
                      size: 20,
                      color: isSevere ? AppColors.statusHard : AppColors.statusDone,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Readiness: ${checkIn!.sleepHours}h sleep • Soreness ${checkIn!.legSoreness}/10',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Text('Edit', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
              ],
            ),
            if (checkIn!.suggestion != null) ...[
              const SizedBox(height: 8),
              Text(
                checkIn!.suggestion!,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

