class MoodModel {
  final String id;
  final String userId;
  final String moodEmoji;
  final String moodLabel;
  final String? note;
  final DateTime createdAt;

  MoodModel({
    required this.id,
    required this.userId,
    required this.moodEmoji,
    required this.moodLabel,
    this.note,
    required this.createdAt,
  });

  factory MoodModel.fromMap(Map<String, dynamic> map) {
    return MoodModel(
      id: map['id'],
      userId: map['user_id'],
      moodEmoji: map['mood_emoji'],
      moodLabel: map['mood_label'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'mood_emoji': moodEmoji,
      'mood_label': moodLabel,
      'note': note,
    };
  }
}
