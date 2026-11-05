import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/session.dart';
import '../../../domain/models/run_interval.dart';
import 'workout_finish_screen.dart';

enum GpsLockStatus {
  searching,
  locked,
  disabled,
  denied,
}

class LiveRunScreen extends ConsumerStatefulWidget {
  final PlannedSession session;

  const LiveRunScreen({super.key, required this.session});

  @override
  ConsumerState<LiveRunScreen> createState() => _LiveRunScreenState();
}

class _LiveRunScreenState extends ConsumerState<LiveRunScreen> with SingleTickerProviderStateMixin {
  late final RunIntervalPlan _intervalPlan;
  int _currentPhaseIndex = 0;
  int _currentPhaseRemainingSeconds = 0;

  bool _isPaused = false;
  int _totalElapsedSeconds = 0;
  double _totalDistanceMeters = 0.0;
  Timer? _tickerTimer;

  StreamSubscription<Position>? _positionStream;
  final List<LatLng> _routePoints = [];
  Position? _lastPosition;
  double? _instantSpeedMps;
  GpsLockStatus _gpsStatus = GpsLockStatus.searching;
  double? _gpsAccuracyMeters;
  final MapController _mapController = MapController();
  bool _showMap = true;

  // Long-press finish button animation
  late AnimationController _finishProgressController;

  @override
  void initState() {
    super.initState();

    _intervalPlan = RunIntervalPlan.fromSession(
      widget.session.type,
      widget.session.details.isNotEmpty ? widget.session.details.first : null,
      widget.session.distanceKm,
    );

    if (_intervalPlan.phases.isNotEmpty) {
      _currentPhaseRemainingSeconds = _intervalPlan.phases.first.durationSeconds;
    }

    _finishProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _startRun();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _positionStream?.cancel();
    _finishProgressController.dispose();
    WakelockPlus.disable().catchError((_) {});
    super.dispose();
  }

