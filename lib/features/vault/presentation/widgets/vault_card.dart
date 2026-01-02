import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/vault_entry.dart';

/// A list item widget representing a single vault entry.
///
/// Displays:
/// - Service icon (lock or QR code)
/// - Service name and username
/// - Live TOTP code (if enabled) with countdown
/// - Swipe actions for Archive and Delete
class VaultCard extends ConsumerStatefulWidget {
  /// The entry to display.
  final VaultEntry entry;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  /// Callback when the card is swiped right (Archive).
  final VoidCallback? onArchive;

  /// Callback when the card is swiped left (Delete).
  final VoidCallback? onDelete;

  /// Creates a [VaultCard].
  const VaultCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onArchive,
    this.onDelete,
  });

  @override
  ConsumerState<VaultCard> createState() => _VaultCardState();
}

class _VaultCardState extends ConsumerState<VaultCard> {
  String? _totpCode;
  int _remainingSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.entry.totpSecret != null) {
      _updateTotpCode();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Starts a timer to update the countdown and refresh the TOTP code every 30 seconds.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final totpService = ref.read(totpServiceProvider);
        final remaining = totpService.getRemainingSeconds();
        
        if (remaining != _remainingSeconds) {
          setState(() {
            _remainingSeconds = remaining;
          });
          
          if (_remainingSeconds == 30) {
            _updateTotpCode();
          }
        }
      }
    });
  }

  /// Generates the current TOTP code.
  Future<void> _updateTotpCode() async {
    if (widget.entry.totpSecret != null) {
      final totpService = ref.read(totpServiceProvider);
      final code = await totpService.generateCode(widget.entry.totpSecret!);
      if (mounted) {
        setState(() {
          _totpCode = code;
          _remainingSeconds = totpService.getRemainingSeconds();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(widget.entry.id),
        background: _buildSwipeBackground(
          color: Colors.green,
          icon: Icons.archive_rounded,
          label: 'Archive',
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: _buildSwipeBackground(
          color: Colors.red,
          icon: Icons.delete_rounded,
          label: 'Delete',
          alignment: Alignment.centerRight,
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Swipe right - Archive
            if (widget.onArchive != null) {
              widget.onArchive!();
              return true;
            }
          } else if (direction == DismissDirection.endToStart) {
            // Swipe left - Delete
            if (widget.onDelete != null) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Entry'),
                  content: Text('Are you sure you want to delete "${widget.entry.serviceName}"?'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                widget.onDelete!();
              }
              return confirm ?? false;
            }
          }
          return false;
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Icon Container
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.entry.totpSecret != null 
                            ? Icons.qr_code_2_rounded 
                            : Icons.lock_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.entry.serviceName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                              if (widget.entry.isShared)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.palePurple,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Shared',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.deepPurple,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.entry.username,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.lightText,
                            ),
                          ),
                          if (_totpCode != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  _totpCode!,
                                  style: const TextStyle(
                                    color: AppColors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: Stack(
                                    children: [
                                      CircularProgressIndicator(
                                        value: _remainingSeconds / 30,
                                        strokeWidth: 3,
                                        backgroundColor: AppColors.palePurple,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          _remainingSeconds < 10 
                                              ? Colors.red.shade400 
                                              : AppColors.deepPurple,
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          '$_remainingSeconds',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: _remainingSeconds < 10 
                                                ? Colors.red.shade400 
                                                : AppColors.deepPurple,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Arrow Icon
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.lightText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
