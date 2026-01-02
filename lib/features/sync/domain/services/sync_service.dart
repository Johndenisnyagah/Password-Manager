import '../../../vault/domain/models/vault.dart';
import '../../../auth/domain/services/auth_service.dart';
import 'package:flutter/foundation.dart';

/// Service responsible for syncing the encrypted vault blob with the backend.
///
/// The backend treats the blob as opaque data, ensuring zero-knowledge architecture.
/// Authentication is handled via [AuthService].
class SyncService {
  final AuthService _authService;
  
  /// The base URL of the sync server.
  final String baseUrl;

  /// Creates a [SyncService].
  SyncService(this._authService, {this.baseUrl = 'https://api.passm.io'});

  /// Uploads the encrypted vault to the backend.
  ///
  /// Includes the current version for optimistic concurrency control.
  /// Throws an exception if the user is not authenticated.
  Future<void> uploadVault(EncryptedVault vault) async {
    if (!_authService.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    // Implementation would involve a POST/PUT request to /vault
    // Example:
    // final headers = {
    //   'Authorization': 'Bearer ${_authService.jwt}',
    //   'Content-Type': 'application/json',
    // };
    // final body = json.encode(vault.toJson());
    // await http.put(Uri.parse('$baseUrl/vault'), headers: headers, body: body);
    
    debugPrint('Sync: Uploaded vault version ${vault.version}');
  }

  /// Downloads the latest encrypted vault from the backend.
  ///
  /// Returns `null` if no vault exists on the server (e.g., new account).
  /// Throws an exception if the user is not authenticated.
  Future<EncryptedVault?> downloadVault() async {
    if (!_authService.isAuthenticated) {
      throw Exception('User not authenticated');
    }

    // Implementation would involve a GET request to /vault
    // Example:
    // final headers = {
    //   'Authorization': 'Bearer ${_authService.jwt}',
    // };
    // final response = await http.get(Uri.parse('$baseUrl/vault'), headers: headers);
    // If 404, return null. Else, parse the JSON.
    
    // For demonstration, we'll return null to simulate a new account.
    return null; 
  }

  /// Resolves conflicts between a local and remote vault.
  ///
  /// Current strategy: Higher version number wins (Last Write Wins).
  /// A more robust solution would involve merging entry lists.
  EncryptedVault resolveConflict(EncryptedVault local, EncryptedVault remote) {
    if (remote.version > local.version) {
      return remote;
    }
    return local;
  }
}
