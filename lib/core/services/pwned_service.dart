import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// A service class for checking passwords against the Have I Been Pwned (HIBP) database.
///
/// This service uses the k-Anonymity model to securely check if a password has
/// appeared in a known data breach without revealing the password itself.
class PwnedService {
  static const String _baseUrl = 'https://api.pwnedpasswords.com/range/';
  final http.Client _client;

  /// Creates a [PwnedService].
  PwnedService({http.Client? client}) : _client = client ?? http.Client();

  /// Checks the number of times the provided [password] has appeared in data breaches.
  ///
  /// This method hashes the password using SHA-1, sends the first 5 characters
  /// of the hash to the HIBP API (k-Anonymity), and checks the returned list
  /// for the matching suffix.
  ///
  /// [password] The password to check.
  ///
  /// Returns the count of breaches found. Returns `0` if the password is empty,
  /// not found, or if an error occurs during the check.
  Future<int> checkPassword(String password) async {
    if (password.isEmpty) return 0;

    // 1. Generate SHA-1 hash of the password
    final bytes = utf8.encode(password);
    final digest = sha1.convert(bytes).toString().toUpperCase();

    // 2. Split into prefix (5 chars) and suffix
    final prefix = digest.substring(0, 5);
    final suffix = digest.substring(5);

    try {
      // 3. Query HIBP Range API
      final response = await _client.get(Uri.parse('$_baseUrl$prefix'));

      if (response.statusCode == 200) {
        // 4. Search for suffix in results
        final lines = const LineSplitter().convert(response.body);
        for (final line in lines) {
          final parts = line.split(':');
          if (parts[0] == suffix) {
            return int.parse(parts[1]);
          }
        }
      }
    } catch (e) {
      // Log error but don't crash
      debugPrint('HIBP Error: $e');
    }

    return 0;
  }
}
