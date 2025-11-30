import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint('=== Initializing TTS ===');

      // Get available languages
      final languages = await _flutterTts.getLanguages;
      debugPrint('Available languages: $languages');

      // Try to set Japanese language
      final japaneseLanguages = ['ja-JP', 'ja_JP', 'ja'];
      bool languageSet = false;

      for (final lang in japaneseLanguages) {
        try {
          await _flutterTts.setLanguage(lang);
          final currentLang = await _flutterTts.getLanguages;
          debugPrint('Attempting to set language: $lang');
          languageSet = true;
          break;
        } catch (e) {
          debugPrint('Failed to set language $lang: $e');
        }
      }

      if (!languageSet) {
        debugPrint('Warning: Could not set Japanese language, using default');
      }

      // Set speech rate (0.0 to 1.0, slower is better for learning)
      await _flutterTts.setSpeechRate(0.4);
      debugPrint('Speech rate set to: 0.4');

      // Set volume (0.0 to 1.0)
      await _flutterTts.setVolume(1.0);
      debugPrint('Volume set to: 1.0');

      // Set pitch (0.5 to 2.0)
      await _flutterTts.setPitch(1.0);
      debugPrint('Pitch set to: 1.0');

      // Set up handlers
      _flutterTts.setStartHandler(() {
        debugPrint('TTS Started');
      });

      _flutterTts.setCompletionHandler(() {
        debugPrint('TTS Completed');
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
      });

      _isInitialized = true;
      debugPrint('TTS initialized successfully');
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
      _isInitialized = false;
    }
  }

  /// Speak Japanese text
  Future<void> speak(String text) async {
    debugPrint('=== TTS Speak Called ===');
    debugPrint('Text to speak: $text');

    if (!_isInitialized) {
      debugPrint('TTS not initialized, initializing now...');
      await initialize();
    }

    try {
      // Stop any current speech
      await _flutterTts.stop();

      // Speak the text
      debugPrint('Speaking: $text');
      final result = await _flutterTts.speak(text);
      debugPrint('Speak result: $result');

      if (result == 0) {
        debugPrint('Speech failed with code 0');
      }
    } catch (e) {
      debugPrint('Error speaking: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      debugPrint('TTS stopped');
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  /// Check if TTS is available
  Future<bool> isLanguageAvailable(String language) async {
    try {
      final result = await _flutterTts.isLanguageAvailable(language);
      debugPrint('Is $language available: $result');
      return result;
    } catch (e) {
      debugPrint('Error checking language availability: $e');
      return false;
    }
  }

  /// Dispose
  void dispose() {
    _flutterTts.stop();
  }
}