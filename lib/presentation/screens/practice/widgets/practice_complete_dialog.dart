import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'dart:math' as math;

/// Practice complete dialog
class PracticeCompleteDialog extends StatefulWidget {
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final bool isPassed;
  final Duration timeTaken;
  final VoidCallback onContinue;
  final VoidCallback onRetry;

  const PracticeCompleteDialog({
    super.key,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.isPassed,
    required this.timeTaken,
    required this.onContinue,
    required this.onRetry,
  });

  @override
  State<PracticeCompleteDialog> createState() => _PracticeCompleteDialogState();
}

class _PracticeCompleteDialogState extends State<PracticeCompleteDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isPassed
                ? [
              AppColors.success.withOpacity(0.1),
              Colors.white,
            ]
                : [
              AppColors.error.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotateAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isPassed
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.error.withOpacity(0.2),
                  ),
                  child: Icon(
                    widget.isPassed ? Icons.star : Icons.replay,
                    size: 60,
                    color: widget.isPassed ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Title
            Text(
              widget.isPassed ? 'Great Job!' : 'Keep Practicing!',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: widget.isPassed ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),

            // Subtitle
            Text(
              widget.isPassed
                  ? 'You passed this level!'
                  : 'Try again to unlock the next level',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Score display
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                color: widget.isPassed
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Column(
                children: [
                  Text(
                    '${widget.score}%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: widget.isPassed ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text(
                    'Your Score',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(
                  icon: Icons.check_circle,
                  label: 'Correct',
                  value: '${widget.correctAnswers}/${widget.totalQuestions}',
                  color: AppColors.success,
                ),
                _buildStat(
                  icon: Icons.timer,
                  label: 'Time',
                  value: _formatDuration(widget.timeTaken),
                  color: AppColors.primaryBlue,
                ),
                _buildStat(
                  icon: Icons.percent,
                  label: 'Accuracy',
                  value: '${((widget.correctAnswers / widget.totalQuestions) * 100).toStringAsFixed(0)}%',
                  color: AppColors.warningOrange,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Action buttons
            Row(
              children: [
                if (!widget.isPassed)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onRetry,
                      icon: const Icon(Icons.replay),
                      label: const Text('Retry'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingM,
                        ),
                        side: const BorderSide(color: AppColors.primaryBlue),
                        foregroundColor: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                if (!widget.isPassed) const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onContinue,
                    icon: Icon(widget.isPassed ? Icons.arrow_forward : Icons.close),
                    label: Text(widget.isPassed ? 'Continue' : 'Exit'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.paddingM,
                      ),
                      backgroundColor: widget.isPassed
                          ? AppColors.success
                          : AppColors.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSizes.paddingXS),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}