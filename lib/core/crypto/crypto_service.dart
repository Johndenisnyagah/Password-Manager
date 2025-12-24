import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:cryptography/cryptography.dart';

/// Service responsible for all cryptographic operations.
///
/// Follows OWASP recommendations for password managers.
/// It uses AES-256-GCM for encryption and PBKDF2-HMAC-SHA256 for key derivation.
class CryptoService {
  // We use AES-GCM (256-bit) as it provides both confidentiality and integrity (AEAD).
  final _cipher = AesGcm.with256bits();

  // Default PBKDF2 iterations (OWASP recommends 600k for HMAC-SHA256)
  static const int defaultIterations = 600000;

  /// Derives a 256-bit key from the master password and salt using PBKDF2-HMAC-SHA256.
  ///
  /// [password] The master password input by the user.
  /// [salt] The unique salt associated with the user/vault.
  /// [iterations] The number of hashing iterations. Defaults to 600,000.
  ///
  /// Returns a [SecretKey] derived from the password.
  Future<SecretKey> deriveMasterKey(String password, Uint8List salt, {int iterations = defaultIterations}) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );

    // Ensure we clear sensitive password from memory as soon as possible
    final passwordBytes = utf8.encode(password);
    final key = await pbkdf2.deriveKey(
      secretKey: SecretKey(passwordBytes),
      nonce: salt,
    );
    
    return key;
  }

  /// Encrypts the [plaintext] using AES-256-GCM and the [masterKey].
  ///
  /// [plaintext] The data to encrypt (e.g., JSON string of the vault).
  /// [masterKey] The key derived from the master password.
  ///
  /// Returns a Map containing:
  /// - `ciphertext`: Base64 encoded combined ciphertext and authentication tag (MAC).
  /// - `nonce`: Base64 encoded nonce (IV) used for encryption.
  Future<Map<String, String>> encrypt(String plaintext, SecretKey masterKey) async {
    final clearTextBytes = utf8.encode(plaintext);
    
    // For every encryption, we use a unique random nonce.
    // Length is 12 bytes for GCM.
    final nonce = _cipher.newNonce();
    
    final secretBox = await _cipher.encrypt(
      clearTextBytes,
      secretKey: masterKey,
      nonce: nonce,
    );

    // We store the Mac alongside the ciphertext for easier handling.
    // secretBox.concatenation() returns [nonce + ciphertext + mac]
    // But we prefer to store nonce separately as per the requirement.
    // So we'll combine [ciphertext + mac].
    final combined = Uint8List(secretBox.cipherText.length + secretBox.mac.bytes.length);
    combined.setAll(0, secretBox.cipherText);
    combined.setAll(secretBox.cipherText.length, secretBox.mac.bytes);

    return {
      'ciphertext': base64.encode(combined),
      'nonce': base64.encode(secretBox.nonce),
    };
  }

  /// Decrypts the [ciphertextWithMacBase64] using the [masterKey] and [nonceBase64].
  ///
  /// [ciphertextWithMacBase64] The Base64 encoded ciphertext including the MAC.
  /// [masterKey] The decryption key.
  /// [nonceBase64] The Base64 encoded nonce associated with the ciphertext.
  ///
  /// Returns the decrypted plaintext string.
  /// Throws an [Exception] if decryption or authentication fails, indicating a wrong password or tampered data.
  Future<String> decrypt(String ciphertextWithMacBase64, SecretKey masterKey, String nonceBase64) async {
    final combined = base64.decode(ciphertextWithMacBase64);
    final nonce = base64.decode(nonceBase64);

    // GCM MAC is 16 bytes.
    if (combined.length < 16) throw Exception('Invalid ciphertext');
    
    final ciphertext = combined.sublist(0, combined.length - 16);
    final macBytes = combined.sublist(combined.length - 16);

    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(macBytes),
    );

    final decryptedBytes = await _cipher.decrypt(
      secretBox,
      secretKey: masterKey,
    );

    return utf8.decode(decryptedBytes);
  }

  /// Generates a cryptographically secure random salt (16 bytes by default).
  ///
  /// [length] The number of bytes to generate. Defaults to 16.
  Uint8List generateSalt([int length = 16]) {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => random.nextInt(256)));
  }
}
