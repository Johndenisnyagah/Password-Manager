import 'package:flutter_test/flutter_test.dart';
import 'package:passm/core/services/password_generator_service.dart';

void main() {
  late PasswordGeneratorService service;

  setUp(() {
    service = PasswordGeneratorService();
  });

  group('PasswordGeneratorService', () {
    test('should generate password of specified length', () {
      final pwd8 = service.generate(length: 8);
      final pwd32 = service.generate(length: 32);
      
      expect(pwd8.length, 8);
      expect(pwd32.length, 32);
    });

    test('should include all required character sets', () {
      final pwd = service.generate(
        length: 4,
        useUppercase: true,
        useLowercase: true,
        useNumbers: true,
        useSymbols: true,
      );

      bool hasUpper = pwd.split('').any((c) => PasswordGeneratorService.upperCaseChars.contains(c));
      bool hasLower = pwd.split('').any((c) => PasswordGeneratorService.lowerCaseChars.contains(c));
      bool hasDigit = pwd.split('').any((c) => PasswordGeneratorService.numberChars.contains(c));
      bool hasSymbol = pwd.split('').any((c) => PasswordGeneratorService.symbolChars.contains(c));

      expect(hasUpper, isTrue);
      expect(hasLower, isTrue);
      expect(hasDigit, isTrue);
      expect(hasSymbol, isTrue);
    });

    test('should calculate entropy correctly', () {
      // Length 16, charset 26 (lowercase only)
      // Entropy = 16 * log2(26) ≈ 16 * 4.7 ≈ 75.2
      final entropy = service.calculateEntropy(
        'abcdefghijklmnop',
        useUppercase: false,
        useLowercase: true,
        useNumbers: false,
        useSymbols: false,
      );
      
      expect(entropy, closeTo(75.21, 0.01));
    });

    test('should throw error if no charset selected', () {
      expect(
        () => service.generate(
          useUppercase: false,
          useLowercase: false,
          useNumbers: false,
          useSymbols: false,
        ),
        throwsArgumentError,
      );
    });
  });
}
