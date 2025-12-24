# Contributing to PassM

First off, thank you for considering contributing to PassM! 🎉

PassM is a security-focused password manager, and we welcome contributions from the community. Whether it's bug reports, feature suggestions, documentation improvements, or code contributions, every bit helps make PassM better and more secure.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Guidelines](#coding-guidelines)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Security Considerations](#security-considerations)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code:

- **Be respectful**: Treat everyone with respect and professionalism
- **Be constructive**: Provide constructive feedback and suggestions
- **Be collaborative**: Work together to solve problems
- **Be patient**: Remember that this is an open-source project maintained by volunteers
- **Be mindful**: This is a security-sensitive project; always consider security implications

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [existing issues](../../issues) to avoid duplicates.

When creating a bug report, include as many details as possible:

- **Clear title**: Use a descriptive title
- **Steps to reproduce**: Detailed steps to reproduce the issue
- **Expected behavior**: What you expected to happen
- **Actual behavior**: What actually happened
- **Screenshots**: If applicable
- **Environment**:
  - OS (Windows, macOS, Linux, iOS, Android, Web)
  - Flutter version (`flutter --version`)
  - PassM version
  - Device details (if mobile)

**Template**:
```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment**
- OS: [e.g., Windows 11, macOS 14, Android 13]
- Flutter version: [e.g., 3.16.0]
- PassM version: [e.g., 1.4.0]
```

### Suggesting Features

Feature suggestions are welcome! Please provide:

- **Use case**: Why is this feature needed?
- **Proposed solution**: How should it work?
- **Alternatives**: Any alternative solutions you've considered
- **Security implications**: Any security considerations

### Reporting Security Vulnerabilities

**⚠️ DO NOT report security vulnerabilities through public issues!**

Please see [SECURITY.md](SECURITY.md) for instructions on how to responsibly disclose security issues.

## Development Setup

### Prerequisites

1. **Flutter SDK** (3.0.0 or higher)
   ```bash
   flutter doctor
   ```

2. **Dart SDK** (included with Flutter)

3. **IDE** (choose one):
   - Visual Studio Code with Flutter extension
   - Android Studio with Flutter plugin
   - IntelliJ IDEA with Flutter plugin

4. **Platform-specific requirements**:
   - **Android**: Android Studio, Android SDK
   - **iOS**: Xcode (macOS only)
   - **Windows**: Visual Studio 2022 with C++ desktop development
   - **Web**: Chrome browser

### Getting Started

1. **Fork the repository** on GitHub

2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/passm.git
   cd passm
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL-OWNER/passm.git
   ```

4. **Install dependencies**:
   ```bash
   flutter pub get
   ```

5. **Verify setup**:
   ```bash
   flutter doctor
   flutter analyze
   ```

6. **Run the app**:
   ```bash
   # For Windows
   flutter run -d windows
   
   # For Web
   flutter run -d chrome
   
   # For Android emulator
   flutter run
   ```

### Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**

3. **Run tests**:
   ```bash
   flutter test
   ```

4. **Check for lint errors**:
   ```bash
   flutter analyze
   ```

5. **Format code**:
   ```bash
   dart format .
   ```

6. **Commit your changes** (see [Commit Messages](#commit-messages))

7. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

8. **Create a Pull Request**

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/                        # Shared infrastructure
│   ├── crypto/                  # Cryptographic services
│   ├── services/                # Core services (storage, clipboard, etc.)
│   ├── providers/               # Riverpod providers
│   ├── theme/                   # App theming
│   ├── utils/                   # Utilities (validators, helpers)
│   └── widgets/                 # Shared widgets
└── features/                    # Feature modules
    ├── auth/                    # Authentication
    ├── vault/                   # Password vault
    ├── totp/                    # TOTP 2FA
    └── sync/                    # Cloud sync (future)

test/                            # Unit and widget tests
integration_test/                # Integration tests
```

For detailed architecture information, see [ARCHITECTURE.md](ARCHITECTURE.md).

### Feature Structure

Each feature follows Clean Architecture:

