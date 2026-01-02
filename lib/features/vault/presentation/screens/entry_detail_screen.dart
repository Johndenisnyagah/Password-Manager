import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/vault_entry.dart';
import 'add_entry_screen.dart';

/// A screen that displays the details of a specific vault entry.
///
/// Shows password (masked by default), username, TOTP code (live updating), and notes.
/// Allows copying values to clipboard and deleting the entry.
class EntryDetailScreen extends ConsumerStatefulWidget {
  /// The vault entry to display.
  final VaultEntry entry;

  /// Creates an [EntryDetailScreen].
  const EntryDetailScreen({super.key, required this.entry});

  @override
  ConsumerState<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends ConsumerState<EntryDetailScreen> {
  bool _isPasswordVisible = false;
  Timer? _totpTimer;
  String _totpCode = '000 000';
  double _totpProgress = 0.0;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    if (widget.entry.totpSecret != null) {
      _startTotpTimer();
    }
  }

  @override
  void dispose() {
    _totpTimer?.cancel();
    super.dispose();
  }

  /// Starts the timer to update the TOTP code every second.
  void _startTotpTimer() {
    _updateTotp();
    _totpTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTotp());
  }

  /// Calculates the current TOTP code and progress.
  Future<void> _updateTotp() async {
    if (!mounted || widget.entry.totpSecret == null) return;
    
    final totpService = ref.read(totpServiceProvider);
    final secret = widget.entry.totpSecret!;
    
    try {
      final code = await totpService.generateCode(secret);
      final remaining = totpService.getRemainingSeconds();
      
      if (mounted) {
        setState(() {
          _totpCode = '${code.substring(0, 3)} ${code.substring(3)}';
          _secondsRemaining = remaining;
          _totpProgress = remaining / 30.0;
        });
      }
    } catch (e) {
      debugPrint('TOTP Error: $e');
    }
  }

  /// Copies the given [text] to the system clipboard and shows a confirmation snackbar.
  ///
  /// If [isSensitive] is true, the snackbar message indicates that the clipboard will be cleared (functionality implied by service).
  void _copyToClipboard(String text, String label, {bool isSensitive = false}) {
    final clipboardService = ref.read(clipboardServiceProvider);
    clipboardService.copy(text, isSensitive: isSensitive);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard${isSensitive ? ' (will clear in 30s)' : ''}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vaultManager = ref.watch(vaultManagerProvider);
    final entry = vaultManager.entries.firstWhere(
      (e) => e.id == widget.entry.id,
      orElse: () => widget.entry,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepPurple),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.deepPurple),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEntryScreen(entry: entry),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.deepPurple,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      entry.totpSecret != null ? Icons.qr_code_2_rounded : Icons.lock_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    entry.serviceName,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.category.toUpperCase(),
                    style: const TextStyle(color: AppColors.deepPurple, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildDetailItem(
                    label: 'Username',
                    value: entry.username,
                    icon: Icons.person_outline_rounded,
                    onCopy: () => _copyToClipboard(entry.username, 'Username'),
                  ),
                  if (entry.password != null) ...[
                    const Divider(height: 40),
                    _buildDetailItem(
                      label: 'Password',
                      value: entry.password!,
                      icon: Icons.lock_outline_rounded,
                      isSensitive: true,
                      onCopy: () => _copyToClipboard(entry.password!, 'Password', isSensitive: true),
                    ),
                  ],
                  if (entry.totpSecret != null) ...[
                    const Divider(height: 40),
                    _buildTotpRow(),
                  ],
                ],
              ),
            ),
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(entry.notes!, style: const TextStyle(fontSize: 16, height: 1.5)),
              ),
            ],
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _confirmDelete(entry),
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Delete Entry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onCopy,
    bool isSensitive = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepPurple, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightText)),
              const SizedBox(height: 4),
              Text(
                isSensitive && !_isPasswordVisible ? '••••••••••••' : value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (isSensitive)
          IconButton(
            icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.lightText),
          onPressed: onCopy,
        ),
      ],
    );
  }

  Widget _buildTotpRow() {
    return Row(
      children: [
        const Icon(Icons.qr_code_2_rounded, color: AppColors.deepPurple, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('One-Time Password', style: TextStyle(fontSize: 12, color: AppColors.lightText)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _totpCode,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepPurple, letterSpacing: 2),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: _totpProgress,
                      strokeWidth: 3,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(_secondsRemaining < 5 ? Colors.red : AppColors.deepPurple),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.lightText),
          onPressed: () => _copyToClipboard(_totpCode.replaceAll(' ', ''), 'TOTP Code', isSensitive: true),
        ),
      ],
    );
  }

  /// Displays a confirmation dialog before deleting the entry.
  Future<void> _confirmDelete(VaultEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "${entry.serviceName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(vaultManagerProvider).deleteEntry(entry.id);
      if (mounted) Navigator.pop(context);
    }
  }
}
