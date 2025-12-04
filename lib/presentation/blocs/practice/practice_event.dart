import 'package:equatable/equatable.dart';
import '../../../data/models/practice_attempt_model.dart';

/// Practice events
abstract class PracticeEvent extends Equatable {
  const PracticeEvent();

  @override
  List<Object?> get props => [];
}

/// Load practice levels
class LoadPracticeLevels extends PracticeEvent {
  final String userId;

  const LoadPracticeLevels(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Start practice level
class StartPracticeLevel extends PracticeEvent {
  final String levelId;

  const StartPracticeLevel(this.levelId);

  @override
  List<Object?> get props => [levelId];
}

/// Submit answer
class SubmitAnswer extends PracticeEvent {
  final String character;
  final bool isCorrect;

  const SubmitAnswer({
    required this.character,
    required this.isCorrect,
  });

  @override
  List<Object?> get props => [character, isCorrect];
}

/// Complete practice level
class CompletePracticeLevel extends PracticeEvent {
  final PracticeAttemptModel attempt;

  const CompletePracticeLevel(this.attempt);

  @override
  List<Object?> get props => [attempt];
}

/// Unlock next level
class UnlockNextLevel extends PracticeEvent {
  final String userId;
  final String levelId;

  const UnlockNextLevel({
    required this.userId,
    required this.levelId,
  });

  @override
  List<Object?> get props => [userId, levelId];
}