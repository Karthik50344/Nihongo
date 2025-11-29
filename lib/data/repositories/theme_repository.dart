import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_config.dart';

/// Theme repository for managing theme preferences
class ThemeRepository {
  static const String _themeKey = 'app_theme_mode';

  /// Get saved theme mode
  Future<AppThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeValue = prefs.getString(_themeKey);

      if (themeValue != null) {
        return AppThemeModeExtension.fromString(themeValue);
      }

      return AppThemeMode.system; // Default to system theme
    } catch (e) {
      return AppThemeMode.system;
    }
  }

  /// Save theme mode
  Future<void> saveThemeMode(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode.value);
    } catch (e) {
      throw Exception('Failed to save theme: ${e.toString()}');
    }
  }

  /// Clear theme preference
  Future<void> clearThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey);
    } catch (e) {
      throw Exception('Failed to clear theme: ${e.toString()}');
    }
  }
}