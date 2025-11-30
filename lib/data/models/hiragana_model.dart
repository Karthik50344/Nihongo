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

/// Stroke data using SVG Path
class HiraganaStroke {
  final String svgPath; // SVG path string (e.g., "M 10 10 L 50 50 Q 80 80 100 100")
  final int order;

  const HiraganaStroke({
    required this.svgPath,
    required this.order,
  }) : assert(svgPath != '', 'SVG path cannot be empty');
}