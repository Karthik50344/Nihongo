import 'dart:ui';
import 'dart:math' as math;
import '../constants/practice_config.dart';
import '../../data/models/stroke_tracking_model.dart';
import 'stroke_analysis_engine.dart';
import 'shape_matching_engine.dart';

/// Comprehensive character validator using all three engines
class CharacterValidator {
  /// Validate drawn character with complete analysis
  static ValidationResult validateCharacter({
    required List<TrackedStroke> drawnStrokes,
    required String expectedCharacter,
  }) {
    if (drawnStrokes.isEmpty) {
      return ValidationResult(
        finalScore: 0.0,
        strokeCountScore: 0.0,
        strokeOrderScore: 0.0,
        strokeDirectionScore: 0.0,
        shapeMatchScore: 0.0,
        qualityScore: 0.0,
        feedback: 'No strokes drawn',
        detailedFeedback: [],
      );
    }

    // Get expected stroke data for the character
    List<ExpectedStrokeData> expectedStrokes =
    _getExpectedStrokes(expectedCharacter);

    if (expectedStrokes.isEmpty) {
      // Fallback to basic validation
      return _basicValidation(drawnStrokes);
    }

    // 1. Stroke Count Analysis (20%)
    StrokeCountAnalysis countAnalysis = StrokeAnalysisEngine.analyzeStrokeCount(
      drawnStrokes: drawnStrokes,
      expectedStrokeCount: expectedStrokes.length,
    );

    // 2. Stroke Order Analysis (25%)
    StrokeOrderAnalysis orderAnalysis = StrokeAnalysisEngine.analyzeStrokeOrder(
      drawnStrokes: drawnStrokes,
      expectedStrokes: expectedStrokes,
    );

    // 3. Stroke Direction Analysis (20%)
    StrokeDirectionAnalysis directionAnalysis =
    StrokeAnalysisEngine.analyzeStrokeDirections(
      drawnStrokes: drawnStrokes,
      expectedStrokes: expectedStrokes,
    );

    // 4. Shape Matching Analysis (25%)
    CharacterShapeMatch shapeMatch = ShapeMatchingEngine.matchCharacterShape(
      drawnStrokes: drawnStrokes,
      expectedStrokes: expectedStrokes,
    );

    // 5. Overall Quality Analysis (10%)
    double qualityScore = StrokeAnalysisEngine.analyzeOverallQuality(
      drawnStrokes,
    );

    // Calculate weighted final score
    double finalScore = (
        countAnalysis.score * 0.20 +
            orderAnalysis.score * 0.25 +
            directionAnalysis.score * 0.20 +
            shapeMatch.averageScore * 0.25 +
            qualityScore * 0.10
    ) * 100;

    // Generate detailed feedback
    List<String> detailedFeedback = _generateDetailedFeedback(
      countAnalysis: countAnalysis,
      orderAnalysis: orderAnalysis,
      directionAnalysis: directionAnalysis,
      shapeMatch: shapeMatch,
      qualityScore: qualityScore,
    );

    // Generate overall feedback
    String overallFeedback = _generateOverallFeedback(finalScore);

    return ValidationResult(
      finalScore: finalScore,
      strokeCountScore: countAnalysis.score * 100,
      strokeOrderScore: orderAnalysis.score * 100,
      strokeDirectionScore: directionAnalysis.score * 100,
      shapeMatchScore: shapeMatch.averageScore * 100,
      qualityScore: qualityScore * 100,
      feedback: overallFeedback,
      detailedFeedback: detailedFeedback,
    );
  }

  /// Basic validation fallback
  static ValidationResult _basicValidation(List<TrackedStroke> drawnStrokes) {
    // Check if strokes have enough points
    int totalPoints = 0;
    for (var stroke in drawnStrokes) {
      totalPoints += stroke.points.length;
    }

    if (totalPoints < PracticeConfig.minimumDrawingPoints) {
      return ValidationResult(
        finalScore: 30.0,
        strokeCountScore: 40.0,
        strokeOrderScore: 30.0,
        strokeDirectionScore: 30.0,
        shapeMatchScore: 20.0,
        qualityScore: 30.0,
        feedback: 'Draw more carefully',
        detailedFeedback: ['Not enough detail in drawing'],
      );
    }

    // Calculate quality
    double quality = StrokeAnalysisEngine.analyzeOverallQuality(drawnStrokes);

    // Calculate coverage
    double coverage = _calculateCoverage(drawnStrokes);

    double score = 40.0 + (quality * 30) + (coverage * 30);

    return ValidationResult(
      finalScore: score,
      strokeCountScore: 60.0,
      strokeOrderScore: quality * 100,
      strokeDirectionScore: 60.0,
      shapeMatchScore: coverage * 100,
      qualityScore: quality * 100,
      feedback: score >= 60 ? 'Good attempt!' : 'Keep practicing!',
      detailedFeedback: ['Character pattern not in database - using basic validation'],
    );
  }

  /// Calculate coverage
  static double _calculateCoverage(List<TrackedStroke> strokes) {
    if (strokes.isEmpty) return 0.0;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var stroke in strokes) {
      for (var point in stroke.points) {
        minX = math.min(minX, point.dx);
        maxX = math.max(maxX, point.dx);
        minY = math.min(minY, point.dy);
        maxY = math.max(maxY, point.dy);
      }
    }

    double width = maxX - minX;
    double height = maxY - minY;

