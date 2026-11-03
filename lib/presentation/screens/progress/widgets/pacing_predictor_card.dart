import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/rules/pacing_rules.dart';

class PacingPredictorCard extends StatefulWidget {
  final int? initialFiveKSeconds;

  const PacingPredictorCard({super.key, this.initialFiveKSeconds});

  @override
  State<PacingPredictorCard> createState() => _PacingPredictorCardState();
}

class _PacingPredictorCardState extends State<PacingPredictorCard> {
  late int _fiveKSeconds;

  @override
  void initState() {
    super.initState();
    // Default to 30:00 (1800s) if no 5K logged yet
    _fiveKSeconds = widget.initialFiveKSeconds ?? 1800;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pacing = PacingCalculator.calculateFrom5kTime(_fiveKSeconds);

    final mins = _fiveKSeconds ~/ 60;
    final secs = _fiveKSeconds % 60;
    final timeStr = '$mins:${secs.toString().padLeft(2, '0')}';

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Training Paces & HM Predictor',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Based on 5K Test (Pete Riegel + walk factor)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  timeStr,
                  style: AppTypography.tabular(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimary : const Color(0xFF8B6800),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 5K Time Slider (20:00 to 35:00)
          Slider(
            value: _fiveKSeconds.toDouble(),
            min: 20 * 60, // 20:00
            max: 35 * 60, // 35:00
            divisions: 30, // 30s increments
            activeColor: theme.colorScheme.primary,
            onChanged: (val) {
              setState(() {
                _fiveKSeconds = val.round();
              });
            },
          ),

          const Divider(height: 16),

          // Target Paces Grid
          Row(
            children: [
              Expanded(
                child: _paceTile(
                  context,
                  title: 'Easy / Long Run',
                  value: pacing.easyPaceRangeFormatted,
                  caption: '+60s to +90s conversational',
                  color: AppColors.statusDone,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _paceTile(
                  context,
                  title: 'Tempo Pace',
                  value: pacing.tempoPaceRangeFormatted,
                  caption: 'Controlled hard (few words)',
                  color: AppColors.statusHard,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Half Marathon Estimated Finish Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sports_score_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Half Marathon Finish Estimate',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Range: ${pacing.halfMarathonRangeFormatted}',
                        style: AppTypography.tabular(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paceTile(
    BuildContext context, {
    required String title,
    required String value,
    required String caption,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.tabular(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

