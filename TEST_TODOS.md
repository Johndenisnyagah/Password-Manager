# Test Coverage TODOs

> **Current Status**: 22 tests passing | **Target**: Comprehensive coverage

## ✅ Already Covered

| Component | Tests |
|-----------|-------|
| `CryptoService` | Key derivation, encrypt/decrypt, wrong key rejection |
| `PasswordGeneratorService` | Length, character sets, entropy, error handling |
| `VaultManager` | CRUD, auto-lock, biometric unlock, lock states |
| `TotpService` | Code generation, URI parsing, secret normalization |
| `PassMApp` | Widget launch test |

---

## 🔴 Critical - Missing Service Tests

### AuthService
- [ ] `login()` - successful authentication
- [ ] `login()` - invalid credentials rejection
- [ ] `register()` - new user creation
- [ ] `logout()` - session cleanup
- [ ] `isAuthenticated` - state management

### SecureStorageService
- [ ] `saveVault()` / `loadVault()` - persistence round-trip
- [ ] `saveEmail()` / `loadEmail()` - email persistence
- [ ] `saveProfilePhoto()` / `loadProfilePhoto()` - binary data handling
- [ ] Error handling for storage failures

### PwnedService
- [ ] `checkPassword()` - returns breach count
- [ ] `checkPassword()` - handles network errors gracefully
- [ ] K-anonymity prefix matching

---

## 🟠 Medium - Missing Widget Tests

### LoginScreen
- [ ] Renders email and password fields
- [ ] Shows validation errors for empty fields
- [ ] Navigates to RegisterScreen on "Create Account"
- [ ] Biometric button appears when enabled

### RegisterScreen
- [ ] Password strength indicator updates
- [ ] Validation rejects weak passwords
- [ ] Confirm password mismatch error
- [ ] Successful registration navigates to vault

### VaultScreen
- [ ] Displays entries list
- [ ] Search filters entries correctly
- [ ] Tab switching (Personal/Shared, Active/Archived)
- [ ] Add entry FAB navigates to AddEntryScreen

### ProfileScreen
- [ ] Theme selection dialog
- [ ] Auto-lock timer selection
- [ ] Export vault to clipboard
- [ ] Import vault from JSON
- [ ] Change password dialog

### GeneratorScreen
- [ ] Slider adjusts password length
- [ ] Toggles change character set
- [ ] Copy button copies to clipboard
- [ ] Use button returns generated password

### VaultHealthScreen
- [ ] Displays correct health score
- [ ] Lists weak passwords
- [ ] Lists reused passwords
- [ ] Breach check integration

---

## 🟡 Low - Integration Tests

- [ ] **Full Registration Flow**: Onboarding → Register → Create Vault → Vault Screen
- [ ] **Full Login Flow**: Login → Unlock Vault → View Entries
- [ ] **Entry Lifecycle**: Add → Edit → Archive → Delete
- [ ] **Security Flow**: Lock → Biometric Unlock → Auto-lock timeout

---

## 📝 Notes

- Use `MockSecureStorage` pattern from `vault_manager_test.dart`
- Use `ProviderScope` with overrides for widget tests
- Consider using `mocktail` or `mockito` for cleaner mocks
