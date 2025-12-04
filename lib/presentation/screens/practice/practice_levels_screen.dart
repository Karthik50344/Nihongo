import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/practice/practice_bloc.dart';
import '../../blocs/practice/practice_event.dart';
import '../../blocs/practice/practice_state.dart';
import '../../../data/models/practice_level_model.dart';
import 'widgets/level_card_widget.dart';

/// Practice levels screen
class PracticeLevelsScreen extends StatefulWidget {
  const PracticeLevelsScreen({super.key});

  @override
  State<PracticeLevelsScreen> createState() => _PracticeLevelsScreenState();
}

class _PracticeLevelsScreenState extends State<PracticeLevelsScreen> {
  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  void _loadLevels() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<PracticeBloc>().add(LoadPracticeLevels(authState.user.id));
    }
  }

  void _startLevel(PracticeLevelModel level) {
    if (!level.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete previous levels to unlock this one'),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    // Navigate to practice session screen
    context.push('/practice/session/${level.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.practice),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: BlocConsumer<PracticeBloc, PracticeState>(
        listener: (context, state) {
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
          if (state is PracticeLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            );
          }

          if (state is PracticeLevelsLoaded) {
            return _buildLevelsList(state.levels);
          }

          if (state is LevelUnlocked) {
            return _buildLevelsList(state.updatedLevels);
          }

          return const Center(
            child: Text('No levels available'),
          );
        },
      ),
    );
  }

  Widget _buildLevelsList(List<PracticeLevelModel> levels) {
    return RefreshIndicator(
      onRefresh: () async => _loadLevels(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
            child: LevelCardWidget(
              level: level,
              onTap: () => _startLevel(level),
            ),
          );
        },
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info, color: AppColors.primaryRed),
            const SizedBox(width: AppSizes.paddingM),
            const Text('Practice Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(
              icon: Icons.grade,
              title: 'Complete Levels',
              description: 'Score ${80}% or higher to unlock next level',
            ),
            const SizedBox(height: AppSizes.paddingM),
            _buildInfoItem(
              icon: Icons.edit,
              title: 'Write Characters',
              description: 'Draw the characters shown to you',
            ),
            const SizedBox(height: AppSizes.paddingM),
            _buildInfoItem(
              icon: Icons.trending_up,
              title: 'Track Progress',
              description: 'View your stats in the Progress tab',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryBlue, size: 24),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}