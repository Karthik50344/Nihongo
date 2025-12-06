import 'dart:ui';
import 'dart:math' as math;
import '../../data/models/stroke_tracking_model.dart';
import 'stroke_analysis_engine.dart';

/// Engine to match stroke shapes
class ShapeMatchingEngine {
  /// Match individual stroke shape
  static StrokeShapeMatch matchStrokeShape({
    required TrackedStroke drawnStroke,
    required ExpectedStrokeData expectedStroke,
  }) {
    // 1. Position matching (start and end points)
    double positionScore = _calculatePositionMatch(
      drawnStroke,
      expectedStroke,
    );

    // 2. Direction matching
    double directionScore = _calculateDirectionMatch(
      drawnStroke,
      expectedStroke,
    );

    // 3. Length matching
    double lengthScore = _calculateLengthMatch(
      drawnStroke,
      expectedStroke,
    );

    // 4. Shape similarity (curvature, path)
    double shapeScore = _calculateShapeMatch(
      drawnStroke,
      expectedStroke,
    );

    // Weighted average
    double totalScore = (
        positionScore * 0.3 +
            directionScore * 0.3 +
            lengthScore * 0.2 +
            shapeScore * 0.2
    );

    return StrokeShapeMatch(
      positionScore: positionScore,
      directionScore: directionScore,
      lengthScore: lengthScore,
      shapeScore: shapeScore,
      totalScore: totalScore,
    );
  }

  /// Calculate position match score
  static double _calculatePositionMatch(
      TrackedStroke drawn,
      ExpectedStrokeData expected,
      ) {
    // Calculate distances
    double startDistance = _distance(drawn.startPoint, expected.startPoint);
    double endDistance = _distance(drawn.endPoint, expected.endPoint);

    // Normalize distances (assuming max canvas size of 1000)
    double maxDistance = 1000.0;
    double startScore = 1.0 - math.min(startDistance / maxDistance, 1.0);
    double endScore = 1.0 - math.min(endDistance / maxDistance, 1.0);

    return (startScore + endScore) / 2.0;
  }

  /// Calculate direction match score
  static double _calculateDirectionMatch(
      TrackedStroke drawn,
      ExpectedStrokeData expected,
      ) {
    if (drawn.direction == expected.direction) {
      return 1.0;
    }

    // Check if directions are adjacent
    List<StrokeDirection> adjacent = _getAdjacentDirections(expected.direction);
    if (adjacent.contains(drawn.direction)) {
      return 0.7;
    }

    // Check if directions are opposite
    if (_areOppositeDirections(drawn.direction, expected.direction)) {
      return 0.3;
    }

    return 0.5;
  }

  /// Calculate length match score
  static double _calculateLengthMatch(
      TrackedStroke drawn,
      ExpectedStrokeData expected,
      ) {
    double drawnLength = drawn.length;
    double expectedLength = expected.expectedLength;

    if (expectedLength == 0) return 1.0;

    double ratio = drawnLength / expectedLength;

    // Perfect match
    if (ratio >= 0.8 && ratio <= 1.2) {
      return 1.0;
    }

    // Close match
    if (ratio >= 0.6 && ratio <= 1.4) {
      return 0.8;
    }

    // Acceptable match
    if (ratio >= 0.4 && ratio <= 1.6) {
      return 0.6;
    }

    return 0.4;
  }

  /// Calculate shape match score
  static double _calculateShapeMatch(
      TrackedStroke drawn,
      ExpectedStrokeData expected,
      ) {
    // Compare curvature
    double drawnCurvature = drawn.getCurvature();

    // Calculate expected curvature from expected stroke
    double expectedCurvature = _calculateExpectedCurvature(expected);

    double curvatureDiff = (drawnCurvature - expectedCurvature).abs();
    double curvatureScore = 1.0 - math.min(curvatureDiff / 2.0, 1.0);

    // Compare bounding box aspect ratio
    double aspectRatioScore = _compareAspectRatios(drawn, expected);

    return (curvatureScore + aspectRatioScore) / 2.0;
  }

  /// Calculate expected curvature
  static double _calculateExpectedCurvature(ExpectedStrokeData expected) {
    // Estimate curvature based on start and end points
    // Straight line = 0, curved = higher value
    double dx = (expected.endPoint.dx - expected.startPoint.dx).abs();
    double dy = (expected.endPoint.dy - expected.startPoint.dy).abs();

    // If very different, likely more curved
    double ratio = dx > 0 ? dy / dx : 1.0;
    if (ratio > 2.0 || ratio < 0.5) {
      return 0.5; // Some curvature expected
    }
    return 0.1; // Relatively straight
  }

