import 'package:equatable/equatable.dart';

/// User progress model
class UserProgressModel extends Equatable {
  final String userId;
  final Map<String, int> completedLevels; // levelId -> bestScore
  final int totalPracticeAttempts;
  final int totalCorrectAnswers;
  final int totalQuestions;
  final DateTime lastPracticeDate;
  final int currentStreak;
  final int longestStreak;

  const UserProgressModel({
    required this.userId,
    required this.completedLevels,
    required this.totalPracticeAttempts,
    required this.totalCorrectAnswers,
    required this.totalQuestions,
    required this.lastPracticeDate,
    required this.currentStreak,
    required this.longestStreak,
  });

  double get overallAccuracy => totalQuestions > 0
      ? (totalCorrectAnswers / totalQuestions) * 100
      : 0.0;

  int get completedLevelsCount => completedLevels.length;

  @override
  List<Object?> get props => [
    userId,
    completedLevels,
    totalPracticeAttempts,
    totalCorrectAnswers,
    totalQuestions,
    lastPracticeDate,
    currentStreak,
    longestStreak,
  ];

  UserProgressModel copyWith({
    String? userId,
    Map<String, int>? completedLevels,
    int? totalPracticeAttempts,
    int? totalCorrectAnswers,
    int? totalQuestions,
    DateTime? lastPracticeDate,
    int? currentStreak,
    int? longestStreak,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      completedLevels: completedLevels ?? this.completedLevels,
      totalPracticeAttempts:
      totalPracticeAttempts ?? this.totalPracticeAttempts,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lastPracticeDate: lastPracticeDate ?? this.lastPracticeDate,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'completedLevels': completedLevels,
      'totalPracticeAttempts': totalPracticeAttempts,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalQuestions': totalQuestions,
      'lastPracticeDate': lastPracticeDate.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      userId: json['userId'] as String,
      completedLevels: Map<String, int>.from(json['completedLevels'] as Map),
      totalPracticeAttempts: json['totalPracticeAttempts'] as int,
      totalCorrectAnswers: json['totalCorrectAnswers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      lastPracticeDate: DateTime.parse(json['lastPracticeDate'] as String),
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
    );
  }

  factory UserProgressModel.empty(String userId) {
    return UserProgressModel(
      userId: userId,
      completedLevels: {},
      totalPracticeAttempts: 0,
      totalCorrectAnswers: 0,
      totalQuestions: 0,
      lastPracticeDate: DateTime.now().subtract(const Duration(days: 2)), // Set to past so first practice starts streak
      currentStreak: 0,
      longestStreak: 0,
    );
  }
}