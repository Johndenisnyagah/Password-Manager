import 'package:meta/meta.dart';

/// Represents the parameters used for Key Derivation (PBKDF2).
///
/// These parameters are essential for reconstructing the encryption key from
/// the master password in a deterministic way.
@immutable
class KdfParameters {
  /// The salt used in the KDF (Base64 encoded).
  final String salt; 

  /// The number of iterations for the KDF algorithm.
  final int iterations;

  /// The algorithm identifier (e.g., 'pbkdf2-hmac-sha256').
  final String algorithm; 

  /// Creates a [KdfParameters] instance.
  const KdfParameters({
    required this.salt,
    required this.iterations,
    this.algorithm = 'pbkdf2-hmac-sha256',
  });

  /// Converts the parameters to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'salt': salt,
      'iterations': iterations,
      'algorithm': algorithm,
    };
  }

  /// Creates a [KdfParameters] instance from a JSON map.
  factory KdfParameters.fromJson(Map<String, dynamic> json) {
    return KdfParameters(
      salt: json['salt'] as String,
      iterations: json['iterations'] as int,
      algorithm: json['algorithm'] as String? ?? 'pbkdf2-hmac-sha256',
    );
  }
}
