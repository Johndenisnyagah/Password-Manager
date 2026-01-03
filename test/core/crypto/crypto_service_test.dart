import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:keynest/core/crypto/crypto_service.dart';

void main() {
  late CryptoService cryptoService;

  setUp(() {
    cryptoService = CryptoService();
  });

  group('CryptoService Tests', () {
    test('deriveMasterKey should produce the same key for the same password and salt', () async {
      const password = 'extremely-strong-password';
      final salt = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
      
      final key1 = await cryptoService.deriveMasterKey(password, salt, iterations: 1000);
      final key2 = await cryptoService.deriveMasterKey(password, salt, iterations: 1000);
      
      final bytes1 = await key1.extractBytes();
      final bytes2 = await key2.extractBytes();
      
      expect(bytes1, equals(bytes2));
    });

    test('Encryption and Decryption round-trip', () async {
      const password = 'my-master-password';
      final salt = cryptoService.generateSalt();
      final masterKey = await cryptoService.deriveMasterKey(password, salt, iterations: 1000);
      
      const plaintext = 'Sensitive data to be encrypted';
      
      final encryptedData = await cryptoService.encrypt(plaintext, masterKey);
      
      expect(encryptedData['ciphertext'], isNotNull);
      expect(encryptedData['nonce'], isNotNull);
      
      final decryptedText = await cryptoService.decrypt(
        encryptedData['ciphertext']!,
        masterKey,
        encryptedData['nonce']!,
      );
      
      expect(decryptedText, equals(plaintext));
    });

    test('Decryption should fail with wrong key', () async {
      const password = 'correct-password';
      const wrongPassword = 'wrong-password';
      final salt = cryptoService.generateSalt();
      
      final masterKey = await cryptoService.deriveMasterKey(password, salt, iterations: 1000);
      final wrongKey = await cryptoService.deriveMasterKey(wrongPassword, salt, iterations: 1000);
      
      const plaintext = 'Top secret';
      final encryptedData = await cryptoService.encrypt(plaintext, masterKey);
      
      expect(
        () => cryptoService.decrypt(encryptedData['ciphertext']!, wrongKey, encryptedData['nonce']!),
        throwsA(anything),
      );
    });
  });
}
