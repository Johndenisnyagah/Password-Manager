# Security Policy

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

The security of PassM is taken very seriously. If you discover a security vulnerability, we appreciate your help in disclosing it to us in a responsible manner.

### How to Report

To report a security vulnerability, please use one of the following methods:

1. **GitHub Security Advisories** (Recommended)
   - Go to the repository's Security tab
   - Click "Report a vulnerability"
   - Fill out the vulnerability report form

2. **Email** (Alternative)
   - Send details to: [Your security email - e.g., security@yourproject.com]
   - Use PGP encryption if possible (key: [link to PGP key if available])

### What to Include

Please include the following information in your report:

- **Type of vulnerability** (e.g., encryption weakness, authentication bypass, XSS, etc.)
- **Affected component** (e.g., crypto service, vault manager, specific screen)
- **Steps to reproduce** the vulnerability
- **Potential impact** of the vulnerability
- **Suggested fix** (if you have one)
- **Proof of concept** or exploit code (if applicable)
- **Your contact information** for follow-up questions

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your vulnerability report within **48 hours**.
- **Initial Assessment**: We will provide an initial assessment of the report within **7 days**.
- **Status Updates**: We will keep you informed of our progress toward a fix.
- **Disclosure Timeline**: We aim to release patches within **90 days** of initial report.
- **Credit**: We will publicly credit you for the discovery (unless you prefer to remain anonymous).

### Security Update Process

1. **Assessment**: We evaluate the severity and impact of the vulnerability.
2. **Fix Development**: We develop and test a patch in a private branch.
3. **Security Advisory**: We prepare a security advisory with details and mitigation steps.
4. **Release**: We release a patched version and publish the security advisory.
5. **User Notification**: We notify users through GitHub releases and README updates.

## Supported Versions

As PassM is currently in active development, security updates will be provided for:

| Version | Supported          |
| ------- | ------------------ |
| 1.4.x   | :white_check_mark: |
| < 1.4   | :x:                |

**Note**: Until PassM reaches v2.0.0 (stable production release), we recommend users stay on the latest version for the most up-to-date security fixes.

## Security Best Practices for Users

While using PassM, please follow these security best practices:

### Master Password
- **Use a strong, unique master password** (minimum 12 characters, mixed case, numbers, symbols)
- **Never reuse** your master password from other services
- **Do not share** your master password with anyone
- **Write it down** and store it in a physically secure location (safe, lockbox) as backup
- **Consider using a passphrase** (e.g., "Correct-Horse-Battery-Staple-2025!")

### Device Security
- **Keep your device locked** with a PIN/password/biometric when not in use
- **Enable device encryption** (FileVault on macOS, BitLocker on Windows, default on iOS/Android)
- **Keep your OS updated** with the latest security patches
- **Use antivirus software** on Windows/Android devices

### PassM Security
- **Enable auto-lock** with a short timeout (5-15 minutes recommended)
- **Enable biometric unlock** (when feature is fully released) for convenience with security
- **Regularly export encrypted backups** and store them securely offline
- **Review vault health** periodically and update weak/reused/pwned passwords
- **Verify app integrity** - Only download PassM from official sources

### What to Avoid
- ❌ **Never** enter your master password on phishing sites
- ❌ **Never** run PassM on a compromised/jailbroken device
- ❌ **Never** screenshot your vault entries
- ❌ **Never** share your encrypted vault file over insecure channels

## Known Security Limitations

PassM is currently in **active development** and has the following known limitations:

### Current Status (v1.4.0)
- ⚠️ **Not production-ready**: Do not use as your primary password manager yet
- ⚠️ **Limited security audit**: Code has not undergone professional third-party security audit
- ⚠️ **No cloud sync**: Data is stored locally only (reduces attack surface but increases data loss risk)
- ⚠️ **Biometric authentication**: UI present but full integration pending

### Cryptographic Implementation
- ✅ **AES-256-GCM**: Industry-standard AEAD cipher
- ✅ **PBKDF2-HMAC-SHA256**: 600,000 iterations (OWASP compliant)
- ⚠️ **Key Derivation**: Uses PBKDF2 instead of Argon2id (Flutter library limitations)
  - Note: README mentions Argon2id, but actual implementation uses PBKDF2 (will be updated)
- ⚠️ **Memory protection**: Limited protection against memory dumps on some platforms

### Platform-Specific Risks
- **Web**: Browser-based storage has inherent security limitations
  - Use desktop/mobile apps for sensitive data when possible
- **Windows**: Secure storage uses DPAPI (tied to Windows user account)
- **Android**: Relies on Android Keystore (vulnerable if device is rooted)

### Future Security Enhancements
- [ ] Professional third-party security audit
- [ ] Argon2id key derivation (replace PBKDF2)
- [ ] Memory protection improvements
- [ ] Secure enclave integration (iOS/Android)
- [ ] Hardware security key support (YubiKey, etc.)
- [ ] End-to-end encrypted cloud sync
- [ ] Tamper-evident signatures
- [ ] Canary tokens for breach detection

## Security Architecture

For detailed information about PassM's security architecture, cryptographic implementation, and threat model, please see:

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Complete technical documentation
  - Security Architecture section (encryption stack, threat model)
  - Cryptographic implementation details
  - Data flow diagrams

## Responsible Disclosure Examples

We appreciate security researchers who follow responsible disclosure practices. Examples of good vulnerability reports:

### ✅ Good Report Example
```
Subject: SQL Injection in Entry Search Function

**Vulnerability Type**: SQL Injection
**Affected Component**: lib/features/vault/presentation/screens/vault_screen.dart (line 245)
**Severity**: High

**Description**: 
The search functionality does not properly sanitize user input, allowing 
SQL injection through the search bar.

**Steps to Reproduce**:
1. Open vault screen
2. Enter: ' OR '1'='1 in search bar
3. All entries are exposed regardless of search term

**Impact**: 
Attacker could bypass search filters and access all vault entries.

**Suggested Fix**:
Use parameterized queries or sanitize input with RegExp.
```

### ❌ Poor Report Example
```
Subject: Security bug

There's a security issue in your app. Fix it ASAP.
```

## Security Hall of Fame

We recognize and thank the following security researchers for responsibly disclosing vulnerabilities:

- *Be the first to contribute!*

## Contact

For general security questions or concerns (non-vulnerability), you can:
- Open a public discussion in GitHub Discussions
- Tag issues with the `security` label

For private security matters, always use the vulnerability reporting process above.

---

**Last Updated**: December 24, 2025

Thank you for helping keep PassM and its users secure! 🔒
