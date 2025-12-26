import 'package:flutter_test/flutter_test.dart';
import 'package:passm/features/vault/domain/services/vault_manager.dart';
import 'package:passm/core/services/secure_storage_service.dart';
import 'package:passm/core/crypto/crypto_service.dart';

class MockSecureStorage extends SecureStorageService {
  @override
  Future<void> saveVault(String encryptedVault) async {}
  
  @override
  Future<String?> loadVault() async => null;
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
  });
}
