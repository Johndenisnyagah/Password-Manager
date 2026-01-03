import 'dart:async';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:uuid/uuid.dart';

import 'package:keynest/features/vault/domain/models/kdf_params.dart';
import 'package:keynest/features/vault/domain/models/vault.dart';
import 'package:keynest/features/vault/domain/models/vault_entry.dart';
import 'package:keynest/core/services/secure_storage_service.dart';
import 'package:keynest/core/crypto/crypto_service.dart';

import 'package:flutter/foundation.dart';
import 'package:keynest/core/services/biometric_service.dart';

/// Manages the vault lifecycle including encryption, decryption, and data persistence.
///
/// This provider holds the decrypted vault entries in memory while the app is unlocked.
/// It uses [CryptoService] for cryptographic operations and [SecureStorageService] for disk storage.
///
/// Key responsibilities:
/// - Unlocking the vault (decrypting from storage)
/// - Creating a new vault
/// - CRUD operations on vault entries
/// - Auto-locking the vault after inactivity
class VaultManager with ChangeNotifier {
  final CryptoService _cryptoService;
  final SecureStorageService _storageService; 
  final BiometricService _biometricService;
  final _uuid = const Uuid();

  /// The derived master key. Held in memory only while unlocked.
  SecretKey? _masterKey;
  
  /// The list of decrypted vault entries. Held in memory only while unlocked.
  List<VaultEntry>? _entries;

  /// Stored KDF parameters for re-encrypting when saving.
  KdfParameters? _kdfParams;

  Timer? _autoLockTimer;
  Duration _autoLockDuration;

  /// Creates a [VaultManager].
  VaultManager({
    CryptoService? cryptoService,
    SecureStorageService? storageService,
    BiometricService? biometricService,
    Duration autoLockDuration = const Duration(minutes: 5),
  })  : _cryptoService = cryptoService ?? CryptoService(),
        _storageService = storageService ?? SecureStorageService(),
        _biometricService = biometricService ?? BiometricService(),
        _autoLockDuration = autoLockDuration;

  /// Returns `true` if the vault is currently locked (master key is not present).
  bool get isLocked => _masterKey == null;

  /// Returns the current list of decrypted entries. 
  /// 
  /// Throws an [Exception] if the vault is locked.
  List<VaultEntry> get entries {
    if (isLocked) throw Exception('Vault is locked');
    return List.unmodifiable(_entries!);
  }

  /// Checks if a vault exists in secure storage.
  Future<bool> hasStoredVault() async {
    final storedVault = await _storageService.loadVault();
    return storedVault != null;
  }

  /// Loads and unlocks the vault from secure storage.
  ///
  /// [masterPassword] The user's master password used to derive the decryption key.
  Future<void> unlockFromStorage(String masterPassword) async {
    final storedVaultJson = await _storageService.loadVault();
    if (storedVaultJson == null) {
      throw Exception('No vault found in storage');
    }

    final encryptedVault = EncryptedVault.fromJson(json.decode(storedVaultJson));
    await unlock(masterPassword, encryptedVault);
  }

  /// Unlocks the vault using the master password and the stored encrypted vault metadata.
  ///
  /// 1. Derives the key using KDF parameters from the vault.
  /// 2. Decrypts the vault blob.
  /// 3. Parses entries into memory.
  Future<void> unlock(String masterPassword, EncryptedVault encryptedVault) async {
    final salt = base64.decode(encryptedVault.kdfParams.salt);
    
    // 1. Derive the master key
    final key = await _cryptoService.deriveMasterKey(
      masterPassword,
      salt,
      iterations: encryptedVault.kdfParams.iterations,
    );

    try {
      // 2. Attempt to decrypt the blob
      final plaintext = await _cryptoService.decrypt(
        encryptedVault.encryptedBlob,
        key,
        encryptedVault.nonce,
      );

      // 3. Parse entries
      final List<dynamic> jsonList = json.decode(plaintext);
      _entries = jsonList.map((e) => VaultEntry.fromJson(e)).toList();
      _masterKey = key;
      _kdfParams = encryptedVault.kdfParams; // Store params for saving

      _resetAutoLockTimer();
      notifyListeners();
    } catch (e) {
      // If decryption fails (wrong password or data tampered), we clear the derived key immediately.
      _masterKey = null;
      _kdfParams = null;
      throw Exception('Failed to unlock vault: Invalid password or corrupted data.');
    }
  }

