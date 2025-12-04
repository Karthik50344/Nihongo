import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/practice_level_model.dart';
import '../models/practice_attempt_model.dart';
import '../models/user_progress_model.dart';

/// Repository for practice data
class PracticeRepository {
  static const String _levelsKey = 'practice_levels';
  static const String _attemptsKey = 'practice_attempts';
  static const String _progressKey = 'user_progress';

  /// Get all practice levels
  Future<List<PracticeLevelModel>> getAllLevels(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final levelsJson = prefs.getString('${_levelsKey}_$userId');

      if (levelsJson != null) {
        final List<dynamic> decoded = json.decode(levelsJson);
        return decoded
            .map((json) => PracticeLevelModel.fromJson(json))
            .toList();
      }

      // Initialize default levels if none exist
      final defaultLevels = _getDefaultLevels();
      await _saveLevels(userId, defaultLevels);
      return defaultLevels;
    } catch (e) {
      throw Exception('Failed to load levels: ${e.toString()}');
    }
  }

  /// Save practice levels
  Future<void> _saveLevels(String userId, List<PracticeLevelModel> levels) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final levelsJson = json.encode(levels.map((l) => l.toJson()).toList());
      await prefs.setString('${_levelsKey}_$userId', levelsJson);
    } catch (e) {
      throw Exception('Failed to save levels: ${e.toString()}');
    }
  }

  /// Unlock a level
  Future<void> unlockLevel(String userId, String levelId) async {
    try {
      final levels = await getAllLevels(userId);
      final updatedLevels = levels.map((level) {
        if (level.id == levelId) {
          return level.copyWith(isUnlocked: true);
        }
        return level;
      }).toList();
      await _saveLevels(userId, updatedLevels);
    } catch (e) {
      throw Exception('Failed to unlock level: ${e.toString()}');
    }
  }

  /// Save practice attempt
  Future<void> savePracticeAttempt(PracticeAttemptModel attempt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attemptsJson = prefs.getString('${_attemptsKey}_${attempt.userId}');

      List<PracticeAttemptModel> attempts = [];
      if (attemptsJson != null) {
        final List<dynamic> decoded = json.decode(attemptsJson);
        attempts = decoded.map((json) => PracticeAttemptModel.fromJson(json)).toList();
      }

      attempts.add(attempt);

      final updatedJson = json.encode(attempts.map((a) => a.toJson()).toList());
      await prefs.setString('${_attemptsKey}_${attempt.userId}', updatedJson);

      // Update user progress
      await _updateUserProgress(attempt);
    } catch (e) {
      throw Exception('Failed to save attempt: ${e.toString()}');
    }
  }

  /// Get user attempts
  Future<List<PracticeAttemptModel>> getUserAttempts(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attemptsJson = prefs.getString('${_attemptsKey}_$userId');

      if (attemptsJson != null) {
        final List<dynamic> decoded = json.decode(attemptsJson);
        return decoded.map((json) => PracticeAttemptModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load attempts: ${e.toString()}');
    }
  }

  /// Get user progress
  Future<UserProgressModel> getUserProgress(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('${_progressKey}_$userId');

      if (progressJson != null) {
        final decoded = json.decode(progressJson);
        return UserProgressModel.fromJson(decoded);
      }

      return UserProgressModel.empty(userId);
    } catch (e) {
      throw Exception('Failed to load progress: ${e.toString()}');
    }
  }

  /// Update user progress after an attempt
  Future<void> _updateUserProgress(PracticeAttemptModel attempt) async {
    try {
      final progress = await getUserProgress(attempt.userId);

      // Calculate streak
      final now = DateTime.now();
      final lastDate = progress.lastPracticeDate;
      final daysDifference = now.difference(lastDate).inDays;

      int newStreak = progress.currentStreak;
      if (daysDifference == 0) {
        // Same day, keep streak
        newStreak = progress.currentStreak;
      } else if (daysDifference == 1) {
        // Consecutive day, increase streak
        newStreak = progress.currentStreak + 1;
      } else {
        // Streak broken, reset to 1
        newStreak = 1;
      }

      final newLongestStreak = newStreak > progress.longestStreak
          ? newStreak
          : progress.longestStreak;

      // Update completed levels
      final updatedCompletedLevels = Map<String, int>.from(progress.completedLevels);
      if (attempt.isPassed) {
        final currentBest = updatedCompletedLevels[attempt.levelId] ?? 0;
        if (attempt.score > currentBest) {
          updatedCompletedLevels[attempt.levelId] = attempt.score;
        }
      }

      final updatedProgress = progress.copyWith(
        completedLevels: updatedCompletedLevels,
        totalPracticeAttempts: progress.totalPracticeAttempts + 1,
        totalCorrectAnswers: progress.totalCorrectAnswers + attempt.correctAnswers,
        totalQuestions: progress.totalQuestions + attempt.totalQuestions,
        lastPracticeDate: now,
        currentStreak: newStreak,
        longestStreak: newLongestStreak,
      );

      final prefs = await SharedPreferences.getInstance();
      final progressJson = json.encode(updatedProgress.toJson());
      await prefs.setString('${_progressKey}_${attempt.userId}', progressJson);
    } catch (e) {
      throw Exception('Failed to update progress: ${e.toString()}');
    }
  }

  /// Get default practice levels
  List<PracticeLevelModel> _getDefaultLevels() {
    return [
      // Hiragana Levels
      PracticeLevelModel(
        id: 'h_level_1',
        name: 'Vowels',
        levelNumber: 1,
        category: 'hiragana',
        characterGroup: 'vowel',
        characters: ['あ', 'い', 'う', 'え', 'お'],
        requiredScore: 80,
        isUnlocked: true, // First level is always unlocked
      ),
      PracticeLevelModel(
        id: 'h_level_2',
        name: 'K-Group',
        levelNumber: 2,
        category: 'hiragana',
        characterGroup: 'k-group',
        characters: ['か', 'き', 'く', 'け', 'こ'],
        requiredScore: 80,
        isUnlocked: false,
      ),
      PracticeLevelModel(
        id: 'h_level_3',
        name: 'S-Group',
        levelNumber: 3,
        category: 'hiragana',
        characterGroup: 's-group',
        characters: ['さ', 'し', 'す', 'せ', 'そ'],
        requiredScore: 80,
        isUnlocked: false,
      ),
      PracticeLevelModel(
        id: 'h_level_4',
        name: 'T-Group',
        levelNumber: 4,
        category: 'hiragana',
        characterGroup: 't-group',
        characters: ['た', 'ち', 'つ', 'て', 'と'],
        requiredScore: 80,
        isUnlocked: false,
      ),
      PracticeLevelModel(
        id: 'h_level_5',
        name: 'N-Group',
        levelNumber: 5,
        category: 'hiragana',
        characterGroup: 'n-group',
        characters: ['な', 'に', 'ぬ', 'ね', 'の'],
        requiredScore: 80,
        isUnlocked: false,
      ),
      PracticeLevelModel(
        id: 'h_level_6',
        name: 'H-Group',
        levelNumber: 6,
        category: 'hiragana',
        characterGroup: 'h-group',
        characters: ['は', 'ひ', 'ふ', 'へ', 'ほ'],
        requiredScore: 80,
        isUnlocked: false,
      ),
      PracticeLevelModel(
        id: 'h_level_7',
        name: 'M-Group',
        levelNumber: 7,
        category: 'hiragana',
        characterGroup: 'm-group',
        characters: ['ま', 'み', 'む', 'め', 'も'],
        requiredScore: 80,
        isUnlocked: false,
      ),
      PracticeLevelModel(
        id: 'h_level_8',
        name: 'R-Group',
        levelNumber: 8,
        category: 'hiragana',
        characterGroup: 'r-group',
        characters: ['ら', 'り', 'る', 'れ', 'ろ'],
        requiredScore: 80,
        isUnlocked: false,
      ),
      PracticeLevelModel(
        id: 'h_level_9',
        name: 'Mixed Review 1',
        levelNumber: 9,
        category: 'hiragana',
        characterGroup: 'mixed',
        characters: ['あ', 'か', 'さ', 'た', 'な', 'い', 'き', 'し'],
        requiredScore: 85,
        isUnlocked: false,
      ),
    ];
  }
}