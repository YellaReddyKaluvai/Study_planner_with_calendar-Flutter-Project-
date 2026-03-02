import 'package:flutter/material.dart';
import '../../shared/glass_container.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/chat_provider.dart';
import '../../../../services/voice_assistant_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final VoiceAssistantService _voiceService = VoiceAssistantService();

  bool _isVoiceListening = false;
  bool _voiceAvailable = false;
  bool _ttsEnabled = false;

  @override
  void initState() {
    super.initState();
    _initVoice();
  }

  Future<void> _initVoice() async {
    final ok = await _voiceService.init();
    if (mounted) setState(() => _voiceAvailable = ok);
  }

  void _sendMessage(ChatProvider chatProvider) {
    if (_controller.text.trim().isEmpty) return;
    final tasks = context.read<TaskProvider>().tasks;
    chatProvider.sendMessage(_controller.text.trim(), tasks: tasks);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _toggleVoice(ChatProvider chatProvider) async {
    if (_isVoiceListening) {
      await _voiceService.stopListening();
      setState(() => _isVoiceListening = false);
      if (_controller.text.trim().isNotEmpty) {
        _sendMessage(chatProvider);
      }
    } else {
      setState(() => _isVoiceListening = true);
      await _voiceService.startListening((text) {
        if (mounted) {
          setState(() => _controller.text = text);
        }
      });
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Get your key from Google AI Studio (aistudio.google.com).",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: keyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Paste API Key here",
                hintStyle: const TextStyle(color: Colors.white38),
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                  onPressed: () => keyController.clear(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (keyController.text.isNotEmpty) {
                context.read<ChatProvider>().setApiKey(keyController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('API Key saved ✓'),
                    backgroundColor: Color(0xFF4CAF50),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text("Save", style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _voiceService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("AI Study Assistant",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // TTS Toggle
          IconButton(
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              color: _ttsEnabled ? AppTheme.primary : Colors.white54,
            ),
            tooltip: _ttsEnabled ? 'TTS On' : 'TTS Off',
            onPressed: () {
              setState(() {
                _ttsEnabled = !_ttsEnabled;
                _voiceService.setTtsEnabled(_ttsEnabled);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.key, color: Colors.white),
            tooltip: 'Set API Key',
            onPressed: () => _showApiKeyDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Clear Chat',
            onPressed: () => context.read<ChatProvider>().clearHistory(),
          ),
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
              // Message List
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    final messages = chatProvider.messages;
                    final isTyping = chatProvider.isTyping;

                    if (messages.isEmpty && !isTyping) {
                      return _buildEmptyState();
                    }

                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToBottom());

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && isTyping) {
                          return _buildTypingIndicator();
                        }
                        final msg = messages[index];
                        final isUser = msg['role'] == 'user';
                        return _buildMessageBubble(msg['content']!, isUser, index);
                      },
                    );
                  },
                ),
              ),

              // Voice listening indicator
              if (_isVoiceListening)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: AppTheme.primary, size: 16)
                          .animate(onPlay: (c) => c.repeat())
                          .fadeOut(duration: 600.ms)
                          .then()
                          .fadeIn(duration: 600.ms),
                      const SizedBox(width: 8),
                      const Text('Listening...',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const Spacer(),
                      Text(_controller.text,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.8), fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.3, end: 0),

              // Suggest quick questions
              if (!_isVoiceListening)
                _buildQuickSuggestions(),

              // Input Row
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, _) {
                    return Row(
                      children: [
                        // Voice Button
                        if (_voiceAvailable)
                          GestureDetector(
                            onTap: () => _toggleVoice(chatProvider),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: _isVoiceListening
                                    ? AppTheme.primary
                                    : Colors.white10,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isVoiceListening ? Icons.stop : Icons.mic,
                                color: _isVoiceListening
                                    ? Colors.black
                                    : Colors.white70,
                                size: 20,
                              ),
                            ),
                          ),
                        if (_voiceAvailable) const SizedBox(width: 8),

                        // Message Input
                        Expanded(
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              maxLines: 3,
                              minLines: 1,
                              textInputAction: TextInputAction.send,
                              decoration: const InputDecoration(
                                hintText: "Ask anything about your studies...",
                                hintStyle: TextStyle(
                                    color: Colors.white38, fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onSubmitted: (_) => _sendMessage(chatProvider),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Send Button
                        GestureDetector(
                          onTap: chatProvider.isTyping
                              ? null
                              : () => _sendMessage(chatProvider),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: chatProvider.isTyping
                                  ? Colors.white12
                                  : AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              chatProvider.isTyping
                                  ? Icons.hourglass_empty
                                  : Icons.send_rounded,
                              color: chatProvider.isTyping
                                  ? Colors.white38
                                  : Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser, int index) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isUser
              ? AppTheme.primary.withOpacity(0.25)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft:
                isUser ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight:
                isUser ? const Radius.circular(4) : const Radius.circular(18),
          ),
          border: Border.all(
              color: isUser
                  ? AppTheme.primary.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1)),
        ),
        child: SelectableText(
          content,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 20).ms)
        .slideX(
          begin: isUser ? 0.3 : -0.3,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 3; i++)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                    color: Colors.white54, shape: BoxShape.circle),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .moveY(
                    begin: 0,
                    end: -5,
                    duration: 600.ms,
                    delay: (i * 200).ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .moveY(begin: -5, end: 0, duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 64)
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          const Text(
            'AI Study Assistant',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about your studies!\nI can help with plans, summaries, and more.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 12),
          const Text(
            '⚡ Set your Gemini API key first',
            style: TextStyle(
                color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w500),
          ).animate().fadeIn(delay: 700.ms),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions = [
      '📋 Suggest a study plan',
      '🧠 How to memorize faster?',
      '⏰ Best study hours?',
      '💡 Pomodoro technique?',
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _controller.text = suggestions[index]
                  .replaceAll(RegExp(r'^[\p{Emoji}\s]+', unicode: true), '')
                  .trim();
              final chatProvider =
                  context.read<ChatProvider>();
              _sendMessage(chatProvider);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Text(
                suggestions[index],
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
