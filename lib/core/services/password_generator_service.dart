import 'dart:math';

/// A service for generating cryptographically secure passwords.
class PasswordGeneratorService {
  static const String upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String lowerCaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String numberChars = '0123456789';
  static const String symbolChars = r'!@#$%^&*()_+-=[]{}|;:,.<>?';

  final Random _random = Random.secure();

  /// Generates a password based on the provided configuration.
  String generate({
    int length = 16,
    bool useUppercase = true,
    bool useLowercase = true,
    bool useNumbers = true,
    bool useSymbols = true,
  }) {
    String charset = '';
    if (useUppercase) charset += upperCaseChars;
    if (useLowercase) charset += lowerCaseChars;
    if (useNumbers) charset += numberChars;
    if (useSymbols) charset += symbolChars;

    if (charset.isEmpty) {
      throw ArgumentError('At least one character set must be selected.');
    }

    // Ensure we have at least one of each required type if length permits
    final List<String> password = [];
    final List<String> requiredSets = [];
    if (useUppercase) requiredSets.add(upperCaseChars);
    if (useLowercase) requiredSets.add(lowerCaseChars);
    if (useNumbers) requiredSets.add(numberChars);
    if (useSymbols) requiredSets.add(symbolChars);

    // Initial random characters from the combined set
    for (int i = 0; i < length; i++) {
      password.add(charset[_random.nextInt(charset.length)]);
    }

    // Replace first N characters with one from each required set to guarantee inclusion
    // only if length is sufficient. This is a common practice for "strong" generation.
    if (length >= requiredSets.length) {
      for (int i = 0; i < requiredSets.length; i++) {
        final set = requiredSets[i];
        password[i] = set[_random.nextInt(set.length)];
      }
    }

    // Shuffle the result to hide the fixed positions of guaranteed characters
    password.shuffle(_random);

    return password.join();
  }

  /// Calculates the entropy of a password in bits.
  /// 
  /// Entropy = log2(charset_size ^ length) = length * log2(charset_size)
  double calculateEntropy(String password, {
    bool useUppercase = true,
    bool useLowercase = true,
    bool useNumbers = true,
    bool useSymbols = true,
  }) {
    if (password.isEmpty) return 0;
    
    int charsetSize = 0;
    if (useUppercase) charsetSize += 26;
    if (useLowercase) charsetSize += 26;
    if (useNumbers) charsetSize += 10;
    if (useSymbols) charsetSize += symbolChars.length;

    if (charsetSize == 0) return 0;

    return password.length * (log(charsetSize) / log(2));
  }
}
