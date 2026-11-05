import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/services/notification_service.dart';
import '../../providers/settings_provider.dart';
import '../../providers/plan_provider.dart';
import 'export_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
          children: [
            // Plan Variant Selector Card
            _buildSectionHeader(theme, 'Training Plan Variant'),
            Material(
              color: theme.colorScheme.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Jan 3 Race (Default)'),
                    subtitle: const Text('9-week compressed build • Peak long run 12 km'),
                    value: 'JAN_3',
                    groupValue: settings.planVariant,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      if (val != null) {
                        AppHaptics.selection();
                        settingsNotifier.setPlanVariant(val);
                        ref.read(planProvider.notifier).switchVariant(val);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Option B: Jan 17 Race'),
                    subtitle: const Text('11-week build • Peak 13.5 km • 2-week taper'),
                    value: 'JAN_17',
                    groupValue: settings.planVariant,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      if (val != null) {
                        AppHaptics.selection();
                        settingsNotifier.setPlanVariant(val);
                        ref.read(planProvider.notifier).switchVariant(val);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Option C: Jan 24 Race (Recommended)'),
                    subtitle: const Text('12-week build • Peak 15 km • Safest & strongest'),
                    value: 'JAN_24',
                    groupValue: settings.planVariant,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      if (val != null) {
                        AppHaptics.selection();
                        settingsNotifier.setPlanVariant(val);
                        ref.read(planProvider.notifier).switchVariant(val);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Key Dates
            _buildSectionHeader(theme, 'Target Dates'),
            Material(
              color: theme.colorScheme.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.flagBanner),
                    title: const Text('Half Marathon Race Date'),
                    subtitle: Text(settings.raceDate),
                    trailing: const Icon(PhosphorIconsRegular.calendar, size: 20),
                    onTap: () async {
                      final current = DateTime.tryParse(settings.raceDate) ?? DateTime(2027, 1, 3);
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: current,
                        firstDate: DateTime(2026, 11, 1),
                        lastDate: DateTime(2027, 4, 1),
                      );
                      if (picked != null) {
                        settingsNotifier.setRaceDate(AppDateFormatters.toIso(picked));
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.graduationCap),
                    title: const Text('Finals Window'),
                    subtitle: Text('${settings.finalsStart} to ${settings.finalsEnd}'),
                    trailing: const Icon(PhosphorIconsRegular.pencilSimple, size: 20),
                    onTap: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2026, 11, 1),
                        lastDate: DateTime(2027, 1, 1),
                        initialDateRange: DateTimeRange(
                          start: DateTime.tryParse(settings.finalsStart) ?? DateTime(2026, 12, 1),
                          end: DateTime.tryParse(settings.finalsEnd) ?? DateTime(2026, 12, 15),
                        ),
                      );
                      if (range != null) {
                        settingsNotifier.setFinalsDates(
                          AppDateFormatters.toIso(range.start),
                          AppDateFormatters.toIso(range.end),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Appearance & Theme
            _buildSectionHeader(theme, 'Appearance'),
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
                  Text('App Theme', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildThemeChip(context, ref, 'system', 'System Default'),
                      const SizedBox(width: 8),
                      _buildThemeChip(context, ref, 'light', 'Cream Light'),
                      const SizedBox(width: 8),
                      _buildThemeChip(context, ref, 'dark', 'Dark'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Reminders & Export
            _buildSectionHeader(theme, 'Export & Reminders'),
            Material(
              color: theme.colorScheme.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Morning Workout Reminder (7:00 AM)'),
                    subtitle: const Text('Notify me of today\'s planned session in the morning'),
                    value: settings.reminderMorning,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) async {
                      if (val) {
                        await NotificationService.instance.requestPermissions();
                      }
                      settingsNotifier.setReminderMorning(val);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Sunday 8 PM Export Reminder'),
                    subtitle: const Text('Remind me to export weekly summary for review'),
                    value: settings.reminderSundayExport,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) async {
                      if (val) {
                        await NotificationService.instance.requestPermissions();
                      }
                      settingsNotifier.setReminderSundayExport(val);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(PhosphorIconsRegular.shareNetwork),
                    title: const Text('Export for Review'),
                    subtitle: const Text('Markdown summary table + full JSON backup'),
                    trailing: const Icon(PhosphorIconsRegular.caretRight, size: 20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExportScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildThemeChip(BuildContext context, WidgetRef ref, String mode, String label) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final isSelected = settings.themeMode == mode;

    return Expanded(
      child: InkWell(
        onTap: () {
          AppHaptics.selection();
          ref.read(settingsProvider.notifier).setThemeMode(mode);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.lightOnPrimary : theme.textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}
