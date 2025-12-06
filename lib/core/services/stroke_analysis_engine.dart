import 'dart:ui';
import 'dart:math' as math;
import '../../data/models/stroke_tracking_model.dart';

/// Engine to analyze strokes
class StrokeAnalysisEngine {
  /// Analyze stroke count match
  static StrokeCountAnalysis analyzeStrokeCount({
    required List<TrackedStroke> drawnStrokes,
    required int expectedStrokeCount,
  }) {
    int drawn = drawnStrokes.length;
    int expected = expectedStrokeCount;
    int difference = (drawn - expected).abs();

    double score;
    String feedback;

    if (difference == 0) {
      score = 1.0;
      feedback = 'Perfect stroke count!';
    } else if (difference == 1) {
      score = 0.8;
      feedback = 'Close! ${difference} stroke off.';
    } else if (difference == 2) {
      score = 0.6;
      feedback = '${difference} strokes off.';
    } else {
      score = 0.4;
      feedback = 'Too many or too few strokes.';
    }

    return StrokeCountAnalysis(
      drawnCount: drawn,
      expectedCount: expected,
      difference: difference,
      score: score,
      feedback: feedback,
    );
  }

  /// Analyze stroke order
  static StrokeOrderAnalysis analyzeStrokeOrder({
    required List<TrackedStroke> drawnStrokes,
    required List<ExpectedStrokeData> expectedStrokes,
  }) {
    if (drawnStrokes.isEmpty || expectedStrokes.isEmpty) {
      return StrokeOrderAnalysis(
        correctOrderCount: 0,
        totalStrokes: expectedStrokes.length,
        score: 0.0,
        feedback: 'No strokes drawn',
      );
    }

    int correctOrder = 0;
    int minLength = math.min(drawnStrokes.length, expectedStrokes.length);

    for (int i = 0; i < minLength; i++) {
      // Check if drawn stroke matches expected stroke at this position
      if (_strokesMatchPosition(drawnStrokes[i], expectedStrokes[i])) {
        correctOrder++;
      }
    }

    double score = correctOrder / expectedStrokes.length;
    String feedback = correctOrder == expectedStrokes.length
        ? 'Perfect stroke order!'
        : 'Some strokes in wrong order';

    return StrokeOrderAnalysis(
      correctOrderCount: correctOrder,
      totalStrokes: expectedStrokes.length,
      score: score,
      feedback: feedback,
    );
  }

  /// Analyze stroke directions
  static StrokeDirectionAnalysis analyzeStrokeDirections({
    required List<TrackedStroke> drawnStrokes,
    required List<ExpectedStrokeData> expectedStrokes,
  }) {
    if (drawnStrokes.isEmpty || expectedStrokes.isEmpty) {
      return StrokeDirectionAnalysis(
        correctDirections: 0,
        totalStrokes: expectedStrokes.length,
        score: 0.0,
        feedback: 'No strokes to analyze',
      );
    }

    int correctDirections = 0;
    int minLength = math.min(drawnStrokes.length, expectedStrokes.length);

    for (int i = 0; i < minLength; i++) {
      if (_directionsMatch(
        drawnStrokes[i].direction,
        expectedStrokes[i].direction,
      )) {
        correctDirections++;
      }
    }

    double score = correctDirections / expectedStrokes.length;
    String feedback = correctDirections == expectedStrokes.length
        ? 'Excellent stroke directions!'
        : 'Check stroke directions';

    return StrokeDirectionAnalysis(
      correctDirections: correctDirections,
      totalStrokes: expectedStrokes.length,
      score: score,
      feedback: feedback,
    );
  }

  /// Check if two strokes match position
  static bool _strokesMatchPosition(
      TrackedStroke drawn,
      ExpectedStrokeData expected,
      ) {
    // Check if start and end points are close enough
    double startDistance = _distance(drawn.startPoint, expected.startPoint);
    double endDistance = _distance(drawn.endPoint, expected.endPoint);

    // Tolerance: 100 pixels
    const double tolerance = 100.0;

    return startDistance < tolerance && endDistance < tolerance;
  }

