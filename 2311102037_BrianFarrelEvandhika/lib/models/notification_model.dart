class NotificationLog {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final String type; // 'create' | 'update' | 'delete' | 'complete'

  NotificationLog({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory NotificationLog.fromJson(Map<String, dynamic> json) {
    return NotificationLog(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
    );
  }
}