  /// Verifies if the [masterPassword] is correct for the current vault.
  ///
  /// This derives a key from the password and compares it to the current master key.
  Future<bool> verifyMasterPassword(String masterPassword) async {
    if (isLocked || _kdfParams == null) return false;

    final salt = base64.decode(_kdfParams!.salt);
    final key = await _cryptoService.deriveMasterKey(
      masterPassword,
      salt,
      iterations: _kdfParams!.iterations,
    );

    final currentBytes = await _masterKey!.extractBytes();
    final checkBytes = await key.extractBytes();

    return listEquals(currentBytes, checkBytes);
  }

  /// Attempts to unlock the vault using biometrics.
  /// 
  /// 1. Verifies biometric authentication.
  /// 2. Retrieves the wrapped master key from secure storage.
  /// 3. Standard unlock flow using the retrieved key.
  Future<void> unlockWithBiometrics() async {
    final isBiometricsEnabled = await _storageService.loadBiometricsEnabled();
    if (!isBiometricsEnabled) {
      throw Exception('Biometric unlock is not enabled.');
    }

    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Unlock your vault',
    );

    if (!authenticated) {
      throw Exception('Biometric authentication failed or was canceled.');
    }

    final wrappedKeyBase64 = await _storageService.loadWrappedMasterKey();
    if (wrappedKeyBase64 == null) {
      throw Exception('Biometric key not found. Please log in with your password.');
    }

    final keyBytes = base64.decode(wrappedKeyBase64);
    final key = SecretKey(keyBytes);

    final storedVaultJson = await _storageService.loadVault();
    if (storedVaultJson == null) {
      throw Exception('No vault found in storage.');
    }

    final encryptedVault = EncryptedVault.fromJson(json.decode(storedVaultJson));

