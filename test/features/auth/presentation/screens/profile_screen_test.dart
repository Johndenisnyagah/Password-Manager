import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keynest/features/auth/presentation/screens/profile_screen.dart';
import 'package:keynest/core/providers/service_providers.dart';
import 'package:keynest/core/services/secure_storage_service.dart';
import 'package:keynest/core/services/biometric_service.dart';
import 'package:keynest/features/vault/domain/services/vault_manager.dart';
import 'package:keynest/features/auth/domain/services/auth_service.dart';
import 'dart:typed_data';
import 'package:keynest/features/vault/domain/models/vault_entry.dart';


class MockSecureStorage extends Fake implements SecureStorageService {
  @override
  Future<String?> loadUsername() async => 'TestProfileUser';
  @override
  Future<bool> loadBiometricsEnabled() async => false;
  @override
  Future<String?> loadThemeMode() async => 'system';
  @override
  Future<Uint8List?> loadProfilePhoto() async => null;
}

class MockBiometricService extends Fake implements BiometricService {
  @override
  Future<bool> isAvailable() async => true; // Available for testing
  @override
  Future<bool> isEnabled(SecureStorageService storage) async => false;
}

class MockVaultManager extends ChangeNotifier implements VaultManager {
  @override
  bool get isLocked => false;
  @override
  List<VaultEntry> get entries => [];

  @override
  Duration autoLockDuration = const Duration(minutes: 5);
  
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthService extends Fake implements AuthService {
  @override
  void logout() {}
}

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(MockSecureStorage()),
        biometricServiceProvider.overrideWithValue(MockBiometricService()),
        vaultManagerProvider.overrideWith((ref) => MockVaultManager()),
        authServiceProvider.overrideWithValue(MockAuthService()),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen Tests', () {
    testWidgets('Should display username and stats', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('TestProfileUser'), findsOneWidget);
      expect(find.text('Passwords'), findsOneWidget);
      expect(find.text('TOTP Codes'), findsOneWidget);
    });

    testWidgets('Should show theme selection dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final themeTile = find.text('Theme Mode');
      await tester.scrollUntilVisible(
          themeTile,
          500.0,
          scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(themeTile);
      await tester.pumpAndSettle();
      
      expect(find.text('Select Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('Should show auto-lock selection dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      final autoLockTile = find.text('Auto-Lock');
      await tester.scrollUntilVisible(
          autoLockTile,
          500.0,
          scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(autoLockTile);
      await tester.pumpAndSettle();
      
      expect(find.text('Auto-Lock Timer'), findsOneWidget);
      expect(find.text('15 minutes'), findsOneWidget);
    });

    testWidgets('Should have biometric switch if available', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.byType(Switch), findsOneWidget);
    });
  });
}
