import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../data/models/readiness_checkin.dart';
import '../../../../data/models/session.dart';
import '../../../../domain/rules/readiness_rules.dart';

class ReadinessDialog extends StatefulWidget {
  final String dateStr;
  final PlannedSession? currentSession;
  final ReadinessCheckIn? existingCheckIn;
  final Function(ReadinessCheckIn) onSave;
  final VoidCallback? onPerformSwap;

  const ReadinessDialog({
    super.key,
    required this.dateStr,
    this.currentSession,
    this.existingCheckIn,
    required this.onSave,
    this.onPerformSwap,
  });

  @override
  State<ReadinessDialog> createState() => _ReadinessDialogState();
}

class _ReadinessDialogState extends State<ReadinessDialog> {
  double _sleepHours = 7.5;
  int _legSoreness = 2; // 0-10
  String _pain = 'none'; // none, mild, sharp
  int _stress = 2; // 1-5
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingCheckIn != null) {
      _sleepHours = widget.existingCheckIn!.sleepHours;
      _legSoreness = widget.existingCheckIn!.legSoreness;
      _pain = widget.existingCheckIn!.pain;
      _stress = widget.existingCheckIn!.stress;
      _noteController.text = widget.existingCheckIn!.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Live evaluation
    final tempCheckIn = ReadinessCheckIn(
      date: widget.dateStr,
      sleepHours: _sleepHours,
      legSoreness: _legSoreness,
      pain: _pain,
      stress: _stress,
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    final evaluation = ReadinessRules.evaluate(
      checkIn: tempCheckIn,
      currentSession: widget.currentSession,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Readiness Check-in',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.x, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Sleep Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sleep', style: theme.textTheme.titleSmall),
                  Text('${_sleepHours.toStringAsFixed(1)} hrs',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _sleepHours < 6.0 ? AppColors.statusHard : theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
              Slider(
                value: _sleepHours,
                min: 3.0,
                max: 12.0,
                divisions: 18,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) {
                  setState(() => _sleepHours = val);
                },
              ),
              const SizedBox(height: 12),

              // Leg Soreness Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Leg Soreness (0-10)', style: theme.textTheme.titleSmall),
                  Text('$_legSoreness / 10',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _legSoreness >= 7 ? AppColors.statusHard : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
              Slider(
                value: _legSoreness.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: _legSoreness >= 7 ? AppColors.statusHard : theme.colorScheme.primary,
                onChanged: (val) {
                  setState(() => _legSoreness = val.round());
                },
              ),
              const SizedBox(height: 12),

              // Pain selector (None, Mild, Sharp)
              Text('Pain / Discomfort', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildOptionChip('none', 'None', theme),
                  const SizedBox(width: 8),
                  _buildOptionChip('mild', 'Mild', theme),
                  const SizedBox(width: 8),
                  _buildOptionChip('sharp', 'Sharp', theme, isAlert: true),
                ],
              ),
              const SizedBox(height: 16),

              // Stress (1-5)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Stress / Mental Fatigue', style: theme.textTheme.titleSmall),
                  Text('$_stress / 5', style: theme.textTheme.titleSmall),
                ],
              ),
              Slider(
                value: _stress.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) {
                  setState(() => _stress = val.round());
                },
              ),
              const SizedBox(height: 8),

              // Note field
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  hintText: 'Optional notes (e.g. tight calves, late flight)',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Dynamic Recommendation Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: evaluation.flag == ReadinessFlag.danger
                      ? AppColors.statusHard.withOpacity(0.12)
                      : evaluation.flag == ReadinessFlag.warning
                          ? AppColors.statusWarning.withOpacity(0.12)
                          : AppColors.statusDone.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: evaluation.flag == ReadinessFlag.danger
                        ? AppColors.statusHard
                        : evaluation.flag == ReadinessFlag.warning
                            ? AppColors.statusWarning
                            : AppColors.statusDone,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          evaluation.flag == ReadinessFlag.danger
                              ? PhosphorIconsFill.warningOctagon
                              : evaluation.flag == ReadinessFlag.warning
                                  ? PhosphorIconsFill.warning
                                  : PhosphorIconsFill.checkCircle,
                          size: 18,
                          color: evaluation.flag == ReadinessFlag.danger
                              ? AppColors.statusHard
                              : evaluation.flag == ReadinessFlag.warning
                                  ? AppColors.statusWarning
                                  : AppColors.statusDone,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          evaluation.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: evaluation.flag == ReadinessFlag.danger
                                ? AppColors.statusHard
                                : evaluation.flag == ReadinessFlag.warning
                                    ? AppColors.statusWarning
                                    : AppColors.statusDone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      evaluation.message,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              ElevatedButton(
                onPressed: () {
                  AppHaptics.light();
                  final checkInToSave = ReadinessCheckIn(
                    date: widget.dateStr,
                    sleepHours: _sleepHours,
                    legSoreness: _legSoreness,
                    pain: _pain,
                    stress: _stress,
                    note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
                    suggestion: evaluation.message,
                  );
                  widget.onSave(checkInToSave);
                  Navigator.pop(context);
                },
                child: const Text('Save Readiness'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChip(String value, String label, ThemeData theme, {bool isAlert = false}) {
    final isSelected = _pain == value;
    final alertColor = isAlert ? AppColors.statusHard : theme.colorScheme.primary;

    return Expanded(
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          setState(() => _pain = value);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? alertColor : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? alertColor : theme.dividerColor,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? (isAlert ? Colors.white : AppColors.lightOnPrimary)
                  : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}

