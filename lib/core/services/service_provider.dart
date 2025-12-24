import 'package:flutter/material.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/vault/domain/services/vault_manager.dart';
import '../../features/totp/domain/services/totp_service.dart';
import '../services/secure_storage_service.dart';
import '../services/clipboard_service.dart';
import '../services/pwned_service.dart';
import '../services/biometric_service.dart';

import 'package:flutter/material.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/vault/domain/services/vault_manager.dart';
import '../../features/totp/domain/services/totp_service.dart';
import '../services/secure_storage_service.dart';
import '../services/clipboard_service.dart';
import '../services/pwned_service.dart';
import '../services/biometric_service.dart';

/// A service provider widget that uses [InheritedWidget] for dependency injection.
///
/// This widget holds instances of core and feature services and makes them
/// accessible to all descendant widgets in the widget tree.
class ServiceProvider extends InheritedWidget {
  /// The authentication service instance.
  final AuthService authService;

  /// The vault manager instance.
  final VaultManager vaultManager;

  /// The TOTP service instance.
  final TotpService totpService;

  /// The secure storage service instance.
  final SecureStorageService storageService;

  /// The clipboard service instance.
  final ClipboardService clipboardService;

  /// The HIBP check service instance.
  final PwnedService pwnedService;

  /// The biometric authentication service instance.
  final BiometricService biometricService;

  /// Creates a [ServiceProvider].
  ///
  /// Requires all service instances to be passed as arguments.
  const ServiceProvider({
    super.key,
    required this.authService,
    required this.vaultManager,
    required this.totpService,
    required this.storageService,
    required this.clipboardService,
    required this.pwnedService,
    required this.biometricService,
    required super.child,
  });

  /// Retrieves the [ServiceProvider] from the widget tree.
  ///
  /// Throws an [Exception] if the [ServiceProvider] is not found in the context.
  static ServiceProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ServiceProvider>();
    if (provider == null) {
      throw Exception('ServiceProvider not found in widget tree');
    }
    return provider;
  }

  @override
  bool updateShouldNotify(ServiceProvider oldWidget) => false;
}
