import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/generator_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/password_strength_indicator.dart';

class GeneratorScreen extends ConsumerWidget {
  const GeneratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatorData = ref.watch(generatorProvider);
    final notifier = ref.read(generatorProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepPurple.withValues(alpha: 0.9),
              AppColors.deepPurple.withAlpha(255),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _buildGlassCard(
                  context,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPasswordDisplay(context, generatorData.password, generatorData.entropy),
                        const SizedBox(height: 32),
                        _buildSettings(context, generatorData.config, notifier),
                        const SizedBox(height: 48),
                        _buildActionButtons(context, generatorData.password),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Password Generator',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Spacer for balance
        ],
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: child,
      ),
    );
  }

  Widget _buildPasswordDisplay(BuildContext context, String password, double entropy) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SelectableText(
            password,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Entropy: ${entropy.toStringAsFixed(1)} bits',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              _buildSecurityBadge(entropy),
            ],
          ),
          const SizedBox(height: 16),
          PasswordStrengthIndicator(
            strength: (entropy / 128).clamp(0.0, 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(double entropy) {
    String label;
    Color color;
    if (entropy < 40) {
      label = 'Weak';
      color = Colors.red;
    } else if (entropy < 80) {
      label = 'Medium';
      color = Colors.orange;
    } else if (entropy < 110) {
      label = 'Strong';
      color = Colors.green;
    } else {
      label = 'Unbreakable';
      color = Colors.cyanAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettings(BuildContext context, GeneratorConfig config, GeneratorNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Length: ${config.length}'),
        Slider(
          value: config.length.toDouble(),
          min: 8,
          max: 64,
          divisions: 56,
          activeColor: Colors.white,
          inactiveColor: Colors.white.withValues(alpha: 0.2),
          onChanged: (val) => notifier.updateConfig(config.copyWith(length: val.toInt())),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Options'),
        const SizedBox(height: 12),
        _buildToggle('Uppercase', config.useUppercase, (v) => notifier.updateConfig(config.copyWith(useUppercase: v))),
        _buildToggle('Lowercase', config.useLowercase, (v) => notifier.updateConfig(config.copyWith(useLowercase: v))),
        _buildToggle('Numbers', config.useNumbers, (v) => notifier.updateConfig(config.copyWith(useNumbers: v))),
        _buildToggle('Symbols', config.useSymbols, (v) => notifier.updateConfig(config.copyWith(useSymbols: v))),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(color: Colors.white)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String password) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, password),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Use this Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: password));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Copied to clipboard')),
            );
          },
          icon: const Icon(Icons.copy, color: Colors.white70),
          label: const Text('Copy to Clipboard', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
