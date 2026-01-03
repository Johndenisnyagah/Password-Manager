# Changelog

All notable changes to KeyNest will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Full biometric authentication integration (Face ID/Touch ID/Fingerprint)
- Cloud sync with end-to-end encryption
- Password generator with customizable options
- Browser autofill integration
- Shared vault functionality
- Multi-vault support
- Hardware security key support (YubiKey)

---

## [1.4.0] - 2025-12-24

### Added
- **Theme Management**: Added "Appearance" settings with Light/Dark/System mode toggle
- **Profile Pictures**: Users can now upload and persist custom profile pictures
- **Reactive UI**: Entry detail screen and vault screen now update instantly without manual refresh

### Fixed
- **Critical Web Storage Bug**: Fixed data loss issue on web/Chrome where vault data was lost on page refresh
- **Persistence Layer**: Implemented fully async CRUD operations for robust data saving across all platforms

### Changed
- **Web Compatibility**: Refactored storage layer to remove web-incompatible dependencies (`dart:io`)
- **Cross-Platform**: Improved compatibility and stability across all supported platforms

### Status
- Stability: **Stable** - Final polish and advanced features implemented

---

## [1.3.0] - 2025-12-15

### Added
- **Vault Health Dashboard**: Professional security auditing for weak, reused, or leaked passwords
  - Integration with Have I Been Pwned (HIBP) API using k-Anonymity
  - Password strength analysis with entropy calculation
  - Duplicate password detection
  - Visual security score and recommendations
- **Advanced Password Generator**: Interactive dialog for generating complex passwords
- **Clipboard Auto-Clear**: Sensitive data automatically wiped from clipboard after timeout
- **Encrypted Import/Export**: Secure JSON backup functionality for data portability
- **Biometric Service**: Integrated biometric authentication service foundation (UI ready)
- **Smart Auto-Lock**: Timer now resets on user activity and gestures

### Changed
- **State Management**: Refactored core architecture from Provider to **Riverpod**
  - Improved reactivity and testability
  - Better dependency injection
  - Cleaner separation of concerns
- **Dark Mode Polish**: Comprehensive theme audit fixing all hardcoded colors
  - Seamless dark mode experience
  - Proper color palette throughout app
  - Improved contrast and readability

### Security
- **HIBP Integration**: Private password auditing using hash prefix (k-Anonymity model)
- **Enhanced Validation**: Improved password strength requirements
- **Activity-Based Auto-Lock**: Better session security

---

## [1.2.0] - 2025-11-28

### Added
- **TOTP 2FA Support**: Built-in Time-based One-Time Password generation
  - 6-digit codes with 30-second refresh
  - Copy to clipboard functionality
  - Visual countdown timer
- **Password Visibility Toggle**: Show/hide passwords in entry details
- **Archive Feature**: Move old entries to archive without deletion
- **Search Functionality**: Real-time filtering by service name or username
- **Entry Categories**: Personal vs Shared tabs (UI foundation)

### Changed
- **Vault Screen UI**: Improved layout with tab navigation
- **Entry Cards**: Enhanced visual design with better information hierarchy

---

## [1.1.0] - 2025-11-10

### Added
- **Auto-Lock Timer**: Configurable inactivity timeout (1, 5, 15, 30, 60 minutes)
- **Change Master Password**: Secure vault re-keying functionality
- **Profile Screen**: User profile with settings and customization
- **Lottie Animations**: Dynamic profile placeholder animation
- **Privacy Overlay**: Hides app content when in app switcher

### Security
- **PBKDF2 Iterations**: Increased to 600,000 iterations (OWASP compliant)
- **Memory Protection**: Master key cleared from memory on lock

---

## [1.0.0] - 2025-10-20

### Added
- **Initial Release**: First functional version of KeyNest
- **Core Features**:
  - Master password authentication
  - Zero-knowledge architecture
  - Client-side encryption (AES-256-GCM)
  - PBKDF2-HMAC-SHA256 key derivation
  - Vault entry CRUD operations (Create, Read, Update, Delete)
  - Secure local storage using `flutter_secure_storage`
- **Authentication**:
  - User registration with password strength validation
  - Login functionality
  - Session management
- **Vault Management**:
  - Add password entries
  - Edit password entries
  - Delete password entries
  - View entry details
  - Copy credentials to clipboard
- **UI/UX**:
  - Material Design implementation
  - Deep Purple theme
  - Responsive layouts
  - Cross-platform support (iOS, Android, Web, Windows, macOS)

### Security
- **Encryption**: AES-256-GCM with authenticated encryption
- **Key Derivation**: PBKDF2-HMAC-SHA256 with 100,000 iterations
- **Storage**: Platform-specific secure storage
  - iOS: Keychain
  - Android: EncryptedSharedPreferences
  - Windows: DPAPI
  - Web: IndexedDB with encryption

---

## Development Roadmap

### Phase 1: Core Security (Q1 2026)
- [ ] Professional third-party security audit
- [ ] Argon2id key derivation (replace PBKDF2)
- [ ] Enhanced memory protection
- [ ] Secure enclave integration

### Phase 2: Advanced Features (Q2 2026)
- [ ] Full biometric authentication
- [ ] Password generator
- [ ] Browser extension
- [ ] Autofill integration

### Phase 3: Collaboration (Q3 2026)
- [ ] End-to-end encrypted cloud sync
- [ ] Shared vaults with permissions
- [ ] Team management features

### Phase 4: Enterprise (Q4 2026)
- [ ] SSO integration
- [ ] Audit logging
- [ ] Admin console
- [ ] Compliance certifications

---

## Version History Summary

| Version | Release Date | Status | Key Features |
|---------|--------------|--------|--------------|
| 1.4.0 | 2025-12-24 | Stable | Theme management, Profile pictures, Web storage fix |
| 1.3.0 | 2025-12-15 | Stable | Vault health, Riverpod, HIBP integration |
| 1.2.0 | 2025-11-28 | Stable | TOTP 2FA, Archive, Search |
| 1.1.0 | 2025-11-10 | Beta | Auto-lock, Change password, Privacy overlay |
| 1.0.0 | 2025-10-20 | Beta | Initial release, Core functionality |

---

## Notes

### Versioning Strategy

- **Major version (X.0.0)**: Breaking changes, major architectural updates
- **Minor version (1.X.0)**: New features, non-breaking changes
- **Patch version (1.0.X)**: Bug fixes, security patches

### Security Updates

Security patches are released as soon as possible after a vulnerability is discovered and fixed. Security updates will be marked with `[SECURITY]` in the changelog.

### Breaking Changes

Breaking changes will be clearly marked with `[BREAKING]` and include migration instructions.

---

**Legend:**
- `Added` - New features
- `Changed` - Changes in existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Security improvements or fixes

---

*For detailed architecture and technical information, see [ARCHITECTURE.md](ARCHITECTURE.md)*

*For contribution guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md)*

*For security policy and vulnerability reporting, see [SECURITY.md](SECURITY.md)*
