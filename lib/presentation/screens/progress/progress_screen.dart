import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/logs_provider.dart';
import 'body_tracker_screen.dart';
import 'fuel_guide_screen.dart';
import 'widgets/pacing_predictor_card.dart';
import 'widgets/strength_trend_card.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logsState = ref.watch(logsProvider);

    // Calculate totals
    double totalKmRun = 0.0;
    int totalWorkouts = logsState.logsByDate.length;
    double longestRunKm = 0.0;

    for (final log in logsState.logsByDate.values) {
      if (log.runDistanceKm != null && log.runDistanceKm! > 0) {
        totalKmRun += log.runDistanceKm!;
        if (log.runDistanceKm! > longestRunKm) {
          longestRunKm = log.runDistanceKm!;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress & Metrics'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Top Stat Tiles
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: 'Total Distance',
                    value: '${totalKmRun.toStringAsFixed(1)} km',
                    icon: PhosphorIconsRegular.personSimpleRun,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: 'Sessions Logged',
                    value: '$totalWorkouts',
                    icon: PhosphorIconsRegular.barbell,
                    color: AppColors.statusDone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: 'Longest Run',
                    value: '${longestRunKm.toStringAsFixed(1)} km',
                    icon: PhosphorIconsRegular.chartLineUp,
                    color: AppColors.statusInfo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    context,
                    title: '5K Test Goal',
                    value: '20:00 Target',
                    icon: PhosphorIconsRegular.trophy,
                    color: AppColors.statusWarning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Quick Links to Body Tracker & Fuel Guide
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BodyTrackerScreen()),
                      );
                    },
                    icon: const Icon(PhosphorIconsRegular.scales, size: 18),
                    label: const Text('Body Tracker'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FuelGuideScreen()),
                      );
                    },
                    icon: const Icon(PhosphorIconsRegular.forkKnife, size: 18),
                    label: const Text('Fuel Guide'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Weekly Distance Progression Chart
            Text('Planned Long-Run Build (km)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: SizedBox(
                height: 180,
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
                          reservedSize: 32,
                          getTitlesWidget: (val, meta) => Text(
                            '${val.toInt()}k',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            final w = val.toInt();
                            if (w % 2 == 1 && w <= 9) {
                              return Text('W$w', style: theme.textTheme.labelSmall);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(1, 4.0),
                          FlSpot(2, 5.0),
                          FlSpot(3, 6.0),
                          FlSpot(4, 7.0),
                          FlSpot(5, 8.0),
                          FlSpot(6, 9.0),
                          FlSpot(7, 10.5),
                          FlSpot(8, 12.0),
                          FlSpot(9, 21.1),
                        ],
                        isCurved: true,
                        color: theme.colorScheme.primary,
                        barWidth: 3.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.surface,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.35),
                              theme.colorScheme.primary.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pacing & Half Marathon Predictor
            const PacingPredictorCard(),

            const SizedBox(height: 24),

            // Strength Progression Chart
            StrengthTrendCard(logs: logsState.logsByDate.values.toList()),

            const SizedBox(height: 24),

            // 5K Test Benchmark Card
            Text('5K Test Target & 20:00 Goal Line', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Dec 17 Target', style: theme.textTheme.bodyMedium),
                      Text(
                        'Sub-30:00 (Controlled)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.statusDone,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Long-term Goal Line', style: theme.textTheme.bodyMedium),
                      Text(
                        '20:00 (4:00/km)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Paces and half-marathon finishing estimate update dynamically above based on your time.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.bodySmall),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.tabular(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
