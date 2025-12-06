import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/practice_config.dart';
import '../../../../data/models/practice_level_model.dart';

/// Level card widget
class LevelCardWidget extends StatelessWidget {
  final PracticeLevelModel level;
  final VoidCallback onTap;

  const LevelCardWidget({
    super.key,
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: level.isUnlocked ? AppSizes.elevationM : AppSizes.elevationS,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: level.isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            gradient: level.isUnlocked
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                AppColors.darkCardBackground,
                AppColors.darkSurface,
              ]
                  : [
                AppColors.lightCardBackground,
                Colors.white,
              ],
            )
                : null,
            color: level.isUnlocked
                ? null
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
          child: Row(
            children: [
              // Level number circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: level.isUnlocked
                      ? AppColors.primaryRed.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                  border: Border.all(
                    color: level.isUnlocked
                        ? AppColors.primaryRed
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: level.isUnlocked
                      ? Text(
                    '${level.levelNumber}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  )
                      : Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingL),

              // Level info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: level.isUnlocked ? null : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Text(
                      '${level.characters.length} characters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: level.isUnlocked
                            ? AppColors.primaryBlue
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingXS),
                    Text(
                      'Required: ${level.requiredScore}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: level.isUnlocked ? AppColors.primaryRed : Colors.grey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}