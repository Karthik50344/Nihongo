import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/audio_service.dart';
import '../../../data/models/hiragana_model.dart';
import '../../../data/repositories/hiragana_repository.dart';
import 'widgets/hiragana_card_widget.dart';
import 'widgets/writing_dialog_widget.dart';

/// Hiragana learning screen
class HiraganaScreen extends StatefulWidget {
  const HiraganaScreen({super.key});

  @override
  State<HiraganaScreen> createState() => _HiraganaScreenState();
}

class _HiraganaScreenState extends State<HiraganaScreen> {
  final HiraganaRepository _repository = HiraganaRepository();
  final AudioService _audioService = AudioService();

  List<HiraganaModel> _allHiragana = [];
  List<HiraganaModel> _filteredHiragana = [];
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
    'vowel': 'Vowels (あ行)',
    'k-group': 'K-Group (か行)',
    's-group': 'S-Group (さ行)',
    't-group': 'T-Group (た行)',
    'n-group': 'N-Group (な行)',
    'h-group': 'H-Group (は行)',
    'm-group': 'M-Group (ま行)',
    'y-group': 'Y-Group (や行)',
    'r-group': 'R-Group (ら行)',
    'w-group': 'W-Group (わ行)',
    'n-single': 'N (ん)',
  };

  @override
  void initState() {
    super.initState();
    _loadHiragana();
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    debugPrint('Initializing audio service...');
    await _audioService.initialize();
    debugPrint('Audio service initialized');
  }

  Future<void> _loadHiragana() async {
    setState(() => _isLoading = true);

    try {
      final hiragana = await _repository.getAllHiragana();
      setState(() {
        _allHiragana = hiragana;
        _filteredHiragana = hiragana;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading hiragana: $e'),
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
        _filteredHiragana = _allHiragana;
      } else {
        _filteredHiragana = _allHiragana
            .where((h) => h.category == category)
            .toList();
      }
    });
  }

  void _onHiraganaTap(HiraganaModel hiragana) {
    debugPrint('=== Hiragana Tapped ===');
    debugPrint('Character: ${hiragana.character}');
    debugPrint('Romaji: ${hiragana.romaji}');

    // Play pronunciation
    _audioService.speak(hiragana.character);

    // Show feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white),
            const SizedBox(width: AppSizes.paddingM),
            Text(
              '${hiragana.character} (${hiragana.romaji})',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _onHiraganaDoubleTap(HiraganaModel hiragana) {
    // Show writing animation dialog
    showDialog(
      context: context,
      builder: (context) => WritingDialogWidget(hiragana: hiragana),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.hiragana),
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

          // Hiragana Grid
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryRed,
              ),
            )
                : _filteredHiragana.isEmpty
                ? _buildEmptyState()
                : _buildHiraganaGrid(),
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

  Widget _buildHiraganaGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSizes.paddingM,
        mainAxisSpacing: AppSizes.paddingM,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredHiragana.length,
      itemBuilder: (context, index) {
        final hiragana = _filteredHiragana[index];
        return HiraganaCardWidget(
          hiragana: hiragana,
          onTap: () => _onHiraganaTap(hiragana),
          onDoubleTap: () => _onHiraganaDoubleTap(hiragana),
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
            'No hiragana found',
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