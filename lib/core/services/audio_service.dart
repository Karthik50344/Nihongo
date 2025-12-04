import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Audio service for pronunciation
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String? _currentLanguage;

  /// Initialize TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('=== Initializing TTS ===');

      // Get available languages
      final languages = await _flutterTts.getLanguages;
      debugPrint('Available languages: $languages');

      // Try to set Japanese language
      await _setJapaneseLanguage();

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
        // Re-ensure Japanese language after completion
        _setJapaneseLanguage();
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

  /// Set Japanese language
  Future<void> _setJapaneseLanguage() async {
    try {
      final japaneseLanguages = ['ja-JP', 'ja_JP', 'ja'];

      for (final lang in japaneseLanguages) {
        try {
          final result = await _flutterTts.setLanguage(lang);
          if (result == 1) {
            _currentLanguage = lang;
            debugPrint('Successfully set language to: $lang');
            return;
          }
        } catch (e) {
          debugPrint('Failed to set language $lang: $e');
        }
      }

      debugPrint('Warning: Could not set Japanese language');
    } catch (e) {
      debugPrint('Error setting Japanese language: $e');
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
      // Always ensure Japanese language is set before speaking
      await _setJapaneseLanguage();

      // Stop any current speech
      await _flutterTts.stop();

      // Small delay to ensure language is set
      await Future.delayed(const Duration(milliseconds: 100));

      // Speak the text
      debugPrint('Speaking: $text in language: $_currentLanguage');
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

  /// Get current language
  String? get currentLanguage => _currentLanguage;

  /// Dispose
  void dispose() {
    _flutterTts.stop();
  }
}