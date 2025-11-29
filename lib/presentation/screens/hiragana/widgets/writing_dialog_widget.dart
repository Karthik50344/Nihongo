import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/hiragana_model.dart';

/// Dialog showing how to write Hiragana
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
  int _currentStroke = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _startAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    setState(() {
      _isAnimating = true;
      _currentStroke = 0;
    });
    _animateNextStroke();
  }

  void _animateNextStroke() {
    if (_currentStroke >= widget.hiragana.strokes.length) {
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
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _animateNextStroke();
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

            // Writing Canvas
            Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: AppColors.lightDivider, width: 2),
              ),
              child: CustomPaint(
                painter: HiraganaStrokePainter(
                  strokes: widget.hiragana.strokes,
                  currentStroke: _currentStroke,
                  animationProgress: _animationController.value,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),

            // Stroke Order Info
            Text(
              'Stroke ${_currentStroke + 1} of ${widget.hiragana.strokes.length}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSizes.paddingM),

            // Replay Button
            ElevatedButton.icon(
              onPressed: _isAnimating ? null : _startAnimation,
              icon: const Icon(Icons.replay),
              label: const Text('Replay Animation'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for Hiragana strokes
class HiraganaStrokePainter extends CustomPainter {
  final List<HiraganaStroke> strokes;
  final int currentStroke;
  final double animationProgress;

  HiraganaStrokePainter({
    required this.strokes,
    required this.currentStroke,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    _drawGrid(canvas, size);

    // Draw completed strokes
    for (int i = 0; i < currentStroke && i < strokes.length; i++) {
      _drawStroke(canvas, size, strokes[i], 1.0, Colors.grey.shade400);
    }

    // Draw current animating stroke
    if (currentStroke < strokes.length) {
      _drawStroke(
        canvas,
        size,
        strokes[currentStroke],
        animationProgress,
        AppColors.primaryRed,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Horizontal center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  void _drawStroke(
      Canvas canvas,
      Size size,
      HiraganaStroke stroke,
      double progress,
      Color color,
      ) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Calculate how many points to draw based on progress
    final totalPoints = stroke.points.length;
    final pointsToDraw = (totalPoints * progress).ceil();

    if (pointsToDraw > 0) {
      final firstPoint = stroke.points[0];
      path.moveTo(firstPoint.x * size.width, firstPoint.y * size.height);

      for (int i = 1; i < pointsToDraw && i < stroke.points.length; i++) {
        final point = stroke.points[i];
        path.lineTo(point.x * size.width, point.y * size.height);
      }

      // If we're in the middle of drawing, add a partial line
      if (pointsToDraw < totalPoints) {
        final prevPoint = stroke.points[pointsToDraw - 1];
        final nextPoint = stroke.points[pointsToDraw];
        final fraction = (totalPoints * progress) - (pointsToDraw - 1);

        final interpolatedX = prevPoint.x + (nextPoint.x - prevPoint.x) * fraction;
        final interpolatedY = prevPoint.y + (nextPoint.y - prevPoint.y) * fraction;

        path.lineTo(interpolatedX * size.width, interpolatedY * size.height);
      }

      canvas.drawPath(path, paint);

      // Draw stroke order number at start
      if (progress < 0.2) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${stroke.order}',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            firstPoint.x * size.width - 8,
            firstPoint.y * size.height - 20,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(HiraganaStrokePainter oldDelegate) {
    return oldDelegate.currentStroke != currentStroke ||
        oldDelegate.animationProgress != animationProgress;
  }
}