import 'package:equatable/equatable.dart';
import '../../../data/models/user_progress_model.dart';
import '../../../data/models/practice_attempt_model.dart';

/// Progress states
abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProgressInitial extends ProgressState {
  const ProgressInitial();
}

/// Loading state
class ProgressLoading extends ProgressState {
  const ProgressLoading();
}

/// Progress loaded state
class ProgressLoaded extends ProgressState {
  final UserProgressModel progress;
  final List<PracticeAttemptModel> recentAttempts;

  const ProgressLoaded({
    required this.progress,
    required this.recentAttempts,
  });

  @override
  List<Object?> get props => [progress, recentAttempts];
}

/// Progress error state
class ProgressError extends ProgressState {
  final String message;

  const ProgressError(this.message);

  @override
  List<Object?> get props => [message];
}