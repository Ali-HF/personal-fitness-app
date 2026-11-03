import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/pace_calculator.dart';
import '../../../data/models/session.dart';
import '../../../domain/rules/long_run_cap_rule.dart';
import '../../providers/logs_provider.dart';
import 'workout_finish_screen.dart';

class LogRunScreen extends ConsumerStatefulWidget {
  final PlannedSession session;

  const LogRunScreen({super.key, required this.session});

  @override
  ConsumerState<LogRunScreen> createState() => _LogRunScreenState();
}

class _LogRunScreenState extends ConsumerState<LogRunScreen> {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  double _distanceKm = 0.0;
  int _durationSeconds = 0;
  LongRunCapResult? _capResult;

  @override
  void initState() {
    super.initState();
    if (widget.session.distanceKm != null) {
      _distanceKm = widget.session.distanceKm!;
      _distanceController.text = _distanceKm.toStringAsFixed(1);
    }
    if (widget.session.durationMinutes != null) {
      _minutesController.text = '${widget.session.durationMinutes}';
      _durationSeconds = widget.session.durationMinutes! * 60;
    } else {
      _minutesController.text = '30';
      _durationSeconds = 30 * 60;
    }
    _secondsController.text = '00';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLongRunCap();
    });
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _onValuesChanged() {
    final dist = double.tryParse(_distanceController.text.trim()) ?? 0.0;
    final mins = int.tryParse(_minutesController.text.trim()) ?? 0;
    final secs = int.tryParse(_secondsController.text.trim()) ?? 0;

    setState(() {
      _distanceKm = dist;
      _durationSeconds = (mins * 60) + secs;
    });

    _checkLongRunCap();
  }

  void _checkLongRunCap() {
    final logsNotifier = ref.read(logsProvider.notifier);
    final pastRuns = logsNotifier.getPast30DaysRunLogs(DateTime.now());

    final res = LongRunCapRule.evaluate(
      proposedDistanceKm: _distanceKm,
      runLogsLast30Days: pastRuns,
    );

    setState(() {
      _capResult = res;
    });
  }

  void _continueToFinish() {
    AppHaptics.medium();
    final avgPace = PaceCalculator.paceSeconds(_distanceKm, _durationSeconds);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutFinishScreen(
          session: widget.session,
          runDistanceKm: _distanceKm,
          runDurationSeconds: _durationSeconds,
          avgPaceSeconds: avgPace,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final paceString = PaceCalculator.formatPace(_distanceKm, _durationSeconds);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Target Info
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
                    Text('Target Plan', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      widget.session.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    ...widget.session.details.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('• $d', style: theme.textTheme.bodySmall),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Large Numeric Inputs
              Text('Distance (km)', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor, width: 1.5),
                ),
                child: TextField(
                  controller: _distanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTypography.tabular(fontSize: 32, color: theme.colorScheme.onSurface),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    suffixText: 'km',
                    suffixStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onChanged: (_) => _onValuesChanged(),
                ),
              ),

              const SizedBox(height: 20),

              Text('Duration (Time)', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor, width: 1.5),
                      ),
                      child: TextField(
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.tabular(fontSize: 32, color: theme.colorScheme.onSurface),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: 'min',
                          suffixStyle: TextStyle(fontSize: 16),
                        ),
                        onChanged: (_) => _onValuesChanged(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor, width: 1.5),
                      ),
                      child: TextField(
                        controller: _secondsController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.tabular(fontSize: 32, color: theme.colorScheme.onSurface),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          suffixText: 'sec',
                          suffixStyle: TextStyle(fontSize: 16),
                        ),
                        onChanged: (_) => _onValuesChanged(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Live Pace Display
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Calculated Average Pace', style: theme.textTheme.bodyMedium),
                    Text(
                      paceString,
                      style: AppTypography.tabular(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Long Run Cap Warning Card
              if (_capResult != null && _capResult!.isWarningTriggered)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.statusWarning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.statusWarning),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(PhosphorIconsFill.warning, color: AppColors.statusWarning, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _capResult!.warningMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Continue to summary button
              ElevatedButton(
                onPressed: _distanceKm <= 0 || _durationSeconds <= 0 ? null : _continueToFinish,
                child: const Text('Review & Save Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

