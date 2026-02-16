class StudySession {
  final String id;
  final DateTime date;
  final int minutes;
  final String subject;
  final String taskId;

  StudySession({
    required this.id,
    required this.date,
    required this.minutes,
    required this.subject,
    required this.taskId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'minutes': minutes,
        'subject': subject,
        'taskId': taskId,
      };

  factory StudySession.fromMap(Map<String, dynamic> map) => StudySession(
        id: map['id'],
        date: DateTime.parse(map['date']),
        minutes: map['minutes'],
        subject: map['subject'],
        taskId: map['taskId'],
      );
}
