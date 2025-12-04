import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/audio_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/practice/practice_bloc.dart';
import '../../blocs/practice/practice_event.dart';
import '../../blocs/practice/practice_state.dart';
import '../../../data/models/practice_attempt_model.dart';
import 'widgets/drawing_canvas_widget.dart';
import 'widgets/practice_complete_dialog.dart';
import 'dart:math';

/// Practice session screen
class PracticeSessionScreen extends StatefulWidget {
  final String levelId;

  const PracticeSessionScreen({
    super.key,
    required this.levelId,
  });

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  final AudioService _audioService = AudioService();
  final GlobalKey<DrawingCanvasWidgetState> _canvasKey = GlobalKey();
  String? _currentCharacter;
  List<String> _shuffledCharacters = [];

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
    _startPractice();
  }

  void _startPractice() {
    context.read<PracticeBloc>().add(StartPracticeLevel(widget.levelId));
  }

  void _setupCharacters(List<String> characters) {
    // Shuffle characters for random order
    _shuffledCharacters = List.from(characters)..shuffle(Random());
    if (_shuffledCharacters.isNotEmpty) {
      _currentCharacter = _shuffledCharacters[0];
    }
  }

  void _checkAnswer() {
    if (state is! PracticeInProgress) return;

    final currentState = state as PracticeInProgress;
    final drawnPaths = _canvasKey.currentState?.getDrawnPaths() ?? [];

    // Simple validation: check if user drew something
    final isCorrect = drawnPaths.isNotEmpty;

    // Play audio feedback
    _audioService.speak(_currentCharacter ?? '');

    // Submit answer
    context.read<PracticeBloc>().add(SubmitAnswer(
      character: _currentCharacter ?? '',
      isCorrect: isCorrect,
    ));

    // Clear canvas for next question
    Future.delayed(const Duration(milliseconds: 500), () {
      _canvasKey.currentState?.clear();
    });
  }

  void _skipQuestion() {
    if (state is! PracticeInProgress) return;

    context.read<PracticeBloc>().add(SubmitAnswer(
      character: _currentCharacter ?? '',
      isCorrect: false,
    ));

    _canvasKey.currentState?.clear();
  }

  PracticeState get state => context.read<PracticeBloc>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
      ),
      body: BlocConsumer<PracticeBloc, PracticeState>(
        listener: (context, state) {
          if (state is PracticeInProgress) {
            if (_shuffledCharacters.isEmpty) {
              _setupCharacters(state.currentLevel.characters);
            }
            // Update current character
            if (state.currentQuestionIndex < _shuffledCharacters.length) {
              setState(() {
                _currentCharacter = _shuffledCharacters[state.currentQuestionIndex];
              });
            }
          }

          if (state is PracticeCompleted) {
            _showCompletionDialog(state);
          }

          if (state is PracticeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PracticeInProgress) {
            return _buildPracticeUI(state);
          }

          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryRed,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPracticeUI(PracticeInProgress state) {
    return Column(
      children: [
        // Progress bar
        _buildProgressBar(state),

        // Score display
        _buildScoreDisplay(state),

        const SizedBox(height: AppSizes.paddingL),

        // Character to draw
        _buildCharacterDisplay(),

        const SizedBox(height: AppSizes.paddingL),

        // Drawing canvas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
            child: DrawingCanvasWidget(key: _canvasKey),
          ),
        ),

        const SizedBox(height: AppSizes.paddingL),

        // Action buttons
        _buildActionButtons(),

        const SizedBox(height: AppSizes.paddingL),
      ],
    );
  }

  Widget _buildProgressBar(PracticeInProgress state) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${state.currentQuestionIndex + 1}/${state.totalQuestions}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${state.score}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingS),
          LinearProgressIndicator(
            value: state.progress,
            backgroundColor: Colors.grey.shade300,
            color: AppColors.primaryRed,
            minHeight: 8,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDisplay(PracticeInProgress state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingS,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildScoreItem(
            icon: Icons.check_circle,
            label: 'Correct',
            value: state.correctAnswers.toString(),
            color: AppColors.success,
          ),
          const SizedBox(width: AppSizes.paddingXL),
          _buildScoreItem(
            icon: Icons.cancel,
            label: 'Incorrect',
            value: (state.currentQuestionIndex - state.correctAnswers).toString(),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: AppSizes.paddingS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCharacterDisplay() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        children: [
          Text(
            'Draw this character:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            _currentCharacter ?? '',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
      child: Row(
        children: [
          // Clear button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _canvasKey.currentState?.clear(),
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                side: const BorderSide(color: AppColors.primaryBlue),
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),

          // Skip button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _skipQuestion,
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                side: BorderSide(color: Colors.grey.shade400),
                foregroundColor: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),

          // Check button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _checkAnswer,
              icon: const Icon(Icons.check),
              label: const Text('Check'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(PracticeCompleted state) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    // Create attempt model
    final attempt = PracticeAttemptModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authState.user.id,
      levelId: state.levelId,
      score: state.score,
      totalQuestions: state.totalQuestions,
      correctAnswers: state.correctAnswers,
      completedAt: DateTime.now(),
      isPassed: state.isPassed,
      timeTaken: state.timeTaken,
    );

    // Save attempt
    context.read<PracticeBloc>().add(CompletePracticeLevel(attempt));

    // Show dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PracticeCompleteDialog(
        score: state.score,
        correctAnswers: state.correctAnswers,
        totalQuestions: state.totalQuestions,
        isPassed: state.isPassed,
        timeTaken: state.timeTaken,
        onContinue: () {
          Navigator.pop(context);
          context.pop();
        },
        onRetry: () {
          Navigator.pop(context);
          _startPractice();
        },
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Practice?'),
        content: const Text('Your progress will not be saved if you exit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}