class PaceCalculator {
  /// Returns pace string formatted as M:SS /km given distance (km) and duration (seconds).
  static String formatPace(double distanceKm, int durationSeconds) {
    if (distanceKm <= 0 || durationSeconds <= 0) return "--:-- /km";
    final secondsPerKm = (durationSeconds / distanceKm).round();
    final minutes = secondsPerKm ~/ 60;
    final seconds = secondsPerKm % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')} /km";
  }

  /// Calculates pace in seconds per km.
  static int? paceSeconds(double distanceKm, int durationSeconds) {
    if (distanceKm <= 0 || durationSeconds <= 0) return null;
    return (durationSeconds / distanceKm).round();
  }

  /// Formats seconds to HH:MM:SS or MM:SS
  static String formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } else {
      return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }
  }

  /// Converts MM:SS or HH:MM:SS string to total seconds
  static int parseDurationStringToSeconds(String text) {
    final parts = text.trim().split(':');
    if (parts.length == 2) {
      final mins = int.tryParse(parts[0]) ?? 0;
      final secs = int.tryParse(parts[1]) ?? 0;
      return (mins * 60) + secs;
    } else if (parts.length == 3) {
      final hrs = int.tryParse(parts[0]) ?? 0;
      final mins = int.tryParse(parts[1]) ?? 0;
      final secs = int.tryParse(parts[2]) ?? 0;
      return (hrs * 3600) + (mins * 60) + secs;
    }
    return int.tryParse(text) ?? 0;
  }
}

