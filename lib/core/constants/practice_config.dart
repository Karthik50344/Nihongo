/// Practice configuration constants
class PracticeConfig {
  PracticeConfig._();

  /// Minimum score required to pass a level (percentage)
  static const int minimumPassScore = 80;

  /// Minimum validation score to consider an answer correct (percentage)
  static const double minimumCorrectScore = 60.0;

  /// Score thresholds for feedback
  static const double excellentScore = 80.0;
  static const double goodScore = 60.0;
  static const double almostScore = 40.0;

  /// Minimum number of points required in a drawing
  static const int minimumDrawingPoints = 10;

  /// Feedback duration in milliseconds
  static const int feedbackDuration = 700;

  /// Delay before moving to next question (milliseconds)
  static const int nextQuestionDelay = 800;

  /// Canvas clear delay (milliseconds)
  static const int canvasClearDelay = 300;
}