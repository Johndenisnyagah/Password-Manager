import 'package:flutter_test/flutter_test.dart';
import 'package:passm/features/vault/domain/services/vault_manager.dart';
import 'package:passm/core/services/secure_storage_service.dart';
import 'package:passm/core/crypto/crypto_service.dart';

import 'package:passm/core/services/biometric_service.dart';

class MockBiometricService extends BiometricService {
  bool authenticateResult = true;
  @override
  Future<bool> isAvailable() async => true;
  @override
  Future<bool> authenticate({required String localizedReason}) async => authenticateResult;
}

class MockSecureStorage extends SecureStorageService {
  String? vaultData;
  String? wrappedKey;
  bool biometricsEnabled = false;

  @override
  Future<void> saveVault(String encryptedVault) async {
    vaultData = encryptedVault;
  }
  
  @override
  Future<String?> loadVault() async => vaultData;

  @override
  Future<void> saveBiometricsEnabled(bool enabled) async {
    biometricsEnabled = enabled;
  }

  @override
  Future<bool> loadBiometricsEnabled() async => biometricsEnabled;

  @override
  Future<void> saveWrappedMasterKey(String masterKeyBase64) async {
    wrappedKey = masterKeyBase64;
  }

  @override
  Future<String?> loadWrappedMasterKey() async => wrappedKey;
}

void main() {
  late VaultManager vaultManager;

  setUp(() {
    vaultManager = VaultManager(
      cryptoService: CryptoService(),
      storageService: MockSecureStorage(),
    );
  });

  group('VaultManager CRUD Tests', () {
    test('Should throw error when accessing entries while locked', () {
      expect(() => vaultManager.entries, throwsA(isA<Exception>()));
    });

    test('Add Entry should update entries list', () async {
      // Unlock first (mocking storage or use createVault)
      await vaultManager.createVault('password');
      
      final entry = vaultManager.generateNewEntry(
        serviceName: 'Test Service',
        username: 'testuser',
        password: 'testpassword',
      );
      
      vaultManager.addEntry(entry);
      
      expect(vaultManager.entries.length, 1);
      expect(vaultManager.entries.first.serviceName, 'Test Service');
    });

    test('Update Entry should modify entry', () async {
      await vaultManager.createVault('password');
      final entry = vaultManager.generateNewEntry(
        serviceName: 'Test Service',
        username: 'testuser',
      );
      vaultManager.addEntry(entry);
      
      final updated = entry.copyWith(username: 'newuser');
      vaultManager.updateEntry(updated);
      
      expect(vaultManager.entries.first.username, 'newuser');
    });

    test('Delete Entry should remove entry', () async {
      await vaultManager.createVault('password');
      final entry = vaultManager.generateNewEntry(
        serviceName: 'Test Service',
        username: 'testuser',
      );
      vaultManager.addEntry(entry);
      
      vaultManager.deleteEntry(entry.id);
      
      expect(vaultManager.entries.length, 0);
    });

    test('Vault should lock after auto-lock duration', () async {
      // Use a short duration for testing
      vaultManager = VaultManager(
        autoLockDuration: const Duration(milliseconds: 100),
        storageService: MockSecureStorage(),
      );
      await vaultManager.createVault('password');
      expect(vaultManager.isLocked, false);
      
      await Future.delayed(const Duration(milliseconds: 200));
      expect(vaultManager.isLocked, true);
    });

    test('Enable Biometric Unlock should save wrapped key', () async {
      final mockStorage = MockSecureStorage();
      vaultManager = VaultManager(
        storageService: mockStorage,
        biometricService: MockBiometricService(),
      );
      
      await vaultManager.createVault('password');
      await vaultManager.enableBiometricUnlock('password');
      
      expect(mockStorage.biometricsEnabled, true);
      expect(mockStorage.wrappedKey, isNotNull);
    });

    test('Unlock with Biometrics should unlock successfully', () async {
      final mockStorage = MockSecureStorage();
      final mockBio = MockBiometricService();
      vaultManager = VaultManager(
        storageService: mockStorage,
        biometricService: mockBio,
      );
      
      // 1. Create and enable
      await vaultManager.createVault('password');
      await vaultManager.enableBiometricUnlock('password');
      
      // 2. Lock
      vaultManager.lock();
      expect(vaultManager.isLocked, true);
      
      // 3. Unlock with biometrics
      await vaultManager.unlockWithBiometrics();
      expect(vaultManager.isLocked, false);
    });
  });
}
