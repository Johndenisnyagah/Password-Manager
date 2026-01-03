# Test Coverage TODOs

> **Current Status**: ✅ 67 tests passing | All critical tests covered

## ✅ Already Covered

| Component | Tests |
|-----------|-------|
| `CryptoService` | Key derivation, encrypt/decrypt, wrong key rejection |
| `PasswordGeneratorService` | Length, character sets, entropy, error handling |
| `PasswordValidator` | Length, uppercase, lowercase, digits, special chars |
| `VaultManager` | CRUD, auto-lock, biometric unlock, lock states |
| `TotpService` | Code generation, URI parsing, secret normalization |
| `SecureStorageService` | Vault persistence, email, profile photo, biometrics |
| `PwnedService` | Breach count, k-anonymity, network error handling |
| `KeyNestApp` | Widget launch test |

---

## ✅ Widget Tests

### LoginScreen
- [x] Renders email and password fields
- [x] Shows validation errors for empty fields
- [x] Navigates to RegisterScreen on "Create Account"
- [x] Toggle password visibility

### RegisterScreen
- [x] Renders all registration fields
- [x] Password strength indicator updates

### ProfileScreen
- [x] Displays username and stats
- [x] Theme selection dialog
- [x] Auto-lock timer selection
- [x] Biometric switch appears when available

### GeneratorScreen
- [x] Displays generated password and entropy
- [x] Slider adjusts password length
- [x] Toggles change password output

### VaultScreen
- [x] Displays entries list
- [x] Search filters entries correctly
- [x] Tab switching

### VaultHealthScreen
- [x] Displays health score
- [x] Lists weak/reused passwords

### AddEntryScreen
- [x] All entry fields render
- [x] Category selector works
- [x] Password generator integration

### EntryDetailScreen
- [x] Entry details render
- [x] Copy buttons work
- [x] TOTP code displays

---

## ✅ Integration Tests

- [x] **Full Registration Flow**: Onboarding → Register → Create Vault → Vault Screen
- [x] **Full Login Flow**: Login → Unlock Vault → View Entries
- [x] **Entry Lifecycle**: Add → Edit → Archive → Delete
- [x] **Security Flow**: Lock → Unlock → Auto-lock

---

## 📝 Notes

- All 67 tests pass as of 2026-01-03
- Use `flutter test` to run all tests
- Widget tests use `ProviderScope` with mock overrides
