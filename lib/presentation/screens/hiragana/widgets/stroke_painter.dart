import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'dart:math' show cos, sin;

/// Custom painter for animating KanjiVG strokes
class StrokePainter extends CustomPainter {
  final List<Path> allStrokes;
  final int currentStrokeIndex;
  final double animationProgress;
  final Rect originalBounds;

  StrokePainter({
    required this.allStrokes,
    required this.currentStrokeIndex,
    required this.animationProgress,
    required this.originalBounds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    _drawGrid(canvas, size);

    if (allStrokes.isEmpty) {
      _drawEmptyMessage(canvas, size);
      return;
    }

    // Calculate transform to fit strokes in canvas
    final transform = _calculateTransform(size);

    // Draw completed strokes (gray)
    for (int i = 0; i < currentStrokeIndex && i < allStrokes.length; i++) {
      _drawCompletedStroke(canvas, allStrokes[i], transform);
    }

    // Draw current animating stroke (red)
    if (currentStrokeIndex < allStrokes.length) {
      _drawAnimatedStroke(
        canvas,
        allStrokes[currentStrokeIndex],
        transform,
        animationProgress,
        currentStrokeIndex + 1,
      );
    }
  }

  /// Calculate transformation matrix to fit path in canvas
  Matrix4 _calculateTransform(Size size) {
    if (originalBounds.isEmpty) {
      return Matrix4.identity();
    }

    // Add padding
    final padding = 20.0;
    final targetWidth = size.width - (padding * 2);
    final targetHeight = size.height - (padding * 2);

    // Calculate scale to fit
    final scaleX = targetWidth / originalBounds.width;
    final scaleY = targetHeight / originalBounds.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate translation to center
    final scaledWidth = originalBounds.width * scale;
    final scaledHeight = originalBounds.height * scale;
    final translateX = (size.width - scaledWidth) / 2 - (originalBounds.left * scale);
    final translateY = (size.height - scaledHeight) / 2 - (originalBounds.top * scale);

    return Matrix4.identity()
      ..translate(translateX, translateY)
      ..scale(scale, scale);
  }

  /// Draw grid lines
  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Center lines
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  /// Draw completed stroke in gray
  void _drawCompletedStroke(Canvas canvas, Path stroke, Matrix4 transform) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final transformedPath = stroke.transform(transform.storage);
    canvas.drawPath(transformedPath, paint);
  }

  /// Draw animated stroke in red
  void _drawAnimatedStroke(
      Canvas canvas,
      Path stroke,
      Matrix4 transform,
      double progress,
      int strokeNumber,
      ) {
    final transformedPath = stroke.transform(transform.storage);
    final metrics = transformedPath.computeMetrics().toList();

    if (metrics.isEmpty) return;

    for (final metric in metrics) {
      // Calculate length to draw
      final length = metric.length * progress;

      if (length > 0) {
        // Extract partial path
        final extractedPath = metric.extractPath(0, length);

        // Draw the stroke
        final paint = Paint()
          ..color = AppColors.primaryRed
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

        canvas.drawPath(extractedPath, paint);

        // Draw stroke number at start
        if (progress < 0.15) {
          final startTangent = metric.getTangentForOffset(0);
          if (startTangent != null) {
            _drawStrokeNumber(canvas, strokeNumber, startTangent.position);
          }
        }

        // Draw direction arrow
        if (progress > 0.1 && progress < 0.95) {
          final currentTangent = metric.getTangentForOffset(length);
          if (currentTangent != null) {
            _drawArrow(canvas, currentTangent.position, currentTangent.angle);
          }
        }
      }
    }
  }

  /// Draw stroke order number
  void _drawStrokeNumber(Canvas canvas, int number, Offset position) {
    // Background circle
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 15, circlePaint);

    // Border
    final borderPaint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(position, 15, borderPaint);

    // Number text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
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
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  /// Draw direction arrow
  void _drawArrow(Canvas canvas, Offset position, double angle) {
    final paint = Paint()
      ..color = AppColors.primaryRed
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arrowSize = 12.0;
    final path = Path();

    // Arrow head
    final angle1 = angle - 2.5;
    final angle2 = angle + 2.5;

    path.moveTo(
      position.dx - arrowSize * cos(angle1),
      position.dy - arrowSize * sin(angle1),
    );
    path.lineTo(position.dx, position.dy);
    path.lineTo(
      position.dx - arrowSize * cos(angle2),
      position.dy - arrowSize * sin(angle2),
    );

    canvas.drawPath(path, paint);
  }

  /// Draw empty message
  void _drawEmptyMessage(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'No stroke data available',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(StrokePainter oldDelegate) {
    return oldDelegate.currentStrokeIndex != currentStrokeIndex ||
        oldDelegate.animationProgress != animationProgress;
  }
}