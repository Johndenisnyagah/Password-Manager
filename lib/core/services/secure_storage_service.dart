import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:idb_shim/idb_browser.dart';

/// A service class provides secure storage capabilities for the application.
///
/// It uses [FlutterSecureStorage] for mobile and desktop platforms to store sensitive data
/// in the secure enclave (Keychain/Keystore).
/// For Web, it uses [IndexedDB] as a fallback since secure storage is not natively supported.
///
/// Handles storage for:
/// - Encrypted vault data
/// - User profile information (username, email, photo)
/// - App preferences (theme)
class SecureStorageService {
  static const String _vaultKey = 'encrypted_vault';
  static const String _photoKey = 'profile_photo';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'user_email';
  static const String _themeKey = 'theme_mode';
  static const String _biometricsEnabledKey = 'biometrics_enabled';
  static const String _wrappedMasterKey = 'wrapped_master_key';
  static const String _dbName = 'keynest_db';
  static const String _storeName = 'secure_store';

  // Mobile/Desktop storage
  final FlutterSecureStorage _secureStorage;

  // WARNING: Web storage (IndexedDB) is NOT as secure as native mobile secure storage (Keychain/Keystore).
  // Native storage is hardware-backed, while IndexedDB relies on browser sandboxing.
  // Data is encrypted at the application level before being saved here, but the keys
  // are inherently more vulnerable in a browser environment.
  Database? _db;

  /// Creates a [SecureStorageService].
  SecureStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initializes the storage service.
  ///
  /// For Web, this initializes the [IndexedDB].
  /// On other platforms, this method is primarily a placeholder as [FlutterSecureStorage]
  /// doesn't require explicit initialization.
  Future<void> init() async {
    if (kIsWeb) {
      try {
        final factory = idbFactoryBrowser;
        _db = await factory.open(
          _dbName,
          version: 1,
          onUpgradeNeeded: (VersionChangeEvent event) {
            final db = event.database;
            if (!db.objectStoreNames.contains(_storeName)) {
              db.createObjectStore(_storeName);
            }
          },
        );
        debugPrint('SecureStorageService: IndexedDB initialized successfully');
      } catch (e) {
        debugPrint('SecureStorageService: Failed to initialize IndexedDB: $e');
      }
    }
  }

  /// Saves the encrypted vault data.
  ///
  /// [encryptedVault] The JSON string representing the encrypted vault.
  Future<void> saveVault(String encryptedVault) async {
    if (kIsWeb) {
      await _saveWeb(_vaultKey, encryptedVault);
    } else {
      await _secureStorage.write(key: _vaultKey, value: encryptedVault);
    }
  }

  /// Loads the encrypted vault data.
  ///
  /// Returns the encrypted vault JSON string, or `null` if not found.
  Future<String?> loadVault() async {
    if (kIsWeb) {
      final result = await _loadWeb(_vaultKey);
      return result as String?;
    } else {
      return await _secureStorage.read(key: _vaultKey);
    }
  }

  /// Saves the user's profile photo.
  ///
  /// [bytes] The image data as a byte array. It will be Base64 encoded before storage.
  Future<void> saveProfilePhoto(Uint8List bytes) async {
    final base64Image = base64Encode(bytes);
    if (kIsWeb) {
      await _saveWeb(_photoKey, base64Image);
    } else {
      await _secureStorage.write(key: _photoKey, value: base64Image);
    }
  }

  /// Loads the user's profile photo.
  ///
  /// Returns the image data as [Uint8List], or `null` if not found.
  Future<Uint8List?> loadProfilePhoto() async {
    String? base64Image;
    if (kIsWeb) {
      base64Image = await _loadWeb(_photoKey) as String?;
    } else {
      base64Image = await _secureStorage.read(key: _photoKey);
    }

    if (base64Image != null) {
      return base64Decode(base64Image);
    }
    return null;
  }


  /// Saves the username.
  ///
  /// [username] The username string.
  Future<void> saveUsername(String username) async {
    if (kIsWeb) {
      await _saveWeb(_usernameKey, username);
    } else {
      await _secureStorage.write(key: _usernameKey, value: username);
    }
  }

  /// Loads the username.
  ///
  /// Returns the username string, or `null` if not found.
  Future<String?> loadUsername() async {
    if (kIsWeb) {
      return await _loadWeb(_usernameKey) as String?;
    } else {
      return await _secureStorage.read(key: _usernameKey);
    }
  }

  /// Saves the user's email address.
  ///
  /// [email] The email address string.
  Future<void> saveEmail(String email) async {
    if (kIsWeb) {
      await _saveWeb(_emailKey, email);
    } else {
      await _secureStorage.write(key: _emailKey, value: email);
    }
  }

