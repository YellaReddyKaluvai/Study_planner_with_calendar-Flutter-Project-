import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistantService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  Future<bool> init() async {
    return _speech.initialize();
  }

  Future<String?> listenOnce() async {
    String? resultText;
    await _speech.listen(onResult: (result) {
      resultText = result.recognizedWords;
    });
    await Future.delayed(const Duration(seconds: 4));
    await _speech.stop();
    return resultText;
  }

  Future<void> speak(String text) async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }
}
