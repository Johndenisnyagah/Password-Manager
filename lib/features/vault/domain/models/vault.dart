import 'package:meta/meta.dart';
import 'kdf_params.dart';

/// Represents an encrypted vault container.
///
/// This class encapsulates the encrypted data, encryption metadata (nonce),
/// and Key Derivation Function parameters required to access the vault.
@immutable
class EncryptedVault {
  /// The encrypted JSON blob containing the vault entries (Base64 encoded).
  final String encryptedBlob; 

  /// The nonce (IV) used for encryption (Base64 encoded).
  final String nonce;

  /// The parameters used to derive the encryption key.
  final KdfParameters kdfParams;

  /// The schema version of the vault. Defaults to 1.
  final int version;

  /// Creates an [EncryptedVault] instance.
  const EncryptedVault({
    required this.encryptedBlob,
    required this.nonce,
    required this.kdfParams,
    this.version = 1,
  });

  /// Converts the vault container to a JSON map for storage.
  Map<String, dynamic> toJson() {
    return {
      'encryptedBlob': encryptedBlob,
      'nonce': nonce,
      'kdfParams': kdfParams.toJson(),
      'version': version,
    };
  }

  /// Creates an [EncryptedVault] instance from a JSON map.
  factory EncryptedVault.fromJson(Map<String, dynamic> json) {
    return EncryptedVault(
      encryptedBlob: json['encryptedBlob'] as String,
      nonce: json['nonce'] as String,
      kdfParams: KdfParameters.fromJson(json['kdfParams'] as Map<String, dynamic>),
      version: json['version'] as int? ?? 1,
    );
  }
}
