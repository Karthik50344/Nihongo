import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../data/models/stroke_tracking_model.dart';

/// Drawing canvas widget for practice with stroke tracking
class DrawingCanvasWidget extends StatefulWidget {
  const DrawingCanvasWidget({super.key});

  @override
  State<DrawingCanvasWidget> createState() => DrawingCanvasWidgetState();
}

class DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  List<DrawingPath> _paths = [];
  DrawingPath? _currentPath;
  int _strokeOrder = 0;
  DateTime? _currentStrokeStartTime;

  /// Get tracked strokes for validation
  List<TrackedStroke> getTrackedStrokes() {
    List<TrackedStroke> trackedStrokes = [];

    for (int i = 0; i < _paths.length; i++) {
      try {
        TrackedStroke tracked = TrackedStroke.fromPoints(
          points: _paths[i].points,
          order: i + 1,
          startTime: _paths[i].startTime,
          endTime: _paths[i].endTime,
        );
        trackedStrokes.add(tracked);
      } catch (e) {
        // Skip invalid strokes
        continue;
      }
    }

    return trackedStrokes;
  }

  /// Clear the canvas
  void clear() {
    setState(() {
      _paths.clear();
      _currentPath = null;
      _strokeOrder = 0;
    });
  }

  void _onPanStart(DragStartDetails details) {
    _currentStrokeStartTime = DateTime.now();
    setState(() {
      _currentPath = DrawingPath(
        points: [details.localPosition],
        color: AppColors.primaryRed,
        strokeWidth: 8.0,
        startTime: _currentStrokeStartTime!,
        endTime: _currentStrokeStartTime!, // Will be updated on end
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentPath?.points.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPath != null && _currentPath!.points.isNotEmpty) {
      setState(() {
        // Update end time
        _currentPath = DrawingPath(
          points: _currentPath!.points,
          color: _currentPath!.color,
          strokeWidth: _currentPath!.strokeWidth,
          startTime: _currentPath!.startTime,
          endTime: DateTime.now(),
        );

        _paths.add(_currentPath!);
        _strokeOrder++;
        _currentPath = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(
          color: AppColors.primaryRed.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Stack(
          children: [
            // Grid lines for guidance
            CustomPaint(
              painter: GridPainter(isDark: isDark),
              size: Size.infinite,
            ),

            // Drawing canvas
            GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: DrawingPainter(
                  paths: _paths,
                  currentPath: _currentPath,
                ),
                size: Size.infinite,
              ),
            ),

            // Helper text and stroke counter
            if (_paths.isEmpty && _currentPath == null)
              Center(
                child: Text(
                  'Draw here',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.grey.withOpacity(0.3),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),

            // Stroke counter
            if (_paths.isNotEmpty || _currentPath != null)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Strokes: ${_paths.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Drawing path model with timing
class DrawingPath {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final DateTime startTime;
  final DateTime endTime;

  DrawingPath({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.startTime,
    required this.endTime,
  });
}

/// Custom painter for drawing
class DrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;
  final DrawingPath? currentPath;

  DrawingPainter({
    required this.paths,
    this.currentPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed paths
    for (final path in paths) {
      _drawPath(canvas, path);
    }

    // Draw current path
    if (currentPath != null) {
      _drawPath(canvas, currentPath!);
    }
  }

  void _drawPath(Canvas canvas, DrawingPath path) {
    if (path.points.isEmpty) return;

    final paint = Paint()
      ..color = path.color
      ..strokeWidth = path.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final pathToDraw = Path();
    pathToDraw.moveTo(path.points[0].dx, path.points[0].dy);

    for (int i = 1; i < path.points.length; i++) {
      pathToDraw.lineTo(path.points[i].dx, path.points[i].dy);
    }

    canvas.drawPath(pathToDraw, paint);
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.paths != paths || oldDelegate.currentPath != currentPath;
  }
}

/// Custom painter for grid
class GridPainter extends CustomPainter {
  final bool isDark;

  GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.grey).withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Draw horizontal center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Draw diagonal guides
    final dashedPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.grey).withOpacity(0.1)
      ..strokeWidth = 1;

    // Top-left to bottom-right
    _drawDashedLine(
      canvas,
      Offset(0, 0),
      Offset(size.width, size.height),
      dashedPaint,
    );

    // Top-right to bottom-left
    _drawDashedLine(
      canvas,
      Offset(size.width, 0),
      Offset(0, size.height),
      dashedPaint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 10;
    const dashSpace = 5;
    final distance = (end - start).distance;
    final normalizedDx = (end.dx - start.dx) / distance;
    final normalizedDy = (end.dy - start.dy) / distance;

    double currentDistance = 0;
    while (currentDistance < distance) {
      final startPoint = Offset(
        start.dx + normalizedDx * currentDistance,
        start.dy + normalizedDy * currentDistance,
      );
      currentDistance += dashWidth;
      final endPoint = Offset(
        start.dx + normalizedDx * currentDistance.clamp(0, distance),
        start.dy + normalizedDy * currentDistance.clamp(0, distance),
      );
      canvas.drawLine(startPoint, endPoint, paint);
      currentDistance += dashSpace;
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}