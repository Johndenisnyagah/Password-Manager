import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:passm/core/services/secure_storage_service.dart';

/// A service class for handling biometric authentication.
///
/// This service provides methods to check biometric availability,
/// retrieve available biometric types, and authenticate the user.
class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if biometric authentication is available on the device.
  ///
  /// Returns `true` if the device supports biometrics and can check them,
  /// otherwise returns `false`.
  Future<bool> isAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Retrieves a list of available biometric types on the device.
  ///
  /// Returns a [List] of [BiometricType]. Returns an empty list if
  /// retrieving the available biometrics fails.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  /// Authenticates the user using biometrics.
  ///
  /// [localizedReason] The message to display to the user explaining why
  /// authentication is required.
  ///
  /// Returns `true` if authentication is successful, otherwise returns `false`.
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('BiometricService: Authentication error: $e');
      return false;
    }
  }

  /// Checks if the user has enabled biometric unlock in the app settings.
  Future<bool> isEnabled(SecureStorageService storageService) async {
    return await storageService.loadBiometricsEnabled();
  }
}