    double coverage = (width * height) / (1000 * 1000);
    return math.min(coverage / 0.3, 1.0);
  }

  /// Generate detailed feedback
  static List<String> _generateDetailedFeedback({
    required StrokeCountAnalysis countAnalysis,
    required StrokeOrderAnalysis orderAnalysis,
    required StrokeDirectionAnalysis directionAnalysis,
    required CharacterShapeMatch shapeMatch,
    required double qualityScore,
  }) {
    List<String> feedback = [];

    // Stroke count feedback
    if (countAnalysis.score < 0.8) {
      feedback.add('• ${countAnalysis.feedback}');
    }

    // Stroke order feedback
    if (orderAnalysis.score < 0.8) {
      feedback.add('• ${orderAnalysis.feedback}');
    }

    // Direction feedback
    if (directionAnalysis.score < 0.8) {
      feedback.add('• ${directionAnalysis.feedback}');
    }

    // Shape feedback
    if (shapeMatch.averageScore < 0.8) {
      feedback.add('• ${shapeMatch.feedback}');
    }

    // Quality feedback
    if (qualityScore < 0.7) {
      feedback.add('• Draw more smoothly');
    }

    if (feedback.isEmpty) {
      feedback.add('• Excellent work!');
    }

    return feedback;
  }

  /// Generate overall feedback
  static String _generateOverallFeedback(double score) {
    if (score >= 90) {
      return 'Perfect! 完璧！';
    } else if (score >= 80) {
      return 'Excellent! すばらしい！';
    } else if (score >= 70) {
      return 'Very Good! とても良い！';
    } else if (score >= 60) {
      return 'Good! 良い！';
    } else if (score >= 50) {
      return 'Almost there! もう少し！';
    } else {
      return 'Keep practicing! 頑張って！';
    }
  }

  /// Get expected strokes for a character
  static List<ExpectedStrokeData> _getExpectedStrokes(String character) {
    final Map<String, List<ExpectedStrokeData>> strokeDatabase = {
      // Vowels (あ行)
      'あ': [
        ExpectedStrokeData(
          startPoint: Offset(300, 200),
          endPoint: Offset(500, 600),
          direction: StrokeDirection.downRight,
          order: 1,
          expectedLength: 450,
        ),
        ExpectedStrokeData(
          startPoint: Offset(200, 400),
          endPoint: Offset(800, 400),
          direction: StrokeDirection.right,
          order: 2,
          expectedLength: 600,
        ),
        ExpectedStrokeData(
          startPoint: Offset(700, 200),
          endPoint: Offset(700, 800),
          direction: StrokeDirection.down,
          order: 3,
          expectedLength: 600,
        ),
      ],
      'い': [
        ExpectedStrokeData(
          startPoint: Offset(400, 200),
          endPoint: Offset(400, 600),
          direction: StrokeDirection.down,
          order: 1,
          expectedLength: 400,
        ),
        ExpectedStrokeData(
          startPoint: Offset(600, 300),
          endPoint: Offset(600, 800),
          direction: StrokeDirection.down,
          order: 2,
          expectedLength: 500,
        ),
      ],
      'う': [
        ExpectedStrokeData(
          startPoint: Offset(300, 300),
          endPoint: Offset(600, 300),
          direction: StrokeDirection.right,
          order: 1,
          expectedLength: 300,
        ),
        ExpectedStrokeData(
          startPoint: Offset(400, 300),
          endPoint: Offset(300, 700),
          direction: StrokeDirection.downLeft,
          order: 2,
          expectedLength: 420,
        ),
      ],
      'え': [
        ExpectedStrokeData(
          startPoint: Offset(300, 300),
          endPoint: Offset(700, 300),
          direction: StrokeDirection.right,
          order: 1,
          expectedLength: 400,
        ),
        ExpectedStrokeData(
          startPoint: Offset(300, 600),
          endPoint: Offset(700, 600),
          direction: StrokeDirection.right,
          order: 2,
          expectedLength: 400,
        ),
      ],
      'お': [
        ExpectedStrokeData(
          startPoint: Offset(300, 200),
          endPoint: Offset(600, 200),
          direction: StrokeDirection.right,
          order: 1,
          expectedLength: 300,
        ),
        ExpectedStrokeData(
          startPoint: Offset(300, 500),
          endPoint: Offset(700, 500),
          direction: StrokeDirection.right,
          order: 2,
          expectedLength: 400,
        ),
        ExpectedStrokeData(
          startPoint: Offset(500, 200),
          endPoint: Offset(500, 800),
          direction: StrokeDirection.down,
          order: 3,
          expectedLength: 600,
        ),
      ],
      // Add more characters as needed...
    };

    return strokeDatabase[character] ?? [];
  }
}

/// Complete validation result
class ValidationResult {
  final double finalScore;
  final double strokeCountScore;
  final double strokeOrderScore;
  final double strokeDirectionScore;
  final double shapeMatchScore;
  final double qualityScore;
  final String feedback;
  final List<String> detailedFeedback;

  ValidationResult({
    required this.finalScore,
    required this.strokeCountScore,
    required this.strokeOrderScore,
    required this.strokeDirectionScore,
    required this.shapeMatchScore,
    required this.qualityScore,
    required this.feedback,
    required this.detailedFeedback,
  });

  bool get isPassed => finalScore >= PracticeConfig.minimumCorrectScore;
}