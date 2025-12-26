import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/password_validator.dart';
import '../widgets/password_generator_dialog.dart';

import '../../domain/models/vault_entry.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  final VaultEntry? entry;
  const AddEntryScreen({super.key, this.entry});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serviceNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _totpSecretController = TextEditingController();
  final _notesController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedCategory = 'Work';
  bool _isShared = false;
  double _passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
    if (widget.entry != null) {
      final e = widget.entry!;
      _serviceNameController.text = e.serviceName;
      _usernameController.text = e.username;
      _passwordController.text = e.password ?? '';
      _totpSecretController.text = e.totpSecret ?? '';
      _notesController.text = e.notes ?? '';
      _selectedCategory = e.category; 
      _isShared = e.isShared;
    }
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _serviceNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _totpSecretController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = PasswordValidator.calculateStrength(_passwordController.text);
    });
  }

  Future<void> _generatePassword() async {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const PasswordGeneratorDialog(),
    );
    
    if (password != null) {
      _passwordController.text = password;
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final vaultManager = ref.read(vaultManagerProvider);
    
    if (widget.entry != null) {
      // Update existing entry
      final updatedEntry = widget.entry!.copyWith(
        serviceName: _serviceNameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        totpSecret: _totpSecretController.text.isNotEmpty ? _totpSecretController.text.trim() : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        isShared: _isShared,
        category: _selectedCategory,
      );
      
      await vaultManager.updateEntry(updatedEntry);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry updated successfully')),
        );
      }
    } else {
      // Create new entry
      var entry = vaultManager.generateNewEntry(
        serviceName: _serviceNameController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        totpSecret: _totpSecretController.text.isNotEmpty ? _totpSecretController.text.trim() : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        category: _selectedCategory,
      );
      entry = entry.copyWith(isShared: _isShared);
      await vaultManager.addEntry(entry);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepPurple,
      body: SafeArea(
        child: Column(
          children: [
            // Purple Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.entry != null ? 'Edit Entry' : 'Create New Entry',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            
            // White Form Area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Basic Info Section
                        _buildSectionCard(
                          title: 'BASIC INFO',
                          children: [
                            TextFormField(
                              controller: _serviceNameController,
                              decoration: const InputDecoration(
                                labelText: 'Service Name',
                                hintText: 'e.g., Google Account',
                                prefixIcon: Icon(Icons.business_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Service name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Username / Email',
                                hintText: 'user@example.com',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username is required';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Password Section
                        _buildSectionCard(
                          title: 'PASSWORD',
                          children: [
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password (optional)',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        _obscurePassword 
                                            ? Icons.visibility_outlined 
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.refresh_rounded),
                                      onPressed: _generatePassword,
                                      tooltip: 'Generate Password',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _passwordStrength,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    PasswordValidator.getStrengthColor(_passwordStrength),
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                PasswordValidator.getStrengthText(_passwordStrength),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: PasswordValidator.getStrengthColor(_passwordStrength),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // TOTP Section
                        _buildSectionCard(
                          title: 'TWO-FACTOR AUTH',
                          children: [
                            TextFormField(
                              controller: _totpSecretController,
                              decoration: const InputDecoration(
                                labelText: 'TOTP Secret (optional)',
                                hintText: 'JBSWY3DPEHPK3PXP',
                                prefixIcon: Icon(Icons.qr_code_scanner_rounded),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Category Section
                        _buildSectionCard(
                          title: 'CATEGORY',
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildCategoryChip('Work'),
                                _buildCategoryChip('Personal'),
                                _buildCategoryChip('Finance'),
                                _buildCategoryChip('Social'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Share Toggle Section
                        _buildSectionCard(
                          title: 'SHARING',
                          children: [
                            SwitchListTile(
                              value: _isShared,
                              onChanged: (value) {
                                setState(() {
                                  _isShared = value;
                                });
                              },
                                title: const Text(
                                  'Share this entry',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Allow others to access this password',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                activeColor: AppColors.deepPurple,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Notes Section
                          _buildSectionCard(
                            title: 'NOTES',
                            children: [
                              TextFormField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Notes (optional)',
                                  hintText: 'Add any additional information...',
                                  prefixIcon: Icon(Icons.note_outlined),
                                  alignLabelWithHint: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          // Create Button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _saveEntry,
                              child: Text(widget.entry != null ? 'Save Changes' : 'Create Entry'),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildSectionCard({required String title, required List<Widget> children}) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      );
    }

    Widget _buildCategoryChip(String label) {
      final isSelected = _selectedCategory == label;
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? AppColors.lightPurple : AppColors.deepPurple)
                : (isDark ? const Color(0xFF2C2C2C) : AppColors.palePurple),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.white70 : AppColors.deepPurple),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      );
    }
}
