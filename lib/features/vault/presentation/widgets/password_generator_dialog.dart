import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/password_generator.dart';

/// A configuration dialog for generating a random secure password.
///
/// Users can customize:
/// - Length
/// - Character types (uppercase, numbers, symbols)
///
/// Returns the generated password string when confirmed.
class PasswordGeneratorDialog extends StatefulWidget {
  /// The initial password to display (optional).
  final String initialPassword;

  /// Creates a [PasswordGeneratorDialog].
  const PasswordGeneratorDialog({super.key, this.initialPassword = ''});

  @override
  State<PasswordGeneratorDialog> createState() => _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  int _length = 16;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  
  late String _generatedPassword;

  @override
  void initState() {
    super.initState();
    _generatedPassword = widget.initialPassword.isNotEmpty 
        ? widget.initialPassword 
        : _generate();
  }

  String _generate() {
    return PasswordGenerator.generate(
      length: _length,
      includeUppercase: _includeUppercase,
      includeNumbers: _includeNumbers,
      includeSymbols: _includeSymbols,
    );
  }

  void _refresh() {
    setState(() {
      _generatedPassword = _generate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Password Generator',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Password Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.palePurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.palePurple),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _generatedPassword,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.deepPurple),
                    tooltip: 'Regenerate',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Length Slider
            Text(
              'Length: $_length',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.mediumText),
            ),
            Slider(
              value: _length.toDouble(),
              min: 8,
              max: 64,
              divisions: 56,
              activeColor: AppColors.deepPurple,
              inactiveColor: AppColors.palePurple,
              onChanged: (value) {
                setState(() {
                  _length = value.toInt();
                });
                _refresh();
              },
            ),
            
            // Options
            _buildOptionTile('A-Z', 'Include Uppercase', _includeUppercase, (val) {
              setState(() => _includeUppercase = val);
              _refresh();
            }),
            _buildOptionTile('0-9', 'Include Numbers', _includeNumbers, (val) {
              setState(() => _includeNumbers = val);
              _refresh();
            }),
            _buildOptionTile('!@#', 'Include Symbols', _includeSymbols, (val) {
              setState(() => _includeSymbols = val);
              _refresh();
            }),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _generatedPassword),
              child: const Text('Use Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String leading, String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      secondary: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.palePurple.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          leading,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.deepPurple,
            fontSize: 12,
          ),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.deepPurple,
      contentPadding: EdgeInsets.zero,
    );
  }
}
