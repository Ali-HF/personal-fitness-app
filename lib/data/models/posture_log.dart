class PostureLog {
  final String date; // YYYY-MM-DD
  final bool routineDone;
  final int minutes;

  const PostureLog({
    required this.date,
    required this.routineDone,
    this.minutes = 10,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'routine_done': routineDone ? 1 : 0,
      'minutes': minutes,
    };
  }

  factory PostureLog.fromMap(Map<String, dynamic> map) {
    return PostureLog(
      date: map['date'] as String,
      routineDone: (map['routine_done'] as int? ?? 0) == 1,
      minutes: map['minutes'] as int? ?? 10,
    );
  }
}

