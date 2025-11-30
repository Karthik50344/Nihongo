import 'package:equatable/equatable.dart';

/// Katakana character model
class KatakanaModel extends Equatable {
  final String character;
  final String romaji;
  final String pronunciation;
  final String category;

  const KatakanaModel({
    required this.character,
    required this.romaji,
    required this.pronunciation,
    required this.category,
  });

  @override
  List<Object?> get props => [character, romaji, pronunciation, category];
}