import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/practice_attempt_model.dart';

/// Recent attempts widget
class RecentAttemptsWidget extends StatelessWidget {
  final List<PracticeAttemptModel> attempts;

  const RecentAttemptsWidget({
    super.key,
    required this.attempts,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat.jm().format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat.jm().format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attempts.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSizes.paddingM),
      itemBuilder: (context, index) {
        final attempt = attempts[index];
        return _buildAttemptCard(context, attempt);
      },
    );
  }

  Widget _buildAttemptCard(BuildContext context, PracticeAttemptModel attempt) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: AppSizes.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: attempt.isPassed
                ? AppColors.success.withOpacity(0.3)
                : AppColors.error.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: attempt.isPassed
                        ? AppColors.success.withOpacity(0.2)
                        : AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        attempt.isPassed ? Icons.check_circle : Icons.cancel,
                        color: attempt.isPassed ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: AppSizes.paddingXS),
                      Text(
                        attempt.isPassed ? 'Passed' : 'Failed',
                        style: TextStyle(
                          color: attempt.isPassed ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Date
                Text(
                  _formatDate(attempt.completedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Score display
            Row(
              children: [
                // Score circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: attempt.isPassed
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    border: Border.all(
                      color: attempt.isPassed ? AppColors.success : AppColors.error,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${attempt.score}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: attempt.isPassed ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),

                // Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow(
                        icon: Icons.check,
                        label: 'Correct',
                        value: '${attempt.correctAnswers}/${attempt.totalQuestions}',
                      ),
                      const SizedBox(height: AppSizes.paddingXS),
                      _buildStatRow(
                        icon: Icons.timer,
                        label: 'Time',
                        value: _formatDuration(attempt.timeTaken),
                      ),
                      const SizedBox(height: AppSizes.paddingXS),
                      _buildStatRow(
                        icon: Icons.percent,
                        label: 'Accuracy',
                        value: '${attempt.accuracy.toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: AppSizes.paddingXS),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}