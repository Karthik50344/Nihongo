import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

/// Streak widget showing current and longest streak
class StreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              AppColors.warningOrange.withOpacity(0.1),
              isDark ? AppColors.darkCardBackground : Colors.white,
            ],
          ),
        ),
        child: Row(
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