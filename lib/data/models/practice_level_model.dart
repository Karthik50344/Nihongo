import 'package:equatable/equatable.dart';

/// Practice level model
class PracticeLevelModel extends Equatable {
  final String id;
  final String name;
  final int levelNumber;
  final String category; // 'hiragana' or 'katakana'
  final String characterGroup; // 'vowel', 'k-group', etc.
  final List<String> characters;
  final int requiredScore; // Minimum score to pass
  final bool isUnlocked;

  const PracticeLevelModel({
    required this.id,
    required this.name,
    required this.levelNumber,
    required this.category,
    required this.characterGroup,
    required this.characters,
    required this.requiredScore,
    this.isUnlocked = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    levelNumber,
    category,
    characterGroup,
    characters,
    requiredScore,
    isUnlocked,
  ];

  PracticeLevelModel copyWith({
    String? id,
    String? name,
    int? levelNumber,
    String? category,
    String? characterGroup,
    List<String>? characters,
    int? requiredScore,
    bool? isUnlocked,
  }) {
    return PracticeLevelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      levelNumber: levelNumber ?? this.levelNumber,
      category: category ?? this.category,
      characterGroup: characterGroup ?? this.characterGroup,
      characters: characters ?? this.characters,
      requiredScore: requiredScore ?? this.requiredScore,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'levelNumber': levelNumber,
      'category': category,
      'characterGroup': characterGroup,
      'characters': characters,
      'requiredScore': requiredScore,
      'isUnlocked': isUnlocked,
    };
  }

  factory PracticeLevelModel.fromJson(Map<String, dynamic> json) {
    return PracticeLevelModel(
      id: json['id'] as String,
      name: json['name'] as String,
      levelNumber: json['levelNumber'] as int,
      category: json['category'] as String,
      characterGroup: json['characterGroup'] as String,
      characters: List<String>.from(json['characters'] as List),
      requiredScore: json['requiredScore'] as int,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }
}