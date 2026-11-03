class RunPhase {
  final String title;
  final int durationSeconds;
  final bool isRun;
  final String targetEffort;

  const RunPhase({
    required this.title,
    required this.durationSeconds,
    required this.isRun,
    required this.targetEffort,
  });
}

class RunIntervalPlan {
  final List<RunPhase> phases;
  final double? targetDistanceKm;

  const RunIntervalPlan({
    required this.phases,
    this.targetDistanceKm,
  });

  int get totalDurationSeconds =>
      phases.fold(0, (sum, phase) => sum + phase.durationSeconds);

  static RunIntervalPlan fromSession(String sessionType, String? description, double? distanceKm) {
    final type = sessionType.toUpperCase();

    if (type.contains('RW1')) {
      return RunIntervalPlan(
        targetDistanceKm: distanceKm ?? 4.0,
        phases: [
          const RunPhase(title: 'Brisk Walk', durationSeconds: 5 * 60, isRun: false, targetEffort: 'Warm-up'),
          for (int i = 1; i <= 8; i++) ...[
            RunPhase(title: 'Jog #$i', durationSeconds: 2 * 60, isRun: true, targetEffort: 'Easy Jog'),
            RunPhase(title: 'Walk #$i', durationSeconds: 1 * 60, isRun: false, targetEffort: 'Recovery Walk'),
          ],
          const RunPhase(title: 'Cool-down Walk', durationSeconds: 5 * 60, isRun: false, targetEffort: 'Cool-down'),
        ],
      );
    }

    if (type.contains('RW2')) {
      return RunIntervalPlan(
        targetDistanceKm: distanceKm ?? 4.0,
        phases: [
          const RunPhase(title: 'Brisk Walk', durationSeconds: 5 * 60, isRun: false, targetEffort: 'Warm-up'),
          for (int i = 1; i <= 8; i++) ...[
            RunPhase(title: 'Jog #$i', durationSeconds: 3 * 60, isRun: true, targetEffort: 'Easy Jog'),
            RunPhase(title: 'Walk #$i', durationSeconds: 1 * 60, isRun: false, targetEffort: 'Recovery Walk'),
          ],
          const RunPhase(title: 'Cool-down Walk', durationSeconds: 5 * 60, isRun: false, targetEffort: 'Cool-down'),
        ],
      );
    }

    if (type.contains('RW3')) {
      return RunIntervalPlan(
        targetDistanceKm: distanceKm ?? 4.5,
        phases: [
          const RunPhase(title: 'Brisk Walk', durationSeconds: 5 * 60, isRun: false, targetEffort: 'Warm-up'),
          for (int i = 1; i <= 5; i++) ...[
            RunPhase(title: 'Jog #$i', durationSeconds: 4 * 60, isRun: true, targetEffort: 'Easy Jog'),
            RunPhase(title: 'Walk #$i', durationSeconds: 1 * 60, isRun: false, targetEffort: 'Recovery Walk'),
          ],
          const RunPhase(title: 'Cool-down Walk', durationSeconds: 5 * 60, isRun: false, targetEffort: 'Cool-down'),
        ],
      );
    }

    if (type.contains('RW4')) {
      return RunIntervalPlan(
        targetDistanceKm: distanceKm ?? 5.0,
        phases: [
          const RunPhase(title: 'Brisk Walk', durationSeconds: 5 * 60, isRun: false, targetEffort: 'Warm-up'),
          for (int i = 1; i <= 5; i++) ...[
            RunPhase(title: 'Jog #$i', durationSeconds: 5 * 60, isRun: true, targetEffort: 'Easy Jog'),
            RunPhase(title: 'Walk #$i', durationSeconds: 1 * 60, isRun: false, targetEffort: 'Recovery Walk'),
          ],
          const RunPhase(title: 'Cool-down Walk', durationSeconds: 5 * 60, isRun: false, targetEffort: 'Cool-down'),
        ],
      );
    }

    if (type.contains('INT-1') || type.contains('INT1')) {
      return RunIntervalPlan(
        targetDistanceKm: distanceKm ?? 5.0,
        phases: [
          const RunPhase(title: 'Easy Jog Warm-up', durationSeconds: 10 * 60, isRun: true, targetEffort: 'Easy'),
          for (int i = 1; i <= 5; i++) ...[
            RunPhase(title: 'Interval #$i', durationSeconds: 1 * 60, isRun: true, targetEffort: 'Comfortably Hard'),
            RunPhase(title: 'Recovery Jog #$i', durationSeconds: 2 * 60, isRun: true, targetEffort: 'Easy Jog'),
          ],
          const RunPhase(title: 'Cool-down Jog', durationSeconds: 10 * 60, isRun: true, targetEffort: 'Easy'),
        ],
      );
    }

    if (type.contains('INT-2') || type.contains('INT2')) {
      return RunIntervalPlan(
        targetDistanceKm: distanceKm ?? 6.0,
        phases: [
          const RunPhase(title: 'Easy Jog Warm-up', durationSeconds: 10 * 60, isRun: true, targetEffort: 'Easy'),
          for (int i = 1; i <= 4; i++) ...[
            RunPhase(title: 'Interval #$i', durationSeconds: 3 * 60, isRun: true, targetEffort: 'Comfortably Hard'),
            RunPhase(title: 'Recovery Jog #$i', durationSeconds: 2 * 60, isRun: true, targetEffort: 'Easy Jog'),
          ],
          const RunPhase(title: 'Cool-down Jog', durationSeconds: 10 * 60, isRun: true, targetEffort: 'Easy'),
        ],
      );
    }

    if (type.contains('TEMPO')) {
      return RunIntervalPlan(
        targetDistanceKm: distanceKm ?? 6.0,
        phases: [
          const RunPhase(title: 'Warm-up Jog', durationSeconds: 10 * 60, isRun: true, targetEffort: 'Easy'),
          const RunPhase(title: 'Tempo Block 1', durationSeconds: 10 * 60, isRun: true, targetEffort: 'Tempo (few words)'),
          const RunPhase(title: 'Recovery Jog', durationSeconds: 3 * 60, isRun: true, targetEffort: 'Easy Jog'),
          const RunPhase(title: 'Tempo Block 2', durationSeconds: 10 * 60, isRun: true, targetEffort: 'Tempo (few words)'),
          const RunPhase(title: 'Cool-down Jog', durationSeconds: 10 * 60, isRun: true, targetEffort: 'Easy'),
        ],
      );
    }

    if (type.contains('TEST5K') || (type.contains('TEST') && type.contains('5K'))) {
      return RunIntervalPlan(
        targetDistanceKm: 5.0,
        phases: [
          const RunPhase(title: 'Warm-up & 4 Strides', durationSeconds: 10 * 60, isRun: true, targetEffort: 'Easy Jog + Strides'),
          const RunPhase(title: '5K Time Trial', durationSeconds: 30 * 60, isRun: true, targetEffort: '8/10 Controlled Hard'),
          const RunPhase(title: 'Cool-down Walk', durationSeconds: 10 * 60, isRun: false, targetEffort: 'Easy Walk'),
        ],
      );
    }

    if (type.contains('LONG')) {
      // Run 8' / walk 1' strategy recommended in the spec
      final distance = distanceKm ?? 8.0;
      final estimatedMinutes = (distance * 7.5).round(); // ~7:30/km
      final numCycles = (estimatedMinutes / 9.0).floor();
      return RunIntervalPlan(
        targetDistanceKm: distance,
        phases: [
          for (int i = 1; i <= numCycles; i++) ...[
            RunPhase(title: 'Run Segment #$i', durationSeconds: 8 * 60, isRun: true, targetEffort: 'Easy Conversational'),
            RunPhase(title: 'Walk Break #$i', durationSeconds: 1 * 60, isRun: false, targetEffort: 'Recovery Walk'),
          ],
        ],
      );
    }

    // Default continuous easy run
    final durationMins = (distanceKm != null) ? (distanceKm * 7.5).round() : 30;
    return RunIntervalPlan(
      targetDistanceKm: distanceKm,
      phases: [
        RunPhase(
          title: 'Continuous Run',
          durationSeconds: durationMins * 60,
          isRun: true,
          targetEffort: 'Easy Conversational',
        ),
      ],
    );
  }
}

