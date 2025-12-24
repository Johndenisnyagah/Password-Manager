import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../services/secure_storage_service.dart';
import '../services/clipboard_service.dart';
import '../services/pwned_service.dart';
import '../services/biometric_service.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/vault/domain/services/vault_manager.dart';
import '../../features/totp/domain/services/totp_service.dart';

/// The global provider for the [SecureStorageService].
final storageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// The global provider for the [AuthService].
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// The global provider for the [TotpService].
final totpServiceProvider = Provider<TotpService>((ref) {
  return TotpService();
});

/// The global provider for the [ClipboardService].
final clipboardServiceProvider = Provider<ClipboardService>((ref) {
  return ClipboardService();
});

/// The global provider for the [PwnedService].
final pwnedServiceProvider = Provider<PwnedService>((ref) {
  return PwnedService();
});

/// The global provider for the [BiometricService].
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// The global provider for the [VaultManager].
///
/// This provider watches [storageServiceProvider] to inject the dependency.
final vaultManagerProvider = ChangeNotifierProvider<VaultManager>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return VaultManager(storageService: storage);
});

/// The global provider for the current [ThemeMode].
///
/// This is managed by the [ThemeNotifier].
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final storage = ref.read(storageServiceProvider);
  return ThemeNotifier(storage);
});

/// A notifier class that manages the application's theme.
///
/// It persists the selected theme mode to secure storage.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SecureStorageService _storage;

  /// Creates a [ThemeNotifier] and loads the saved theme.
  ThemeNotifier(this._storage) : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Loads the theme from secure storage.
  Future<void> _loadTheme() async {
    final mode = await _storage.loadThemeMode();
    if (mode == 'light') state = ThemeMode.light;
    if (mode == 'dark') state = ThemeMode.dark;
    if (mode == 'system') state = ThemeMode.system;
  }

  /// Sets and persists the [ThemeMode].
  ///
  /// [mode] The new theme mode to apply.
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _storage.saveThemeMode(mode.name);
  }
}

/// The global provider for the user's profile photo.
///
/// This is managed by the [ProfilePhotoNotifier].
final profilePhotoProvider = StateNotifierProvider<ProfilePhotoNotifier, Uint8List?>((ref) {
  final storage = ref.read(storageServiceProvider);
  return ProfilePhotoNotifier(storage);
});

/// A notifier class that manages the user's profile photo.
///
/// It persists the photo data to secure storage.
class ProfilePhotoNotifier extends StateNotifier<Uint8List?> {
  final SecureStorageService _storage;

  /// Creates a [ProfilePhotoNotifier] and loads the saved photo.
  ProfilePhotoNotifier(this._storage) : super(null) {
    _loadPhoto();
  }

  /// Loads the profile photo from secure storage.
  Future<void> _loadPhoto() async {
    state = await _storage.loadProfilePhoto();
  }

  /// Sets and persists the profile photo.
  ///
  /// [photo] The image data as bytes, or `null` to clear.
  Future<void> setPhoto(Uint8List? photo) async {
    state = photo;
    if (photo != null) {
      await _storage.saveProfilePhoto(photo);
    } else {
      // Logic for deleting photo if needed
    }
  }
}
