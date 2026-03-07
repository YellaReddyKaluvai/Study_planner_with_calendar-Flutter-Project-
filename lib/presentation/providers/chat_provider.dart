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
      _messages = [
        {
          'id': 'welcome',
          'role': 'ai',
          'content':
              '👋 Hi there! I\'m your **AI Study Assistant** powered by Gemini.\n\n'
                  'I can help you with:\n'
                  '- 📋 Creating personalized study plans\n'
                  '- 🧠 Memorization techniques & tips\n'
                  '- ⏰ Time management strategies\n'
                  '- 📊 Analyzing your tasks & priorities\n'
                  '- 💡 Explaining any topic or concept\n\n'
                  '> **Tip**: Set your Gemini API key using the 🔑 icon above to get started!',
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

    final String aiMsgId = const Uuid().v4();

    try {
      final stream = _geminiService.chatStream(text, tasks: tasks);

      final aiMsg = {
        'id': aiMsgId,
        'role': 'ai',
        'content': '',
        'timestamp': DateTime.now().toIso8601String(),
      };
      _messages.add(aiMsg);

      await for (final chunk in stream) {
        final msgIndex = _messages.indexWhere((m) => m['id'] == aiMsgId);
        if (msgIndex != -1) {
          _messages[msgIndex]['content'] += chunk;
          notifyListeners();
        }
      }

      // Save after stream completes
      final finalMsgIndex = _messages.indexWhere((m) => m['id'] == aiMsgId);
      if (finalMsgIndex != -1) {
        await DatabaseHelper.instance.saveMessage(_messages[finalMsgIndex]);
      }
    } catch (e) {
      // Remove empty placeholder
      final msgIndex = _messages.indexWhere((m) => m['id'] == aiMsgId);
      if (msgIndex != -1 && _messages[msgIndex]['content'].isEmpty) {
        _messages.removeAt(msgIndex);
      }

      // User-friendly error message
      String errorContent;
      final errorStr = e.toString();
      if (errorStr.contains('API Key') || errorStr.contains('API_KEY')) {
        errorContent = '🔑 **API Key Required**\n\n'
            'Please set your Gemini API key to start chatting:\n'
            '1. Tap the 🔑 icon in the top right\n'
            '2. Get a free key from [aistudio.google.com](https://aistudio.google.com)\n'
            '3. Paste your key and save\n\n'
            '> It only takes 30 seconds!';
      } else if (errorStr.contains('network') ||
          errorStr.contains('SocketException')) {
        errorContent = '📡 **Connection Error**\n\n'
            'Unable to reach the AI service. Please check your internet connection and try again.';
      } else {
        errorContent = '⚠️ **Something went wrong**\n\n'
            '${errorStr.replaceAll('Exception: ', '')}\n\n'
            'Please try again in a moment.';
      }

      final errorMsg = {
        'id': const Uuid().v4(),
        'role': 'ai',
        'content': errorContent,
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
        'content': '👋 Chat cleared! I\'m ready to help with your studies.\n\n'
            'Ask me anything — study plans, exam tips, or concept explanations!',
        'timestamp': DateTime.now().toIso8601String(),
      }
    ];
    notifyListeners();
    await DatabaseHelper.instance.clearChatHistory();
  }

  Future<void> setApiKey(String key) async {
    await _geminiService.setApiKey(key);

    final msg = {
      'id': const Uuid().v4(),
      'role': 'ai',
      'content': '✅ **API Key Saved!**\n\n'
          'I\'m now connected and ready to help. Try asking me:\n'
          '- "Create a study plan for my upcoming tasks"\n'
          '- "How should I prepare for a math exam?"\n'
          '- "Explain the Pomodoro technique"',
      'timestamp': DateTime.now().toIso8601String(),
    };
    _messages.add(msg);
    notifyListeners();
  }
}
