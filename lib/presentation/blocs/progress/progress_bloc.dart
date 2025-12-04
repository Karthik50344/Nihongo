import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/practice_repository.dart';
import 'progress_event.dart';
import 'progress_state.dart';

/// Progress BLoC
class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final PracticeRepository _practiceRepository;

  ProgressBloc(this._practiceRepository) : super(const ProgressInitial()) {
    on<LoadUserProgress>(_onLoadUserProgress);
    on<LoadUserAttempts>(_onLoadUserAttempts);
    on<RefreshProgress>(_onRefreshProgress);
  }

  /// Load user progress
  Future<void> _onLoadUserProgress(
      LoadUserProgress event,
      Emitter<ProgressState> emit,
      ) async {
    emit(const ProgressLoading());
    try {
      final progress = await _practiceRepository.getUserProgress(event.userId);
      final attempts = await _practiceRepository.getUserAttempts(event.userId);

      // Get recent attempts (last 10)
      final recentAttempts = attempts.reversed.take(10).toList();

      emit(ProgressLoaded(
        progress: progress,
        recentAttempts: recentAttempts,
      ));
    } catch (e) {
      emit(ProgressError('Failed to load progress: ${e.toString()}'));
    }
  }

  /// Load user attempts
  Future<void> _onLoadUserAttempts(
      LoadUserAttempts event,
      Emitter<ProgressState> emit,
      ) async {
    try {
      if (state is! ProgressLoaded) return;

      final currentState = state as ProgressLoaded;
      final attempts = await _practiceRepository.getUserAttempts(event.userId);
      final recentAttempts = attempts.reversed.take(10).toList();

      emit(ProgressLoaded(
        progress: currentState.progress,
        recentAttempts: recentAttempts,
      ));
    } catch (e) {
      emit(ProgressError('Failed to load attempts: ${e.toString()}'));
    }
  }

  /// Refresh progress data
  Future<void> _onRefreshProgress(
      RefreshProgress event,
      Emitter<ProgressState> emit,
      ) async {
    try {
      final progress = await _practiceRepository.getUserProgress(event.userId);
      final attempts = await _practiceRepository.getUserAttempts(event.userId);
      final recentAttempts = attempts.reversed.take(10).toList();

      emit(ProgressLoaded(
        progress: progress,
        recentAttempts: recentAttempts,
      ));
    } catch (e) {
      emit(ProgressError('Failed to refresh progress: ${e.toString()}'));
    }
  }
}