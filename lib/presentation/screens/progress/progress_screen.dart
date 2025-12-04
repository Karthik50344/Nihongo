import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/progress/progress_bloc.dart';
import '../../blocs/progress/progress_event.dart';
import '../../blocs/progress/progress_state.dart';
import 'widgets/stats_card_widget.dart';
import 'widgets/recent_attempts_widget.dart';
import 'widgets/streak_widget.dart';

/// Progress screen showing user statistics
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ProgressBloc>().add(LoadUserProgress(authState.user.id));
    }
  }

  Future<void> _refreshProgress() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ProgressBloc>().add(RefreshProgress(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.progress),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProgress,
          ),
        ],
      ),
      body: BlocConsumer<ProgressBloc, ProgressState>(
        listener: (context, state) {
          if (state is ProgressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProgressLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            );
          }

          if (state is ProgressLoaded) {
            return _buildProgressContent(state);
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildProgressContent(ProgressLoaded state) {
    return RefreshIndicator(
      onRefresh: _refreshProgress,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        children: [
          // Welcome message
          _buildWelcomeSection(),
          const SizedBox(height: AppSizes.paddingL),

          // Streak widget
          StreakWidget(
            currentStreak: state.progress.currentStreak,
            longestStreak: state.progress.longestStreak,
          ),
          const SizedBox(height: AppSizes.paddingL),

          // Statistics cards
          _buildStatsSection(state),
          const SizedBox(height: AppSizes.paddingL),

          // Recent attempts
          if (state.recentAttempts.isNotEmpty) ...[
            Text(
              'Recent Practice Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),
            RecentAttemptsWidget(attempts: state.recentAttempts),
          ] else
            _buildNoAttemptsCard(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
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
      child: Row(
        children: [
          const Icon(
            Icons.trending_up,
            color: Colors.white,
            size: AppSizes.iconXL,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXS),
                Text(
                  'Keep up the great work!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ProgressLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: StatsCardWidget(
                icon: Icons.check_circle,
                title: 'Completed',
                value: '${state.progress.completedLevelsCount}',
                subtitle: 'Levels',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: StatsCardWidget(
                icon: Icons.repeat,
                title: 'Practice',
                value: '${state.progress.totalPracticeAttempts}',
                subtitle: 'Sessions',
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingM),
        Row(
          children: [
            Expanded(
              child: StatsCardWidget(
                icon: Icons.percent,
                title: 'Accuracy',
                value: '${state.progress.overallAccuracy.toStringAsFixed(1)}%',
                subtitle: 'Overall',
                color: AppColors.warningOrange,
              ),
            ),
            const SizedBox(width: AppSizes.paddingM),
            Expanded(
              child: StatsCardWidget(
                icon: Icons.question_answer,
                title: 'Questions',
                value: '${state.progress.totalQuestions}',
                subtitle: 'Answered',
                color: AppColors.primaryRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoAttemptsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.school,
            size: 60,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            'Start Practicing!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            'Complete practice sessions to see your progress here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.insert_chart,
            size: 80,
            color: AppColors.lightDivider,
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            'No progress data yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.paddingM),
          ElevatedButton(
            onPressed: _loadProgress,
            child: const Text('Load Progress'),
          ),
        ],
      ),
    );
  }
}