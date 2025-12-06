import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:intl/intl.dart';

/// Streak widget showing current and longest streak
class StreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastPracticeDate;

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.lastPracticeDate,
  });

  String _getStreakStatus() {
    if (lastPracticeDate == null) return 'Start your streak!';

    final now = DateTime.now();
    final lastDate = DateTime(
      lastPracticeDate!.year,
      lastPracticeDate!.month,
      lastPracticeDate!.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    final daysDiff = today.difference(lastDate).inDays;

    if (daysDiff == 0) {
      return 'Practiced today! 🔥';
    } else if (daysDiff == 1) {
      return 'Practice today to continue!';
    } else {
      return 'Streak broken - start again!';
    }
  }

  Color _getStreakColor() {
    if (lastPracticeDate == null) return Colors.grey;

    final now = DateTime.now();
    final lastDate = DateTime(
      lastPracticeDate!.year,
      lastPracticeDate!.month,
      lastPracticeDate!.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    final daysDiff = today.difference(lastDate).inDays;

    if (daysDiff == 0) {
      return AppColors.success;
    } else if (daysDiff == 1) {
      return AppColors.warningOrange;
    } else {
      return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final streakColor = _getStreakColor();

    return Card(
      elevation: AppSizes.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              streakColor.withOpacity(0.1),
              isDark ? AppColors.darkCardBackground : Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Status message
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingM,
                vertical: AppSizes.paddingS,
              ),
              decoration: BoxDecoration(
                color: streakColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: streakColor,
                    size: 16,
                  ),
                  const SizedBox(width: AppSizes.paddingS),
                  Text(
                    _getStreakStatus(),
                    style: TextStyle(
                      color: streakColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Streak counters
            Row(
              children: [
                // Current streak
                Expanded(
                  child: _buildStreakItem(
                    context: context,
                    icon: Icons.local_fire_department,
                    label: 'Current Streak',
                    value: currentStreak,
                    color: AppColors.warningOrange,
                    isPrimary: true,
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                ),

                // Longest streak
                Expanded(
                  child: _buildStreakItem(
                    context: context,
                    icon: Icons.emoji_events,
                    label: 'Best Streak',
                    value: longestStreak,
                    color: AppColors.accentGreen,
                    isPrimary: false,
                  ),
                ),
              ],
            ),

            // Last practice date
            if (lastPracticeDate != null) ...[
              const SizedBox(height: AppSizes.paddingM),
              Text(
                'Last practice: ${DateFormat('MMM dd, yyyy').format(lastPracticeDate!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    required bool isPrimary,
  }) {
    return Column(
      children: [
        // Icon with animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.all(AppSizes.paddingM),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isPrimary ? AppSizes.iconXL : AppSizes.iconL,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSizes.paddingM),

        // Value
        Text(
          '$value',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: isPrimary ? 36 : 28,
          ),
        ),
        const SizedBox(height: AppSizes.paddingXS),

        // Label
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),

        // Days text
        Text(
          value == 1 ? 'day' : 'days',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}