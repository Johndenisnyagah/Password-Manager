# KeyNest Architecture Documentation

## Table of Contents
- [Overview](#overview)
- [Architecture Principles](#architecture-principles)
- [High-Level Architecture](#high-level-architecture)
- [Project Structure](#project-structure)
- [Layer Architecture](#layer-architecture)
- [Core Components](#core-components)
- [Feature Modules](#feature-modules)
- [Security Architecture](#security-architecture)
- [Data Flow](#data-flow)
- [State Management](#state-management)
- [Testing Strategy](#testing-strategy)

---

## Overview

KeyNest is a cross-platform password manager built with Flutter that prioritizes security through client-side encryption and follows clean architecture principles. The application uses a feature-first modular structure with clear separation of concerns.

**Key Technical Characteristics:**
- **Framework**: Flutter 3.0+ (Dart)
- **Architecture**: Clean Architecture + Feature-First Organization
- **Security**: AES-256-GCM encryption with Argon2id key derivation
- **State Management**: Flutter Riverpod + ChangeNotifier
- **Platforms**: iOS, Android, Web, Windows, macOS

---

## Architecture Principles

1. **Zero-Knowledge Architecture**: Master password never leaves the device; all encryption/decryption happens client-side
2. **Separation of Concerns**: Clear boundaries between presentation, domain, and data layers
3. **Dependency Injection**: Services are injected via InheritedWidget and Riverpod providers
4. **Immutability**: Vault entries and sensitive data are immutable where possible
5. **Security by Design**: Cryptographic operations follow OWASP best practices
6. **Testability**: Business logic is decoupled from UI for comprehensive testing

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                       │
│  (Screens, Widgets, UI Logic)                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │  Auth    │  │  Vault   │  │  Profile │  │  TOTP    │         │
│  │  Screens │  │  Screens │  │  Screens │  │  Screens │         │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Domain Layer                            │
│  (Business Logic, Services, Models)                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │Auth      │  │ Vault    │  │  TOTP    │  │  Sync    │         │
│  │Service   │  │ Manager  │  │  Service │  │  Service │         │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Data Layer                              │
│  (Repositories, Storage, External APIs)                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │ Vault    │  │ Secure   │  │  Pwned   │  │  Local   │         │
│  │Repository│  │ Storage  │  │  API     │  │  Storage │         │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Core Infrastructure                        │
│  (Crypto, Utils, Theme, Widgets)                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │ Crypto   │  │ Service  │  │  App     │  │ Common   │         │
│  │ Service  │  │ Provider │  │  Theme   │  │ Widgets  │         │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
lib/
├── main.dart                      # Application entry point
│
├── core/                          # Shared infrastructure
│   ├── crypto/
│   │   └── crypto_service.dart    # AES-GCM encryption & Argon2id key derivation
│   ├── providers/
│   │   └── service_providers.dart # Riverpod provider definitions
│   ├── services/
│   │   ├── service_provider.dart  # InheritedWidget DI container
│   │   ├── secure_storage_service.dart  # flutter_secure_storage wrapper
│   │   ├── clipboard_service.dart # Clipboard operations
│   │   ├── pwned_service.dart     # Have I Been Pwned API client
│   │   └── biometric_service.dart # Biometric authentication wrapper
│   ├── theme/
│   │   └── app_theme.dart         # Material theme configuration
│   ├── utils/
│   │   └── password_validator.dart # Password strength & validation
│   └── widgets/
│       └── privacy_overlay.dart   # App switcher privacy layer
│
└── features/                      # Feature modules (vertical slices)
    ├── auth/
    │   ├── domain/
    │   │   └── services/
    │   │       └── auth_service.dart    # Authentication logic
    │   ├── data/
    │   │   └── repositories/
    │   │       └── auth_repository.dart # Auth data persistence
    │   └── presentation/
    │       ├── screens/
    │       │   ├── login_screen.dart    # Login UI
    │       │   └── register_screen.dart # Registration UI
    │       └── widgets/
    │           └── password_strength_indicator.dart
    │
    ├── vault/
    │   ├── domain/
    │   │   ├── models/
    │   │   │   ├── vault.dart          # Vault data model
    │   │   │   ├── vault_entry.dart    # Password entry model
    │   │   │   └── kdf_params.dart     # Key derivation parameters
    │   │   └── services/
    │   │       └── vault_manager.dart  # Vault CRUD operations & encryption
    │   ├── data/
    │   │   └── repositories/
    │   │       └── vault_repository.dart # Vault data persistence
    │   └── presentation/
    │       ├── screens/
    │       │   ├── vault_screen.dart
    │       │   ├── add_entry_screen.dart
    │       │   ├── entry_details_screen.dart
    │       │   └── vault_health_screen.dart
    │       └── widgets/
    │           ├── vault_card.dart
    │           └── entry_tile.dart
    │
    ├── totp/
    │   ├── domain/
    │   │   └── services/
    │   │       └── totp_service.dart   # TOTP code generation
    │   └── presentation/
    │       └── widgets/
    │           └── totp_display.dart
    │
    └── sync/
        ├── domain/
        │   └── services/
        │       └── sync_service.dart   # Cloud sync (future)
        └── data/
            └── repositories/
                └── sync_repository.dart
```

---

## Layer Architecture

### Presentation Layer
**Responsibility**: UI rendering, user interaction, state display

**Components**:
- **Screens**: Full-page views (e.g., `VaultScreen`, `LoginScreen`)
- **Widgets**: Reusable UI components (e.g., `EntryTile`, `PasswordStrengthIndicator`)
- **State**: Local UI state managed via `StatefulWidget` or Riverpod providers

**Rules**:
- Never contains business logic
- Depends on domain services via dependency injection
- Uses `ServiceProvider.of(context)` to access services
- Displays data from domain models

### Domain Layer
**Responsibility**: Business logic, validation, orchestration

**Components**:
- **Services**: Business logic containers (e.g., `VaultManager`, `AuthService`)
- **Models**: Immutable data classes with business rules (e.g., `VaultEntry`, `Vault`)
- **Interfaces**: Abstract contracts for repositories (future enhancement)

**Rules**:
- No direct dependency on Flutter framework (except `ChangeNotifier`)
- No direct access to storage/network (delegates to data layer)
- Pure Dart code for maximum testability
- Models contain validation logic

### Data Layer
**Responsibility**: Data persistence, external API communication

**Components**:
- **Repositories**: Abstract data sources (file system, secure storage, APIs)
- **Data Sources**: Platform-specific implementations
- **DTOs**: Data transfer objects (if needed for API mapping)

**Rules**:
- Implements repository interfaces defined in domain
- Handles serialization/deserialization
- Manages platform-specific storage mechanisms

---

## Core Components

### 1. CryptoService
**Location**: `core/crypto/crypto_service.dart`

**Purpose**: Centralized cryptographic operations following OWASP guidelines

**Key Methods**:
```dart
Future<SecretKey> deriveMasterKey(String password, Uint8List salt, {int iterations})
Future<Map<String, String>> encrypt(String plaintext, SecretKey masterKey)
Future<String> decrypt(String ciphertextWithMacBase64, SecretKey masterKey, String nonceBase64)
Uint8List generateSalt()
```

**Security Details**:
- **Algorithm**: AES-256-GCM (AEAD - Authenticated Encryption with Associated Data)
- **Key Derivation**: Argon2id (32 MiB, 3 iterations, 1 parallelism)
- **Nonce**: 12-byte random nonce per encryption operation
- **Output**: Base64-encoded ciphertext + MAC + nonce

### 2. VaultManager
**Location**: `features/vault/domain/services/vault_manager.dart`

**Purpose**: Manages the lifecycle of the encrypted vault

**Key Responsibilities**:
- Unlocking the vault (decrypting from storage)
- Creating a new vault with master password
- CRUD operations on vault entries
- Auto-lock timer management
- Re-encrypting vault on save

**State**:
- `_masterKey`: Held in memory only while unlocked
- `_entries`: Decrypted list of password entries
- `_kdfParams`: Salt and iteration count for re-encryption

**Key Methods**:
```dart
Future<void> unlock(String masterPassword)
Future<void> lock()
Future<void> createVault(String masterPassword)
Future<void> addEntry(VaultEntry entry)
Future<void> updateEntry(String id, VaultEntry updatedEntry)
Future<void> deleteEntry(String id)
void setAutoLockDuration(Duration duration)
```

### 3. SecureStorageService
**Location**: `core/services/secure_storage_service.dart`

**Purpose**: Abstraction over `flutter_secure_storage` for sensitive data

**Storage Items**:
- Encrypted vault blob
- KDF parameters (salt, iterations)
- Biometric authentication tokens (future)

**Platform Support**:
- **iOS**: Keychain
- **Android**: EncryptedSharedPreferences
- **Windows**: DPAPI
- **Web**: IndexedDB with encryption

### 4. ServiceProvider (InheritedWidget)
**Location**: `core/services/service_provider.dart`

**Purpose**: Dependency injection container for core services

**Provided Services**:
- `AuthService`
- `VaultManager`
- `TotpService`
- `SecureStorageService`
- `ClipboardService`
- `PwnedService`
- `BiometricService`

**Usage**:
```dart
final vaultManager = ServiceProvider.of(context).vaultManager;
```

### 5. Riverpod Providers
**Location**: `core/providers/service_providers.dart`

**Purpose**: Modern state management and dependency injection

**Providers**:
```dart
final storageServiceProvider = Provider<SecureStorageService>((ref) => ...);
final authServiceProvider = Provider<AuthService>((ref) => ...);
final vaultManagerProvider = ChangeNotifierProvider<VaultManager>((ref) => ...);
final totpServiceProvider = Provider<TotpService>((ref) => ...);
```

---

## Feature Modules

### Authentication Module (`features/auth/`)

**Purpose**: User registration, login, and session management

**Key Components**:
- `AuthService`: JWT-based authentication (currently mocked for backend-less operation)
- `LoginScreen`: Email/password login form
- `RegisterScreen`: Account creation with password validation
- `PasswordStrengthIndicator`: Real-time password strength meter

**Flow**:
1. User registers → `AuthService.register()` → Mock JWT stored
2. User logs in → `AuthService.login()` → Session established
3. User unlocks vault → `VaultManager.unlock()` → Master key derived separately

**Note**: Account password (for authentication) is separate from master password (for vault encryption)

### Vault Module (`features/vault/`)

**Purpose**: Password entry management and vault operations

**Models**:
- `Vault`: Container for entries with metadata
- `VaultEntry`: Individual password record
  ```dart
  {
    id, serviceName, username, password, 
    totpSecret, url, notes, category, 
    tags, createdAt, updatedAt, isArchived
  }
  ```
- `KdfParameters`: Salt and iteration count

**Screens**:
- `VaultScreen`: Main password list with tabs (Personal/Shared, Active/Archived)
- `AddEntryScreen`: Create new password entry
- `EntryDetailsScreen`: View/edit entry with copy-to-clipboard
- `VaultHealthScreen`: Security audit (weak/reused/pwned passwords)

**Key Features**:
- Real-time search/filter
- Copy to clipboard with auto-clear
- Password visibility toggle
- TOTP code generation
- Archive/unarchive entries
- Vault export/import (encrypted JSON)

### TOTP Module (`features/totp/`)

**Purpose**: Time-based One-Time Password (2FA) generation

**Algorithm**: RFC 6238 TOTP
- Base32 secret decoding
- HMAC-SHA1 hashing
- 30-second time window
- 6-digit codes

**Integration**: Embedded in `VaultEntry` with optional `totpSecret` field

### Sync Module (`features/sync/`)

**Purpose**: Cloud synchronization (future implementation)

**Planned Features**:
- End-to-end encrypted sync
- Conflict resolution (last-write-wins or merge)
- Differential updates
- Offline-first architecture

---

## Security Architecture

### Encryption Stack

```
┌─────────────────────────────────────────────┐
│         Master Password (User Input)        │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
         ┌──────────────────────┐
         │   PBKDF2-HMAC-SHA256 │
         │   600,000 iterations │
         │   + Random Salt      │
         └─────────┬────────────┘
                   │
                   ▼
         ┌──────────────────────┐
         │  Master Key (256-bit)│ ← Held in memory only
         └─────────┬────────────┘
                   │
                   ▼
         ┌─────────────────────┐
         │   AES-256-GCM       │
         │   + Random Nonce    │
         │   + MAC (Auth Tag)  │
         └─────────┬───────────┘
                   │
                   ▼
         ┌──────────────────────┐
         │  Encrypted Vault Blob│ ← Stored on disk
         │  (Base64 Ciphertext) │
         └──────────────────────┘
```

### Key Security Features

1. **Zero-Knowledge Architecture**
   - Master password never transmitted to server
   - All encryption/decryption happens locally
   - Server (when implemented) only stores encrypted blob

2. **Memory Protection**
   - Master key cleared on lock
   - Sensitive data not persisted in plain text
   - Auto-lock timer prevents unauthorized access

3. **Crypto Best Practices**
   - AEAD cipher (AES-GCM) prevents tampering
   - Unique nonce per encryption
   - PBKDF2 with high iteration count resists brute-force
   - Random salt per vault

4. **Additional Security**
   - Password strength validation (entropy, character classes)
   - Have I Been Pwned integration (k-Anonymity via hash prefix)
   - Biometric authentication (UI stub for future implementation)
   - Privacy overlay on app switcher

### Threat Model

**Protected Against**:
- ✅ Brute-force attacks (high PBKDF2 iterations)
- ✅ Data tampering (MAC verification)
- ✅ Stolen device access (encryption at rest)
- ✅ Memory dumps while locked (key cleared)
- ✅ Network sniffing (no plaintext transmission)

**Not Protected Against** (Acceptable Risks):
- ❌ Compromised device with keylogger (no password manager can protect against this)
- ❌ Side-channel attacks on hardware
- ❌ Quantum computing attacks (AES-256 has partial resistance)

---

## Data Flow

### Vault Unlock Flow

```
User Input (Master Password)
         ↓
LoginScreen → VaultManager.unlock()
         ↓
CryptoService.deriveMasterKey() → Generate master key from password + salt
         ↓
SecureStorageService.read() → Retrieve encrypted vault blob
         ↓
CryptoService.decrypt() → Decrypt blob with master key
         ↓
JSON.decode() → Parse vault entries
         ↓
VaultManager._entries = decrypted list
         ↓
VaultManager.notifyListeners() → Update UI
         ↓
VaultScreen displays entries
```

### Add Entry Flow

```
AddEntryScreen (User Input)
         ↓
VaultManager.addEntry(newEntry)
         ↓
_entries.add(newEntry) → Update in-memory list
         ↓
_saveVault() → Serialize entries to JSON
         ↓
CryptoService.encrypt() → Encrypt with master key
         ↓
SecureStorageService.write() → Persist encrypted blob
         ↓
notifyListeners() → Update UI
```

### TOTP Generation Flow

```
VaultCard Widget → User taps TOTP icon
         ↓
TotpService.generateCode(entry.totpSecret)
         ↓
Base32.decode(secret) → Convert secret to bytes
         ↓
HMAC-SHA1(counter, secret) → Generate hash
         ↓
Dynamic Truncation → Extract 6-digit code
         ↓
ClipboardService.copy(code) → Copy to clipboard
         ↓
Show SnackBar confirmation
```

---

## State Management

### Approach: Hybrid (Riverpod + ChangeNotifier)

**Riverpod Providers**:
- Service singletons (stateless services)
- Global state (vault manager, auth service)
- Dependency injection

**ChangeNotifier**:
- `VaultManager`: Notifies UI when vault state changes (lock/unlock, entry CRUD)
- Custom notifiers for specific features

**Local State**:
- `StatefulWidget` for transient UI state (form inputs, visibility toggles)

### State Hierarchy

```
ProviderScope (Root)
    ↓
ServiceProvider (InheritedWidget)
    ↓
Consumer Widgets (Listen to Riverpod)
    ↓
Stateful Widgets (Local UI state)
```

**Example**:
```dart
// Riverpod provider for global vault state
final vaultManagerProvider = ChangeNotifierProvider<VaultManager>((ref) {
  return ref.watch(vaultManagerProvider);
});

// Consumer widget listens to changes
Consumer(
  builder: (context, ref, child) {
    final vaultManager = ref.watch(vaultManagerProvider);
    return ListView(children: vaultManager.entries.map(...));
  }
)
```

---

## Testing Strategy

### Test Pyramid

```
        ┌──────────────┐
        │   E2E Tests  │  ← Integration tests (Flutter Driver)
        └──────────────┘
       ┌─────────────────┐
       │  Widget Tests   │  ← UI component tests
       └─────────────────┘
     ┌──────────────────────┐
     │     Unit Tests       │  ← Business logic tests
     └──────────────────────┘
```

### Testing Approach

**Unit Tests** (`test/core/`, `test/features/`):
- CryptoService encryption/decryption
- VaultManager CRUD operations
- TotpService code generation
- PasswordValidator strength calculation
- AuthService mock authentication

**Widget Tests** (`test/features/*/presentation/`):
- Screen rendering
- User interaction flows
- State updates
- Error handling

**Integration Tests** (`integration_test/`):
- Complete user flows (register → unlock → add entry → lock)
- Data persistence
- Cross-feature interactions

### Mocking Strategy
- Use `mocktail` for service mocking
- Repository pattern allows easy data layer mocking
- InheritedWidget DI simplifies test setup

---

## Dependencies

### Production Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| `cryptography` | AES-GCM, PBKDF2 crypto operations | ^2.5.0 |
| `flutter_secure_storage` | Secure key-value storage | ^9.0.0 |
| `flutter_riverpod` | State management & DI | ^2.5.1 |
| `uuid` | Unique ID generation | ^4.0.0 |
| `local_auth` | Biometric authentication | ^2.1.6 |
| `image_picker` | Profile photo upload | ^1.0.7 |
| `lottie` | Animated profile placeholder | ^3.3.2 |
| `http` | Pwned Passwords API client | ^1.2.0 |
| `base32` | TOTP secret decoding | ^2.1.3 |
| `crypto` | SHA hashing utilities | ^3.0.3 |

### Dev Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_test` | Widget & unit testing |
| `build_runner` | Code generation |
| `json_serializable` | Model serialization |
| `flutter_lints` | Dart linting rules |

---

## Future Enhancements

### Planned Features
1. **Biometric Unlock**: Full integration with `local_auth` package
2. **Cloud Sync**: End-to-end encrypted sync via backend API
3. **Password Generator**: Configurable random password generation
4. **Autofill Integration**: Platform-specific autofill providers
5. **Browser Extension**: WebAuthn-based companion extension
6. **Backup/Restore**: Encrypted cloud backups
7. **Shared Vaults**: Team password sharing with permissions

### Architecture Evolution
1. **Repository Pattern**: Abstract data sources with interfaces
2. **Use Cases**: Extract business logic into single-responsibility use cases
3. **Bloc Pattern**: Replace ChangeNotifier with BLoC for complex state
4. **Offline-First**: Robust sync conflict resolution
5. **Multi-Vault**: Support multiple vaults with different master passwords

---

## Conventions & Best Practices

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter_lints` analyzer rules
- Document all public APIs with DartDoc comments
- Prefer composition over inheritance

### Security Guidelines
- Never log sensitive data (passwords, keys)
- Clear sensitive data from memory after use
- Validate all user inputs
- Use constant-time comparisons for MACs/hashes
- Keep crypto libraries up-to-date

### Git Workflow
- Feature branches: `feature/add-password-generator`
- Commit messages: Follow [Conventional Commits](https://www.conventionalcommits.org/)
- PR reviews required for all changes
- Automated tests must pass before merge

---

## Performance Considerations

1. **Key Derivation**: PBKDF2 with 600k iterations is CPU-intensive (~500ms on modern devices). Consider offloading to isolate.
2. **Large Vaults**: For >1000 entries, implement pagination or virtualized lists.
3. **Auto-Lock Timer**: Uses `Timer.periodic` which may impact battery on long intervals.
4. **Memory**: Decrypted vault held in memory; monitor for large vaults.

---

## Contact & Contribution

For questions or contributions, please refer to:
- **Issues**: GitHub Issues for bug reports and feature requests
- **Pull Requests**: Follow the contribution guidelines in `CONTRIBUTING.md`
- **Security**: Report vulnerabilities privately to [security contact email]

---

*Last Updated: December 24, 2025*
