class PlannedSession {
  final String id;
  final String date; // YYYY-MM-DD
  final int weekNumber;
  final String type; // UA, UB, UC, LEG_A, LEG_B, RW, EASY, INT, TEMPO, LONG, TEST5K, SHAKE, MOB, REST, RACE, FINALS_MINI
  final String title;
  final String category; // strength, run, mobility, rest, race
  final bool isHard;
  final double? distanceKm;
  final int? durationMinutes;
  final int? estimatedMinutes;
  final List<String> details;
  final List<String> exerciseIds;

  const PlannedSession({
    required this.id,
    required this.date,
    required this.weekNumber,
    required this.type,
    required this.title,
    required this.category,
    required this.isHard,
    this.distanceKm,
    this.durationMinutes,
    this.estimatedMinutes,
    this.details = const [],
    this.exerciseIds = const [],
  });

  factory PlannedSession.fromJson(Map<String, dynamic> json) {
    return PlannedSession(
      id: json['id'] as String? ?? 's_${json['date']}',
      date: json['date'] as String,
      weekNumber: json['week'] as int? ?? 1,
      type: json['type'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'general',
      isHard: json['isHard'] as bool? ?? false,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      durationMinutes: json['durationMinutes'] as int?,
      estimatedMinutes: json['estimatedMinutes'] as int?,
      details: (json['details'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      exerciseIds: (json['exerciseIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'week': weekNumber,
      'type': type,
      'title': title,
      'category': category,
      'isHard': isHard,
      if (distanceKm != null) 'distanceKm': distanceKm,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
      if (estimatedMinutes != null) 'estimatedMinutes': estimatedMinutes,
      'details': details,
      'exerciseIds': exerciseIds,
    };
  }

  PlannedSession copyWith({
    String? id,
    String? date,
    int? weekNumber,
    String? type,
    String? title,
    String? category,
    bool? isHard,
    double? distanceKm,
    int? durationMinutes,
    int? estimatedMinutes,
    List<String>? details,
    List<String>? exerciseIds,
  }) {
    return PlannedSession(
      id: id ?? this.id,
      date: date ?? this.date,
      weekNumber: weekNumber ?? this.weekNumber,
      type: type ?? this.type,
      title: title ?? this.title,
      category: category ?? this.category,
      isHard: isHard ?? this.isHard,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      details: details ?? this.details,
      exerciseIds: exerciseIds ?? this.exerciseIds,
    );
  }
}
