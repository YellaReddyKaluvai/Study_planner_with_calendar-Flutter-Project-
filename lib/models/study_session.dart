/// Represents a single focused study session with enhanced tracking
class StudySession {
  final String id;
  final DateTime date;
  final int minutes;
  final String subject;
  final String taskId;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? notes;
  final int? tasksCompleted;
  final double focusQuality; // 0.0 to 1.0

  StudySession({
    required this.id,
    required this.date,
    required this.minutes,
    required this.subject,
    required this.taskId,
    this.startTime,
    this.endTime,
    this.notes,
    this.tasksCompleted,
    this.focusQuality = 0.85,
  });

  // Convenience getter for durationMinutes (same as minutes)
  int get durationMinutes => minutes;

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'minutes': minutes,
        'subject': subject,
        'taskId': taskId,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'notes': notes,
        'tasksCompleted': tasksCompleted,
        'focusQuality': focusQuality,
      };

  Map<String, dynamic> toJson() => toMap();

  factory StudySession.fromMap(Map<String, dynamic> map) => StudySession(
        id: map['id'],
        date: DateTime.parse(map['date']),
        minutes: map['minutes'],
        subject: map['subject'],
        taskId: map['taskId'],
        startTime:
            map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
        endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
        notes: map['notes'],
        tasksCompleted: map['tasksCompleted'],
        focusQuality: (map['focusQuality'] as num?)?.toDouble() ?? 0.85,
      );

  factory StudySession.fromJson(Map<String, dynamic> json) =>
      StudySession.fromMap(json);

  StudySession copyWith({
    String? id,
    DateTime? date,
    int? minutes,
    String? subject,
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    int? tasksCompleted,
    double? focusQuality,
  }) =>
      StudySession(
        id: id ?? this.id,
        date: date ?? this.date,
        minutes: minutes ?? this.minutes,
        subject: subject ?? this.subject,
        taskId: taskId ?? this.taskId,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        notes: notes ?? this.notes,
        tasksCompleted: tasksCompleted ?? this.tasksCompleted,
        focusQuality: focusQuality ?? this.focusQuality,
      );
}
