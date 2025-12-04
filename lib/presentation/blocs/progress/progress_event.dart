import 'package:equatable/equatable.dart';

/// Progress events
abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

/// Load user progress
class LoadUserProgress extends ProgressEvent {
  final String userId;

  const LoadUserProgress(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load user attempts
class LoadUserAttempts extends ProgressEvent {
  final String userId;

  const LoadUserAttempts(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Refresh progress data
class RefreshProgress extends ProgressEvent {
  final String userId;

  const RefreshProgress(this.userId);

  @override
  List<Object?> get props => [userId];
}