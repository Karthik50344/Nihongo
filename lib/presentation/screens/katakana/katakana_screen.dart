import 'package:flutter/material.dart';
import 'package:nihongo/presentation/screens/katakana/widgets/katakana_card_widget.dart';
import 'package:nihongo/presentation/screens/katakana/widgets/writing_dialog_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/audio_service.dart';
import '../../../data/models/katakana_model.dart';
import '../../../data/repositories/katakana_repository.dart';

/// Katakana learning screen
class KatakanaScreen extends StatefulWidget {
  const KatakanaScreen({super.key});

  @override
  State<KatakanaScreen> createState() => _KatakanaScreenState();
}

class _KatakanaScreenState extends State<KatakanaScreen> {
  final KatakanaRepository _repository = KatakanaRepository();
  final AudioService _audioService = AudioService();

  List<KatakanaModel> _allKatakana = [];
  List<KatakanaModel> _filteredKatakana = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  final List<String> _categories = [
    'all',
    'vowel',
    'k-group',
    's-group',
    't-group',
    'n-group',
    'h-group',
    'm-group',
    'y-group',
    'r-group',
    'w-group',
    'n-single',
  ];

  final Map<String, String> _categoryNames = {
    'all': 'All (全て)',
    'vowel': 'Vowels (ア行)',
    'k-group': 'K-Group (カ行)',
    's-group': 'S-Group (サ行)',
    't-group': 'T-Group (タ行)',
    'n-group': 'N-Group (ナ行)',
    'h-group': 'H-Group (ハ行)',
    'm-group': 'M-Group (マ行)',
    'y-group': 'Y-Group (ヤ行)',
    'r-group': 'R-Group (ラ行)',
    'w-group': 'W-Group (ワ行)',
    'n-single': 'N (ン)',
  };

  @override
  void initState() {
    super.initState();
    _loadKatakana();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    debugPrint('Initializing audio service...');
    await _audioService.initialize();
    debugPrint('Audio service initialized');
  }

  Future<void> _loadKatakana() async {
    setState(() => _isLoading = true);

    try {
      final katakana = await _repository.getAllKatakana();
      setState(() {
        _allKatakana = katakana;
        _filteredKatakana = katakana;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading katakana: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'all') {
        _filteredKatakana = _allKatakana;
      } else {
        _filteredKatakana = _allKatakana
            .where((k) => k.category == category)
            .toList();
      }
    });
  }

  void _onKatakanaTap(KatakanaModel katakana) {
    debugPrint('=== Katakana Tapped ===');
    debugPrint('Character: ${katakana.character}');
    debugPrint('Romaji: ${katakana.romaji}');

    // Play pronunciation
    _audioService.speak(katakana.character);

    // Show feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white),
            const SizedBox(width: AppSizes.paddingM),
            Text(
              '${katakana.character} (${katakana.romaji})',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _onKatakanaDoubleTap(KatakanaModel katakana) {
    // Show writing animation dialog
    showDialog(
      context: context,
      builder: (context) => KatakanaWritingDialogWidget(katakana: katakana),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.katakana),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildInfoDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          _buildCategoryFilter(),

          // Katakana Grid
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            )
                : _filteredKatakana.isEmpty
                ? _buildEmptyState()
                : _buildKatakanaGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingS),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.paddingS),
            child: FilterChip(
              label: Text(_categoryNames[category] ?? category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) _filterByCategory(category);
              },
              backgroundColor: Theme.of(context).cardColor,
              selectedColor: AppColors.primaryRed.withOpacity(0.2),
              checkmarkColor: AppColors.primaryRed,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryRed : null,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKatakanaGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSizes.paddingM,
        mainAxisSpacing: AppSizes.paddingM,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredKatakana.length,
      itemBuilder: (context, index) {
        final katakana = _filteredKatakana[index];
        return KatakanaCardWidget(
          katakana: katakana,
          onTap: () => _onKatakanaTap(katakana),
          onDoubleTap: () => _onKatakanaDoubleTap(katakana),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.text_fields,
            size: 80,
            color: AppColors.lightDivider,
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            'No katakana found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoDialog() {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.info, color: AppColors.primaryRed),
          const SizedBox(width: AppSizes.paddingM),
          const Text('How to Use'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
            icon: Icons.touch_app,
            title: 'Single Tap',
            description: 'Hear the pronunciation',
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildInfoItem(
            icon: Icons.touch_app_outlined,
            title: 'Double Tap',
            description: 'See how to write it',
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildInfoItem(
            icon: Icons.filter_list,
            title: 'Filter',
            description: 'Select category to filter',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it!'),
        ),
      ],
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

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}