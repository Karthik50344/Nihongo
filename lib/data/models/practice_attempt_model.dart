import 'package:equatable/equatable.dart';

/// User's practice attempt model
class PracticeAttemptModel extends Equatable {
  final String id;
  final String userId;
  final String levelId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime completedAt;
  final bool isPassed;
  final Duration timeTaken;

  const PracticeAttemptModel({
    required this.id,
    required this.userId,
    required this.levelId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.completedAt,
    required this.isPassed,
    required this.timeTaken,
  });

  double get accuracy => (correctAnswers / totalQuestions) * 100;

  @override
  List<Object?> get props => [
    id,
    userId,
    levelId,
    score,
    totalQuestions,
    correctAnswers,
    completedAt,
    isPassed,
    timeTaken,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'levelId': levelId,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'completedAt': completedAt.toIso8601String(),
      'isPassed': isPassed,
      'timeTaken': timeTaken.inSeconds,
    };
  }

  factory PracticeAttemptModel.fromJson(Map<String, dynamic> json) {
    return PracticeAttemptModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      levelId: json['levelId'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
      isPassed: json['isPassed'] as bool,
      timeTaken: Duration(seconds: json['timeTaken'] as int),
    );
  }
}