import '../models/katakana_model.dart';

/// Repository for Katakana data
class KatakanaRepository {
  /// Get all Katakana characters
  Future<List<KatakanaModel>> getAllKatakana() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _katakanaCharacters.map((data) {
      return KatakanaModel(
        character: data['character']!,
        romaji: data['romaji']!,
        pronunciation: data['pronunciation']!,
        category: data['category']!,
      );
    }).toList();
  }

  /// Get Katakana by category
  Future<List<KatakanaModel>> getKatakanaByCategory(String category) async {
    final all = await getAllKatakana();
    return all.where((k) => k.category == category).toList();
  }

  /// Basic katakana character data
  static final List<Map<String, String>> _katakanaCharacters = [
    // Vowels (ア行)
    {'character': 'ア', 'romaji': 'a', 'pronunciation': 'ah', 'category': 'vowel'},
    {'character': 'イ', 'romaji': 'i', 'pronunciation': 'ee', 'category': 'vowel'},
    {'character': 'ウ', 'romaji': 'u', 'pronunciation': 'oo', 'category': 'vowel'},
    {'character': 'エ', 'romaji': 'e', 'pronunciation': 'eh', 'category': 'vowel'},
    {'character': 'オ', 'romaji': 'o', 'pronunciation': 'oh', 'category': 'vowel'},

    // K-Group (カ行)
    {'character': 'カ', 'romaji': 'ka', 'pronunciation': 'kah', 'category': 'k-group'},
    {'character': 'キ', 'romaji': 'ki', 'pronunciation': 'kee', 'category': 'k-group'},
    {'character': 'ク', 'romaji': 'ku', 'pronunciation': 'koo', 'category': 'k-group'},
    {'character': 'ケ', 'romaji': 'ke', 'pronunciation': 'keh', 'category': 'k-group'},
    {'character': 'コ', 'romaji': 'ko', 'pronunciation': 'koh', 'category': 'k-group'},

    // S-Group (サ行)
    {'character': 'サ', 'romaji': 'sa', 'pronunciation': 'sah', 'category': 's-group'},
    {'character': 'シ', 'romaji': 'shi', 'pronunciation': 'shee', 'category': 's-group'},
    {'character': 'ス', 'romaji': 'su', 'pronunciation': 'soo', 'category': 's-group'},
    {'character': 'セ', 'romaji': 'se', 'pronunciation': 'seh', 'category': 's-group'},
    {'character': 'ソ', 'romaji': 'so', 'pronunciation': 'soh', 'category': 's-group'},

    // T-Group (タ行)
    {'character': 'タ', 'romaji': 'ta', 'pronunciation': 'tah', 'category': 't-group'},
    {'character': 'チ', 'romaji': 'chi', 'pronunciation': 'chee', 'category': 't-group'},
    {'character': 'ツ', 'romaji': 'tsu', 'pronunciation': 'tsoo', 'category': 't-group'},
    {'character': 'テ', 'romaji': 'te', 'pronunciation': 'teh', 'category': 't-group'},
    {'character': 'ト', 'romaji': 'to', 'pronunciation': 'toh', 'category': 't-group'},

    // N-Group (ナ行)
    {'character': 'ナ', 'romaji': 'na', 'pronunciation': 'nah', 'category': 'n-group'},
    {'character': 'ニ', 'romaji': 'ni', 'pronunciation': 'nee', 'category': 'n-group'},
    {'character': 'ヌ', 'romaji': 'nu', 'pronunciation': 'noo', 'category': 'n-group'},
    {'character': 'ネ', 'romaji': 'ne', 'pronunciation': 'neh', 'category': 'n-group'},
    {'character': 'ノ', 'romaji': 'no', 'pronunciation': 'noh', 'category': 'n-group'},

    // H-Group (ハ行)
    {'character': 'ハ', 'romaji': 'ha', 'pronunciation': 'hah', 'category': 'h-group'},
    {'character': 'ヒ', 'romaji': 'hi', 'pronunciation': 'hee', 'category': 'h-group'},
    {'character': 'フ', 'romaji': 'fu', 'pronunciation': 'foo', 'category': 'h-group'},
    {'character': 'ヘ', 'romaji': 'he', 'pronunciation': 'heh', 'category': 'h-group'},
    {'character': 'ホ', 'romaji': 'ho', 'pronunciation': 'hoh', 'category': 'h-group'},

    // M-Group (マ行)
    {'character': 'マ', 'romaji': 'ma', 'pronunciation': 'mah', 'category': 'm-group'},
    {'character': 'ミ', 'romaji': 'mi', 'pronunciation': 'mee', 'category': 'm-group'},
    {'character': 'ム', 'romaji': 'mu', 'pronunciation': 'moo', 'category': 'm-group'},
    {'character': 'メ', 'romaji': 'me', 'pronunciation': 'meh', 'category': 'm-group'},
    {'character': 'モ', 'romaji': 'mo', 'pronunciation': 'moh', 'category': 'm-group'},

    // Y-Group (ヤ行)
    {'character': 'ヤ', 'romaji': 'ya', 'pronunciation': 'yah', 'category': 'y-group'},
    {'character': 'ユ', 'romaji': 'yu', 'pronunciation': 'yoo', 'category': 'y-group'},
    {'character': 'ヨ', 'romaji': 'yo', 'pronunciation': 'yoh', 'category': 'y-group'},

    // R-Group (ラ行)
    {'character': 'ラ', 'romaji': 'ra', 'pronunciation': 'rah', 'category': 'r-group'},
    {'character': 'リ', 'romaji': 'ri', 'pronunciation': 'ree', 'category': 'r-group'},
    {'character': 'ル', 'romaji': 'ru', 'pronunciation': 'roo', 'category': 'r-group'},
    {'character': 'レ', 'romaji': 're', 'pronunciation': 'reh', 'category': 'r-group'},
    {'character': 'ロ', 'romaji': 'ro', 'pronunciation': 'roh', 'category': 'r-group'},

    // W-Group (ワ行)
    {'character': 'ワ', 'romaji': 'wa', 'pronunciation': 'wah', 'category': 'w-group'},
    {'character': 'ヲ', 'romaji': 'wo', 'pronunciation': 'woh', 'category': 'w-group'},

    // N (ン)
    {'character': 'ン', 'romaji': 'n', 'pronunciation': 'n', 'category': 'n-single'},
  ];
}