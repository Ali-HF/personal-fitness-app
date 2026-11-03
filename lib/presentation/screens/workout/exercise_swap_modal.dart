import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/exercise.dart';

class ExerciseSwapModal extends StatelessWidget {
  final Exercise exercise;
  final Function(String selectedAlternativeName) onSelectAlternative;

  const ExerciseSwapModal({
    super.key,
    required this.exercise,
    required this.onSelectAlternative,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise Options',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.x),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Current: ${exercise.name} (${exercise.target})',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
          ),
          if (exercise.cues != null) ...[
            const SizedBox(height: 6),
            Text(
              'Form cues: ${exercise.cues}',
              style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Regressions (Easier)
          Row(
            children: [
              const Icon(PhosphorIconsRegular.arrowDown, size: 16, color: AppColors.statusWarning),
              const SizedBox(width: 6),
              Text(
                'Regressions (Easier / De-load)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (exercise.regressions.isEmpty)
            Text('No standard regressions listed.', style: theme.textTheme.bodySmall)
          else
            ...exercise.regressions.map((reg) => _buildOptionTile(context, reg, isProgression: false)),

          const SizedBox(height: 16),

          // Progressions (Harder)
          Row(
            children: [
              const Icon(PhosphorIconsRegular.arrowUp, size: 16, color: AppColors.statusDone),
              const SizedBox(width: 6),
              Text(
                'Progressions (Harder / Challenge)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (exercise.progressions.isEmpty)
            Text('No standard progressions listed.', style: theme.textTheme.bodySmall)
          else
            ...exercise.progressions.map((prog) => _buildOptionTile(context, prog, isProgression: true)),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, String name, {required bool isProgression}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          onSelectAlternative(name);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(
                isProgression ? 'Progress' : 'Regress',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isProgression ? AppColors.statusDone : AppColors.statusWarning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

