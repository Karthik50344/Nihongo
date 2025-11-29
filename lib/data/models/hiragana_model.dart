import 'package:equatable/equatable.dart';

/// Hiragana character model
class HiraganaModel extends Equatable {
  final String character;
  final String romaji;
  final String pronunciation;
  final List<HiraganaStroke> strokes;
  final String category; // vowel, k-group, s-group, etc.

  const HiraganaModel({
    required this.character,
    required this.romaji,
    required this.pronunciation,
    required this.strokes,
    required this.category,
  });

  @override
  List<Object?> get props => [character, romaji, pronunciation, category];
}

/// Stroke data for drawing animation
class HiraganaStroke {
  final List<StrokePoint> points;
  final int order;

  const HiraganaStroke({
    required this.points,
    required this.order,
  });
}

/// Point in a stroke
class StrokePoint {
  final double x;
  final double y;

  const StrokePoint(this.x, this.y);
}