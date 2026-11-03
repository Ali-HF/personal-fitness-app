class BodyLog {
  final String date; // YYYY-MM-DD
  final double? weightKg;
  final double? waistCm;
  final String? photoPath;
  final String? note;

  const BodyLog({
    required this.date,
    this.weightKg,
    this.waistCm,
    this.photoPath,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'weight_kg': weightKg,
      'waist_cm': waistCm,
      'photo_path': photoPath,
      'note': note,
    };
  }

  factory BodyLog.fromMap(Map<String, dynamic> map) {
    return BodyLog(
      date: map['date'] as String,
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      waistCm: (map['waist_cm'] as num?)?.toDouble(),
      photoPath: map['photo_path'] as String?,
      note: map['note'] as String?,
    );
  }
}

