import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;
  final Color color;
  final String type; // 'study', 'exam', 'assignment', 'other'
  final int priority;
  final String? preparationPlan;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    required this.color,
    this.type = 'study',
    this.priority = 2,
    this.preparationPlan,
  });

  bool get hasAiPlan => preparationPlan != null && preparationPlan!.isNotEmpty;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    Color? color,
    String? type,
    int? priority,
    String? preparationPlan,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      color: color ?? this.color,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      preparationPlan: preparationPlan ?? this.preparationPlan,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'color': color.value,
      'type': type,
      'preparationPlan': preparationPlan,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      isCompleted: map['isCompleted'] == 1,
      color: Color(map['color']),
      type: map['type'],
      preparationPlan: map['preparationPlan'],
    );
  }
}
