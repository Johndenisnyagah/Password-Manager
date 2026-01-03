import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keynest/core/providers/service_providers.dart';
import 'dart:ui';

import 'package:keynest/main.dart';
import 'package:keynest/core/services/secure_storage_service.dart';
import 'package:keynest/core/services/clipboard_service.dart';
import 'package:keynest/core/services/pwned_service.dart';
import 'package:keynest/core/services/biometric_service.dart';
import 'package:keynest/features/auth/domain/services/auth_service.dart';
import 'package:keynest/features/vault/domain/services/vault_manager.dart';
import 'package:keynest/features/totp/domain/services/totp_service.dart';

void main() {
  testWidgets('App launches with onboarding screen', (WidgetTester tester) async {
    // Initialize services for testing
    final storageService = SecureStorageService();
    final authService = AuthService();
    final vaultManager = VaultManager(storageService: storageService);
    final totpService = TotpService();
    final clipboardService = ClipboardService();
    final pwnedService = PwnedService();
    final biometricService = BiometricService();

    // Set a large enough screen size to avoid overflow errors
    tester.view.physicalSize = const Size(2400, 3200);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build our app and trigger a frame.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
        authServiceProvider.overrideWithValue(authService),
        totpServiceProvider.overrideWithValue(totpService),
        clipboardServiceProvider.overrideWithValue(clipboardService),
        pwnedServiceProvider.overrideWithValue(pwnedService),
        biometricServiceProvider.overrideWithValue(biometricService),
        vaultManagerProvider.overrideWith((ref) => vaultManager),
      ],
      child: KeyNestApp(
        authService: authService,
        vaultManager: vaultManager,
        totpService: totpService,
        storageService: storageService,
        clipboardService: clipboardService,
        pwnedService: pwnedService,
        biometricService: biometricService,
      ),
    ));

    // Verify that the onboarding/login text is displayed.
    // The Onboarding screen likely has the app name or some Welcome text.
    expect(find.text('KeyNest'), findsOneWidget);
  });
}
