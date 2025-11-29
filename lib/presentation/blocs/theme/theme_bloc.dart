import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/theme_repository.dart';
import '../../../core/theme/theme_config.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// Theme BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository _themeRepository;

  ThemeBloc(this._themeRepository) : super(const ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeTheme>(_onChangeTheme);
  }

  /// Load theme from storage
  Future<void> _onLoadTheme(
      LoadTheme event,
      Emitter<ThemeState> emit,
      ) async {
    try {
      final themeMode = await _themeRepository.getThemeMode();
      emit(ThemeLoaded(themeMode));
    } catch (e) {
      // Default to system theme if loading fails
      emit(const ThemeLoaded(AppThemeMode.system));
    }
  }

  /// Change theme
  Future<void> _onChangeTheme(
      ChangeTheme event,
      Emitter<ThemeState> emit,
      ) async {
    try {
      await _themeRepository.saveThemeMode(event.themeMode);
      emit(ThemeLoaded(event.themeMode));
    } catch (e) {
      // Keep current theme if saving fails
      if (state is ThemeLoaded) {
        emit(state);
      } else {
        emit(const ThemeLoaded(AppThemeMode.system));
      }
    }
  }
}