import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/task.dart';
import '../data/database_helper.dart';

class GeminiService {
  static const String _apiKeyKey = 'gemini_api_key';

  GenerativeModel? _model;
  ChatSession? _chat;

  // System instruction for the AI study assistant
  static const String _systemInstruction = '''
You are an intelligent, friendly AI Study Assistant built into a Study Planner app.
Your role is to help students study more effectively. You should:

1. **Study Planning**: Create detailed, actionable study plans tailored to the student's tasks, deadlines, and goals.
2. **Memorization Techniques**: Suggest proven techniques like spaced repetition, active recall, mnemonics, and mind maps.
3. **Time Management**: Recommend optimal study schedules, break patterns (like Pomodoro), and prioritization strategies.
4. **Subject Help**: Explain concepts, summarize topics, and create practice questions when asked.
5. **Motivation**: Encourage students, celebrate their progress, and help them overcome procrastination.
6. **Task Analysis**: When provided with the student's task list, analyze their workload, suggest priorities, and identify potential conflicts.

Guidelines:
- Be concise but thorough. Use bullet points, numbered lists, and headers for clarity.
- Use emojis sparingly to keep responses friendly (📚, ✅, 🧠, ⏰, 💡).
- If the student shares their tasks, reference them by name in your advice.
- Always provide actionable, practical advice.
- Format responses in Markdown for better readability.
- When creating study plans, include specific time blocks and break periods.
''';

  Future<void> _init() async {
    final apiKey = await DatabaseHelper.instance.getSetting(_apiKeyKey);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API Key not found. Please set it in settings.");
    }

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      systemInstruction: Content.text(_systemInstruction),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      ],
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.9,
        topK: 40,
        maxOutputTokens: 2048,
      ),
    );
    _chat = _model!.startChat();
  }

  Future<void> setApiKey(String key) async {
    await DatabaseHelper.instance.saveSetting(_apiKeyKey, key);
    _model = null;
    _chat = null;
  }

  Future<String?> getApiKey() async {
    return await DatabaseHelper.instance.getSetting(_apiKeyKey);
  }

  Future<String> generatePreparationPlan(Task task) async {
    try {
      if (_model == null) await _init();

      final prompt = '''
Create a concise preparation plan for this study task:

📋 **Task**: "${task.title}"
📝 **Description**: "${task.description}"
📂 **Type**: "${task.type}"
⏱️ **Duration**: ${task.endTime.difference(task.startTime).inMinutes} minutes

Please provide:
1. A step-by-step preparation plan
2. Key focus areas
3. Recommended study techniques for this type of task
4. A suggested timeline within the duration
      ''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ?? "Could not generate a plan. Please try again.";
    } catch (e) {
      if (e.toString().contains("API Key") ||
          e.toString().contains("API_KEY_INVALID")) {
        return "⚠️ API Key is invalid. Please update your Gemini API key in settings.";
      }
      return "Error generating plan: $e";
    }
  }

  Future<String> chat(String message, {List<Task>? tasks}) async {
    try {
      if (_model == null) await _init();

      String fullMessage = _buildContextualMessage(message, tasks);

      final response = await _chat!.sendMessage(Content.text(fullMessage));
      return response.text ?? "I didn't understand that. Could you rephrase?";
    } catch (e) {
      if (e.toString().contains("API Key") ||
          e.toString().contains("API_KEY_INVALID")) {
        throw Exception("API Key Missing or Invalid");
      }
      return "I'm having trouble connecting right now. Please check your internet connection and try again.";
    }
  }

  Stream<String> chatStream(String message, {List<Task>? tasks}) async* {
    try {
      final currentKey = await DatabaseHelper.instance.getSetting(_apiKeyKey);
      if (currentKey == null || currentKey.isEmpty) {
        throw Exception(
            "Please set your Gemini API key first. Tap the 🔑 icon in the top right.");
      }

      if (_model == null) {
        await _init();
      }

      String fullMessage = _buildContextualMessage(message, tasks);

      final stream = _chat!.sendMessageStream(Content.text(fullMessage));

      await for (final chunk in stream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      if (e.toString().contains("API Key") ||
          e.toString().contains("API_KEY_INVALID")) {
        throw Exception(
            "Your API key seems invalid. Please update it by tapping the 🔑 icon.");
      }
      if (e.toString().contains("SocketException") ||
          e.toString().contains("network")) {
        yield "📡 Network error. Please check your internet connection and try again.";
      } else {
        yield "⚠️ Something went wrong: ${e.toString().replaceAll('Exception: ', '')}";
      }
    }
  }

  String _buildContextualMessage(String message, List<Task>? tasks) {
    if (tasks == null || tasks.isEmpty) return message;

    final now = DateTime.now();
    final upcoming = tasks
        .where((t) => !t.isCompleted && t.endTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final completed = tasks.where((t) => t.isCompleted).toList();

    final buffer = StringBuffer();
    buffer.writeln('Here is the context of my current study tasks:');
    buffer.writeln();

    if (upcoming.isNotEmpty) {
      buffer.writeln('📋 **Upcoming Tasks** (${upcoming.length}):');
      for (final t in upcoming) {
        buffer.writeln(
            '- ${t.title} | Type: ${t.type} | Due: ${t.endTime} | Priority: ${t.priority}');
        if (t.description.isNotEmpty) {
          buffer.writeln('  Description: ${t.description}');
        }
      }
      buffer.writeln();
    }

    if (completed.isNotEmpty) {
      buffer.writeln('✅ **Completed** (${completed.length}):');
      for (final t in completed.take(5)) {
        buffer.writeln('- ${t.title}');
      }
      buffer.writeln();
    }

    buffer.writeln('**My question**: $message');
    return buffer.toString();
  }
}
