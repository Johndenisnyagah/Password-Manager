import 'package:flutter_test/flutter_test.dart';

import 'package:passm/main.dart';
import 'package:passm/core/services/secure_storage_service.dart';
import 'package:passm/core/services/clipboard_service.dart';
import 'package:passm/core/services/pwned_service.dart';
import 'package:passm/core/services/biometric_service.dart';
import 'package:passm/features/auth/domain/services/auth_service.dart';
import 'package:passm/features/vault/domain/services/vault_manager.dart';
import 'package:passm/features/totp/domain/services/totp_service.dart';

void main() {
  testWidgets('App launches with login screen', (WidgetTester tester) async {
    // Initialize services for testing
    final storageService = SecureStorageService();
    final authService = AuthService();
    final vaultManager = VaultManager();
    final totpService = TotpService();
    final clipboardService = ClipboardService();
    final pwnedService = PwnedService();
    final biometricService = BiometricService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(PassMApp(
      authService: authService,
      vaultManager: vaultManager,
      totpService: totpService,
      storageService: storageService,
      clipboardService: clipboardService,
      pwnedService: pwnedService,
      biometricService: biometricService,
    ));

    // Verify that the login screen is displayed.
    expect(find.text('PassM'), findsOneWidget);
  });
}
