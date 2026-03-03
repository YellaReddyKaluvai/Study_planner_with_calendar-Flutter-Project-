import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Voice Assistant Service
/// TTS (Text-to-Speech) is fully functional.
/// STT (Speech-to-Text) is disabled due to speech_to_text plugin incompatibility
/// with Kotlin 2.x — it will be re-enabled once the plugin releases a compatible version.
class VoiceAssistantService {
  final FlutterTts _tts = FlutterTts();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _ttsEnabled = true;

  bool get isListening => _isListening;
  bool get ttsEnabled => _ttsEnabled;
  bool get sttAvailable => false; // STT disabled - see class docstring

  void setTtsEnabled(bool value) {
    _ttsEnabled = value;
  }

  Future<bool> init() async {
    if (kIsWeb) return false;
    if (_isInitialized) return true;

    try {
      await _tts.setLanguage('en-US');
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.9);
      await _tts.setVolume(1.0);
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('TTS init error: $e');
      return false;
    }
  }

  /// Start voice listening — currently returns false (STT not available).
  Future<void> startListening(Function(String text) onResult) async {
    // STT disabled — no-op
  }

  /// Stop voice listening — currently a no-op.
  Future<String?> stopListening() async {
    _isListening = false;
    return null;
  }

  /// Speak text aloud via TTS
  Future<void> speak(String text) async {
    if (kIsWeb || !_ttsEnabled || !_isInitialized) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    if (kIsWeb) return;
    await _tts.stop();
  }

  Future<bool> get isAvailable async {
    return _isInitialized && !kIsWeb;
  }
}
