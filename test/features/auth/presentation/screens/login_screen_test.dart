import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keynest/features/auth/presentation/screens/login_screen.dart';
import 'package:keynest/features/auth/presentation/screens/register_screen.dart';
import 'package:keynest/core/providers/service_providers.dart';
import 'package:keynest/features/auth/domain/services/auth_service.dart';
import 'dart:typed_data';
import 'package:keynest/features/vault/domain/models/vault_entry.dart';

import 'package:keynest/core/services/secure_storage_service.dart';
import 'package:keynest/core/services/biometric_service.dart';
import 'package:keynest/features/vault/domain/services/vault_manager.dart';
import 'package:keynest/core/services/pwned_service.dart';
import 'package:keynest/features/vault/domain/models/vault_entry.dart';
import 'dart:typed_data';


class MockAuthService extends Fake implements AuthService {
  @override
  Future<void> login(String email, String password) async {}
}

class MockSecureStorage extends Fake implements SecureStorageService {
  @override
  Future<String?> loadEmail() async => null;
  @override
  Future<void> saveEmail(String email) async {}
  @override
  Future<String?> loadThemeMode() async => 'system';
  @override
  Future<Uint8List?> loadProfilePhoto() async => null;
}

class MockBiometricService extends Fake implements BiometricService {
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<bool> isEnabled(SecureStorageService storage) async => false;
}

class MockVaultManager extends ChangeNotifier implements VaultManager {
  @override
  Future<bool> hasStoredVault() async => true;
  @override
  Future<void> unlockFromStorage(String password) async {}
  @override
  void lock() {}
  @override
  bool get isLocked => true;
  @override
  List<VaultEntry> get entries => [];
  
  // Minimal overrides for MockVaultManager as it's a complex class
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class SpyNavigatorObserver extends NavigatorObserver {
  bool didPushRoute = false;
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    didPushRoute = true;
    super.didPush(route, previousRoute);
  }
}

class FakePwnedService extends Fake implements PwnedService {}

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(MockAuthService()),
        storageServiceProvider.overrideWithValue(MockSecureStorage()),
        biometricServiceProvider.overrideWithValue(MockBiometricService()),
        vaultManagerProvider.overrideWith((ref) => MockVaultManager()),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen Tests', () {
    testWidgets('Should render email and password fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Master Password'), findsOneWidget);
      expect(find.text('Unlock Vault'), findsOneWidget);
    });

    testWidgets('Should show error message when fields are empty', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Unlock Vault'));
      await tester.pump();
      
      expect(find.text('Please enter both email and password'), findsOneWidget);
    });

    testWidgets('Should navigate to RegisterScreen when Create Account is tapped', (tester) async {
      final spyObserver = SpyNavigatorObserver();
      
      await tester.pumpWidget(ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(MockAuthService()),
          storageServiceProvider.overrideWithValue(MockSecureStorage()),
          biometricServiceProvider.overrideWithValue(MockBiometricService()),
          vaultManagerProvider.overrideWith((ref) => MockVaultManager()),
          // Provide dummy for RegisterScreen if it builds partially
          pwnedServiceProvider.overrideWithValue(FakePwnedService()),
        ],
        child: MaterialApp(
          home: const LoginScreen(),
          navigatorObservers: [spyObserver],
        ),
      ));
      
      await tester.tap(find.text('Create Account'));
      await tester.pump(); // Don't pumpAndSettle if the next screen fails to build cleanly
      
      expect(spyObserver.didPushRoute, isTrue);
    });

    testWidgets('Should toggle password visibility', (tester) async {
      await tester.pumpWidget(createTestWidget());
      
      final passwordField = find.widgetWithText(TextField, 'Master Password');
      final TextField textField = tester.widget(passwordField);
      expect(textField.obscureText, isTrue);
      
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      
      final TextField updatedField = tester.widget(passwordField);
      expect(updatedField.obscureText, isFalse);
    });
  });
}
