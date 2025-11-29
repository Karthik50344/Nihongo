import '../models/hiragana_model.dart';

/// Repository for Hiragana data
class HiraganaRepository {
  /// Get all Hiragana characters
  Future<List<HiraganaModel>> getAllHiragana() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _hiraganaData;
  }

  /// Get Hiragana by category
  Future<List<HiraganaModel>> getHiraganaByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _hiraganaData.where((h) => h.category == category).toList();
  }

  /// All Hiragana data with stroke information
  static final List<HiraganaModel> _hiraganaData = [
    // Vowels (あ行)
    HiraganaModel(
      character: 'あ',
      romaji: 'a',
      pronunciation: 'ah',
      category: 'vowel',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.1), StrokePoint(0.5, 0.3), StrokePoint(0.4, 0.6),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.2, 0.4), StrokePoint(0.8, 0.4),
        ]),
        HiraganaStroke(order: 3, points: [
          StrokePoint(0.7, 0.2), StrokePoint(0.7, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'い',
      romaji: 'i',
      pronunciation: 'ee',
      category: 'vowel',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.4, 0.2), StrokePoint(0.4, 0.6),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.6, 0.3), StrokePoint(0.5, 0.5), StrokePoint(0.6, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'う',
      romaji: 'u',
      pronunciation: 'oo',
      category: 'vowel',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.6, 0.3),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.4, 0.3), StrokePoint(0.3, 0.7), StrokePoint(0.7, 0.7),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'え',
      romaji: 'e',
      pronunciation: 'eh',
      category: 'vowel',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.5, 0.2), StrokePoint(0.7, 0.3),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.3, 0.6), StrokePoint(0.7, 0.6), StrokePoint(0.6, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'お',
      romaji: 'o',
      pronunciation: 'oh',
      category: 'vowel',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.2), StrokePoint(0.6, 0.2),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.3, 0.5), StrokePoint(0.7, 0.5),
        ]),
        HiraganaStroke(order: 3, points: [
          StrokePoint(0.5, 0.2), StrokePoint(0.5, 0.8),
        ]),
      ],
    ),

    // K-Group (か行)
    HiraganaModel(
      character: 'か',
      romaji: 'ka',
      pronunciation: 'kah',
      category: 'k-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.2), StrokePoint(0.7, 0.2),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.3, 0.5), StrokePoint(0.7, 0.5),
        ]),
        HiraganaStroke(order: 3, points: [
          StrokePoint(0.5, 0.3), StrokePoint(0.4, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'き',
      romaji: 'ki',
      pronunciation: 'kee',
      category: 'k-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.2), StrokePoint(0.6, 0.2),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.4, 0.4), StrokePoint(0.7, 0.4),
        ]),
        HiraganaStroke(order: 3, points: [
          StrokePoint(0.3, 0.7), StrokePoint(0.5, 0.6), StrokePoint(0.7, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'く',
      romaji: 'ku',
      pronunciation: 'koo',
      category: 'k-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.4, 0.3), StrokePoint(0.5, 0.6), StrokePoint(0.7, 0.7),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'け',
      romaji: 'ke',
      pronunciation: 'keh',
      category: 'k-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.2), StrokePoint(0.6, 0.3),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.3, 0.5), StrokePoint(0.7, 0.5),
        ]),
        HiraganaStroke(order: 3, points: [
          StrokePoint(0.4, 0.6), StrokePoint(0.6, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'こ',
      romaji: 'ko',
      pronunciation: 'koh',
      category: 'k-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.7, 0.3),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.3, 0.6), StrokePoint(0.7, 0.6), StrokePoint(0.6, 0.8),
        ]),
      ],
    ),

    // S-Group (さ行)
    HiraganaModel(
      character: 'さ',
      romaji: 'sa',
      pronunciation: 'sah',
      category: 's-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.2), StrokePoint(0.6, 0.2),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.4, 0.4), StrokePoint(0.6, 0.4),
        ]),
        HiraganaStroke(order: 3, points: [
          StrokePoint(0.3, 0.6), StrokePoint(0.5, 0.7), StrokePoint(0.7, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'し',
      romaji: 'shi',
      pronunciation: 'shee',
      category: 's-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.4, 0.2), StrokePoint(0.5, 0.5), StrokePoint(0.6, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'す',
      romaji: 'su',
      pronunciation: 'soo',
      category: 's-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.6, 0.2),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.4, 0.5), StrokePoint(0.5, 0.7), StrokePoint(0.7, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'せ',
      romaji: 'se',
      pronunciation: 'seh',
      category: 's-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.6, 0.3),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.4, 0.5), StrokePoint(0.7, 0.5),
        ]),
        HiraganaStroke(order: 3, points: [
          StrokePoint(0.5, 0.4), StrokePoint(0.5, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'そ',
      romaji: 'so',
      pronunciation: 'soh',
      category: 's-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.2), StrokePoint(0.5, 0.3), StrokePoint(0.7, 0.5), StrokePoint(0.6, 0.8),
        ]),
      ],
    ),

    // T-Group (た行)
    HiraganaModel(
      character: 'た',
      romaji: 'ta',
      pronunciation: 'tah',
      category: 't-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.2), StrokePoint(0.7, 0.2),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.4, 0.5), StrokePoint(0.6, 0.5),
        ]),
        HiraganaStroke(order: 3, points: [
          StrokePoint(0.5, 0.3), StrokePoint(0.5, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'ち',
      romaji: 'chi',
      pronunciation: 'chee',
      category: 't-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.6, 0.3),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.4, 0.5), StrokePoint(0.5, 0.7), StrokePoint(0.7, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'つ',
      romaji: 'tsu',
      pronunciation: 'tsoo',
      category: 't-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.5, 0.5), StrokePoint(0.7, 0.6),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'て',
      romaji: 'te',
      pronunciation: 'teh',
      category: 't-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.7, 0.4), StrokePoint(0.5, 0.7),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'と',
      romaji: 'to',
      pronunciation: 'toh',
      category: 't-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.6, 0.3),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.4, 0.5), StrokePoint(0.5, 0.7), StrokePoint(0.7, 0.8),
        ]),
      ],
    ),

    // N-Group (な行)
    HiraganaModel(
      character: 'な',
      romaji: 'na',
      pronunciation: 'nah',
      category: 'n-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.2), StrokePoint(0.6, 0.2),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.5, 0.3), StrokePoint(0.4, 0.6),
        ]),
        HiraganaStroke(order: 3, points: [
          StrokePoint(0.3, 0.7), StrokePoint(0.7, 0.7),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'に',
      romaji: 'ni',
      pronunciation: 'nee',
      category: 'n-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.6, 0.3),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.4, 0.5), StrokePoint(0.7, 0.5),
        ]),
        HiraganaStroke(order: 3, points: [
          StrokePoint(0.5, 0.4), StrokePoint(0.4, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'ぬ',
      romaji: 'nu',
      pronunciation: 'noo',
      category: 'n-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.5, 0.4), StrokePoint(0.4, 0.6), StrokePoint(0.6, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'ね',
      romaji: 'ne',
      pronunciation: 'neh',
      category: 'n-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.3, 0.3), StrokePoint(0.6, 0.3),
        ]),
        HiraganaStroke(order: 2, points: [
          StrokePoint(0.4, 0.5), StrokePoint(0.5, 0.6), StrokePoint(0.7, 0.8),
        ]),
      ],
    ),
    HiraganaModel(
      character: 'の',
      romaji: 'no',
      pronunciation: 'noh',
      category: 'n-group',
      strokes: [
        HiraganaStroke(order: 1, points: [
          StrokePoint(0.4, 0.2), StrokePoint(0.5, 0.5), StrokePoint(0.4, 0.7), StrokePoint(0.6, 0.6),
        ]),
      ],
    ),

    // Continue with remaining groups...
    // H, M, Y, R, W, N groups can be added similarly
  ];
}