import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../data/models/session.dart';
import '../../../domain/rules/finals_mode_rule.dart';
import '../../providers/plan_provider.dart';
import '../../providers/logs_provider.dart';
import '../../providers/settings_provider.dart';
import '../plan/widgets/swap_session_modal.dart';
import '../workout/active_strength_screen.dart';
import '../workout/log_run_screen.dart';
import '../workout/session_detail_screen.dart';
import 'widgets/week_strip.dart';
import 'widgets/readiness_card.dart';
import 'widgets/readiness_dialog.dart';
import 'widgets/posture_card.dart';
import 'widgets/hero_session_card.dart';
import 'widgets/week_summary_row.dart';
import 'widgets/countdown_card.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  DateTime _selectedDate = DateTime.now();

  void _openReadinessDialog(PlannedSession? session, String dateStr) {
    final logsState = ref.read(logsProvider);
    final existing = logsState.readinessByDate[dateStr];

    showDialog(
      context: context,
      builder: (_) => ReadinessDialog(
        dateStr: dateStr,
        currentSession: session,
        existingCheckIn: existing,
        onSave: (checkIn) {
          ref.read(logsProvider.notifier).saveReadiness(checkIn);
        },
      ),
    );
  }

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

    if (planState.isLoading || logsState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dateStr = AppDateFormatters.toIso(_selectedDate);
    final session = ref.read(planProvider.notifier).getSessionForDate(dateStr);
    final workoutLog = logsState.logsByDate[dateStr];
    final sessionChange = planState.changes[dateStr];
    final readinessCheckIn = logsState.readinessByDate[dateStr];
    final postureLog = logsState.postureLogsByDate[dateStr];

    // Check finals mode
    final isFinals = FinalsModeRule.isInFinalsMode(
      currentDate: dateStr,
      finalsStart: settings.finalsStart,
      finalsEnd: settings.finalsEnd,
    );

    // Week calculations for "This week" summary
    final monday = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDates = List.generate(7, (i) => AppDateFormatters.toIso(monday.add(Duration(days: i))));

    double weekDistanceKm = 0.0;
    int weekCompletedSessions = 0;
    int weekPlannedSessions = 0;

    for (final d in weekDates) {
      final s = ref.read(planProvider.notifier).getSessionForDate(d);
      if (s != null && s.type != 'REST') weekPlannedSessions++;
      final l = logsState.logsByDate[d];
      if (l != null) {
        weekCompletedSessions++;
        weekDistanceKm += (l.runDistanceKm ?? 0.0);
      }
    }

    // Up next session (tomorrow)
    final tomorrowStr = AppDateFormatters.toIso(_selectedDate.add(const Duration(days: 1)));
    final upNextSession = ref.read(planProvider.notifier).getSessionForDate(tomorrowStr);

    // Check if 2+ skipped sessions in current week for "Repeat this week" prompt
    final currentWeekNum = session?.weekNumber ?? 1;
    final skippedInWeek = ref.read(planProvider.notifier).getSkippedCountForWeek(currentWeekNum);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Ali',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              AppDateFormatters.fullDate.format(_selectedDate),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(planProvider.notifier).load();
            await ref.read(logsProvider.notifier).loadAllLogs();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Finals Mode Banner
              if (isFinals)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.statusWarning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.statusWarning),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsFill.graduationCap, color: AppColors.statusWarning, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Finals Mode active (${settings.finalsStart} to ${settings.finalsEnd}). Sessions capped at 30m, intervals hidden, eat at maintenance.',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Repeat this week prompt
              if (skippedInWeek >= 2)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.primary, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsRegular.arrowCounterClockwise, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$skippedInWeek sessions missed this week',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                            Text('Would you like to repeat Week $currentWeekNum before progressing?',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(planProvider.notifier).repeatWeek(currentWeekNum);
                        },
                        child: const Text('Repeat'),
                      ),
                    ],
                  ),
                ),

              // Week date strip
              WeekStrip(
                selectedDate: _selectedDate,
                onSelectDate: (dt) {
                  setState(() => _selectedDate = dt);
                },
                plannedSessions: {for (final s in planState.sessions) s.date: s},
                workoutLogs: logsState.logsByDate,
                sessionChanges: planState.changes,
              ),

              const SizedBox(height: 16),

              // Readiness Check-in Card
              ReadinessCard(
                checkIn: readinessCheckIn,
                onTap: () => _openReadinessDialog(session, dateStr),
              ),

              const SizedBox(height: 12),

              // Daily Posture Routine Card
              PostureCard(
                postureLog: postureLog,
                onToggle: (done) {
                  ref.read(logsProvider.notifier).togglePosture(dateStr, done);
                },
              ),

              const SizedBox(height: 16),

              // Hero Session Card
              HeroSessionCard(
                session: session,
                log: workoutLog,
                change: sessionChange,
                onStart: () {
                  if (session == null) return;
                  if (session.category == 'run') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogRunScreen(session: session),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActiveStrengthScreen(session: session),
                      ),
                    );
                  }
                },
                onSwap: () {
                  if (session != null) _openSwapModal(session);
                },
                onSkip: () {
                  if (session != null) {
                    ref.read(planProvider.notifier).skipSession(
                          dateStr: session.date,
                          originalSessionId: session.id,
                        );
                  }
                },
                onViewDetails: () {
                  if (session != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SessionDetailScreen(session: session),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // This Week summary row
              WeekSummaryRow(
                completedSessions: weekCompletedSessions,
                plannedSessions: weekPlannedSessions,
                totalKm: weekDistanceKm,
              ),

              const SizedBox(height: 16),

              // Up Next Card
              if (upNextSession != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(PhosphorIconsRegular.calendarPlus, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Up Next (Tomorrow)', style: theme.textTheme.labelSmall),
                            const SizedBox(height: 2),
                            Text(
                              upNextSession.title,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const Icon(PhosphorIconsRegular.caretRight, size: 18),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Race & 5K countdown card
              CountdownCard(
                raceDateStr: settings.raceDate,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

