import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../domain/entities/task.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class QrService {
  static final QrService _instance = QrService._internal();
  factory QrService() => _instance;
  QrService._internal();

  /// Encodes a task to a JSON string for QR generation
  String encodeTask(Task task) {
    return jsonEncode({
      'title': task.title,
      'description': task.description,
      'startTime': task.startTime.toIso8601String(),
      'endTime': task.endTime.toIso8601String(),
      'type': task.type,
      'priority': task.priority,
    });
  }

  /// Parses a scanned QR barcode value into a Task (or returns null if invalid)
  Task? parseTaskFromQr(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return Task(
        id: const Uuid().v4(),
        title: map['title'] as String? ?? 'Scanned Task',
        description: map['description'] as String? ?? '',
        startTime: map['startTime'] != null
            ? DateTime.parse(map['startTime'] as String)
            : DateTime.now(),
        endTime: map['endTime'] != null
            ? DateTime.parse(map['endTime'] as String)
            : DateTime.now().add(const Duration(hours: 1)),
        color: const Color(0xFF6366F1),
        type: map['type'] as String? ?? 'study',
        priority: (map['priority'] as int?) ?? 2,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns the raw string value from a [BarcodeCapture]
  String? extractValue(BarcodeCapture capture) {
    return capture.barcodes.firstOrNull?.rawValue;
  }
}
