import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keynest/features/vault/presentation/screens/vault_screen.dart';
import 'package:keynest/core/providers/service_providers.dart';
import 'package:keynest/features/vault/domain/models/vault_entry.dart';
import 'package:keynest/features/vault/domain/services/vault_manager.dart';
import 'package:keynest/core/services/secure_storage_service.dart';
import 'dart:typed_data';


class MockSecureStorage extends Fake implements SecureStorageService {
  @override
  Future<String?> loadUsername() async => 'TestUser';
  @override
  Future<String?> loadThemeMode() async => 'system';
  @override
  Future<Uint8List?> loadProfilePhoto() async => null;
}

class MockVaultManager extends ChangeNotifier implements VaultManager {
  final List<VaultEntry> _entries = [
    VaultEntry(
      id: '1',
      serviceName: 'Google',
      username: 'user1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isArchived: false,
      isShared: false,
    ),
    VaultEntry(
      id: '2',
      serviceName: 'GitHub',
      username: 'user2',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isArchived: false,
      isShared: false,
    ),
    VaultEntry(
      id: '3',
      serviceName: 'ArchivedService',
      username: 'user3',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isArchived: true,
      isShared: false,
    ),
  ];

  @override
  List<VaultEntry> get entries => _entries;

  @override
  bool get isLocked => false;

  @override
  Future<void> updateEntry(VaultEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
  
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(MockSecureStorage()),
        vaultManagerProvider.overrideWith((ref) => MockVaultManager()),
      ],
      child: const MaterialApp(
        home: VaultScreen(),
      ),
    );
  }

  group('VaultScreen Tests', () {
    testWidgets('Should display entries list active by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('ArchivedService'), findsNothing);
    });

    testWidgets('Search should filter entries', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField), 'Goo');
      await tester.pump();
      
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('GitHub'), findsNothing);
    });

    testWidgets('Tab switching should show different entries', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      // Initially in My Vault
      expect(find.text('Google'), findsOneWidget);
      
      // Switch to Archived
      await tester.tap(find.text('Archived'));
      await tester.pumpAndSettle();
      
      expect(find.text('Google'), findsNothing);
      expect(find.text('ArchivedService'), findsOneWidget);
    });

    testWidgets('Should show empty state for shared tab', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Shared'));
      await tester.pumpAndSettle();
      
      expect(find.text('No shared entries'), findsOneWidget);
    });
  });
}
