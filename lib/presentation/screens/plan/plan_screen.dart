import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/session.dart';
import '../../../domain/rules/plan_adjuster.dart';
import '../../providers/plan_provider.dart';
import '../../providers/logs_provider.dart';
import '../../providers/settings_provider.dart';
import '../workout/session_detail_screen.dart';
import 'widgets/swap_session_modal.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  int _selectedWeek = 1;

  void _openSwapModal(PlannedSession session) {
    final planState = ref.read(planProvider);
    final sessionsMap = {for (final s in planState.sessions) s.date: s};
    final hasChange = planState.changes.containsKey(session.date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SwapSessionModal(
        session: session,
        allSessions: sessionsMap,
        hasExistingChange: hasChange,
        onConfirmSwap: ({required String replacementType, required String reason}) {
          ref.read(planProvider.notifier).swapSession(
                dateStr: session.date,
                originalSessionId: session.id,
                replacementType: replacementType,
                reason: reason,
              );
        },
        onSkip: (reason) {
          ref.read(planProvider.notifier).skipSession(
                dateStr: session.date,
                originalSessionId: session.id,
                reason: reason,
              );
        },
        onResetChange: () {
          ref.read(planProvider.notifier).resetSessionChange(session.date);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planState = ref.watch(planProvider);
    final logsState = ref.watch(logsProvider);
    final settings = ref.watch(settingsProvider);

    if (planState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Group sessions by weekNumber
    final Map<int, List<PlannedSession>> weeksMap = {};
    for (final s in planState.sessions) {
      weeksMap.putIfAbsent(s.weekNumber, () => []).add(s);
    }

    final totalWeeks = weeksMap.keys.length;
    final currentWeekSessions = weeksMap[_selectedWeek] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Plan'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              settings.planVariant,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Week selector horizontal bar
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: totalWeeks,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (ctx, idx) {
                  final weekNum = idx + 1;
                  final isSelected = weekNum == _selectedWeek;
                  return ChoiceChip(
                    label: Text('Week $weekNum'),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.lightOnPrimary : theme.textTheme.bodyMedium?.color,
                    ),
                    onSelected: (val) {
                      if (val) {
                        AppHaptics.selection();
                        setState(() => _selectedWeek = weekNum);
                      }
                    },
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Missed Week Banner & Repeat Option
            Builder(
              builder: (ctx) {
                final weekAnalysis = PlanAdjuster.analyzeWeek(
                  weekNumber: _selectedWeek,
                  weekSessions: currentWeekSessions,
                  changes: planState.changes,
                  logs: logsState.logsByDate,
                );

                if (!weekAnalysis.shouldOfferRepeat) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary),
                  ),
                  child: Row(
                    children: [
                      Icon(PhosphorIconsFill.warning, color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Missed Sessions (${weekAnalysis.skippedSessionsCount} skipped)',
                              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              weekAnalysis.recommendation,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          for (final s in currentWeekSessions) {
                            if (planState.changes[s.date]?.isSkipped == true) {
                              ref.read(planProvider.notifier).resetSessionChange(s.date);
                            }
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Week sessions reset for repetition.')),
                          );
                        },
                        child: const Text('Repeat'),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Sessions list for selected week
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: currentWeekSessions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (ctx, index) {
                  final baseSession = currentWeekSessions[index];
                  final session = ref.read(planProvider.notifier).getSessionForDate(baseSession.date) ?? baseSession;
                  final log = logsState.logsByDate[session.date];
                  final change = planState.changes[session.date];

                  return _buildSessionCard(
                    context: context,
                    session: session,
                    log: log,
                    change: change,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard({
    required BuildContext context,
    required PlannedSession session,
    required dynamic log,
    required dynamic change,
  }) {
    final theme = Theme.of(context);
    final isDone = log != null;
    final isSkipped = change?.isSkipped == true;
    final isSwapped = change?.replacementType != null;
    final isRest = session.type == 'REST';

    return Material(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDone
              ? AppColors.statusDone
              : isSkipped
                  ? AppColors.statusHard
                  : isSwapped
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
          width: isDone || isSkipped || isSwapped ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.statusDone.withOpacity(0.15)
                : isSkipped
                    ? AppColors.statusHard.withOpacity(0.15)
                    : session.isHard
                        ? AppColors.statusHard.withOpacity(0.12)
                        : theme.colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isDone
                ? PhosphorIconsFill.checkCircle
                : isSkipped
                    ? PhosphorIconsBold.x
                    : session.category == 'run'
                        ? PhosphorIconsRegular.personSimpleRun
                        : isRest
                            ? PhosphorIconsRegular.moon
                            : PhosphorIconsRegular.barbell,
            color: isDone
                ? AppColors.statusDone
                : isSkipped
                    ? AppColors.statusHard
                    : session.isHard
                        ? AppColors.statusHard
                        : theme.colorScheme.primary,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Text(
              session.date,
              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                session.type,
                style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: isSkipped ? TextDecoration.lineThrough : null,
                ),
              ),
              if (isDone)
                Text(
                  'Completed • Logged',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.statusDone),
                ),
              if (isSkipped)
                Text(
                  'Skipped: ${change.reason ?? "By user"}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.statusHard),
                ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(PhosphorIconsRegular.dotsThreeVertical, size: 20),
          onSelected: (action) {
            if (action == 'details') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionDetailScreen(session: session),
                ),
              );
            } else if (action == 'swap') {
              _openSwapModal(session);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'details',
              child: Text('View Details'),
            ),
            const PopupMenuItem(
              value: 'swap',
              child: Text('Swap / Skip'),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionDetailScreen(session: session),
            ),
          );
        },
      ),
    );
  }
}
