import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../data/models/session.dart';
import '../../../../domain/rules/swap_rules.dart';

class SwapSessionModal extends StatefulWidget {
  final PlannedSession session;
  final Map<String, PlannedSession> allSessions;
  final Function({
    required String replacementType,
    required String reason,
  }) onConfirmSwap;
  final Function(String reason) onSkip;
  final VoidCallback onResetChange;
  final bool hasExistingChange;

  const SwapSessionModal({
    super.key,
    required this.session,
    required this.allSessions,
    required this.onConfirmSwap,
    required this.onSkip,
    required this.onResetChange,
    this.hasExistingChange = false,
  });

  @override
  State<SwapSessionModal> createState() => _SwapSessionModalState();
}

class _SwapSessionModalState extends State<SwapSessionModal> {
  String? _selectedType;
  final TextEditingController _reasonController = TextEditingController(text: 'Schedule adjustment');
  SwapValidation? _validation;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _selectType(String type) {
    AppHaptics.selection();
    setState(() {
      _selectedType = type;
      _validation = SwapRules.validateSwap(
        targetDate: widget.session.date,
        targetType: type,
        allSessionsByDate: widget.allSessions,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableSwaps = SwapRules.getAvailableSwaps(widget.session);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: ListView(
            controller: controller,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Swap Session',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.x),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Original: ${widget.session.title} (${widget.session.date})',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 16),

              Text('Choose Alternative Session', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),

              ...availableSwaps.map((opt) {
                final isSelected = _selectedType == opt.type;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _selectType(opt.type),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.12)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            opt.isHard ? PhosphorIconsRegular.lightning : PhosphorIconsRegular.check,
                            size: 18,
                            color: opt.isHard ? AppColors.statusHard : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(opt.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                                Text('${opt.category.toUpperCase()} • ${opt.isHard ? "Hard Session" : "Normal/Easy"}',
                                    style: theme.textTheme.labelSmall),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(PhosphorIconsFill.checkCircle, color: theme.colorScheme.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Validation warnings or errors
              if (_validation != null) ...[
                if (!_validation!.isAllowed)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusHard.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.statusHard),
                    ),
                    child: Row(
                      children: [
                        const Icon(PhosphorIconsFill.xCircle, color: AppColors.statusHard, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _validation!.message ?? 'This swap is blocked by safety rules.',
                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.statusHard),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_validation!.isAllowed && _validation!.hasWarning)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusWarning.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.statusWarning),
                    ),
                    child: Row(
                      children: [
                        const Icon(PhosphorIconsFill.warning, color: AppColors.statusWarning, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _validation!.message ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.statusWarning),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],

              // Swap Reason input
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Swap / Change',
                  hintText: 'e.g. Legs heavy, work internship, fatigue',
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Swap Button
              ElevatedButton(
                onPressed: (_selectedType == null || (_validation != null && !_validation!.isAllowed))
                    ? null
                    : () {
                        AppHaptics.medium();
                        widget.onConfirmSwap(
                          replacementType: _selectedType!,
                          reason: _reasonController.text.trim().isEmpty
                              ? 'Swapped to $_selectedType'
                              : _reasonController.text.trim(),
                        );
                        Navigator.pop(context);
                      },
                child: const Text('Confirm Session Swap'),
              ),
              const SizedBox(height: 10),

              // Skip Session Button
              OutlinedButton(
                onPressed: () {
                  AppHaptics.light();
                  widget.onSkip(
                    _reasonController.text.trim().isEmpty
                        ? 'Session skipped by user'
                        : _reasonController.text.trim(),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Mark Session as Skipped'),
              ),

              if (widget.hasExistingChange) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    widget.onResetChange();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset to Original Plan'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

