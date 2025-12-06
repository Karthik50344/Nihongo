import 'dart:ui';
import 'dart:math' as math;

/// Tracked stroke with detailed information
class TrackedStroke {
  final List<Offset> points;
  final int order; // Order in which stroke was drawn (1st, 2nd, 3rd...)
  final DateTime startTime;
  final DateTime endTime;
  final double length;
  final StrokeDirection direction;
  final List<double> angles; // Angles at each point
  final Offset startPoint;
  final Offset endPoint;
  final Rect boundingBox;

  TrackedStroke({
    required this.points,
    required this.order,
    required this.startTime,
    required this.endTime,
    required this.length,
    required this.direction,
    required this.angles,
    required this.startPoint,
    required this.endPoint,
    required this.boundingBox,
  });

  /// Create tracked stroke from raw points
  factory TrackedStroke.fromPoints({
    required List<Offset> points,
    required int order,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    if (points.isEmpty) {
      throw ArgumentError('Points cannot be empty');
    }

    // Calculate stroke length
    double length = 0.0;
    for (int i = 1; i < points.length; i++) {
      length += _distance(points[i - 1], points[i]);
    }

    // Calculate angles between consecutive points
    List<double> angles = [];
    for (int i = 1; i < points.length; i++) {
      double angle = math.atan2(
        points[i].dy - points[i - 1].dy,
        points[i].dx - points[i - 1].dx,
      );
      angles.add(angle);
    }

    // Determine primary direction
    StrokeDirection direction = _calculatePrimaryDirection(angles);

    // Calculate bounding box
    Rect boundingBox = _calculateBoundingBox(points);

    return TrackedStroke(
      points: points,
      order: order,
      startTime: startTime,
      endTime: endTime,
      length: length,
      direction: direction,
      angles: angles,
      startPoint: points.first,
      endPoint: points.last,
      boundingBox: boundingBox,
    );
  }

  /// Calculate distance between two points
  static double _distance(Offset p1, Offset p2) {
    return math.sqrt(math.pow(p2.dx - p1.dx, 2) + math.pow(p2.dy - p1.dy, 2));
  }

  /// Calculate primary direction of stroke
  static StrokeDirection _calculatePrimaryDirection(List<double> angles) {
    if (angles.isEmpty) return StrokeDirection.unknown;

    // Average angle
    double avgAngle = angles.reduce((a, b) => a + b) / angles.length;

    // Convert to degrees
    double degrees = avgAngle * 180 / math.pi;

    // Normalize to 0-360
    if (degrees < 0) degrees += 360;

    // Determine direction (8 directions)
    if (degrees >= 337.5 || degrees < 22.5) {
      return StrokeDirection.right;
    } else if (degrees >= 22.5 && degrees < 67.5) {
      return StrokeDirection.downRight;
    } else if (degrees >= 67.5 && degrees < 112.5) {
      return StrokeDirection.down;
    } else if (degrees >= 112.5 && degrees < 157.5) {
      return StrokeDirection.downLeft;
    } else if (degrees >= 157.5 && degrees < 202.5) {
      return StrokeDirection.left;
    } else if (degrees >= 202.5 && degrees < 247.5) {
      return StrokeDirection.upLeft;
    } else if (degrees >= 247.5 && degrees < 292.5) {
      return StrokeDirection.up;
    } else {
      return StrokeDirection.upRight;
    }
  }

  /// Calculate bounding box
  static Rect _calculateBoundingBox(List<Offset> points) {
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var point in points) {
      minX = math.min(minX, point.dx);
      maxX = math.max(maxX, point.dx);
      minY = math.min(minY, point.dy);
      maxY = math.max(maxY, point.dy);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Get curvature of stroke (0 = straight, 1 = very curved)
  double getCurvature() {
    if (points.length < 3) return 0.0;

    double totalAngleChange = 0.0;
    for (int i = 1; i < angles.length; i++) {
      double angleDiff = (angles[i] - angles[i - 1]).abs();
      // Normalize to 0-π
      if (angleDiff > math.pi) angleDiff = 2 * math.pi - angleDiff;
      totalAngleChange += angleDiff;
    }

    // Normalize by length
    return totalAngleChange / angles.length;
  }

  /// Check if stroke is primarily horizontal
  bool isHorizontal() {
    return direction == StrokeDirection.left ||
        direction == StrokeDirection.right;
  }

  /// Check if stroke is primarily vertical
  bool isVertical() {
    return direction == StrokeDirection.up ||
        direction == StrokeDirection.down;
  }

  /// Check if stroke is diagonal
  bool isDiagonal() {
    return direction == StrokeDirection.upLeft ||
        direction == StrokeDirection.upRight ||
        direction == StrokeDirection.downLeft ||
        direction == StrokeDirection.downRight;
  }
}

/// Stroke direction enum
enum StrokeDirection {
  up,
  upRight,
  right,
  downRight,
  down,
  downLeft,
  left,
  upLeft,
  unknown,
}

/// Extension for stroke direction
extension StrokeDirectionExtension on StrokeDirection {
  String get name {
    switch (this) {
      case StrokeDirection.up:
        return 'Up';
      case StrokeDirection.upRight:
        return 'Up-Right';
      case StrokeDirection.right:
        return 'Right';
      case StrokeDirection.downRight:
        return 'Down-Right';
      case StrokeDirection.down:
        return 'Down';
      case StrokeDirection.downLeft:
        return 'Down-Left';
      case StrokeDirection.left:
        return 'Left';
      case StrokeDirection.upLeft:
        return 'Up-Left';
      case StrokeDirection.unknown:
        return 'Unknown';
    }
  }
}