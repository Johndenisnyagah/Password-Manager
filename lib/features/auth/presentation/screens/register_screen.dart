import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../vault/presentation/screens/vault_screen.dart';
import '../../../../core/utils/password_validator.dart';
import '../widgets/password_strength_indicator.dart';

/// A screen that allows new users to create an account and a secure vault.
///
/// Handles input validation, master password creation, and vault initialization.
class RegisterScreen extends ConsumerStatefulWidget {
  /// Creates a [RegisterScreen].
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  double _strength = 0.0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Updates the password strength indicator based on the current password input.
  void _updatePasswordStrength() {
    setState(() {
      _strength = PasswordValidator.calculateStrength(_passwordController.text);
    });
  }

  /// Handles the account registration process.
  ///
  /// Steps:
  /// 1. Validates all input fields.
  /// 2. Checks if passwords match.
  /// 3. Validates password complexity requirements.
  /// 4. Registers using [AuthService].
  /// 5. Creates and initializes the vault using [VaultManager].
  /// 6. Saves user profile info to secure storage.
  /// 7. Navigates to the [VaultScreen].
  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final vaultManager = ref.read(vaultManagerProvider);
      final storageService = ref.read(storageServiceProvider);

      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      // Reusable Validation
      PasswordValidator.validate(password);

      final hasStoredVault = await vaultManager.hasStoredVault();
      if (hasStoredVault && mounted) {
        // Confirmation could go here to warn about overwriting existing vault
      }

      await authService.register(email, password);
      await vaultManager.createVault(password);
      
      await storageService.saveUsername(username);
      await storageService.saveEmail(email);


      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VaultScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepPurple),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set up your secure vault',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),
                
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _usernameController,
                          enabled: !_isLoading,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.newUsername],
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailController,
                          enabled: !_isLoading,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          enabled: !_isLoading,
                          obscureText: _obscurePassword,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: 'Master Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: PasswordStrengthIndicator(strength: _strength),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.1 : 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password Requirements:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.blue.shade200 
                                    : Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildRequirementText('• At least 8 characters'),
                            _buildRequirementText('• One uppercase letter'),
                            _buildRequirementText('• One lowercase letter'),
                            _buildRequirementText('• One number'),
                            _buildRequirementText('• One special character'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _confirmPasswordController,
                        enabled: !_isLoading,
                        obscureText: _obscureConfirmPassword,
                        onSubmitted: (_) => _handleRegister(),
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_clock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.red.withValues(alpha: 0.1) 
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.deepPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
          height: 1.2,
        ),
      ),
    );
  }
}
