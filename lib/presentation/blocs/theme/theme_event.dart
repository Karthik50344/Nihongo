import 'package:equatable/equatable.dart';
import '../../../core/theme/theme_config.dart';

/// Theme events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Load theme from storage
class LoadTheme extends ThemeEvent {
  const LoadTheme();
}

/// Change theme
class ChangeTheme extends ThemeEvent {
  final AppThemeMode themeMode;

  const ChangeTheme(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}