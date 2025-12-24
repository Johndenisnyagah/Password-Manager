import 'dart:math';
import 'dart:typed_data';
import 'package:base32/base32.dart';
import 'package:cryptography/cryptography.dart';

/// Implements RFC 6238 Time-Based One-Time Password (TOTP).
///
/// Default configuration:
/// - 6 digits
/// - 30-second time step
/// - HMAC-SHA1 algorithm
///
/// Handles Base32 decoding of secrets and OTP generation.
class TotpService {
  /// Number of digits in the generated code (default: 6).
  final int digits;
  
  /// The time step in seconds (default: 30).
  final int period;
  
  /// The hashing algorithm used for HMAC (default: SHA1).
  final HashAlgorithm hashAlgorithm;

  /// Creates a [TotpService].
  TotpService({
    this.digits = 6,
    this.period = 30,
    HashAlgorithm? hashAlgorithm,
  }) : hashAlgorithm = hashAlgorithm ?? Sha1();

  /// Generates the current TOTP code for the given [secret].
  ///
  /// [secret] must be a Base32 encoded string.
  /// [time] allows generating codes for a specific point in time (defaults to [DateTime.now]).
  Future<String> generateCode(String secret, {DateTime? time}) async {
    final now = time ?? DateTime.now();
    final counter = now.millisecondsSinceEpoch ~/ (period * 1000);
    return calculateHOTP(secret, counter);
  }

  /// Calculates HOTP based on the secret and counter.
  ///
  /// Implements the HMAC-Based One-Time Password algorithm (RFC 4226).
  Future<String> calculateHOTP(String secret, int counter) async {
    final keyBytes = base32.decode(secret.toUpperCase().replaceAll(' ', ''));
    
    // Counter must be an 8-byte big-endian integer.
    final counterBytes = Uint8List(8);
    var tempCounter = counter;
    for (var i = 7; i >= 0; i--) {
      counterBytes[i] = tempCounter & 0xff;
      tempCounter >>= 8;
    }

    final hmac = Hmac(hashAlgorithm);
    final mac = await hmac.calculateMac(
      counterBytes,
      secretKey: SecretKey(keyBytes),
    );

    final hash = mac.bytes;
    final offset = hash[hash.length - 1] & 0xf;
    
    final binary = ((hash[offset] & 0x7f) << 24) |
                   ((hash[offset + 1] & 0xff) << 16) |
                   ((hash[offset + 2] & 0xff) << 8) |
                   (hash[offset + 3] & 0xff);

    final otp = binary % pow(10, digits).toInt();
    return otp.toString().padLeft(digits, '0');
  }

  /// Parses a TOTP URI (e.g., from a QR code) and returns the secret.
  ///
  /// Example format: otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example
  /// Returns `null` if the URI is invalid or not a TOTP URI.
  String? parseSecretFromUri(String uri) {
    try {
      final parsedUri = Uri.parse(uri);
      if (parsedUri.scheme != 'otpauth' || parsedUri.host != 'totp') return null;
      return parsedUri.queryParameters['secret'];
    } catch (_) {
      return null;
    }
  }

  /// Calculates the remaining seconds for the current window.
  ///
  /// Useful for displaying a countdown timer in the UI.
  int getRemainingSeconds({DateTime? time}) {
    final now = time ?? DateTime.now();
    return period - (now.millisecondsSinceEpoch ~/ 1000 % period);
  }
}
