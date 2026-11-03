import '../../data/models/session.dart';

class SwapRules {
  static const hardSessionTypes = {'INT', 'TEMPO', 'LONG', 'TEST5K', 'RACE'};

  /// Available session alternatives based on session category and type.
  static List<SwapOption> getAvailableSwaps(PlannedSession currentSession) {
    final options = <SwapOption>[];

    if (currentSession.category == 'run' ||
        ['EASY', 'RW', 'INT', 'TEMPO', 'LONG', 'TEST5K', 'SHAKE'].contains(currentSession.type)) {
      // Run options
      options.addAll([
        const SwapOption(
          type: 'EASY',
          title: 'EASY 30\' (Conversational)',
          category: 'run',
          isHard: false,
          durationMinutes: 30,
        ),
        const SwapOption(
          type: 'RW',
          title: 'RW: 5\' walk, 6 x (3\' jog / 1\' walk), 5\' walk',
          category: 'run',
          isHard: false,
          durationMinutes: 34,
        ),
        const SwapOption(
          type: 'EASY',
          title: 'EASY 20\' Short Shakeout',
          category: 'run',
          isHard: false,
          durationMinutes: 20,
        ),
        const SwapOption(
          type: 'REST',
          title: 'REST (Rest & Recovery)',
          category: 'rest',
          isHard: false,
        ),
      ]);
    } else if (currentSession.category == 'strength' ||
        ['UA', 'UB', 'UC', 'LEG_A', 'LEG_B', 'FINALS_MINI'].contains(currentSession.type)) {
      // Upper / Strength options
      options.addAll([
        const SwapOption(
          type: 'UA',
          title: 'Upper A: Pull + Core (40 min)',
          category: 'strength',
          isHard: false,
          estimatedMinutes: 40,
        ),
        const SwapOption(
          type: 'UB',
          title: 'Upper B: Push + Core (40 min)',
          category: 'strength',
          isHard: false,
          estimatedMinutes: 40,
        ),
        const SwapOption(
          type: 'UC',
          title: 'Upper C: Skills & Light (25 min)',
          category: 'strength',
          isHard: false,
          estimatedMinutes: 25,
        ),
        const SwapOption(
          type: 'FINALS_MINI',
          title: 'Finals Mini (20 min, 3 rounds, no failure)',
          category: 'strength',
          isHard: false,
          estimatedMinutes: 20,
        ),
        const SwapOption(
          type: 'MOB',
          title: 'Mobility Routine (15 min)',
          category: 'mobility',
          isHard: false,
          estimatedMinutes: 15,
        ),
        const SwapOption(
          type: 'REST',
          title: 'REST (Full Recovery)',
          category: 'rest',
          isHard: false,
        ),
      ]);
    } else {
      // Mobility / rest fallback
      options.addAll([
        const SwapOption(
          type: 'MOB',
          title: 'Mobility Routine (15 min)',
          category: 'mobility',
          isHard: false,
          estimatedMinutes: 15,
        ),
        const SwapOption(
          type: 'REST',
          title: 'REST',
          category: 'rest',
          isHard: false,
        ),
      ]);
    }

    return options;
  }

  /// Validates swap against schedule rules:
  /// 1. Blocks 2 hard days (INT, TEMPO, LONG, TEST5K, RACE) back-to-back.
  /// 2. Warns if LONG is moved within 2 days of a hard session or a Leg A session.
  static SwapValidation validateSwap({
    required String targetDate, // YYYY-MM-DD
    required String targetType,
    required Map<String, PlannedSession> allSessionsByDate,
  }) {
    final targetDt = DateTime.parse(targetDate);
    final isTargetHard = hardSessionTypes.contains(targetType);

    // Rule 1: Block back-to-back hard days
    if (isTargetHard) {
      final prevDateStr = _formatDate(targetDt.subtract(const Duration(days: 1)));
      final nextDateStr = _formatDate(targetDt.add(const Duration(days: 1)));

      final prevSession = allSessionsByDate[prevDateStr];
      final nextSession = allSessionsByDate[nextDateStr];

      if (prevSession != null && hardSessionTypes.contains(prevSession.type)) {
        return SwapValidation.blocked(
          'Cannot schedule a hard session directly after ${prevSession.type} on $prevDateStr. Two hard days back-to-back are blocked.',
        );
      }
      if (nextSession != null && hardSessionTypes.contains(nextSession.type)) {
        return SwapValidation.blocked(
          'Cannot schedule a hard session directly before ${nextSession.type} on $nextDateStr. Two hard days back-to-back are blocked.',
        );
      }
    }

    // Rule 2: Warn if LONG is moved within 2 days of a hard session or Leg A
    if (targetType == 'LONG') {
      for (int i = -2; i <= 2; i++) {
        if (i == 0) continue;
        final checkDateStr = _formatDate(targetDt.add(Duration(days: i)));
        final neighbor = allSessionsByDate[checkDateStr];
        if (neighbor != null) {
          if (hardSessionTypes.contains(neighbor.type)) {
            return SwapValidation.warning(
              'Warning: Scheduling LONG within 2 days of hard session (${neighbor.type} on $checkDateStr). Make sure to keep effort easy.',
            );
          }
          if (neighbor.type == 'LEG_A') {
            return SwapValidation.warning(
              'Warning: Leg A (strength) is scheduled on $checkDateStr. Heavy leg strength right next to a long run increases fatigue.',
            );
          }
        }
      }
    }

    return SwapValidation.allowed();
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}

class SwapOption {
  final String type;
  final String title;
  final String category;
  final bool isHard;
  final double? distanceKm;
  final int? durationMinutes;
  final int? estimatedMinutes;

  const SwapOption({
    required this.type,
    required this.title,
    required this.category,
    required this.isHard,
    this.distanceKm,
    this.durationMinutes,
    this.estimatedMinutes,
  });
}

class SwapValidation {
  final bool isAllowed;
  final bool hasWarning;
  final String? message;

  const SwapValidation({
    required this.isAllowed,
    required this.hasWarning,
    this.message,
  });

  factory SwapValidation.allowed() => const SwapValidation(
        isAllowed: true,
        hasWarning: false,
      );

  factory SwapValidation.blocked(String message) => SwapValidation(
        isAllowed: false,
        hasWarning: false,
        message: message,
      );

  factory SwapValidation.warning(String message) => SwapValidation(
        isAllowed: true,
        hasWarning: true,
        message: message,
      );
}
