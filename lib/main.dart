import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/service_provider.dart';
import 'features/auth/domain/services/auth_service.dart';
import 'features/vault/domain/services/vault_manager.dart';
import 'features/totp/domain/services/totp_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/clipboard_service.dart';
import 'core/services/pwned_service.dart';
import 'core/services/biometric_service.dart';
import 'core/providers/service_providers.dart';
import 'core/widgets/privacy_overlay.dart';

/// The application entry point.
///
/// Initializes:
/// - Flutter binding
/// - Secure storage
/// - Core services (Auth, Vault, TOTP, etc.)
/// - Riverpod provider scope
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  final storageService = SecureStorageService();
  await storageService.init();

  // Initialize services
  final authService = AuthService();
  final vaultManager = VaultManager(storageService: storageService);
  final totpService = TotpService();
  final clipboardService = ClipboardService();
  final pwnedService = PwnedService();
  final biometricService = BiometricService();

  runApp(ProviderScope(
    overrides: [
      storageServiceProvider.overrideWithValue(storageService),
      authServiceProvider.overrideWithValue(authService),
      totpServiceProvider.overrideWithValue(totpService),
      clipboardServiceProvider.overrideWithValue(clipboardService),
      pwnedServiceProvider.overrideWithValue(pwnedService),
      biometricServiceProvider.overrideWithValue(biometricService),
      vaultManagerProvider.overrideWith((ref) => vaultManager),
    ],
    child: PassMApp(
      authService: authService,
      vaultManager: vaultManager,
      totpService: totpService,
      storageService: storageService,
      clipboardService: clipboardService,
      pwnedService: pwnedService,
      biometricService: biometricService,
    ),
  ));
}

/// The root widget of the application.
///
/// Configures:
/// - [MaterialApp] with light/dark themes.
/// - [PrivacyOverlay] to protect sensitive screens in background.
/// - Navigation to [LoginScreen].
class PassMApp extends ConsumerWidget {
  final AuthService authService;
  final VaultManager vaultManager;
  final TotpService totpService;
  final SecureStorageService storageService;
  final ClipboardService clipboardService;
  final PwnedService pwnedService;
  final BiometricService biometricService;

  const PassMApp({
    super.key,
    required this.authService,
    required this.vaultManager,
    required this.totpService,
    required this.storageService,
    required this.clipboardService,
    required this.pwnedService,
    required this.biometricService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return ServiceProvider(
      authService: authService,
      vaultManager: vaultManager,
      totpService: totpService,
      storageService: storageService,
      clipboardService: clipboardService,
      pwnedService: pwnedService,
      biometricService: biometricService,
      child: MaterialApp(
        title: 'PassM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        builder: (context, child) => PrivacyOverlay(child: child!),
        home: const LoginScreen(),
      ),
    );
  }
}