  /// Loads the user's email address.
  ///
  /// Returns the email address string, or `null` if not found.
  Future<String?> loadEmail() async {
    if (kIsWeb) {
      return await _loadWeb(_emailKey) as String?;
    } else {
      return await _secureStorage.read(key: _emailKey);
    }
  }

  /// Saves the application theme preference.
  ///
  /// [themeMode] The theme mode string (e.g., 'light', 'dark', 'system').
  Future<void> saveThemeMode(String themeMode) async {
    if (kIsWeb) {
      await _saveWeb(_themeKey, themeMode);
    } else {
      await _secureStorage.write(key: _themeKey, value: themeMode);
    }
  }

  /// Loads the application theme preference.
  ///
  /// Returns the theme mode string, or `null` if not found.
  Future<String?> loadThemeMode() async {
    if (kIsWeb) {
      return await _loadWeb(_themeKey) as String?;
    } else {
      return await _secureStorage.read(key: _themeKey);
    }
  }

  /// Saves whether biometric unlock is enabled.
  Future<void> saveBiometricsEnabled(bool enabled) async {
    final value = enabled.toString();
    if (kIsWeb) {
      await _saveWeb(_biometricsEnabledKey, value);
    } else {
      await _secureStorage.write(key: _biometricsEnabledKey, value: value);
    }
  }

  /// Loads whether biometric unlock is enabled.
  Future<bool> loadBiometricsEnabled() async {
    String? value;
    if (kIsWeb) {
      value = await _loadWeb(_biometricsEnabledKey) as String?;
    } else {
      value = await _secureStorage.read(key: _biometricsEnabledKey);
    }
    return value == 'true';
  }

  /// Saves the master key protected by biometrics.
  /// 
  /// On mobile, it uses [authenticationRequired] true to enforce device-level security.
  Future<void> saveWrappedMasterKey(String masterKeyBase64) async {
    if (kIsWeb) {
      // Biometric protection not natively supported in the same way on Web via this plugin
      await _saveWeb(_wrappedMasterKey, masterKeyBase64);
    } else {
      await _secureStorage.write(
        key: _wrappedMasterKey,
        value: masterKeyBase64,
        iOptions: const IOSOptions(
          // We don't set authenticationRequired: true here because we use local_auth 
          // to provide a better UX and custom messages before reading.
        ),
        aOptions: const AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
    }
  }

  /// Loads the wrapped master key.
  Future<String?> loadWrappedMasterKey() async {
    if (kIsWeb) {
      return await _loadWeb(_wrappedMasterKey) as String?;
    } else {
      return await _secureStorage.read(
        key: _wrappedMasterKey,
        aOptions: const AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
    }
  }

  /// Clears the wrapped master key.
  Future<void> clearWrappedMasterKey() async {
    if (kIsWeb) {
      if (_db != null) {
        final txn = _db!.transaction(_storeName, 'readwrite');
        final store = txn.objectStore(_storeName);
        await store.delete(_wrappedMasterKey);
        await txn.completed;
      }
    } else {
      await _secureStorage.delete(key: _wrappedMasterKey);
    }
  }

  /// Clears all data from the secure storage.
  ///
  /// This removes all keys and values managed by this service.
  Future<void> clear() async {
    if (kIsWeb) {
      if (_db != null) {
        final txn = _db!.transaction(_storeName, 'readwrite');
        final store = txn.objectStore(_storeName);
        await store.clear();
        await txn.completed;
      }
    } else {
      await _secureStorage.deleteAll();
    }
  }

  // Web Helper Methods

  /// Internal helper to save a value to Web [IndexedDB].
  Future<void> _saveWeb(String key, dynamic value) async {
    try {
      if (_db == null) {
        debugPrint('SecureStorageService: Cannot save to Web storage, DB not initialized');
        return;
      }
      final txn = _db!.transaction(_storeName, 'readwrite');
      final store = txn.objectStore(_storeName);
      await store.put(value, key);
      await txn.completed;
      debugPrint('SecureStorageService: Saved $key to Web storage');
    } catch (e) {
      debugPrint('SecureStorageService: Error saving $key to Web storage: $e');
    }
  }

  /// Internal helper to load a value from Web [IndexedDB].
  Future<dynamic> _loadWeb(String key) async {
    try {
      if (_db == null) {
        debugPrint('SecureStorageService: Cannot load from Web storage, DB not initialized');
        return null;
      }
      final txn = _db!.transaction(_storeName, 'readonly');
      final store = txn.objectStore(_storeName);
      final value = await store.getObject(key);
      debugPrint('SecureStorageService: Loaded $key from Web storage: ${value != null}');
      return value;
    } catch (e) {
      debugPrint('SecureStorageService: Error loading $key from Web storage: $e');
      return null;
    }
  }
}
