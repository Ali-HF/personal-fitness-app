import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/body_log.dart';
import '../../../domain/rules/finals_mode_rule.dart';
import '../../providers/logs_provider.dart';
import '../../providers/settings_provider.dart';

class BodyTrackerScreen extends ConsumerStatefulWidget {
  const BodyTrackerScreen({super.key});

  @override
  ConsumerState<BodyTrackerScreen> createState() => _BodyTrackerScreenState();
}

class _BodyTrackerScreenState extends ConsumerState<BodyTrackerScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final DateTime _entryDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    AppHaptics.medium();
    final weight = double.tryParse(_weightController.text.trim());
    final waist = double.tryParse(_waistController.text.trim());
    final note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    if (weight == null && waist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least weight or waist measurement.')),
      );
      return;
    }

    final dateStr = AppDateFormatters.toIso(_entryDate);
    final log = BodyLog(
      date: dateStr,
      weightKg: weight,
      waistCm: waist,
      note: note,
    );

    ref.read(logsProvider.notifier).saveBodyLog(log);

    _weightController.clear();
    _waistController.clear();
    _noteController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Body measurement saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logsState = ref.watch(logsProvider);
    final settings = ref.watch(settingsProvider);

    final sortedLogs = logsState.bodyLogsByDate.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Calculate 7-day average of recent weights
    final recentWeights = sortedLogs
        .where((l) => l.weightKg != null)
        .take(7)
        .map((l) => l.weightKg!)
        .toList();

    final double? sevenDayAvg = recentWeights.isNotEmpty
        ? (recentWeights.reduce((a, b) => a + b) / recentWeights.length)
        : null;

    // Rate of change calculation
    double? weeklyRateOfChange;
    if (recentWeights.length >= 2) {
      weeklyRateOfChange = recentWeights.first - recentWeights.last;
    }

    final isFinals = FinalsModeRule.isInFinalsMode(
      currentDate: AppDateFormatters.toIso(DateTime.now()),
      finalsStart: settings.finalsStart,
      finalsEnd: settings.finalsEnd,
    );

    // Flags evaluation
    String? flagMessage;
    Color flagColor = AppColors.statusDone;

    if (isFinals) {
      flagMessage = 'Finals period active: eat at maintenance. Do not push a calorie deficit during exams.';
      flagColor = AppColors.statusWarning;
    } else if (weeklyRateOfChange != null && weeklyRateOfChange < -0.75) {
      flagMessage =
          'Weight dropping faster than 0.75 kg/week (${weeklyRateOfChange.abs().toStringAsFixed(2)} kg). Increase daily calories by 150-200 kcal to protect muscle.';
      flagColor = AppColors.statusHard;
    } else if (weeklyRateOfChange != null && weeklyRateOfChange.abs() < 0.1 && recentWeights.length >= 7) {
      flagMessage = 'Weight average has been flat. If fat loss is stalled, trim 100-150 kcal or add 2,000 steps/day.';
      flagColor = AppColors.statusWarning;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Tracker & Weight Trend'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 7-day Average Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Text('7-Day Average Weight', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 6),
                  Text(
                    sevenDayAvg != null ? '${sevenDayAvg.toStringAsFixed(1)} kg' : '--.- kg',
                    style: AppTypography.tabular(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Target: ~65 kg (currently aiming for 0.4-0.6 kg/wk)',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (weeklyRateOfChange != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Recent change: ${weeklyRateOfChange > 0 ? "+" : ""}${weeklyRateOfChange.toStringAsFixed(2)} kg',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: weeklyRateOfChange < 0 ? AppColors.statusDone : theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Guidance Flag Banner
            if (flagMessage != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: flagColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: flagColor),
                ),
                child: Row(
                  children: [
                    Icon(PhosphorIconsFill.info, color: flagColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        flagMessage,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.35, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Log New Measurement Form
            Text('Log Measurement', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            hintText: 'e.g. 75.8',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _waistController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Waist (cm)',
                            hintText: 'e.g. 84.0',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Notes / Context',
                      hintText: 'e.g. Morning fasted, post creatine',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveEntry,
                    child: const Text('Save Entry'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // History Log List
            Text('Logged Entries', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            if (sortedLogs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('No measurements logged yet.', style: theme.textTheme.bodyMedium),
                ),
              )
            else
              ...sortedLogs.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.date, style: theme.textTheme.labelMedium),
                          if (entry.note != null) ...[
                            const SizedBox(height: 2),
                            Text(entry.note!, style: theme.textTheme.bodySmall),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          if (entry.weightKg != null)
                            Text(
                              '${entry.weightKg!.toStringAsFixed(1)} kg',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          if (entry.weightKg != null && entry.waistCm != null)
                            const Text(' • '),
                          if (entry.waistCm != null)
                            Text(
                              '${entry.waistCm!.toStringAsFixed(1)} cm waist',
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
