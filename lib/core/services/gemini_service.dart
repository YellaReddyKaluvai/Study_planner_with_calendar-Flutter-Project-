import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/task.dart';
import '../data/database_helper.dart';

class GeminiService {
  static const String _apiKeyKey = 'gemini_api_key';

  // Cache the model to reuse the session if possible,
  // though typically we might want to recreate it if key changes.
  GenerativeModel? _model;
  ChatSession? _chat;

  // We'll init this on first use or when key is provided
  Future<void> _init() async {
    final apiKey = await DatabaseHelper.instance.getSetting(_apiKeyKey);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("API Key not found. Please set it in settings.");
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      ],
    );
    _chat = _model!.startChat();
  }

  Future<void> setApiKey(String key) async {
    await DatabaseHelper.instance.saveSetting(_apiKeyKey, key);
    // Force re-init next time
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
        I have a task: "${task.title}"
        Description: "${task.description}"
        Type: "${task.type}"
        Duration: ${task.endTime.difference(task.startTime).inMinutes} minutes.
        
        Please provide a concise, step-by-step preparation plan for this task. 
        Focus on efficiency and effectiveness.
        Format the response as clear bullet points.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ?? "Could not generate a plan. Please try again.";
    } catch (e) {
      return "Error generating plan: $e.";
    }
  }

  Future<String> chat(String message, {List<Task>? tasks}) async {
    try {
      if (_model == null) await _init();

      String fullMessage = message;

      if (tasks != null && tasks.isNotEmpty) {
        final taskList = tasks.map((t) {
          String details =
              "- ${t.title} (Due: ${t.endTime})\n  Description: ${t.description}";
          if (t.hasAiPlan) {
            details += "\n  Existing Plan: ${t.preparationPlan}";
          }
          return details;
        }).join("\n");

        fullMessage = '''
Context: Detailed list of my current tasks:
$taskList

User Query: $message
''';
      }

      final response = await _chat!.sendMessage(Content.text(fullMessage));
      return response.text ?? "I didn't understand that.";
    } catch (e) {
      // Re-throw if it's an API key issue so the UI can handle it
      if (e.toString().contains("API Key") ||
          e.toString().contains("API_KEY_INVALID")) {
        throw Exception("API Key Missing or Invalid");
      }
      return "Error: $e";
    }
  }
}
