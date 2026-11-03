class Exercise {
  final String id;
  final String name;
  final String pattern;
  final String target;
  final int defaultSets;
  final int defaultReps;
  final double defaultWeightKg;
  final List<String> regressions;
  final List<String> progressions;
  final String? cues;

  const Exercise({
    required this.id,
    required this.name,
    required this.pattern,
    required this.target,
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.defaultWeightKg = 0.0,
    this.regressions = const [],
    this.progressions = const [],
    this.cues,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      pattern: json['pattern'] as String? ?? 'General',
      target: json['target'] as String? ?? '',
      defaultSets: json['defaultSets'] as int? ?? 3,
      defaultReps: json['defaultReps'] as int? ?? 10,
      defaultWeightKg: (json['defaultWeightKg'] as num?)?.toDouble() ?? 0.0,
      regressions: (json['regressions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      progressions: (json['progressions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      cues: json['cues'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pattern': pattern,
      'target': target,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'defaultWeightKg': defaultWeightKg,
      'regressions': regressions,
      'progressions': progressions,
      'cues': cues,
    };
  }
}