```
feature_name/
├── domain/                      # Business logic layer
│   ├── models/                  # Domain models
│   └── services/                # Business logic services
├── data/                        # Data layer
│   └── repositories/            # Data access
└── presentation/                # UI layer
    ├── screens/                 # Full-page screens
    └── widgets/                 # Reusable components
```

## Coding Guidelines

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide:

- Use `dart format` for automatic formatting
- Follow `flutter_lints` rules (configured in `analysis_options.yaml`)
- Use meaningful variable and function names
- Keep functions small and focused (single responsibility)

### Code Conventions

**1. Naming Conventions**
```dart
// Classes: PascalCase
class VaultManager {}

// Variables/functions: camelCase
String masterPassword;
void unlockVault() {}

// Constants: lowerCamelCase
const int defaultIterations = 600000;

// Private members: leading underscore
String _internalKey;
void _helperMethod() {}
```

**2. Documentation**
```dart
/// Service responsible for vault encryption and decryption.
///
/// Uses AES-256-GCM for encryption and PBKDF2 for key derivation.
/// All sensitive data is cleared from memory when the vault is locked.
class VaultManager {
  /// Unlocks the vault using the provided [masterPassword].
  ///
  /// Throws [Exception] if the password is incorrect or vault data is corrupted.
  Future<void> unlock(String masterPassword) async {
    // Implementation...
  }
}
```

**3. Error Handling**
```dart
// Use descriptive exceptions
if (password.isEmpty) {
  throw ArgumentError('Password cannot be empty');
}

// Handle async errors properly
try {
  await vaultManager.unlock(password);
} catch (e) {
  // Log and handle error
  debugPrint('Failed to unlock vault: $e');
  rethrow;
}
```

**4. Null Safety**
```dart
// Prefer non-nullable types
String serviceName;  // Good

// Use nullable only when necessary
String? optionalNote;  // OK when truly optional

// Use null-aware operators
final note = entry.note ?? 'No notes';
```

**5. Async/Await**
```dart
// Always use async/await (not .then())
Future<void> saveEntry(VaultEntry entry) async {
  await repository.save(entry);  // Good
}

// Not this:
Future<void> saveEntry(VaultEntry entry) {
  return repository.save(entry).then((_) => {});  // Avoid
}
```

### Security-Specific Guidelines

**1. Never Log Sensitive Data**
```dart
// ❌ NEVER do this
debugPrint('Password: $password');
debugPrint('Master key: ${_masterKey}');

// ✅ Do this instead
debugPrint('Unlock attempt for user');
debugPrint('Key derivation completed');
```

**2. Clear Sensitive Data**
```dart
// Clear sensitive data when no longer needed
void lock() {
  _masterKey = null;  // Clear from memory
  _entries = null;
  notifyListeners();
}
```

**3. Validate Input**
```dart
// Always validate user input
if (password.length < 8) {
  throw ArgumentError('Password must be at least 8 characters');
}
```

**4. Use Constant-Time Comparisons**
```dart
// For comparing MACs/hashes, use constant-time comparison
// to prevent timing attacks
bool verifyMac(List<int> expected, List<int> actual) {
  if (expected.length != actual.length) return false;
  
  int result = 0;
  for (int i = 0; i < expected.length; i++) {
    result |= expected[i] ^ actual[i];
  }
  return result == 0;
}
```

## Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring (no functional changes)
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, build, etc.)
- `security`: Security fixes or improvements

### Scopes
- `auth`: Authentication feature
- `vault`: Vault management
- `totp`: TOTP 2FA
- `crypto`: Cryptographic services
- `ui`: User interface
- `storage`: Data persistence
- `sync`: Cloud synchronization

### Examples
```bash
feat(vault): add password strength indicator

Implement real-time password strength calculation using entropy
and character class analysis. Displays visual indicator with
weak/medium/strong/excellent ratings.

Closes #123

---

fix(crypto): use constant-time MAC comparison

Prevent timing attacks in MAC verification by using constant-time
comparison instead of equality operator.

SECURITY: Addresses potential timing side-channel

---

docs(architecture): add security threat model section

Expand ARCHITECTURE.md with detailed threat model analysis and
mitigations for common attack vectors.

---

test(vault): add unit tests for entry CRUD operations

Achieve 85% code coverage for VaultManager service.
```

## Pull Request Process

