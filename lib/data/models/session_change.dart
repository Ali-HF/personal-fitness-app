class SessionChange {
  final String date; // YYYY-MM-DD
  final String originalSessionId;
  final String? replacementSessionId;
  final String? replacementType;
  final bool isSkipped;
  final String? reason;
  final DateTime createdAt;

  SessionChange({
    required this.date,
    required this.originalSessionId,
    this.replacementSessionId,
    this.replacementType,
    this.isSkipped = false,
    this.reason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'original_session_id': originalSessionId,
      'replacement_session_id': replacementSessionId,
      'replacement_type': replacementType,
      'is_skipped': isSkipped ? 1 : 0,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SessionChange.fromMap(Map<String, dynamic> map) {
    return SessionChange(
      date: map['date'] as String,
      originalSessionId: map['original_session_id'] as String,
      replacementSessionId: map['replacement_session_id'] as String?,
      replacementType: map['replacement_type'] as String?,
      isSkipped: (map['is_skipped'] as int? ?? 0) == 1,
      reason: map['reason'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

