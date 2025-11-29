import 'package:equatable/equatable.dart';
import '../../../core/theme/theme_config.dart';

/// Theme states
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

/// Initial theme state
class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

/// Theme loaded state
class ThemeLoaded extends ThemeState {
  final AppThemeMode themeMode;

  const ThemeLoaded(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}