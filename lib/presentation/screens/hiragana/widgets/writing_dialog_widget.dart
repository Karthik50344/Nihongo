import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/kanjivg_services.dart';
import '../../../../data/models/hiragana_model.dart';
import 'stroke_painter.dart';

/// Writing dialog showing KanjiVG stroke animation
class WritingDialogWidget extends StatefulWidget {
  final HiraganaModel hiragana;

  const WritingDialogWidget({
    super.key,
    required this.hiragana,
  });

  @override
  State<WritingDialogWidget> createState() => _WritingDialogWidgetState();
}

class _WritingDialogWidgetState extends State<WritingDialogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final KanjiVGService _kanjiVGService = KanjiVGService();

  List<Path> _strokePaths = [];
  Rect _pathBounds = Rect.zero;
  int _currentStroke = 0;
  bool _isLoading = true;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _loadStrokes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStrokes() async {
    debugPrint('=== Loading Strokes for ${widget.hiragana.character} ===');

    setState(() {
      _isLoading = true;
    });

    try {
      final paths = await _kanjiVGService.loadStrokePaths(widget.hiragana.character, "hiragana");

      if (paths.isEmpty) {
        debugPrint('No strokes loaded!');
      } else {
        debugPrint('Loaded ${paths.length} strokes');
      }

      final bounds = _kanjiVGService.getPathBounds(paths);
      debugPrint('Path bounds: $bounds');

      setState(() {
        _strokePaths = paths;
        _pathBounds = bounds;
        _isLoading = false;
      });

      // Start animation automatically
      if (paths.isNotEmpty) {
        _startAnimation();
      }
    } catch (e) {
      debugPrint('Error loading strokes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startAnimation() {
    if (_strokePaths.isEmpty) return;

    setState(() {
      _isAnimating = true;
      _currentStroke = 0;
    });
    _animateNextStroke();
  }

  void _animateNextStroke() {
    if (_currentStroke >= _strokePaths.length) {
      setState(() {
        _isAnimating = false;
      });
      return;
    }

    _animationController.reset();
    _animationController.forward().then((_) {
      setState(() {
        _currentStroke++;
      });

      // Delay before next stroke
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _animateNextStroke();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'How to Write',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Character Info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.hiragana.character,
                  style: const TextStyle(
                    fontSize: 48,
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hiragana.romaji,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${widget.hiragana.pronunciation})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Canvas
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.lightDivider, width: 2),
              ),
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryRed,
                ),
              )
                  : AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: StrokePainter(
                      allStrokes: _strokePaths,
                      currentStrokeIndex: _currentStroke,
                      animationProgress: _animationController.value,
                      originalBounds: _pathBounds,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Stroke info
            if (!_isLoading)
              Text(
                _currentStroke < _strokePaths.length
                    ? 'Stroke ${_currentStroke + 1} of ${_strokePaths.length}'
                    : 'Complete!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: AppSizes.paddingM),

            // Replay button
            if (!_isLoading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnimating ? null : _startAnimation,
                  icon: const Icon(Icons.replay),
                  label: const Text('Replay Animation'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}