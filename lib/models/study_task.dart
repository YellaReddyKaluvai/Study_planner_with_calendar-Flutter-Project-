import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskDifficulty { easy, medium, hard }

class StudyTask {
  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final int estimatedMinutes;
  final TaskDifficulty difficulty;
  final bool isCompleted;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;

  StudyTask({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.estimatedMinutes,
    this.difficulty = TaskDifficulty.medium,
    this.isCompleted = false,
    this.scheduledStart,
    this.scheduledEnd,
  });

  StudyTask copyWith({
    String? id,
    String? title,
    String? subject,
    DateTime? dueDate,
    int? estimatedMinutes,
    TaskDifficulty? difficulty,
    bool? isCompleted,
    DateTime? scheduledStart,
    DateTime? scheduledEnd,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      dueDate: dueDate ?? this.dueDate,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subject': subject,
        'dueDate': Timestamp.fromDate(dueDate),
        'estimatedMinutes': estimatedMinutes,
        'difficulty': difficulty.index,
        'isCompleted': isCompleted,
        'scheduledStart':
            scheduledStart != null ? Timestamp.fromDate(scheduledStart!) : null,
        'scheduledEnd':
            scheduledEnd != null ? Timestamp.fromDate(scheduledEnd!) : null,
      };

  factory StudyTask.fromMap(Map<String, dynamic> map) => StudyTask(
        id: map['id'] as String,
        title: map['title'] as String,
        subject: map['subject'] as String,
        dueDate: (map['dueDate'] as Timestamp).toDate(),
        estimatedMinutes: map['estimatedMinutes'] as int,
        difficulty: TaskDifficulty.values[map['difficulty'] as int],
        isCompleted: map['isCompleted'] as bool,
        scheduledStart: map['scheduledStart'] != null
            ? (map['scheduledStart'] as Timestamp).toDate()
            : null,
        scheduledEnd: map['scheduledEnd'] != null
            ? (map['scheduledEnd'] as Timestamp).toDate()
            : null,
      );
}
