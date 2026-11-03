import 'dart:convert';

/// Converts stored GPS route points into standard GPX 1.1 XML format
/// compatible with Strava, Garmin Connect, and Apple Health.
class GpxExporter {
  static String buildGpx({
    required String trackName,
    required String dateStr,
    required String routeJson,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<gpx version="1.1" creator="AliFitnessApp" '
      'xmlns="http://www.topografix.com/GPX/1/1" '
      'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
      'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
      'http://www.topografix.com/GPX/1/1/gpx.xsd">',
    );
    buffer.writeln('  <metadata>');
    buffer.writeln('    <name>$trackName</name>');
    buffer.writeln('    <time>${DateTime.now().toUtc().toIso8601String()}</time>');
    buffer.writeln('  </metadata>');
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>$trackName</name>');
    buffer.writeln('    <type>running</type>');
    buffer.writeln('    <trkseg>');

    try {
      final List<dynamic> points = jsonDecode(routeJson) as List<dynamic>;
      for (final pt in points) {
        if (pt is List && pt.length >= 2) {
          final lat = pt[0];
          final lon = pt[1];
          buffer.writeln('      <trkpt lat="$lat" lon="$lon">');
          buffer.writeln('        <time>${dateStr}T08:00:00Z</time>');
          buffer.writeln('      </trkpt>');
        }
      }
    } catch (_) {}

    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');

    return buffer.toString();
  }
}

