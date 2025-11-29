import '../constants/app_strings.dart';

/// Input validation utilities
class Validators {
  Validators._();

  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.emailRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return AppStrings.emailValidation;
    }

    return null;
  }

  /// Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }

    if (value.length < 6) {
      return AppStrings.passwordValidation;
    }

    return null;
  }

  /// Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.nameRequired;
    }

    if (value.trim().length < 2) {
      return AppStrings.nameValidation;
    }

    return null;
  }

  /// Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }

    if (value != password) {
      return AppStrings.passwordMismatch;
    }

    return null;
  }

  /// Check if email is valid
  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  /// Check if password is valid
  static bool isValidPassword(String password) {
    return validatePassword(password) == null;
  }

  /// Check if name is valid
  static bool isValidName(String name) {
    return validateName(name) == null;
  }
}