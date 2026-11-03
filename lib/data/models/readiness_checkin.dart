class ReadinessCheckIn {
  final String date; // YYYY-MM-DD
  final double sleepHours;
  final int legSoreness; // 0-10
  final String pain; // none, mild, sharp
  final int stress; // 1-5
  final String? note;
  final String? suggestion; // Generated recommendation from rules

  const ReadinessCheckIn({
    required this.date,
    required this.sleepHours,
    required this.legSoreness,
    required this.pain,
    required this.stress,
    this.note,
    this.suggestion,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'sleep_hours': sleepHours,
      'leg_soreness': legSoreness,
      'pain': pain,
      'stress': stress,
      'note': note,
      'suggestion': suggestion,
    };
  }

  factory ReadinessCheckIn.fromMap(Map<String, dynamic> map) {
    return ReadinessCheckIn(
      date: map['date'] as String,
      sleepHours: (map['sleep_hours'] as num).toDouble(),
      legSoreness: map['leg_soreness'] as int,
      pain: map['pain'] as String,
      stress: map['stress'] as int,
      note: map['note'] as String?,
      suggestion: map['suggestion'] as String?,
    );
  }
}

