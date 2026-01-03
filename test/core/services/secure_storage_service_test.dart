import 'package:flutter_test/flutter_test.dart';
import 'package:keynest/core/services/secure_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data';
import 'dart:convert';

// Manual Mock for FlutterSecureStorage
class MockFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      storage.remove(key);
    } else {
      storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    storage.clear();
  }
}

void main() {
  late SecureStorageService service;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(secureStorage: mockStorage);
  });

  group('SecureStorageService Tests', () {
    test('saveVault and loadVault should persist data', () async {
      const data = '{"vault":"secret"}';
      await service.saveVault(data);
      final loaded = await service.loadVault();
      expect(loaded, equals(data));
    });

    test('saveEmail and loadEmail should persist email', () async {
      const email = 'test@example.com';
      await service.saveEmail(email);
      final loaded = await service.loadEmail();
      expect(loaded, equals(email));
    });

    test('saveUsername and loadUsername should persist username', () async {
      const username = 'testuser';
      await service.saveUsername(username);
      final loaded = await service.loadUsername();
      expect(loaded, equals(username));
    });

    test('saveProfilePhoto and loadProfilePhoto should handle binary data', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      await service.saveProfilePhoto(bytes);
      final loaded = await service.loadProfilePhoto();
      expect(loaded, equals(bytes));
    });

    test('saveThemeMode and loadThemeMode should persist theme', () async {
      const theme = 'dark';
      await service.saveThemeMode(theme);
      final loaded = await service.loadThemeMode();
      expect(loaded, equals(theme));
    });

    test('saveBiometricsEnabled and loadBiometricsEnabled should persist bool', () async {
      await service.saveBiometricsEnabled(true);
      expect(await service.loadBiometricsEnabled(), isTrue);

      await service.saveBiometricsEnabled(false);
      expect(await service.loadBiometricsEnabled(), isFalse);
    });

    test('clear should remove all data', () async {
      await service.saveVault('data');
      await service.saveEmail('email');
      
      await service.clear();
      
      expect(await service.loadVault(), isNull);
      expect(await service.loadEmail(), isNull);
    });
  });
}