### Before Submitting

1. **Update to latest upstream**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run all checks**:
   ```bash
   flutter analyze
   dart format --set-exit-if-changed .
   flutter test
   ```

3. **Ensure tests pass**:
   - All existing tests pass
   - New code has test coverage (aim for 80%+)
   - Security-sensitive code has comprehensive tests

4. **Update documentation**:
   - Update README.md if needed
   - Update ARCHITECTURE.md for architectural changes
   - Add inline code documentation

### PR Guidelines

**Title**: Use a descriptive title following commit message format
```
feat(vault): add bulk entry import feature
```

**Description Template**:
```markdown
## Description
Brief description of the changes.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Security fix

## Testing
Describe the tests you ran and how to reproduce them.

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally
- [ ] I have checked for security implications

## Screenshots (if applicable)
Add screenshots for UI changes.

## Related Issues
Closes #(issue number)
```

### Review Process

1. **Automated Checks**: CI will run tests and linting
2. **Code Review**: Maintainers will review your code
3. **Feedback**: Address any requested changes
4. **Approval**: Once approved, your PR will be merged
5. **Recognition**: You'll be credited in the changelog!

### What We Look For

- ✅ Code quality and readability
- ✅ Test coverage
- ✅ Documentation
- ✅ Security implications addressed
- ✅ Performance considerations
- ✅ Cross-platform compatibility
- ✅ Follows project conventions

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/crypto/crypto_service_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests

**Unit Tests** (test business logic):
```dart
group('VaultManager', () {
  late VaultManager vaultManager;
  
  setUp(() {
    vaultManager = VaultManager();
  });
  
  test('should lock vault when timeout expires', () async {
    await vaultManager.unlock('correct-password');
    expect(vaultManager.isLocked, false);
    
    // Simulate timeout
    await Future.delayed(Duration(seconds: 6));
    
    expect(vaultManager.isLocked, true);
  });
});
```

**Widget Tests** (test UI):
```dart
testWidgets('displays password strength indicator', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PasswordStrengthIndicator(password: 'weak'),
    ),
  );
  
  expect(find.text('Weak'), findsOneWidget);
  expect(find.byType(LinearProgressIndicator), findsOneWidget);
});
```

### Test Coverage Goals

- **Core services**: 90%+ coverage
- **Business logic**: 85%+ coverage
- **UI components**: 70%+ coverage
- **Overall**: 80%+ coverage

## Security Considerations

When contributing to PassM, always consider security implications:

### Cryptography
- **Never roll your own crypto**: Use established libraries
- **Use AEAD ciphers**: AES-GCM provides both encryption and authentication
- **Random nonces**: Always generate fresh random nonces for each encryption
- **Key derivation**: Use proper KDFs (PBKDF2, Argon2) with high iteration counts

### Data Handling
- **Never log sensitive data**: Passwords, keys, personal info
- **Clear memory**: Null out sensitive data when no longer needed
- **Validate input**: Always validate and sanitize user input
- **Prevent injection**: Use parameterized queries, escape special characters

### Authentication
- **Constant-time comparisons**: For MACs, hashes, passwords
- **Rate limiting**: Consider adding rate limits for authentication attempts
- **Secure defaults**: Default to the most secure option

### Dependencies
- **Keep updated**: Regularly update dependencies for security patches
- **Audit dependencies**: Be aware of what dependencies do
- **Minimize dependencies**: Fewer dependencies = smaller attack surface

### Code Review Checklist
Before submitting code, ask yourself:
- [ ] Could this leak sensitive data?
- [ ] Are all user inputs validated?
- [ ] Are cryptographic operations using secure libraries?
- [ ] Is error handling secure (no information leakage)?
- [ ] Are there any timing side-channels?
- [ ] Is this code testable for security properties?

## Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: Create an issue with the bug report template
- **Features**: Create an issue with the feature request template
- **Security**: See [SECURITY.md](SECURITY.md)

## Recognition

All contributors will be recognized in:
- GitHub contributors list
- CHANGELOG.md (for significant contributions)
- Special thanks section (for major features/fixes)

## License

By contributing to PassM, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to PassM! Your efforts help make password management more secure and accessible for everyone. 🚀🔐