  Future<void> _startRun() async {
    setState(() {
      _isPaused = false;
    });

    WakelockPlus.enable().catchError((_) {});

    // Start 1-second ticker
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _totalElapsedSeconds++;
          if (_currentPhaseRemainingSeconds > 0) {
            _currentPhaseRemainingSeconds--;
          } else {
            _advanceToNextPhase();
          }
        });
      }
    });

    await _initGpsTracking();
  }

  void _advanceToNextPhase() {
    if (_currentPhaseIndex < _intervalPlan.phases.length - 1) {
      _currentPhaseIndex++;
      final nextPhase = _intervalPlan.phases[_currentPhaseIndex];
      _currentPhaseRemainingSeconds = nextPhase.durationSeconds;

      // Specialized vibration & sound cues for runners
      if (nextPhase.isRun) {
        // 3 energetic vibration pulses for RUN intervals
        HapticFeedback.heavyImpact();
        Future.delayed(const Duration(milliseconds: 250), () => HapticFeedback.heavyImpact());
        Future.delayed(const Duration(milliseconds: 500), () => HapticFeedback.heavyImpact());
      } else {
        // 1 long continuous vibration for WALK / RECOVERY
        HapticFeedback.vibrate();
      }
      SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> _initGpsTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _gpsStatus = GpsLockStatus.disabled);
        _startSimulationFallback();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _gpsStatus = GpsLockStatus.denied);
          _startSimulationFallback();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _gpsStatus = GpsLockStatus.denied);
        _startSimulationFallback();
        return;
      }

      // Initial fast fix
      try {
        final initialPos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 4),
        );
        final initialLatLng = LatLng(initialPos.latitude, initialPos.longitude);
        if (mounted) {
          setState(() {
            _lastPosition = initialPos;
            _gpsAccuracyMeters = initialPos.accuracy;
            _gpsStatus = initialPos.accuracy <= 30.0 ? GpsLockStatus.locked : GpsLockStatus.searching;
            _routePoints.add(initialLatLng);
          });
        }
      } catch (_) {
        // Timeout on fast fix; stream will take over
      }

      // Configure location settings with Android background foreground service
      late final LocationSettings locationSettings;
      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 2,
          forceLocationManager: false,
          intervalDuration: const Duration(seconds: 1),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: "Ali Fitness • Running",
            notificationText: "GPS route and pace tracking active",
            enableWakeLock: true,
          ),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          activityType: ActivityType.fitness,
          distanceFilter: 2,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
        );
      }

      _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (position) {
          if (_isPaused || !mounted) return;

          // Reject inaccurate readings (> 35m) to avoid false distance jumps
          if (position.accuracy > 35.0) {
            if (_gpsStatus != GpsLockStatus.searching) {
              setState(() {
                _gpsStatus = GpsLockStatus.searching;
                _gpsAccuracyMeters = position.accuracy;
              });
            }
            return;
          }

          if (_gpsStatus != GpsLockStatus.locked) {
            setState(() {
              _gpsStatus = GpsLockStatus.locked;
              _gpsAccuracyMeters = position.accuracy;
            });
          }

          final latLng = LatLng(position.latitude, position.longitude);

          if (_lastPosition != null) {
            final distanceDelta = Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );

            final timeDeltaSec = position.timestamp.difference(_lastPosition!.timestamp).inMilliseconds / 1000.0;
            final isSpeedFeasible = timeDeltaSec <= 0 || (distanceDelta / timeDeltaSec) < 12.0;

            // Only accumulate distance if actual movement >= 1.5m and velocity < 43 km/h
            if (distanceDelta >= 1.5 && isSpeedFeasible) {
              setState(() {
                _totalDistanceMeters += distanceDelta;
                _instantSpeedMps = position.speed >= 0.5
                    ? position.speed
                    : (timeDeltaSec > 0 ? (distanceDelta / timeDeltaSec) : null);
                _gpsAccuracyMeters = position.accuracy;
                _routePoints.add(latLng);
                _lastPosition = position;
              });
              try {
                _mapController.move(latLng, 16.5);
              } catch (_) {}
            }
          } else {
            setState(() {
              _lastPosition = position;
              _gpsAccuracyMeters = position.accuracy;
              _routePoints.add(latLng);
            });
          }
        },
        onError: (err) {
          debugPrint('GPS stream error: $err');
        },
      );
    } catch (e) {
      debugPrint('Location init exception: $e');
      _startSimulationFallback();
    }
  }

  /// Simulation fallback for web/laptop testing or environments without GPS lock
  void _startSimulationFallback() {
    if (_routePoints.isNotEmpty) return;
    const start = LatLng(51.5074, -0.1278);
    setState(() {
      _routePoints.add(start);
    });
  }

  void _togglePause() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _skipInterval() {
    HapticFeedback.lightImpact();
    setState(() {
      _advanceToNextPhase();
    });
  }

  void _finishRun() {
    HapticFeedback.heavyImpact();
    _tickerTimer?.cancel();
    _positionStream?.cancel();
    WakelockPlus.disable().catchError((_) {});

    final distanceKm = _totalDistanceMeters > 0
        ? _totalDistanceMeters / 1000.0
        : (_intervalPlan.targetDistanceKm ?? 3.0);

    final avgPaceSec = (distanceKm > 0.05 && _totalElapsedSeconds > 0)
        ? (_totalElapsedSeconds / distanceKm).round()
        : null;

    final routeList = _routePoints.map((p) => [p.latitude, p.longitude]).toList();
    final routeJson = routeList.isNotEmpty ? jsonEncode(routeList) : null;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutFinishScreen(
          session: widget.session,
          runDistanceKm: double.parse(distanceKm.toStringAsFixed(2)),
          runDurationSeconds: _totalElapsedSeconds,
          avgPaceSeconds: avgPaceSec,
          routeJson: routeJson,
        ),
      ),
    );
  }

  String _formatTimer(int totalSecs) {
    final m = totalSecs ~/ 60;
    final s = totalSecs % 60;
    final h = m ~/ 60;
    if (h > 0) {
      final remM = m % 60;
      return '${h.toString().padLeft(2, '0')}:${remM.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _calculatePaceString() {
    // If running with accurate speed fix, show instant running pace
    if (!_isPaused && _instantSpeedMps != null && _instantSpeedMps! >= 0.8) {
      final instantSecPerKm = (1000.0 / _instantSpeedMps!).round();
      if (instantSecPerKm >= 140 && instantSecPerKm <= 900) {
        final m = instantSecPerKm ~/ 60;
        final s = instantSecPerKm % 60;
        return "$m'${s.toString().padLeft(2, '0')}\"";
      }
    }

    // Fallback to overall average pace
    return _calculateAvgPaceString();
  }

  String _calculateAvgPaceString() {
    final km = _totalDistanceMeters / 1000.0;
    if (km < 0.05 || _totalElapsedSeconds < 5) return "--'--\"";
    final secPerKm = (_totalElapsedSeconds / km).round();
    final m = secPerKm ~/ 60;
    final s = secPerKm % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  Widget _buildGpsStatusBadge(ThemeData theme) {
    Color badgeColor;
    String label;
    IconData icon;

    switch (_gpsStatus) {
      case GpsLockStatus.locked:
        badgeColor = AppColors.statusDone;
        label = _gpsAccuracyMeters != null ? 'GPS ±${_gpsAccuracyMeters!.round()}m' : 'GPS Lock';
        icon = PhosphorIconsFill.navigationArrow;
        break;
      case GpsLockStatus.searching:
        badgeColor = theme.colorScheme.primary;
        label = 'Acquiring GPS...';
        icon = PhosphorIconsBold.broadcast;
        break;
      case GpsLockStatus.disabled:
        badgeColor = AppColors.statusHard;
        label = 'GPS Off';
        icon = PhosphorIconsBold.warningCircle;
        break;
      case GpsLockStatus.denied:
        badgeColor = AppColors.statusHard;
        label = 'Permission Denied';
        icon = PhosphorIconsBold.warningCircle;
        break;
    }

    return InkWell(
      onTap: (_gpsStatus == GpsLockStatus.disabled || _gpsStatus == GpsLockStatus.denied)
          ? () => Geolocator.openLocationSettings()
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: badgeColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: badgeColor.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: badgeColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final currentPhase = (_intervalPlan.phases.isNotEmpty &&
            _currentPhaseIndex < _intervalPlan.phases.length)
        ? _intervalPlan.phases[_currentPhaseIndex]
        : null;

    final nextPhase = (_intervalPlan.phases.isNotEmpty &&
            _currentPhaseIndex < _intervalPlan.phases.length - 1)
        ? _intervalPlan.phases[_currentPhaseIndex + 1]
        : null;

    final distanceKm = _totalDistanceMeters / 1000.0;
    final LatLng initialCenter =
        _routePoints.isNotEmpty ? _routePoints.last : const LatLng(51.5074, -0.1278);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      PhosphorIconsBold.arrowLeft,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    onPressed: () => _confirmExit(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.session.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.session.type,
                          style: textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildGpsStatusBadge(theme),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Toggle Map',
                    icon: Icon(
                      _showMap
                          ? PhosphorIconsFill.mapTrifold
                          : PhosphorIconsRegular.mapTrifold,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _showMap = !_showMap;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Phase Indicator Banner (Run vs Walk)
            if (currentPhase != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: currentPhase.isRun
                        ? (isDark ? AppColors.darkPrimary.withOpacity(0.15) : AppColors.lightPrimary.withOpacity(0.2))
                        : (isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: currentPhase.isRun
                          ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: currentPhase.isRun
                              ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                              : Colors.grey.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          currentPhase.isRun
                              ? PhosphorIconsBold.personSimpleRun
                              : PhosphorIconsBold.personSimpleWalk,
                          color: currentPhase.isRun ? Colors.black : Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  currentPhase.title.toUpperCase(),
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                    color: currentPhase.isRun
                                        ? (isDark ? AppColors.darkPrimary : const Color(0xFF8B6800))
                                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatTimer(_currentPhaseRemainingSeconds),
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nextPhase != null
                                  ? 'Next: ${nextPhase.title} (${_formatTimer(nextPhase.durationSeconds)})'
                                  : 'Target: ${currentPhase.targetEffort}',
                              style: textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Skip phase',
                        icon: Icon(
                          PhosphorIconsBold.skipForward,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        onPressed: _skipInterval,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Map View or Big Number Layout
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    if (_showMap)
                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: initialCenter,
                                  initialZoom: 16.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.ali.fitness_app',
                                  ),
                                  if (_routePoints.length >= 2)
                                    PolylineLayer(
                                      polylines: [
                                        Polyline(
                                          points: _routePoints,
                                          strokeWidth: 5.0,
                                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                        ),
                                      ],
                                    ),
                                  if (_routePoints.isNotEmpty)
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: _routePoints.first,
                                          width: 24,
                                          height: 24,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.play_arrow, size: 14, color: Colors.white),
                                          ),
                                        ),
                                        Marker(
                                          point: _routePoints.last,
                                          width: 28,
                                          height: 28,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black26, blurRadius: 4),
                                              ],
                                            ),
                                            child: const Icon(Icons.navigation, size: 14, color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: FloatingActionButton.small(
                                  backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                  onPressed: () {
                                    if (_routePoints.isNotEmpty) {
                                      _mapController.move(_routePoints.last, 16.5);
                                    }
                                  },
                                  child: Icon(
                                    PhosphorIconsBold.crosshair,
                                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Big Number Metrics Grid
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Big Time Display
                            Column(
                              children: [
                                Text(
                                  'TIME',
                                  style: textTheme.labelSmall?.copyWith(
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                                Text(
                                  _formatTimer(_totalElapsedSeconds),
                                  style: textTheme.displayLarge?.copyWith(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w900,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                    color: isDark ? AppColors.darkText : AppColors.lightText,
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 1),

                            // Distance and Pace Row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'DISTANCE',
                                        style: textTheme.labelSmall?.copyWith(
                                          letterSpacing: 1.1,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            distanceKm.toStringAsFixed(2),
                                            style: textTheme.headlineMedium?.copyWith(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              fontFeatures: const [FontFeature.tabularFigures()],
                                              color: isDark ? AppColors.darkText : AppColors.lightText,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'km',
                                            style: textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 40,
                                  width: 1,
                                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        'PACE',
                                        style: textTheme.labelSmall?.copyWith(
                                          letterSpacing: 1.1,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                      Text(
                                        _calculatePaceString(),
                                        style: textTheme.headlineMedium?.copyWith(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          fontFeatures: const [FontFeature.tabularFigures()],
                                          color: isDark ? AppColors.darkText : AppColors.lightText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Controls Bar (Pause/Resume + Hold to Finish)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  // Pause / Resume Button
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: _togglePause,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          width: 1.5,
                        ),
                        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      ),
                      icon: Icon(
                        _isPaused
                            ? PhosphorIconsBold.play
                            : PhosphorIconsBold.pause,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                      label: Text(
                        _isPaused ? 'Resume' : 'Pause',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Hold to Finish Button (GestureDetector with progress indicator)
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onLongPressStart: (_) {
                        HapticFeedback.selectionClick();
                        _finishProgressController.forward();
                      },
                      onLongPressEnd: (details) {
                        if (_finishProgressController.isCompleted) {
                          _finishRun();
                        } else {
                          _finishProgressController.reverse();
                        }
                      },
                      child: AnimatedBuilder(
                        animation: _finishProgressController,
                        builder: (context, child) {
                          return Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Progress fill
                                Positioned.fill(
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _finishProgressController.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.stop_rounded,
                                      color: Color(0xFF1A1A17),
                                      size: 26,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _finishProgressController.value > 0.05
                                          ? 'Hold to Finish...'
                                          : 'Hold to Finish',
                                      style: textTheme.labelLarge?.copyWith(
                                        color: const Color(0xFF1A1A17),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Live Run?'),
        content: const Text('Are you sure you want to stop tracking? Your run will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
