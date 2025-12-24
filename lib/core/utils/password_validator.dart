import 'package:flutter/material.dart';

/// A utility class for validating passwords and calculating their strength.
class PasswordValidator {
  /// Calculates the strength of a password on a scale from 0.0 to 1.0.
  ///
  /// Criteria:
  /// - Length >= 8
  /// - Contains uppercase
  /// - Contains lowercase
  /// - Contains digit
  /// - Contains special character
  ///
  /// Returns:
  /// - 0.0: Empty
  /// - 0.25: Weak (does not meet all complexity requirements)
  /// - 0.6: Moderate (meets complexity but length < 12)
  /// - 1.0: Strong (meets complexity and length >= 12)
  static double calculateStrength(String password) {
    if (password.isEmpty) return 0.0;

    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasLength = password.length >= 8;

    if (!hasLength || !hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      return 0.25; // Weak
    } else if (password.length < 12) {
      return 0.6; // Moderate
    } else {
      return 1.0; // Strong
    }
  }

  /// Returns a color representing the password strength.
  ///
  /// - Red: Weak (<= 0.25)
  /// - Orange: Moderate (<= 0.6)
  /// - Green: Strong (> 0.6)
  static Color getStrengthColor(double strength) {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.6) return Colors.orange;
    return Colors.green;
  }

  /// Returns a text description of the password strength.
  ///
  /// - 'Password Strength' (0.0)
  /// - 'Weak' (<= 0.25)
  /// - 'Moderate' (<= 0.6)
  /// - 'Strong' (> 0.6)
  static String getStrengthText(double strength) {
    if (strength == 0.0) return 'Password Strength';
    if (strength <= 0.25) return 'Weak';
    if (strength <= 0.6) return 'Moderate';
    return 'Strong';
  }

  /// Validates a password against strict requirements.
  ///
  /// Requirements:
  /// - At least 8 characters
  /// - One uppercase letter
  /// - One lowercase letter
  /// - One number
  /// - One special character
  ///
  /// Throws an [Exception] if any requirement is not met.
  static void validate(String password) {
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters long');
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      throw Exception('Password must contain at least one uppercase letter');
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      throw Exception('Password must contain at least one lowercase letter');
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      throw Exception('Password must contain at least one number');
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      throw Exception('Password must contain at least one special character');
    }
  }
}
