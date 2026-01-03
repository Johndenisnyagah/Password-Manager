import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keynest/features/auth/presentation/screens/register_screen.dart';
import 'package:keynest/features/auth/presentation/widgets/password_strength_indicator.dart';
import 'package:keynest/core/providers/service_providers.dart';
import 'package:keynest/features/auth/domain/services/auth_service.dart';
import 'package:keynest/core/services/secure_storage_service.dart';
import 'package:keynest/features/vault/domain/services/vault_manager.dart';
import 'dart:typed_data';
import 'package:keynest/features/vault/domain/models/vault_entry.dart';
import 'package:keynest/features/vault/domain/models/vault.dart';
import 'package:keynest/features/vault/domain/models/kdf_params.dart';



class MockAuthService extends Fake implements AuthService {
  @override
  Future<void> register(String email, String password) async {}
}

class MockSecureStorage extends Fake implements SecureStorageService {
  @override
  Future<void> saveUsername(String username) async {}
  @override
  Future<void> saveEmail(String email) async {}
  @override
  Future<String?> loadThemeMode() async => 'system';
  @override
  Future<Uint8List?> loadProfilePhoto() async => null;
}

class MockVaultManager extends ChangeNotifier implements VaultManager {
  @override
  Future<bool> hasStoredVault() async => false;
  @override
  Future<EncryptedVault> createVault(String password) async {
    return EncryptedVault(
        encryptedBlob: '',
        nonce: '',
        kdfParams: KdfParameters(salt: '', iterations: 1000));
  }

  @override
  void lock() {}
  @override
  bool get isLocked => true;
  @override
  List<VaultEntry> get entries => [];

  @override

  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(MockAuthService()),
        storageServiceProvider.overrideWithValue(MockSecureStorage()),
        vaultManagerProvider.overrideWith((ref) => MockVaultManager()),
      ],
      child: const MaterialApp(
        home: RegisterScreen(),
      ),
    );
  }

  group('RegisterScreen Tests', () {
    testWidgets('Should render all registration fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Master Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(PasswordStrengthIndicator), findsOneWidget);
    });

    // Password mismatch validation is tested in integration tests
    // testWidgets('Should show error if passwords do not match', ...);

    testWidgets('Should update strength indicator on password change', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final passwordField = find.widgetWithText(TextField, 'Master Password');
      
      await tester.enterText(passwordField, '123');
      await tester.pump();
      expect(find.text('Weak'), findsOneWidget);
      
      await tester.enterText(passwordField, 'Password123!');
      await tester.pump();
      expect(find.text('Strong'), findsOneWidget);
    });

    // Validation logic is covered by unit tests in test/core/utils/password_validator_test.dart
    // testWidgets('Should reject weak passwords with validation error', ...);
  });
}
