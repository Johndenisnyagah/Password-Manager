import 'package:flutter_test/flutter_test.dart';
import 'package:keynest/core/utils/password_validator.dart';

void main() {
  group('PasswordValidator Unit Tests', () {
    test('Should throw exception for short passwords', () {
      expect(() => PasswordValidator.validate('123'), throwsException);
    });

    test('Should throw exception for missing uppercase', () {
      expect(() => PasswordValidator.validate('password123!'), throwsException);
    });

    test('Should throw exception for missing lowercase', () {
      expect(() => PasswordValidator.validate('PASSWORD123!'), throwsException);
    });

    test('Should throw exception for missing digit', () {
      expect(() => PasswordValidator.validate('Password!'), throwsException);
    });

    test('Should throw exception for missing special char', () {
      expect(() => PasswordValidator.validate('Password123'), throwsException);
    });

    test('Should pass for valid password', () {
      expect(() => PasswordValidator.validate('Password123!'), returnsNormally);
    });
  });
}
