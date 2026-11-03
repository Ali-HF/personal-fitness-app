import '../../data/models/readiness_checkin.dart';
import '../../data/models/session.dart';

class ReadinessRules {
  /// Evaluates readiness check-in and session to return a suggestion and optional adapted session.
  static ReadinessEvaluation evaluate({
    required ReadinessCheckIn checkIn,
    PlannedSession? currentSession,
    List<ReadinessCheckIn> pastDays = const [],
  }) {
    // 1. Sharp pain check
    if (checkIn.pain.toLowerCase() == 'sharp') {
      return ReadinessEvaluation(
        flag: ReadinessFlag.danger,
        title: 'Sharp Pain Detected',
        message:
            'Sharp pain requires caution. Do not push through pain. We suggest resting today and consulting a doctor or physiotherapist if it persists.',
        suggestedType: 'REST',
        suggestedTitle: 'REST (Recovery Day)',
        shouldSwap: true,
      );
    }

    // 2. High soreness (>= 7) or sleep under 6 hours
    final isHighSoreness = checkIn.legSoreness >= 7;
    final isLowSleep = checkIn.sleepHours < 6.0;

    if (isHighSoreness || isLowSleep) {
      final reason = isHighSoreness && isLowSleep
          ? 'Leg soreness is high ($checkIn.legSoreness/10) and sleep was low (${checkIn.sleepHours}h)'
          : isHighSoreness
              ? 'Leg soreness is high (${checkIn.legSoreness}/10)'
              : 'Sleep was under 6 hours (${checkIn.sleepHours}h)';

      if (currentSession != null) {
        if (currentSession.type == 'INT' || currentSession.type == 'TEMPO') {
          return ReadinessEvaluation(
            flag: ReadinessFlag.warning,
            title: 'Easier Session Recommended',
            message: '$reason. Swapping intense quality run to an easy 30-min conversational jog.',
            suggestedType: 'EASY',
            suggestedTitle: 'EASY 30\' (Dialed back for recovery)',
            shouldSwap: true,
          );
        } else if (currentSession.type == 'LONG' && currentSession.distanceKm != null) {
          final reducedDistance = (currentSession.distanceKm! * 0.70).roundToDouble();
          return ReadinessEvaluation(
            flag: ReadinessFlag.warning,
            title: 'Volume Reduction Recommended',
            message: '$reason. Capping long run to 70% of target distance (~$reducedDistance km).',
            suggestedType: 'LONG',
            suggestedTitle: 'LONG $reducedDistance km (70% Volume Cap)',
            reducedDistanceKm: reducedDistance,
            shouldSwap: false,
          );
        }
      }

      return ReadinessEvaluation(
        flag: ReadinessFlag.warning,
        title: 'Recovery Warning',
        message: '$reason. Take today at an easy pace and listen to your body.',
        shouldSwap: false,
      );
    }

    // 3. Multi-day fatigue check (3+ consecutive low energy days)
    int lowEnergyStreak = 0;
    for (final past in pastDays) {
      if (past.sleepHours < 6.5 || past.legSoreness >= 6 || past.stress >= 4) {
        lowEnergyStreak++;
      } else {
        break;
      }
    }

    if (lowEnergyStreak >= 2) {
      // Current day + past 2 days = 3 consecutive days
      return const ReadinessEvaluation(
        flag: ReadinessFlag.warning,
        title: '3-Day Low Energy Streak',
        message:
            'You have logged 3 or more low-energy days in a row (fatigue, poor sleep or soreness). Make sure you are eating enough carbs and protein, and prioritize full rest.',
        shouldSwap: false,
      );
    }

    return const ReadinessEvaluation(
      flag: ReadinessFlag.good,
      title: 'Ready to Train',
      message: 'Body readiness looks good for today\'s planned session.',
      shouldSwap: false,
    );
  }
}

enum ReadinessFlag { good, warning, danger }

class ReadinessEvaluation {
  final ReadinessFlag flag;
  final String title;
  final String message;
  final String? suggestedType;
  final String? suggestedTitle;
  final double? reducedDistanceKm;
  final bool shouldSwap;

  const ReadinessEvaluation({
    required this.flag,
    required this.title,
    required this.message,
    this.suggestedType,
    this.suggestedTitle,
    this.reducedDistanceKm,
    this.shouldSwap = false,
  });
}

