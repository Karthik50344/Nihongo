import 'package:equatable/equatable.dart';
import '../../../data/models/practice_level_model.dart';

/// Practice states
abstract class PracticeState extends Equatable {
  const PracticeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PracticeInitial extends PracticeState {
  const PracticeInitial();
}

/// Loading state
class PracticeLoading extends PracticeState {
  const PracticeLoading();
}

/// Levels loaded state
class PracticeLevelsLoaded extends PracticeState {
  final List<PracticeLevelModel> levels;

  const PracticeLevelsLoaded(this.levels);

  @override
  List<Object?> get props => [levels];
}

/// Practice in progress state
class PracticeInProgress extends PracticeState {
  final PracticeLevelModel currentLevel;
  final int currentQuestionIndex;
  final int correctAnswers;
  final int totalQuestions;
  final DateTime startTime;

  const PracticeInProgress({
    required this.currentLevel,
    required this.currentQuestionIndex,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.startTime,
  });

  double get progress => currentQuestionIndex / totalQuestions;

  int get score => totalQuestions > 0
      ? ((correctAnswers / totalQuestions) * 100).round()
      : 0;

  @override
  List<Object?> get props => [
    currentLevel,
    currentQuestionIndex,
    correctAnswers,
    totalQuestions,
    startTime,
  ];

  PracticeInProgress copyWith({
    PracticeLevelModel? currentLevel,
    int? currentQuestionIndex,
    int? correctAnswers,
    int? totalQuestions,
    DateTime? startTime,
  }) {
    return PracticeInProgress(
      currentLevel: currentLevel ?? this.currentLevel,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      startTime: startTime ?? this.startTime,
    );
  }
}

/// Practice completed state
class PracticeCompleted extends PracticeState {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final bool isPassed;
  final String levelId;
  final Duration timeTaken;

  const PracticeCompleted({
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.isPassed,
    required this.levelId,
    required this.timeTaken,
  });

  double get accuracy => (correctAnswers / totalQuestions) * 100;

  @override
  List<Object?> get props => [
    score,
    correctAnswers,
    totalQuestions,
    isPassed,
    levelId,
    timeTaken,
  ];
}

/// Practice error state
class PracticeError extends PracticeState {
  final String message;

  const PracticeError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Level unlocked state
class LevelUnlocked extends PracticeState {
  final String levelId;
  final List<PracticeLevelModel> updatedLevels;

  const LevelUnlocked({
    required this.levelId,
    required this.updatedLevels,
  });

  @override
  List<Object?> get props => [levelId, updatedLevels];
}