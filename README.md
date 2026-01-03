# KeyNest - Secure Password Manager

> 🤖 **AI-Assisted Development**: This project was developed with the assistance of Antigravity AI, which helped with code generation, debugging, architecture decisions, and best practices implementation.

A modern, secure, and hybrid password manager built with Flutter. KeyNest prioritizes security with client-side encryption while offering a premium user experience with smooth animations and intuitive design.

> ⚠️ **Beta Status**: This project is functional and tested (67 tests passing) but has not undergone professional security auditing. Suitable for personal use and evaluation. Back up your data regularly using the built-in export feature.

## Features

### Authentication & Security
*   **Master Password**: Zero-knowledge architecture. Your master password decrypts the vault locally; it is never stored in plain text.
*   **Secure Registration**: Enforces strong password policies (min 8 chars, mixed case, numbers, special chars) with a real-time strength meter.
*   **Auto-Lock**: Configurable inactivity timer blocks access (1, 5, 15, 30, 60 minutes) requiring re-authentication.
*   **Biometric Unlock**: Secure Face/Touch ID integration for effortless and secure vault access.
*   **Change Master Password**: Securely re-keys the entire vault with a new password without losing data.

### Vault Management
*   **Entry Management**: Add, View, Edit, and Delete password entries.
*   **Categorization**:
    *   **Tabs**: Organize entries by "Personal" vs "Shared" and "Active" vs "Archived".
    *   **Search**: Real-time filtering by service name or username.
*   **Entry Details**:
    *   **Copy to Clipboard**: One-tap copy for usernames and passwords.
    *   **Password Visibility**: Toggle to reveal/hide sensitive fields.
    *   **TOTP Support**: Built-in 2FA code generation (Time-based One-Time Passwords).
    *   **Sharing**: "Share" functionality (currently stubs the action).
    *   **Archiving**: Move old accounts to the Archive tag without deleting them.

### Profile & Data
*   **Lottie Avatar**: Dynamic profile placeholder animation when no user photo is set.
*   **Profile Customization**: Upload and store a profile picture (persisted locally).
*   **Data Export**: Export your entire vault as an encrypted JSON blob to the clipboard for backup.
*   **Data Import**: Restore your vault from an encrypted JSON backup string.

## 🛠 Technical Architecture

> 📖 **For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md)**

### Core Stack
*   **Framework**: Flutter (Dart)
*   **Platforms**: iOS, Android, Web, Windows/macOS support.

### Security Implementation
*   **Encryption**:
    *   **Algorithm**: AES-GCM (256-bit) for vault data.
    *   **Key Derivation**: Argon2id for deriving encryption keys from the Master Password (resistance against GPU cracking).
    *   **Library**: `cryptography` package.
*   **Storage**:
    *   **Secrets**: `flutter_secure_storage` for storing the Master Key salt (biometrics) or high-sensitivity tokens.
    *   **Vault Data**: Encrypted JSON blob stored in local file system/preferences.

### State Management & Architecture
*   **State Management**: Architecture powered by **Riverpod** for reactive, testable, and robust state handled through providers.
*   **UI Architecture**: Component-based with reusable widgets (`PasswordStrengthIndicator`, `EntryTile`).
*   **Theming**: Centralized `AppTheme` with custom color palettes (Deep Purple primary) and typography.

## Dependencies

Key packages used in this project:

| Package | Purpose |
| :--- | :--- |
| `cryptography` | High-level cryptographic operations (AES-GCM, Argon2). |
| `flutter_secure_storage` | Secure storage for sensitive keys. |
| `flutter_riverpod` | Reactive state management and dependency injection. |
| `image_picker` | Selecting profile photos from gallery/camera. |
| `lottie` | Rendering After Effects animations (JSON/Zip). |
| `uuid` | Generating unique IDs for vault entries. |
| `json_serializable` | JSON code generation for models. |

## Installation

### **Try the Web App**

**🎯 Recommended - No Installation Required:**

- **🌐 Web App**: [**Launch KeyNest**](YOUR_VERCEL_URL_HERE)
  - Runs directly in your browser - no download needed
  - Works on any device (desktop, tablet, mobile)
  - Data stored locally in your browser

---

### **Native Apps** *(Coming Soon)*

Native app releases are planned for future versions:

