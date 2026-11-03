import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'dart:convert';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/workout_log.dart';
import '../../../data/models/readiness_checkin.dart';
import '../../../data/models/session_change.dart';
import '../../../data/models/body_log.dart';
import '../../../data/models/posture_log.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/datasources/database_helper.dart';
import '../../../domain/rules/export_generator.dart';
import '../../providers/logs_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/settings_provider.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  int _rangeDays = 7; // default 7 days
  String _generatedSummary = '';
  String _generatedJson = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateExport();
    });
  }

  void _generateExport() {
    final now = DateTime.now();
    final dates = List.generate(
      _rangeDays,
      (i) => AppDateFormatters.toIso(now.subtract(Duration(days: _rangeDays - 1 - i))),
    );

    final planState = ref.read(planProvider);
    final logsState = ref.read(logsProvider);
    final settings = ref.read(settingsProvider);

    final pastRuns = ref.read(logsProvider.notifier).getPast30DaysRunLogs(now);

    final summary = ExportGenerator.generateMarkdownSummary(
      dateRange: dates,
      plannedSessions: {for (final s in planState.sessions) s.date: s},
      workoutLogs: logsState.logsByDate,
      readinessLogs: logsState.readinessByDate,
      sessionChanges: planState.changes,
      bodyLogs: logsState.bodyLogsByDate,
      postureLogs: logsState.postureLogsByDate,
      settings: settings,
      past30DaysRunLogs: pastRuns,
    );

    final fullJson = ExportGenerator.generateFullJson(
      appVersion: '1.0.0',
      planVersion: '2.0.0',
      settings: settings,
      workoutLogs: logsState.logsByDate.values.toList(),
      readinessLogs: logsState.readinessByDate.values.toList(),
      sessionChanges: planState.changes.values.toList(),
      bodyLogs: logsState.bodyLogsByDate.values.toList(),
      postureLogs: logsState.postureLogsByDate.values.toList(),
    );

    setState(() {
      _generatedSummary = summary;
      _generatedJson = fullJson;
    });
  }

  Future<void> _shareSummaryFile() async {
    AppHaptics.medium();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/weekly_fitness_summary.md');
    await file.writeAsString(_generatedSummary);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Ali\'s Weekly Fitness Training Summary',
    );
  }

  Future<void> _shareFullJsonBackup() async {
    AppHaptics.medium();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/fitness_backup_${AppDateFormatters.toIso(DateTime.now())}.json');
    await file.writeAsString(_generatedJson);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Ali\'s Fitness Complete Data Backup',
    );
  }

  void _copyToClipboard() {
    AppHaptics.light();
    Clipboard.setData(ClipboardData(text: _generatedSummary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Markdown summary copied to clipboard!')),
    );
  }

  Future<void> _importBackup() async {
    AppHaptics.light();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      try {
        final file = File(result.files.single.path!);
        final jsonContent = await file.readAsString();
        final Map<String, dynamic> data = json.decode(jsonContent);

        // Parse backup data
        final settingsMap = data['settings'] as Map<String, dynamic>? ?? {};
        final restoredSettings = UserSettings.fromMap(settingsMap);

        final rawWorkouts = (data['workout_logs'] as List<dynamic>?) ?? [];
        final restoredLogs = <WorkoutLog>[];
        for (final item in rawWorkouts) {
          final m = item as Map<String, dynamic>;
          final rawSets = (m['sets'] as List<dynamic>?) ?? [];
          final sets = rawSets.map((s) => SetLog.fromMap(s as Map<String, dynamic>)).toList();
          restoredLogs.add(WorkoutLog.fromMap(m, sets));
        }

        final rawReadiness = (data['readiness_logs'] as List<dynamic>?) ?? [];
        final restoredReadiness = rawReadiness.map((r) => ReadinessCheckIn.fromMap(r as Map<String, dynamic>)).toList();

        final rawChanges = (data['session_changes'] as List<dynamic>?) ?? [];
        final restoredChanges = rawChanges.map((c) => SessionChange.fromMap(c as Map<String, dynamic>)).toList();

        final rawBody = (data['body_logs'] as List<dynamic>?) ?? [];
        final restoredBody = rawBody.map((b) => BodyLog.fromMap(b as Map<String, dynamic>)).toList();

        final rawPosture = (data['posture_logs'] as List<dynamic>?) ?? [];
        final restoredPosture = rawPosture.map((p) => PostureLog.fromMap(p as Map<String, dynamic>)).toList();

        await DatabaseHelper.instance.restoreDatabase(
          logs: restoredLogs,
          readiness: restoredReadiness,
          changes: restoredChanges,
          bodyLogs: restoredBody,
          postureLogs: restoredPosture,
          settings: restoredSettings,
        );

        // Reload providers
        await ref.read(settingsProvider.notifier).loadSettings();
        await ref.read(planProvider.notifier).load();
        await ref.read(logsProvider.notifier).loadAllLogs();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup successfully restored!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error restoring backup: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export for Review'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.copy),
            tooltip: 'Copy Markdown',
            onPressed: _copyToClipboard,
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.shareNetwork),
            tooltip: 'Share File',
            onPressed: _shareSummaryFile,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date Range Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: theme.colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Export Range:', style: theme.textTheme.titleSmall),
                  DropdownButton<int>(
                    value: _rangeDays,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 7, child: Text('Last 7 Days (Default)')),
                      DropdownMenuItem(value: 14, child: Text('Last 14 Days')),
                      DropdownMenuItem(value: 30, child: Text('Last 30 Days')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _rangeDays = val);
                        _generateExport();
                      }
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Action Buttons Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareSummaryFile,
                          icon: const Icon(PhosphorIconsRegular.shareNetwork, size: 18),
                          label: const Text('Share Summary'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(PhosphorIconsRegular.copy, size: 18),
                          label: const Text('Copy Text'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareFullJsonBackup,
                          icon: const Icon(PhosphorIconsRegular.floppyDisk, size: 18),
                          label: const Text('Export JSON Backup'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _importBackup,
                          icon: const Icon(PhosphorIconsRegular.downloadSimple, size: 18),
                          label: const Text('Import Backup'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Markdown Preview
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: SelectableText(
                  _generatedSummary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
