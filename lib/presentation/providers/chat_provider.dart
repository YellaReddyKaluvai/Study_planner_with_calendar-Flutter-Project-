import 'package:flutter/material.dart';
import '../../core/data/database_helper.dart';
import '../../core/services/gemini_service.dart';
import '../../domain/entities/task.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  final GeminiService _geminiService = GeminiService();

  List<Map<String, dynamic>> get messages => _messages;
  bool get isTyping => _isTyping;

  ChatProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await DatabaseHelper.instance.getChatHistory();
    if (history.isNotEmpty) {
      _messages = List<Map<String, dynamic>>.from(history);
    } else {
      // Default welcome message if empty
      _messages = [
        {
          'id': 'welcome',
          'role': 'ai',
          'content':
              'Hello! I am your AI study assistant (Powered by Gemini). How can I help you focus today?',
          'timestamp': DateTime.now().toIso8601String(),
        }
      ];
    }
    notifyListeners();
  }

  Future<void> sendMessage(String text, {List<Task>? tasks}) async {
    final userMsg = {
      'id': const Uuid().v4(),
      'role': 'user',
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _messages.add(userMsg);
    notifyListeners();
    await DatabaseHelper.instance.saveMessage(userMsg);

    _isTyping = true;
    notifyListeners();

    try {
      final response = await _geminiService.chat(text, tasks: tasks);

      final aiMsg = {
        'id': const Uuid().v4(),
        'role': 'ai',
        'content': response,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _messages.add(aiMsg);
      await DatabaseHelper.instance.saveMessage(aiMsg);
    } catch (e) {
      // If error, add error message but don't persist it as "history" effectively,
      // or maybe we DO persist it so the user sees the error history?
      // For now, let's show it in UI.
      final errorMsg = {
        'id': const Uuid().v4(),
        'role': 'ai',
        'content': "Error: ${e.toString()}",
        'timestamp': DateTime.now().toIso8601String(),
      };
      _messages.add(errorMsg);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    _messages.clear();
    _messages = [
      {
        'id': 'welcome',
        'role': 'ai',
        'content':
            'Hello! I am your AI study assistant (Powered by Gemini). How can I help you focus today?',
        'timestamp': DateTime.now().toIso8601String(),
      }
    ];
    notifyListeners();
    await DatabaseHelper.instance.clearChatHistory();
  }

  Future<void> setApiKey(String key) async {
    await _geminiService.setApiKey(key);
    // Maybe send a system message saying "API Key updated!"
  }
}