  /// Compare aspect ratios
  static double _compareAspectRatios(
      TrackedStroke drawn,
      ExpectedStrokeData expected,
      ) {
    Rect drawnBox = drawn.boundingBox;
    double drawnAspect = drawnBox.width > 0
        ? drawnBox.height / drawnBox.width
        : 1.0;

    double expectedWidth = (expected.endPoint.dx - expected.startPoint.dx).abs();
    double expectedHeight = (expected.endPoint.dy - expected.startPoint.dy).abs();
    double expectedAspect = expectedWidth > 0
        ? expectedHeight / expectedWidth
        : 1.0;

    double aspectDiff = (drawnAspect - expectedAspect).abs();
    return 1.0 - math.min(aspectDiff, 1.0);
  }

  /// Match complete character shape
  static CharacterShapeMatch matchCharacterShape({
    required List<TrackedStroke> drawnStrokes,
    required List<ExpectedStrokeData> expectedStrokes,
  }) {
    if (drawnStrokes.isEmpty || expectedStrokes.isEmpty) {
      return CharacterShapeMatch(
        individualMatches: [],
        averageScore: 0.0,
        feedback: 'No strokes to match',
      );
    }

    List<StrokeShapeMatch> matches = [];
    int minLength = math.min(drawnStrokes.length, expectedStrokes.length);

    // Match each drawn stroke with corresponding expected stroke
    for (int i = 0; i < minLength; i++) {
      StrokeShapeMatch match = matchStrokeShape(
        drawnStroke: drawnStrokes[i],
        expectedStroke: expectedStrokes[i],
      );
      matches.add(match);
    }

    // Calculate average score
    double totalScore = matches.fold(
      0.0,
          (sum, match) => sum + match.totalScore,
    );
    double averageScore = totalScore / matches.length;

    // Generate feedback
    String feedback = _generateShapeFeedback(averageScore, matches);

    return CharacterShapeMatch(
      individualMatches: matches,
      averageScore: averageScore,
      feedback: feedback,
    );
  }

  /// Generate feedback for shape matching
  static String _generateShapeFeedback(
      double averageScore,
      List<StrokeShapeMatch> matches,
      ) {
    if (averageScore >= 0.9) {
      return 'Excellent shape!';
    } else if (averageScore >= 0.75) {
      return 'Good shape match!';
    } else if (averageScore >= 0.6) {
      return 'Shape is close!';
    } else {
      // Find what needs improvement
      double avgPosition = matches.fold(
        0.0,
            (sum, m) => sum + m.positionScore,
      ) / matches.length;

      double avgDirection = matches.fold(
        0.0,
            (sum, m) => sum + m.directionScore,
      ) / matches.length;

      if (avgPosition < 0.6) {
        return 'Check stroke positions';
      } else if (avgDirection < 0.6) {
        return 'Check stroke directions';
      } else {
        return 'Keep practicing the shape';
      }
    }
  }

  /// Get adjacent directions
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

  /// Check if directions are opposite
  static bool _areOppositeDirections(
      StrokeDirection dir1,
      StrokeDirection dir2,
      ) {
    Map<StrokeDirection, StrokeDirection> opposites = {
      StrokeDirection.up: StrokeDirection.down,
      StrokeDirection.down: StrokeDirection.up,
      StrokeDirection.left: StrokeDirection.right,
      StrokeDirection.right: StrokeDirection.left,
      StrokeDirection.upLeft: StrokeDirection.downRight,
      StrokeDirection.downRight: StrokeDirection.upLeft,
      StrokeDirection.upRight: StrokeDirection.downLeft,
      StrokeDirection.downLeft: StrokeDirection.upRight,
    };

    return opposites[dir1] == dir2;
  }

  /// Calculate distance
  static double _distance(Offset p1, Offset p2) {
    return math.sqrt(math.pow(p2.dx - p1.dx, 2) + math.pow(p2.dy - p1.dy, 2));
  }
}

/// Individual stroke shape match result
class StrokeShapeMatch {
  final double positionScore;
  final double directionScore;
  final double lengthScore;
  final double shapeScore;
  final double totalScore;

  StrokeShapeMatch({
    required this.positionScore,
    required this.directionScore,
    required this.lengthScore,
    required this.shapeScore,
    required this.totalScore,
  });
}

/// Complete character shape match result
class CharacterShapeMatch {
  final List<StrokeShapeMatch> individualMatches;
  final double averageScore;
  final String feedback;

  CharacterShapeMatch({
    required this.individualMatches,
    required this.averageScore,
    required this.feedback,
  });
}