import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/chat_provider.dart';
import '../../../services/voice_assistant_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/color_palette.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final VoiceAssistantService _voiceService = VoiceAssistantService();
  final FocusNode _focusNode = FocusNode();

  bool _isVoiceListening = false;
  bool _voiceAvailable = false;
  bool _ttsEnabled = false;

  // Ultra premium colors
  static const Color _accentPurple = AppPalette.primary;
  static const Color _accentTeal = AppPalette.secondary;
  static const Color _bgDark1 = AppPalette.backgroundDark;
  static const Color _bgDark2 = AppPalette.surfaceDark;
  static const Color _surfaceDark = AppPalette.cardDark;
  static const Color _userBubble = AppPalette.primary;
  static const Color _aiBubble = AppPalette.elevatedDark;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? _bgDark2 : AppPalette.cardLight,
                isDark ? _bgDark1 : AppPalette.surfaceLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _accentPurple.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: _accentPurple.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _accentPurple,
                          _accentPurple.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.key_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Gemini API Key",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Get your free key from Google AI Studio",
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 13,
                ),
              ),
              Text(
                "aistudio.google.com",
                style: GoogleFonts.inter(
                  color: _accentTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: keyController,
                  style: GoogleFonts.jetBrainsMono(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: "Paste your API key here...",
                    hintStyle: TextStyle(color: isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.4)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear_rounded,
                          color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3), size: 18),
                      onPressed: () => keyController.clear(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side:
                              BorderSide(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                        ),
                      ),
                      child: Text("Cancel",
                          style: GoogleFonts.inter(
                              color: isDark ? Colors.white54 : Colors.black54, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_accentPurple, _accentPurple.withBlue(255)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _accentPurple.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          if (keyController.text.trim().isEmpty) return;

                          await context
                              .read<ChatProvider>()
                              .setApiKey(keyController.text.trim());

                          if (!mounted) return;

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text('API Key saved successfully!',
                                      style: GoogleFonts.inter(color: Colors.white)),
                                ],
                              ),
                              backgroundColor: _accentTeal,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("Save Key",
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.copy_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text('Copied to clipboard', style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
          ],
        ),
        backgroundColor: isDark ? _surfaceDark : AppPalette.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _voiceService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentPurple, _accentTeal],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: _accentPurple.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Text("Study AI",
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        actions: [
          // TTS Toggle
          _buildAppBarAction(
            icon: _ttsEnabled
                ? Icons.volume_up_rounded
                : Icons.volume_off_rounded,
            color: _ttsEnabled ? _accentTeal : (isDark ? Colors.white38 : Colors.black54),
            tooltip: _ttsEnabled ? 'TTS On' : 'TTS Off',
            onPressed: () {
              setState(() {
                _ttsEnabled = !_ttsEnabled;
                _voiceService.setTtsEnabled(_ttsEnabled);
              });
            },
          ),
          _buildAppBarAction(
            icon: Icons.key_rounded,
            color: isDark ? Colors.white70 : Colors.black54,
            tooltip: 'Set API Key',
            onPressed: () => _showApiKeyDialog(context),
          ),
          _buildAppBarAction(
            icon: Icons.delete_sweep_rounded,
            color: isDark ? Colors.white70 : Colors.black54,
            tooltip: 'Clear Chat',
            onPressed: () => context.read<ChatProvider>().clearHistory(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [_bgDark1, _bgDark2]
                : [AppPalette.backgroundLight, AppPalette.surfaceLight],
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Messages ──
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    final messages = chatProvider.messages;
                    final isTyping = chatProvider.isTyping;

                    if (messages.isEmpty && !isTyping) {
                      return _buildEmptyState(isDark);
                    }

                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToBottom());

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && isTyping) {
                          return _buildTypingIndicator(isDark);
                        }
                        final msg = messages[index];
                        final isUser = msg['role'] == 'user';
                        return _buildMessageBubble(
                            msg['content']!, isUser, index, isDark);
                      },
                    );
                  },
                ),
              ),

              // ── Voice Listening Bar ──
              if (_isVoiceListening) _buildVoiceListeningBar(isDark),

              // ── Quick Suggestions ──
              if (!_isVoiceListening) _buildQuickSuggestions(isDark),

              // ── Input Area ──
              _buildInputArea(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser, int index, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentPurple, _accentTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _accentPurple.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
            ),
          ],
          // Message Content
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? _userBubble.withOpacity(0.25) 
                        : (isDark ? _aiBubble : AppPalette.cardLight),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isUser
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                    border: Border.all(
                      color: isUser
                          ? _userBubble.withOpacity(0.4)
                          : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? _accentPurple.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isUser
                      ? SelectableText(
                          content,
                          style: GoogleFonts.inter(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        )
                      : MarkdownBody(
                          data: content,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.inter(
                              color: isDark ? const Color(0xFFE2E8F0) : AppPalette.textPrimaryLight,
                              fontSize: 14,
                              height: 1.6,
                            ),
                            h1: GoogleFonts.outfit(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: GoogleFonts.outfit(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: GoogleFonts.outfit(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            strong: GoogleFonts.inter(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w700,
                            ),
                            em: GoogleFonts.inter(
                              color: isDark ? const Color(0xFFCBD5E1) : AppPalette.textSecondaryLight,
                              fontStyle: FontStyle.italic,
                            ),
                            code: GoogleFonts.jetBrainsMono(
                              color: _accentTeal,
                              backgroundColor: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                              fontSize: 13,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.1)),
                            ),
                            codeblockPadding: const EdgeInsets.all(14),
                            listBullet: const TextStyle(color: _accentTeal),
                            blockquote: GoogleFonts.inter(
                              color: isDark ? const Color(0xFF94A3B8) : AppPalette.textSecondaryLight,
                              fontStyle: FontStyle.italic,
                            ),
                            blockquoteDecoration: const BoxDecoration(
                              border: Border(
                                left:
                                    BorderSide(color: _accentPurple, width: 3),
                              ),
                            ),
                            blockquotePadding: const EdgeInsets.only(left: 12),
                          ),
                        ),
                ),
                // Copy button for AI messages
                if (!isUser)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: GestureDetector(
                      onTap: () => _copyToClipboard(content),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded,
                              size: 12, color: isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Text('Copy',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.4))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // User Avatar
          if (isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentPurple, _accentPurple.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_accentPurple, _accentTeal],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? _aiBubble : AppPalette.cardLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < 3; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _accentPurple.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .moveY(
                        begin: 0,
                        end: -6,
                        duration: 500.ms,
                        delay: (i * 150).ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .moveY(begin: -6, end: 0, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated AI Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentPurple, _accentTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _accentPurple.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .scale(
                  begin: const Offset(1.08, 1.08),
                  end: const Offset(1, 1),
                  duration: 2000.ms,
                ),
            const SizedBox(height: 24),
            Text(
              'Study AI Assistant',
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              'Your personal AI tutor powered by Gemini.\nAsk about study plans, exam prep, or any topic!',
              style: GoogleFonts.inter(
                color: isDark ? const Color(0xFF94A3B8) : AppPalette.textSecondaryLight,
                fontSize: 14,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 24),
            // Setup hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _accentPurple.withOpacity(0.15),
                    _accentTeal.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _accentPurple.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.key_rounded,
                      color: _accentPurple.withOpacity(0.8), size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Set your Gemini API key to get started',
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceListeningBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _accentPurple.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accentPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.mic, color: _accentPurple, size: 18)
              .animate(onPlay: (c) => c.repeat())
              .fadeOut(duration: 600.ms)
              .then()
              .fadeIn(duration: 600.ms),
          const SizedBox(width: 10),
          Text('Listening...',
              style: GoogleFonts.inter(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13)),
          const Spacer(),
          Text(_controller.text,
              style: GoogleFonts.inter(
                  color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6), fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, end: 0);
  }

  Widget _buildQuickSuggestions(bool isDark) {
    final suggestions = [
      {'emoji': '📋', 'text': 'Create a study plan'},
      {'emoji': '🧠', 'text': 'How to memorize faster'},
      {'emoji': '⏰', 'text': 'Best study hours'},
      {'emoji': '💡', 'text': 'Pomodoro technique'},
      {'emoji': '📊', 'text': 'Analyze my tasks'},
    ];

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final s = suggestions[index];
          return GestureDetector(
            onTap: () {
              _controller.text = s['text']!;
              final chatProvider = context.read<ChatProvider>();
              _sendMessage(chatProvider);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
                    isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s['emoji']!, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    s['text']!,
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? _bgDark1.withOpacity(0.8) : Colors.white.withOpacity(0.9),
        border: Border(
          top: BorderSide(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.08)),
        ),
      ),
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Voice Button
              if (_voiceAvailable) ...[
                GestureDetector(
                  onTap: () => _toggleVoice(chatProvider),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: _isVoiceListening
                          ? LinearGradient(colors: [_accentPurple, _accentTeal])
                          : null,
                      color: _isVoiceListening
                          ? null
                          : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isVoiceListening
                            ? _accentPurple.withOpacity(0.5)
                            : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.1)),
                      ),
                    ),
                    child: Icon(
                      _isVoiceListening
                          ? Icons.stop_rounded
                          : Icons.mic_rounded,
                      color: _isVoiceListening
                          ? Colors.white
                          : (isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5)),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Text Input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: GoogleFonts.inter(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: "Ask about your studies...",
                      hintStyle: GoogleFonts.inter(
                          color: isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.4), fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                    gradient: chatProvider.isTyping
                        ? null
                        : LinearGradient(
                            colors: [
                              _accentPurple,
                              _accentPurple.withBlue(255)
                            ],
                          ),
                    color: chatProvider.isTyping
                        ? (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.08))
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: chatProvider.isTyping
                        ? []
                        : [
                            BoxShadow(
                              color: _accentPurple.withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ],
                  ),
                  child: Icon(
                    chatProvider.isTyping
                        ? Icons.hourglass_empty_rounded
                        : Icons.send_rounded,
                    color: chatProvider.isTyping
                        ? (isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3))
                        : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
