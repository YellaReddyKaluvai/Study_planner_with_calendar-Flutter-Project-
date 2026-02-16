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

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    required this.color,
    this.type = 'study',
    this.priority = 2, // 1: High, 2: Medium, 3: Low
  });

  final int priority;
}
