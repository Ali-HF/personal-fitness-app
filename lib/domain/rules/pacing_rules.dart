import 'dart:math' as math;

/// Training paces and race predictions based on Part 4 of the spec:
/// "After the 5k test: convert the result into training paces (easy pace roughly 60-90 s/km
/// slower than the test pace, long run at easy pace) and show a half-marathon estimate range:
/// Riegel time (T2 = T1 x (D2/D1)^1.06) multiplied by 1.05 (best case) to 1.15 (conservative,
/// for limited long-run volume and walk breaks). Treat all of it as an estimate."
class PacingCalculator {
  /// Calculate target paces given 5K time in seconds
  static PacingResult calculateFrom5kTime(int totalSeconds) {
    final double testPaceSecondsPerKm = totalSeconds / 5.0;

    // Easy pace is 60s to 90s slower per km
    final double easyPaceMin = testPaceSecondsPerKm + 60.0;
    final double easyPaceMax = testPaceSecondsPerKm + 90.0;

    // Tempo pace is about 15s to 25s slower than 5k race pace
    final double tempoPaceMin = testPaceSecondsPerKm + 15.0;
    final double tempoPaceMax = testPaceSecondsPerKm + 25.0;

    // Riegel formula: T2 = T1 * (D2 / D1)^1.06
    // D1 = 5km, D2 = 21.0975km
    const double d1 = 5.0;
    const double d2 = 21.0975;
    final double riegelRatio = math.pow(d2 / d1, 1.06).toDouble();
    final double rawHalfMarathonSeconds = totalSeconds * riegelRatio;

    // Spec: "multiplied by 1.05 (best case) to 1.15 (conservative, for limited long-run volume and walk breaks)"
    final int halfMarathonBestCaseSeconds = (rawHalfMarathonSeconds * 1.05).round();
    final int halfMarathonConservativeSeconds = (rawHalfMarathonSeconds * 1.15).round();

    return PacingResult(
      fiveKTotalSeconds: totalSeconds,
      fiveKPaceSecondsPerKm: testPaceSecondsPerKm.round(),
      easyPaceMinSecondsPerKm: easyPaceMin.round(),
      easyPaceMaxSecondsPerKm: easyPaceMax.round(),
      tempoPaceMinSecondsPerKm: tempoPaceMin.round(),
      tempoPaceMaxSecondsPerKm: tempoPaceMax.round(),
      halfMarathonBestCaseSeconds: halfMarathonBestCaseSeconds,
      halfMarathonConservativeSeconds: halfMarathonConservativeSeconds,
    );
  }

  /// Format seconds into mm:ss or hh:mm:ss string
  static String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Format pace seconds per km into m'ss"/km
  static String formatPace(int secondsPerKm) {
    final minutes = secondsPerKm ~/ 60;
    final seconds = secondsPerKm % 60;
    return "$minutes'${seconds.toString().padLeft(2, '0')}\"/km";
  }
}

class PacingResult {
  final int fiveKTotalSeconds;
  final int fiveKPaceSecondsPerKm;
  final int easyPaceMinSecondsPerKm;
  final int easyPaceMaxSecondsPerKm;
  final int tempoPaceMinSecondsPerKm;
  final int tempoPaceMaxSecondsPerKm;
  final int halfMarathonBestCaseSeconds;
  final int halfMarathonConservativeSeconds;

  const PacingResult({
    required this.fiveKTotalSeconds,
    required this.fiveKPaceSecondsPerKm,
    required this.easyPaceMinSecondsPerKm,
    required this.easyPaceMaxSecondsPerKm,
    required this.tempoPaceMinSecondsPerKm,
    required this.tempoPaceMaxSecondsPerKm,
    required this.halfMarathonBestCaseSeconds,
    required this.halfMarathonConservativeSeconds,
  });

  String get testPaceFormatted => PacingCalculator.formatPace(fiveKPaceSecondsPerKm);
  String get easyPaceRangeFormatted =>
      '${PacingCalculator.formatPace(easyPaceMinSecondsPerKm)} - ${PacingCalculator.formatPace(easyPaceMaxSecondsPerKm)}';
  String get tempoPaceRangeFormatted =>
      '${PacingCalculator.formatPace(tempoPaceMinSecondsPerKm)} - ${PacingCalculator.formatPace(tempoPaceMaxSecondsPerKm)}';
  String get halfMarathonRangeFormatted =>
      '${PacingCalculator.formatDuration(halfMarathonBestCaseSeconds)} - ${PacingCalculator.formatDuration(halfMarathonConservativeSeconds)}';
}

