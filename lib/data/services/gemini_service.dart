import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // TODO: Replace with a secure way to retrieve API Key (e.g. --dart-define)
  static const String _apiKey = 'YOUR_API_KEY';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
  }

  Future<String> chat(String message) async {
    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      return response.text ??
          "I'm having trouble thinking right now. Try again later.";
    } catch (e) {
      return "Error connecting to AI: $e. (Did you set the API Key?)";
    }
  }

  Stream<String> streamChat(String message) async* {
    try {
      final content = [Content.text(message)];
      final response = _model.generateContentStream(content);
      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      yield "Error: $e";
    }
  }
}
