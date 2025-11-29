import 'package:flutter_tts/flutter_tts.dart';

/// Audio service for pronunciation
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// Initialize TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set language to Japanese
      await _flutterTts.setLanguage('ja-JP');

      // Set speech rate (0.0 to 1.0)
      await _flutterTts.setSpeechRate(0.4);

      // Set volume (0.0 to 1.0)
      await _flutterTts.setVolume(1.0);

      // Set pitch (0.5 to 2.0)
      await _flutterTts.setPitch(1.0);

      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  /// Speak Japanese text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  /// Dispose
  void dispose() {
    _flutterTts.stop();
  }
}