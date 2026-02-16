import 'package:flutter/material.dart';
import '../../shared/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/gemini_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'ai',
      'content':
          'Hello! I am your AI study assistant (Powered by Gemini). How can I help you focus today?'
    }
  ];
  bool _isTyping = false;
  final GeminiService _geminiService = GeminiService();

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMsg = _controller.text;
    setState(() {
      _messages.add({'role': 'user', 'content': userMsg});
      _controller.clear();
      _isTyping = true;
    });

    try {
      final aiResponse = await _geminiService.chat(userMsg);
      if (!mounted) return;

      // Simple check to see if we got an error message back (mocking the service error handling)
      if (aiResponse.startsWith("Error") || aiResponse.contains("API Key")) {
        throw Exception("API Error");
      }

      setState(() {
        _isTyping = false;
        _messages.add({'role': 'ai', 'content': aiResponse});
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        // Fallback to local mock for demo purposes
        _messages.add({'role': 'ai', 'content': _getMockResponse(userMsg)});
      });
    }
  }

  String _getMockResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains("plan") || lower.contains("schedule")) {
      return "I can help you plan! Try using the Calendar tab to block out time for your subjects.";
    } else if (lower.contains("hello") || lower.contains("hi")) {
      return "Hello! I'm your Study Assistant. I'm running in offline mode, but I can still help you stay focused!";
    } else if (lower.contains("tired") || lower.contains("break")) {
      return "You seem tired. Why not play a quick game of 2048 or Snake to recharge?";
    } else if (lower.contains("exam") || lower.contains("test")) {
      return "Good luck with your exams! Remember to take regular breaks and drink water.";
    } else {
      return "That sounds important. Break it down into smaller tasks and tackle them one by one!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("AI Study Assistant"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E17), Color(0xFF161B28)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text("Typing...",
                              style: TextStyle(color: Colors.white70)),
                        ),
                      );
                    }
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppTheme.primary.withOpacity(0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isUser
                                ? const Radius.circular(16)
                                : Radius.zero,
                            bottomRight: isUser
                                ? Radius.zero
                                : const Radius.circular(16),
                          ),
                          border: Border.all(
                              color: isUser
                                  ? AppTheme.primary.withOpacity(0.5)
                                  : Colors.white12),
                        ),
                        child: Text(msg['content']!,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Ask me anything...",
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppTheme.primary),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
