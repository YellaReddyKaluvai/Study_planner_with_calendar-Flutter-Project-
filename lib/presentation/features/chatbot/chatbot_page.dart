import 'package:flutter/material.dart';
import '../../shared/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/chat_provider.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(ChatProvider chatProvider) {
    if (_controller.text.isEmpty) return;

    final tasks = context.read<TaskProvider>().tasks;
    chatProvider.sendMessage(_controller.text, tasks: tasks);
    _controller.clear();
  }

  void _showApiKeyDialog(BuildContext context) {
    final TextEditingController keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        title: const Text("Enter Gemini API Key",
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Get your key from Google AI Studio.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: keyController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Paste API Key here",
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (keyController.text.isNotEmpty) {
                context
                    .read<ChatProvider>()
                    .setApiKey(keyController.text.trim());
                Navigator.pop(context);
              }
            },
            child:
                const Text("Save", style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("AI Study Assistant"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.key, color: Colors.white),
            onPressed: () => _showApiKeyDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => context.read<ChatProvider>().clearHistory(),
          )
        ],
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
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    final messages = chatProvider.messages;
                    final isTyping = chatProvider.isTyping;

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && isTyping) {
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
                        final msg = messages[index];
                        final isUser = msg['role'] == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75),
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
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    Consumer<ChatProvider>(builder: (context, chatProvider, _) {
                  return Row(
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
                            onSubmitted: (_) => _sendMessage(chatProvider),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: AppTheme.primary),
                        onPressed: () => _sendMessage(chatProvider),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
