import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keynest/main.dart';
import 'package:keynest/core/providers/service_providers.dart';
import 'package:keynest/core/services/secure_storage_service.dart';
import 'package:keynest/core/services/biometric_service.dart';
import 'package:keynest/features/auth/domain/services/auth_service.dart';
import 'package:keynest/features/vault/domain/services/vault_manager.dart';
import 'package:keynest/features/totp/domain/services/totp_service.dart';
import 'package:keynest/core/services/clipboard_service.dart';
import 'package:keynest/core/services/pwned_service.dart';
import 'dart:typed_data';

class MockSecureStorage extends Fake implements SecureStorageService {
  final Map<String, String> _storage = {};
  Uint8List? _photo;

  @override
  Future<void> init() async {}

  @override
  Future<void> saveUsername(String username) async => _storage['username'] = username;
  @override
  Future<String?> loadUsername() async => _storage['username'];

  @override
  Future<void> saveEmail(String email) async => _storage['email'] = email;
  @override
  Future<String?> loadEmail() async => _storage['email'];

  @override
  Future<void> saveVault(String vaultJson) async => _storage['vault'] = vaultJson;
  @override
  Future<String?> loadVault() async => _storage['vault'];

  @override
  Future<void> saveThemeMode(String mode) async => _storage['theme'] = mode;
  @override
  Future<String?> loadThemeMode() async => _storage['theme'];

  @override
  Future<void> saveBiometricsEnabled(bool enabled) async => _storage['bio'] = enabled.toString();
  @override
  Future<bool> loadBiometricsEnabled() async => _storage['bio'] == 'true';

  @override
  Future<void> saveProfilePhoto(Uint8List bytes) async => _photo = bytes;
  @override
  Future<Uint8List?> loadProfilePhoto() async => _photo;

  @override
  Future<void> clear() async => _storage.clear();
}

class MockBiometricService extends BiometricService {
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<bool> isEnabled(SecureStorageService storageService) async => false;
}

void main() {
  testWidgets('App Flow Integration Test: Registration -> Login -> Add Entry', (tester) async {
    // Set a realistic mobile surface size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    final storage = MockSecureStorage();
    final authService = AuthService(); // Use real service logic
    final vaultManager = VaultManager(storageService: storage);
    final totpService = TotpService();
    final clipboardService = ClipboardService();
    final pwnedService = PwnedService();
    final biometricService = MockBiometricService();

    addTearDown(() {
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
          authServiceProvider.overrideWithValue(authService),
          vaultManagerProvider.overrideWith((ref) => vaultManager),
          totpServiceProvider.overrideWithValue(totpService),
          clipboardServiceProvider.overrideWithValue(clipboardService),
          pwnedServiceProvider.overrideWithValue(pwnedService),
          biometricServiceProvider.overrideWithValue(biometricService),
        ],
        child: KeyNestApp(
          authService: authService,
          vaultManager: vaultManager,
          totpService: totpService,
          storageService: storage,
          clipboardService: clipboardService,
          pwnedService: pwnedService,
          biometricService: biometricService,
        ),
      ),
    );

    // 1. Onboarding
    await tester.pumpAndSettle();
    final getStartedButton = find.text('Get Started');
    await tester.ensureVisible(getStartedButton);
    await tester.tap(getStartedButton);
    await tester.pumpAndSettle();

    // 2. Navigation to Register
    expect(find.text('Unlock Vault'), findsOneWidget); 
    final createAccountButton = find.text('Create Account');
    await tester.ensureVisible(createAccountButton);
    await tester.tap(createAccountButton);
    await tester.pumpAndSettle();

    // 3. Registration
    expect(find.text('Set up your secure vault'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Username'), 'integration_user');
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Master Password'), 'P@ssw0rd123!');
    await tester.enterText(find.widgetWithText(TextField, 'Confirm Password'), 'P@ssw0rd123!');
    
    final registerButton = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 4. Verify in Vault
    expect(find.text('Hello, integration_user!'), findsOneWidget);
    expect(find.text('My Vault'), findsOneWidget);

    // 5. Add Entry
    // Find FAB - it uses FloatingActionButton.extended with label 'Add Entry'
    final addEntryFab = find.text('Add Entry');
    await tester.tap(addEntryFab);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Service Name'), 'TestService');
    await tester.enterText(find.widgetWithText(TextField, 'Username / Email'), 'serviceuser');
    await tester.enterText(find.widgetWithText(TextField, 'Password (optional)'), 'SecretPass123');
    
    await tester.tap(find.text('Create Entry'));
    await tester.pumpAndSettle();

    // 6. Verify entry in list
    expect(find.text('TestService'), findsOneWidget);
    expect(find.text('serviceuser'), findsOneWidget);

    // 7. Logout and Re-login
    // Tap Profile (person icon)
    await tester.tap(find.byIcon(Icons.person)); 
    await tester.pumpAndSettle();
    
    // In ProfileScreen
    await tester.scrollUntilVisible(find.text('Logout'), 500);
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // After popUntil isFirst, we are back at Onboarding
    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Unlock Vault'), findsOneWidget);
    
    // Re-login
    await tester.enterText(find.widgetWithText(TextField, 'Email Address'), 'test@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Master Password'), 'P@ssw0rd123!');
    await tester.tap(find.text('Unlock Vault'));
    await tester.pumpAndSettle();

    // Verify data persisted
    expect(find.text('TestService'), findsOneWidget);
  });
}
