import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';

/// Home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryRed.withOpacity(0.8),
                    AppColors.primaryBlue.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusL),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: AppSizes.iconXL,
                  ),
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    AppStrings.welcome,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),

            // Learning Options Grid
            Text(
              'Choose Your Path',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppSizes.paddingM,
                mainAxisSpacing: AppSizes.paddingM,
                children: [
                  _buildLearningCard(
                    context: context,
                    title: AppStrings.hiragana,
                    subtitle: AppStrings.hiraganaEnglish,
                    icon: null,
                    text: "あ",
                    color: AppColors.primaryRed,
                    onTap: () {
                      // Navigate to Hiragana screen
                      context.push(AppRoutes.hiragana);
                    },
                  ),
                  _buildLearningCard(
                    context: context,
                    title: AppStrings.katakana,
                    subtitle: AppStrings.katakanaEnglish,
                    icon: null,
                    text: "ア",
                    color: AppColors.primaryBlue,
                    onTap: () {
                      // Navigate to Katakana screen
                      context.push(AppRoutes.katakana);
                    },
                  ),
                  _buildLearningCard(
                    context: context,
                    title: AppStrings.practice,
                    subtitle: AppStrings.practiceEnglish,
                    icon: FontAwesomeIcons.pencil,
                    color: AppColors.accentGreen,
                    onTap: () {
                      // Navigate to Practice screen
                      context.push(AppRoutes.practice);
                    },
                  ),
                  _buildLearningCard(
                    context: context,
                    title: AppStrings.progress,
                    subtitle: AppStrings.progressEnglish,
                    icon: FontAwesomeIcons.chartColumn,
                    color: AppColors.warningOrange,
                    onTap: () {
                      // Navigate to Progress screen
                      context.push(AppRoutes.progress);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    IconData? icon,
    String? text
  }) {
    return Card(
      elevation: AppSizes.elevationM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingS),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: icon != null ? Icon(
                  icon,
                  size: AppSizes.iconXL,
                  color: color,
                ) : Text(
                  text ?? "",
                  style: TextStyle(
                    fontSize: AppSizes.iconXL,
                    fontWeight: FontWeight.w100,
                    height: 1.0,
                    color: color
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.paddingXS),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}