import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:passm/features/vault/presentation/screens/add_entry_screen.dart';
import 'package:passm/core/providers/service_providers.dart';
import 'package:passm/features/vault/domain/services/vault_manager.dart';
import 'package:passm/core/services/secure_storage_service.dart';

class MockSecureStorage extends SecureStorageService {
  @override
  Future<void> saveVault(String encryptedVault) async {}
  @override
  Future<String?> loadVault() async => null;
}

void main() {
  testWidgets('AddEntryScreen should show validation errors for empty fields', (WidgetTester tester) async {
    final vaultManager = VaultManager(storageService: MockSecureStorage());
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vaultManagerProvider.overrideWith((ref) => vaultManager),
        ],
        child: const MaterialApp(
          home: AddEntryScreen(),
        ),
      ),
    );

    // Initial state
    expect(find.text('Create New Entry'), findsOneWidget);

    // Try to save without filling anything
    final createButton = find.text('Create Entry');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    // Check for validation messages
    expect(find.text('Service name is required'), findsOneWidget);
    expect(find.text('Username is required'), findsOneWidget);
  });

  testWidgets('AddEntryScreen should show password strength when typing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AddEntryScreen(),
        ),
      ),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Password (optional)'), 'weak');
    await tester.pumpAndSettle();

    expect(find.text('Weak'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Password (optional)'), 'VeryStrongPassword123!');
    await tester.pumpAndSettle();

    expect(find.text('Strong'), findsOneWidget);
  });
}
