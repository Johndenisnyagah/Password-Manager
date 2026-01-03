import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keynest/features/vault/presentation/screens/vault_health_screen.dart';
import 'package:keynest/core/providers/service_providers.dart';
import 'package:keynest/features/vault/domain/models/vault_entry.dart';
import 'package:keynest/features/vault/domain/services/vault_manager.dart';
import 'package:keynest/core/services/pwned_service.dart';

class MockVaultManager extends ChangeNotifier implements VaultManager {
  final List<VaultEntry> _entries;
  MockVaultManager(this._entries);

  @override
  List<VaultEntry> get entries => _entries;
  
  @override
  bool get isLocked => false;
  
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPwnedService extends Fake implements PwnedService {
  final int mockCount;
  MockPwnedService({this.mockCount = 0});

  @override
  Future<int> checkPassword(String password) async => mockCount;
}

void main() {
  group('VaultHealthScreen Tests', () {
    testWidgets('Should show empty state when no issues found', (tester) async {
      final entries = [
        VaultEntry(
          id: '1',
          serviceName: 'StrongService',
          username: 'user',
          password: 'VeryStrongPassword123!', // Good strength
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultManagerProvider.overrideWith((ref) => MockVaultManager(entries)),
            pwnedServiceProvider.overrideWithValue(MockPwnedService(mockCount: 0)),
          ],
          child: const MaterialApp(home: VaultHealthScreen()),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('No security issues found!'), findsOneWidget);
    });

    testWidgets('Should detect weak and leaked passwords', (tester) async {
      final entries = [
        VaultEntry(
          id: '1',
          serviceName: 'WeakService',
          username: 'user',
          password: '123', // Weak
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        VaultEntry(
          id: '2',
          serviceName: 'LeakedService',
          username: 'user',
          password: 'P@ssw0rd123456!', // Strong BUT Leaked
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultManagerProvider.overrideWith((ref) => MockVaultManager(entries)),
            pwnedServiceProvider.overrideWithValue(MockPwnedService(mockCount: 999)),
          ],
          child: const MaterialApp(home: VaultHealthScreen()),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('WeakService'), findsNWidgets(2)); // One weak, one leaked
      expect(find.text('LeakedService'), findsOneWidget); // Only leaked
      expect(find.textContaining('Weak password detected'), findsOneWidget);
      expect(find.textContaining('found in 999 data breaches'), findsNWidgets(2));
    });

    testWidgets('Should detect reused passwords', (tester) async {
      final entries = [
        VaultEntry(
          id: '1',
          serviceName: 'ServiceA',
          username: 'user',
          password: 'SamePassword123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        VaultEntry(
          id: '2',
          serviceName: 'ServiceB',
          username: 'user',
          password: 'SamePassword123',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultManagerProvider.overrideWith((ref) => MockVaultManager(entries)),
            pwnedServiceProvider.overrideWithValue(MockPwnedService(mockCount: 0)),
          ],
          child: const MaterialApp(home: VaultHealthScreen()),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.textContaining('Password reused in 2 entries'), findsNWidgets(2));
    });
  });
}