  /// Check if directions match
  static bool _directionsMatch(
      StrokeDirection drawn,
      StrokeDirection expected,
      ) {
    // Exact match
    if (drawn == expected) return true;

    // Allow adjacent directions (e.g., right and upRight)
    List<StrokeDirection> adjacentDirections = _getAdjacentDirections(expected);
    return adjacentDirections.contains(drawn);
  }

  /// Get adjacent directions for a direction
  static List<StrokeDirection> _getAdjacentDirections(StrokeDirection dir) {
    switch (dir) {
      case StrokeDirection.up:
        return [StrokeDirection.upLeft, StrokeDirection.upRight];
      case StrokeDirection.upRight:
        return [StrokeDirection.up, StrokeDirection.right];
      case StrokeDirection.right:
        return [StrokeDirection.upRight, StrokeDirection.downRight];
      case StrokeDirection.downRight:
        return [StrokeDirection.right, StrokeDirection.down];
      case StrokeDirection.down:
        return [StrokeDirection.downRight, StrokeDirection.downLeft];
      case StrokeDirection.downLeft:
        return [StrokeDirection.down, StrokeDirection.left];
      case StrokeDirection.left:
        return [StrokeDirection.downLeft, StrokeDirection.upLeft];
      case StrokeDirection.upLeft:
        return [StrokeDirection.left, StrokeDirection.up];
      case StrokeDirection.unknown:
        return [];
    }
  }

  /// Calculate distance between points
  static double _distance(Offset p1, Offset p2) {
    return math.sqrt(math.pow(p2.dx - p1.dx, 2) + math.pow(p2.dy - p1.dy, 2));
  }

  /// Analyze overall stroke quality
  static double analyzeOverallQuality(List<TrackedStroke> strokes) {
    if (strokes.isEmpty) return 0.0;

    double totalQuality = 0.0;

    for (var stroke in strokes) {
      // Check smoothness (less curvature = more smooth for basic strokes)
      double curvature = stroke.getCurvature();
      double smoothness = 1.0 - math.min(curvature / 2.0, 1.0);

      // Check length (should be reasonable)
      double lengthScore = stroke.length > 50 ? 1.0 : stroke.length / 50;

      // Check point count (should have enough detail)
      double pointScore = stroke.points.length > 10
          ? 1.0
          : stroke.points.length / 10;

      // Average quality
      double strokeQuality = (smoothness + lengthScore + pointScore) / 3.0;
      totalQuality += strokeQuality;
    }

    return totalQuality / strokes.length;
  }
}

/// Stroke count analysis result
class StrokeCountAnalysis {
  final int drawnCount;
  final int expectedCount;
  final int difference;
  final double score;
  final String feedback;

  StrokeCountAnalysis({
    required this.drawnCount,
    required this.expectedCount,
    required this.difference,
    required this.score,
    required this.feedback,
  });
}

/// Stroke order analysis result
class StrokeOrderAnalysis {
  final int correctOrderCount;
  final int totalStrokes;
  final double score;
  final String feedback;

  StrokeOrderAnalysis({
    required this.correctOrderCount,
    required this.totalStrokes,
    required this.score,
    required this.feedback,
  });
}

/// Stroke direction analysis result
class StrokeDirectionAnalysis {
  final int correctDirections;
  final int totalStrokes;
  final double score;
  final String feedback;

  StrokeDirectionAnalysis({
    required this.correctDirections,
    required this.totalStrokes,
    required this.score,
    required this.feedback,
  });
}

/// Expected stroke data
class ExpectedStrokeData {
  final Offset startPoint;
  final Offset endPoint;
  final StrokeDirection direction;
  final int order;
  final double expectedLength;

  ExpectedStrokeData({
    required this.startPoint,
    required this.endPoint,
    required this.direction,
    required this.order,
    required this.expectedLength,
  });
}