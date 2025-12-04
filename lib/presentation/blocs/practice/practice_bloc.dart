import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/practice_repository.dart';
import '../../../data/models/practice_attempt_model.dart';
import 'practice_event.dart';
import 'practice_state.dart';

/// Practice BLoC
class PracticeBloc extends Bloc<PracticeEvent, PracticeState> {
  final PracticeRepository _practiceRepository;

  PracticeBloc(this._practiceRepository) : super(const PracticeInitial()) {
    on<LoadPracticeLevels>(_onLoadPracticeLevels);
    on<StartPracticeLevel>(_onStartPracticeLevel);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<CompletePracticeLevel>(_onCompletePracticeLevel);
    on<UnlockNextLevel>(_onUnlockNextLevel);
  }

  /// Load practice levels
  Future<void> _onLoadPracticeLevels(
      LoadPracticeLevels event,
      Emitter<PracticeState> emit,
      ) async {
    emit(const PracticeLoading());
    try {
      final levels = await _practiceRepository.getAllLevels(event.userId);
      emit(PracticeLevelsLoaded(levels));
    } catch (e) {
      emit(PracticeError('Failed to load levels: ${e.toString()}'));
    }
  }

  /// Start practice level
  Future<void> _onStartPracticeLevel(
      StartPracticeLevel event,
      Emitter<PracticeState> emit,
      ) async {
    try {
      if (state is! PracticeLevelsLoaded) return;

      final levelsState = state as PracticeLevelsLoaded;
      final level = levelsState.levels.firstWhere(
            (l) => l.id == event.levelId,
      );

      if (!level.isUnlocked) {
        emit(const PracticeError('This level is locked'));
        return;
      }

      // Start practice with total questions = number of characters in level
      emit(PracticeInProgress(
        currentLevel: level,
        currentQuestionIndex: 0,
        correctAnswers: 0,
        totalQuestions: level.characters.length,
        startTime: DateTime.now(),
      ));
    } catch (e) {
      emit(PracticeError('Failed to start level: ${e.toString()}'));
    }
  }

  /// Submit answer
  Future<void> _onSubmitAnswer(
      SubmitAnswer event,
      Emitter<PracticeState> emit,
      ) async {
    try {
      if (state is! PracticeInProgress) return;

      final currentState = state as PracticeInProgress;
      final newCorrectAnswers = event.isCorrect
          ? currentState.correctAnswers + 1
          : currentState.correctAnswers;
      final newQuestionIndex = currentState.currentQuestionIndex + 1;

      // Check if practice is complete
      if (newQuestionIndex >= currentState.totalQuestions) {
        // Calculate final score and time
        final timeTaken = DateTime.now().difference(currentState.startTime);
        final score = ((newCorrectAnswers / currentState.totalQuestions) * 100).round();
        final isPassed = score >= currentState.currentLevel.requiredScore;

        emit(PracticeCompleted(
          score: score,
          correctAnswers: newCorrectAnswers,
          totalQuestions: currentState.totalQuestions,
          isPassed: isPassed,
          levelId: currentState.currentLevel.id,
          timeTaken: timeTaken,
        ));
      } else {
        // Continue to next question
        emit(currentState.copyWith(
          currentQuestionIndex: newQuestionIndex,
          correctAnswers: newCorrectAnswers,
        ));
      }
    } catch (e) {
      emit(PracticeError('Failed to submit answer: ${e.toString()}'));
    }
  }

  /// Complete practice level
  Future<void> _onCompletePracticeLevel(
      CompletePracticeLevel event,
      Emitter<PracticeState> emit,
      ) async {
    try {
      // Save the attempt
      await _practiceRepository.savePracticeAttempt(event.attempt);

      // If passed, unlock next level
      if (event.attempt.isPassed) {
        final levels = await _practiceRepository.getAllLevels(event.attempt.userId);
        final currentLevelIndex = levels.indexWhere(
              (l) => l.id == event.attempt.levelId,
        );

        // Unlock next level if exists
        if (currentLevelIndex != -1 && currentLevelIndex < levels.length - 1) {
          final nextLevel = levels[currentLevelIndex + 1];
          await _practiceRepository.unlockLevel(
            event.attempt.userId,
            nextLevel.id,
          );
        }
      }

      // Reload levels to show updated state
      final updatedLevels = await _practiceRepository.getAllLevels(
        event.attempt.userId,
      );
      emit(PracticeLevelsLoaded(updatedLevels));
    } catch (e) {
      emit(PracticeError('Failed to complete level: ${e.toString()}'));
    }
  }

  /// Unlock next level
  Future<void> _onUnlockNextLevel(
      UnlockNextLevel event,
      Emitter<PracticeState> emit,
      ) async {
    try {
      await _practiceRepository.unlockLevel(event.userId, event.levelId);
      final updatedLevels = await _practiceRepository.getAllLevels(event.userId);
      emit(LevelUnlocked(
        levelId: event.levelId,
        updatedLevels: updatedLevels,
      ));
    } catch (e) {
      emit(PracticeError('Failed to unlock level: ${e.toString()}'));
    }
  }
}