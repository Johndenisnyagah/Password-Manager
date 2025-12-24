import 'dart:math';

/// A utility class for generating strong, random passwords.
class PasswordGenerator {
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '0123456789';
  static const String _symbols = '!@#\$%^&*()-_=+[]{}|;:,.<>?';

  /// Generates a random password based on the specified criteria.
  ///
  /// [length] The length of the password to generate. Defaults to 20.
  /// [includeUppercase] Whether to include uppercase letters. Defaults to `true`.
  /// [includeNumbers] Whether to include numeric digits. Defaults to `true`.
  /// [includeSymbols] Whether to include special symbols. Defaults to `true`.
  ///
  /// Returns the generated password string.
  static String generate({
    int length = 20,
    bool includeUppercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    final random = Random.secure();
    String charset = _lowercase;
    if (includeUppercase) charset += _uppercase;
    if (includeNumbers) charset += _numbers;
    if (includeSymbols) charset += _symbols;

    return List.generate(length, (_) {
      return charset[random.nextInt(charset.length)];
    }).join();
  }
}
