import 'package:flutter/material.dart';

/// App color constants
class AppColors {
  AppColors._();

  // Primary Colors - Japanese Theme
  static const Color primaryRed = Color(0xFFE63946);
  static const Color primaryBlue = Color(0xFF457B9D);
  static const Color accentGreen = Color(0xFF06D6A0);
  static const Color warningOrange = Color(0xFFF77F00);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFF8F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFBF5);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkCardBackground = Color(0xFF363636);
  static const Color darkTextPrimary = Color(0xFFFAFAFA);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF404040);

  // Social Media Colors
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color facebookBlue = Color(0xFF1877F2);

  // Gradient Colors
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF8F0),
      Color(0xFFFFE5E5),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF2D1F1F),
    ],
  );

  // Status Colors
  static const Color success = Color(0xFF06D6A0);
  static const Color error = Color(0xFFE63946);
  static const Color warning = Color(0xFFF77F00);
  static const Color info = Color(0xFF457B9D);

  // Shadow Colors
  static Color lightShadow = Colors.black.withOpacity(0.1);
  static Color darkShadow = Colors.black.withOpacity(0.3);
}