- **📱 Android**: APK release planned
- **💻 Windows**: Desktop app planned  
- **🍎 iOS/macOS**: Release planned

*For now, use the web app above - it works on all devices!*

---

## Developer Setup (Build from Source)

### **Prerequisites**
- Flutter SDK 3.0+ ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Run `flutter doctor` to verify setup

### **Build Instructions**

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/Johndenisnyagah/KeyNest.git
    cd KeyNest
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run in Development Mode**:
    ```bash
    # Web
    flutter run -d chrome
    
    # Android (requires Android device/emulator)
    flutter run -d android
    
    # Windows
    flutter run -d windows
    ```

4.  **Build Release Version**:
    ```bash
    # Android APK
    flutter build apk --release
    # Output: build/app/outputs/flutter-apk/app-release.apk
    
    # Web
    flutter build web --release
    # Output: build/web/
    
    # Windows (requires Developer Mode enabled)
    flutter build windows --release
    # Output: build/windows/x64/runner/Release/
    ```

## Project Structure

*   `lib/core/`: Shared utilities, theme, and services (Crypto, Storage).
*   `lib/features/auth/`: Authentication screens (Login, Register, Profile) and widgets.
*   `lib/features/vault/`: Main application logic (Vault Screen, Entry Details).
*   `assets/animations/`: Static assets like Lottie files.

---
### **Recent Improvements** (v1.3.0):
- **Vault Health Dashboard**: Professional auditing for weak, reused, or leaked passwords (via HIBP).
- **State Management Modernization**: Refactored core architecture to **Riverpod** for reactive and testable state.
- **Dark Mode UI Polish**: Comprehensive theme audit fixing all hardcoded colors for a seamless dark experience.
- **Smart Auto-lock**: Timer resets on user activity (gestures).
- **Biometric Authentication Service**: Integrated biometric support for FaceID/Fingerprint.
- **HIBP Private Auditing**: Secure checking of passwords against breach databases.
- **Advanced Password Generator**: Interactive dialog for complex secrets.
- **Clipboard Auto-clear**: Sensitive data is automatically wiped from the clipboard.
- **Encrypted Import/Export**: Secure JSON backups for data portability.

### Current Status
**Version**: 1.7.0  
**Stability**: Stable - Production Ready  
**Test Coverage**: ✅ 67 tests passing

### **Latest Updates** (v1.7.0 - Test Coverage Release):
- **Comprehensive Test Suite**: 67 tests covering all core services, widgets, and integration flows.
- **Unit Tests**: `CryptoService`, `PasswordGeneratorService`, `PasswordValidator`, `SecureStorageService`, `PwnedService`, `TotpService`, `VaultManager`.
- **Widget Tests**: `LoginScreen`, `RegisterScreen`, `ProfileScreen`, `GeneratorScreen`, `VaultScreen`, `VaultHealthScreen`, `AddEntryScreen`, `EntryDetailScreen`.
- **Integration Tests**: Full registration, login, entry lifecycle, and security flows.
- **Test Infrastructure**: Mock services, `ProviderScope` overrides, and proper test isolation.

### Previous Updates (v1.6.0 - Code Quality Release):
- **Zero Lint Issues**: Comprehensive static analysis cleanup achieving `flutter analyze` with no issues.
- **Deprecated API Migration**: Updated all `Color.withOpacity()` calls to modern `Color.withValues(alpha:)` API across 13+ files.
- **Async Safety Audit**: Fixed `use_build_context_synchronously` violations with proper `mounted` checks and context handling.
- **Production Logging**: Replaced `print()` statements with `debugPrint()` (auto-stripped in release builds).
- **Dead Code Removal**: Cleaned unused variables in `VaultManager` and `ProfileScreen`.
- **Test Environment**: Fixed widget test layout overflow issues with proper screen dimension configuration.


### Previous Updates (v1.5.0):
- **Security Hardening**: Completely removed the "Password Hint" feature from the registration and profile screens to eliminate potential master password leaks.
- **Profile UI Overhaul**: 
    - Replaced the top colored header with a clean, uniform background.
    - Optimized the settings layout by separating grouped items (Security, Data) into individual "mini cards" for better clarity.
    - Updated the "Logout" button to match the application's deep purple theme.
- **Themed Navigation**: Consistent deep purple navigation icons and titles across the profile management flow.