    try {
      final plaintext = await _cryptoService.decrypt(
        encryptedVault.encryptedBlob,
        key,
        encryptedVault.nonce,
      );

      final List<dynamic> jsonList = json.decode(plaintext);
      _entries = jsonList.map((e) => VaultEntry.fromJson(e)).toList();
      _masterKey = key;
      _kdfParams = encryptedVault.kdfParams;

      _resetAutoLockTimer();
      notifyListeners();
    } catch (e) {
      _masterKey = null;
      _kdfParams = null;
      throw Exception('Biometric unlock failed: Could not decrypt vault with stored key.');
    }
  }

  /// Enables biometric unlock by wrapping the master key and saving it securely.
  Future<void> enableBiometricUnlock(String masterPassword) async {
    if (isLocked) {
      // If locked, we need to verify the password first to get the key
      final storedVaultJson = await _storageService.loadVault();
      if (storedVaultJson == null) throw Exception('No vault found');
      
      final encryptedVault = EncryptedVault.fromJson(json.decode(storedVaultJson));

      
      // Verify password by unlocking
      await unlock(masterPassword, encryptedVault);
    }

    // Now that we are sure we have the correct master key
    final keyData = await _masterKey!.extractBytes();
    final keyBase64 = base64.encode(keyData);

    await _storageService.saveWrappedMasterKey(keyBase64);
    await _storageService.saveBiometricsEnabled(true);
    notifyListeners();
  }

  /// Disables biometric unlock and clears the wrapped key.
  Future<void> disableBiometricUnlock() async {
    await _storageService.saveBiometricsEnabled(false);
    await _storageService.clearWrappedMasterKey();
    notifyListeners();
  }

  /// Locks the vault and clears sensitive data (keys and entries) from memory.
  void lock() {
    _masterKey = null; 
    _entries = null;
    _kdfParams = null;
    _autoLockTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _autoLockTimer?.cancel();
    _autoLockTimer = null;
    super.dispose();
  }

  /// Creates a new, empty encrypted vault with the given master password.
  ///
  /// Used during initial onboarding.
  Future<EncryptedVault> createVault(String masterPassword) async {
    final salt = _cryptoService.generateSalt();
    final key = await _cryptoService.deriveMasterKey(masterPassword, salt);
    
    // Initial empty vault
    final emptyEntriesJson = json.encode([]);
    
    final encrypted = await _cryptoService.encrypt(emptyEntriesJson, key);

    final kdfParams = KdfParameters(
      salt: base64.encode(salt),
      iterations: CryptoService.defaultIterations,
    );

    final vault = EncryptedVault(
      encryptedBlob: encrypted['ciphertext']!,
      nonce: encrypted['nonce']!,
      kdfParams: kdfParams,
    );
    
    // Store for session
    _masterKey = key;
    _entries = [];
    _kdfParams = kdfParams;
    
    await _saveToStorage();
    _resetAutoLockTimer();
    notifyListeners();

    return vault;
  }

  /// Sets the auto-lock duration and resets the timer.
  set autoLockDuration(Duration duration) {
    _autoLockDuration = duration;
    _resetAutoLockTimer();
  }

  /// Gets the current auto-lock duration.
  Duration get autoLockDuration => _autoLockDuration;

  /// Encrypts the current in-memory entries into a new EncryptedVault blob.
  ///
  /// This is used internally when saving changes to disk.
  Future<EncryptedVault> save({KdfParameters? kdfParams}) async {
    if (isLocked) throw Exception('Cannot save a locked vault');
    
    final params = kdfParams ?? _kdfParams;
    if (params == null) throw Exception('No KDF parameters available');

    final plaintext = json.encode(_entries!.map((e) => e.toJson()).toList());
    final encrypted = await _cryptoService.encrypt(plaintext, _masterKey!);

    return EncryptedVault(
      encryptedBlob: encrypted['ciphertext']!,
      nonce: encrypted['nonce']!,
      kdfParams: params,
    );
  }

  /// Change the master password by re-encrypting the vault with a new key derived from [newMasterPassword].
  Future<void> rekey(String newMasterPassword) async {
    if (isLocked) throw Exception('Vault must be unlocked to change password');

    // 1. Derive new key
    final salt = _cryptoService.generateSalt();
    final newKey = await _cryptoService.deriveMasterKey(newMasterPassword, salt);

    // 2. Encrypt current entries with new key
    final plaintext = json.encode(_entries!.map((e) => e.toJson()).toList());
    final encrypted = await _cryptoService.encrypt(plaintext, newKey);

    // 3. Create new params
    final newKdfParams = KdfParameters(
      salt: base64.encode(salt),
      iterations: CryptoService.defaultIterations,
    );

    final newVaultPayload = EncryptedVault(
      encryptedBlob: encrypted['ciphertext']!,
      nonce: encrypted['nonce']!,
      kdfParams: newKdfParams,
    );

    // 4. Update memory state
    _masterKey = newKey;
    _kdfParams = newKdfParams;

    // 5. Save to storage
    final jsonString = json.encode(newVaultPayload.toJson());
    await _storageService.saveVault(jsonString);
  }

  /// Exports the current encrypted vault as a JSON string.
  Future<String> exportVault() async {
    if (isLocked) throw Exception('Vault must be unlocked to export');
    final encryptedVault = await save();
    return json.encode(encryptedVault.toJson());
  }

  /// Imports an encrypted vault from a JSON string.
  Future<void> importVault(String jsonString) async {
    try {
      final decoded = json.decode(jsonString);
      // Validate format by attempting to parse
      EncryptedVault.fromJson(decoded);
      await _storageService.saveVault(jsonString);
    } catch (e) {
      throw Exception('Invalid vault format');
    }
  }

  // --- Internal Persistence ---

  Future<void> _saveToStorage() async {
    if (isLocked || _kdfParams == null) return;
    
    final encryptedVault = await save(kdfParams: _kdfParams);
    final jsonString = json.encode(encryptedVault.toJson());
    await _storageService.saveVault(jsonString);
  }

  // --- CRUD Operations ---

  /// Adds a new entry to the vault and saves immediately.
  Future<void> addEntry(VaultEntry entry) async {
    if (isLocked) throw Exception('Vault is locked');
    _entries!.add(entry);
    _resetAutoLockTimer();
    await _saveToStorage();
    notifyListeners();
  }

  /// Updates an existing entry in the vault and saves immediately.
  Future<void> updateEntry(VaultEntry updatedEntry) async {
    if (isLocked) throw Exception('Vault is locked');
    final index = _entries!.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _entries![index] = updatedEntry;
      _resetAutoLockTimer();
      await _saveToStorage();
      notifyListeners();
    }
  }

  /// Deletes an entry from the vault and saves immediately.
  Future<void> deleteEntry(String id) async {
    if (isLocked) throw Exception('Vault is locked');
    _entries!.removeWhere((e) => e.id == id);
    _resetAutoLockTimer();
    await _saveToStorage();
    notifyListeners();
  }

  /// Helper to generate a new [VaultEntry] with a unique ID and current timestamp.
  VaultEntry generateNewEntry({
    required String serviceName,
    required String username,
    String? password,
    String? totpSecret,
    String? notes,
    String category = 'Personal',
  }) {
    final now = DateTime.now();
    return VaultEntry(
      id: _uuid.v4(),
      serviceName: serviceName,
      username: username,
      password: password,
      totpSecret: totpSecret,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      category: category,
    );
  }

  /// Resets the auto-lock timer (e.g., on user interaction).
  void resetTimer() {
    _resetAutoLockTimer();
  }

  void _resetAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = Timer(_autoLockDuration, () {
      lock();
    });
  }
}
