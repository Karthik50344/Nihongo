import '../models/hiragana_model.dart';

/// Repository for Hiragana data (strokes loaded separately by KanjiVG service)
class HiraganaRepository {
  /// Get all Hiragana characters
  Future<List<HiraganaModel>> getAllHiragana() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _hiraganaCharacters.map((data) {
      return HiraganaModel(
        character: data['character']!,
        romaji: data['romaji']!,
        pronunciation: data['pronunciation']!,
        category: data['category']!,
        strokes: [], // Strokes loaded dynamically from KanjiVG
      );
    }).toList();
  }

  /// Get Hiragana by category
  Future<List<HiraganaModel>> getHiraganaByCategory(String category) async {
    final all = await getAllHiragana();
    return all.where((h) => h.category == category).toList();
  }

  /// Basic hiragana character data (strokes loaded from KanjiVG)
  static final List<Map<String, String>> _hiraganaCharacters = [
    // Vowels (あ行)
    {'character': 'あ', 'romaji': 'a', 'pronunciation': 'ah', 'category': 'vowel'},
    {'character': 'い', 'romaji': 'i', 'pronunciation': 'ee', 'category': 'vowel'},
    {'character': 'う', 'romaji': 'u', 'pronunciation': 'oo', 'category': 'vowel'},
    {'character': 'え', 'romaji': 'e', 'pronunciation': 'eh', 'category': 'vowel'},
    {'character': 'お', 'romaji': 'o', 'pronunciation': 'oh', 'category': 'vowel'},

    // K-Group (か行)
    {'character': 'か', 'romaji': 'ka', 'pronunciation': 'kah', 'category': 'k-group'},
    {'character': 'き', 'romaji': 'ki', 'pronunciation': 'kee', 'category': 'k-group'},
    {'character': 'く', 'romaji': 'ku', 'pronunciation': 'koo', 'category': 'k-group'},
    {'character': 'け', 'romaji': 'ke', 'pronunciation': 'keh', 'category': 'k-group'},
    {'character': 'こ', 'romaji': 'ko', 'pronunciation': 'koh', 'category': 'k-group'},

    // S-Group (さ行)
    {'character': 'さ', 'romaji': 'sa', 'pronunciation': 'sah', 'category': 's-group'},
    {'character': 'し', 'romaji': 'shi', 'pronunciation': 'shee', 'category': 's-group'},
    {'character': 'す', 'romaji': 'su', 'pronunciation': 'soo', 'category': 's-group'},
    {'character': 'せ', 'romaji': 'se', 'pronunciation': 'seh', 'category': 's-group'},
    {'character': 'そ', 'romaji': 'so', 'pronunciation': 'soh', 'category': 's-group'},

    // T-Group (た行)
    {'character': 'た', 'romaji': 'ta', 'pronunciation': 'tah', 'category': 't-group'},
    {'character': 'ち', 'romaji': 'chi', 'pronunciation': 'chee', 'category': 't-group'},
    {'character': 'つ', 'romaji': 'tsu', 'pronunciation': 'tsoo', 'category': 't-group'},
    {'character': 'て', 'romaji': 'te', 'pronunciation': 'teh', 'category': 't-group'},
    {'character': 'と', 'romaji': 'to', 'pronunciation': 'toh', 'category': 't-group'},

    // N-Group (な行)
    {'character': 'な', 'romaji': 'na', 'pronunciation': 'nah', 'category': 'n-group'},
    {'character': 'に', 'romaji': 'ni', 'pronunciation': 'nee', 'category': 'n-group'},
    {'character': 'ぬ', 'romaji': 'nu', 'pronunciation': 'noo', 'category': 'n-group'},
    {'character': 'ね', 'romaji': 'ne', 'pronunciation': 'neh', 'category': 'n-group'},
    {'character': 'の', 'romaji': 'no', 'pronunciation': 'noh', 'category': 'n-group'},

    // H-Group (は行)
    {'character': 'は', 'romaji': 'ha', 'pronunciation': 'hah', 'category': 'h-group'},
    {'character': 'ひ', 'romaji': 'hi', 'pronunciation': 'hee', 'category': 'h-group'},
    {'character': 'ふ', 'romaji': 'fu', 'pronunciation': 'foo', 'category': 'h-group'},
    {'character': 'へ', 'romaji': 'he', 'pronunciation': 'heh', 'category': 'h-group'},
    {'character': 'ほ', 'romaji': 'ho', 'pronunciation': 'hoh', 'category': 'h-group'},

    // M-Group (ま行)
    {'character': 'ま', 'romaji': 'ma', 'pronunciation': 'mah', 'category': 'm-group'},
    {'character': 'み', 'romaji': 'mi', 'pronunciation': 'mee', 'category': 'm-group'},
    {'character': 'む', 'romaji': 'mu', 'pronunciation': 'moo', 'category': 'm-group'},
    {'character': 'め', 'romaji': 'me', 'pronunciation': 'meh', 'category': 'm-group'},
    {'character': 'も', 'romaji': 'mo', 'pronunciation': 'moh', 'category': 'm-group'},

    // Y-Group (や行)
    {'character': 'や', 'romaji': 'ya', 'pronunciation': 'yah', 'category': 'y-group'},
    {'character': 'ゆ', 'romaji': 'yu', 'pronunciation': 'yoo', 'category': 'y-group'},
    {'character': 'よ', 'romaji': 'yo', 'pronunciation': 'yoh', 'category': 'y-group'},

    // R-Group (ら行)
    {'character': 'ら', 'romaji': 'ra', 'pronunciation': 'rah', 'category': 'r-group'},
    {'character': 'り', 'romaji': 'ri', 'pronunciation': 'ree', 'category': 'r-group'},
    {'character': 'る', 'romaji': 'ru', 'pronunciation': 'roo', 'category': 'r-group'},
    {'character': 'れ', 'romaji': 're', 'pronunciation': 'reh', 'category': 'r-group'},
    {'character': 'ろ', 'romaji': 'ro', 'pronunciation': 'roh', 'category': 'r-group'},

    // W-Group (わ行)
    {'character': 'わ', 'romaji': 'wa', 'pronunciation': 'wah', 'category': 'w-group'},
    {'character': 'を', 'romaji': 'wo', 'pronunciation': 'woh', 'category': 'w-group'},

    // N (ん)
    {'character': 'ん', 'romaji': 'n', 'pronunciation': 'n', 'category': 'n-single'},
  ];
}