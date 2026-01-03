import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/utils/password_validator.dart';
import '../../domain/models/vault_entry.dart';

/// A screen that performs a security audit on the user's vault.
///
/// Checks for:
/// - Weak passwords (entropy / length)
/// - Reused passwords
/// - Leaked passwords (via Pwned Passwords API)
class VaultHealthScreen extends ConsumerStatefulWidget {
  /// Creates a [VaultHealthScreen].
  const VaultHealthScreen({super.key});

  @override
  ConsumerState<VaultHealthScreen> createState() => _VaultHealthScreenState();
}

class _VaultHealthScreenState extends ConsumerState<VaultHealthScreen> {
  bool _isAuditing = false;
  List<AuditIssue> _issues = [];
  double _healthScore = 100.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _performAudit());
  }

  /// Runs the audit process on all vault entries.
  ///
  /// 1. Iterates through all entries.
  /// 2. Checks password strength using [PasswordValidator].
  /// 3. Detects reused passwords locally.
  /// 4. Checks against the HIBP database using [PwnedService].
  /// 5. Calculates a health score based on weighted issue severity.
  Future<void> _performAudit() async {
    setState(() {
      _isAuditing = true;
      _issues = [];
    });

    final vaultManager = ref.read(vaultManagerProvider);
    if (vaultManager.isLocked) {
      if (mounted) setState(() => _isAuditing = false);
      return;
    }
    final pwnedService = ref.read(pwnedServiceProvider);
    final entries = vaultManager.entries;

    final List<AuditIssue> foundIssues = [];
    int totalChecks = entries.length;
    int issuesWeight = 0;

    // Password counts for re-use detection
    final Map<String, List<VaultEntry>> passwordMap = {};

    for (var entry in entries) {
      if (entry.password == null || entry.password!.isEmpty) continue;

      // 1. Weak Password Check
      final strength = PasswordValidator.calculateStrength(entry.password!);
      if (strength < 0.6) {
        foundIssues.add(AuditIssue(
          entry: entry,
          type: AuditIssueType.weak,
          message: 'Weak password detected',
          severity: AuditSeverity.medium,
        ));
        issuesWeight += 20;
      }

      // 2. Reuse Mapping
      passwordMap.putIfAbsent(entry.password!, () => []).add(entry);

      // 3. Pwned check (Background)
      try {
        final count = await pwnedService.checkPassword(entry.password!);
        if (count > 0) {
          foundIssues.add(AuditIssue(
            entry: entry,
            type: AuditIssueType.leaked,
            message: 'Password found in $count data breaches!',
            severity: AuditSeverity.critical,
          ));
          issuesWeight += 50;
        }
      } catch (e) {
        debugPrint('HIBP Audit Error: $e');
      }
    }

    // 4. Reuse detection
    passwordMap.forEach((password, reusedEntries) {
      if (reusedEntries.length > 1) {
        for (var entry in reusedEntries) {
          foundIssues.add(AuditIssue(
            entry: entry,
            type: AuditIssueType.reused,
            message: 'Password reused in ${reusedEntries.length} entries',
            severity: AuditSeverity.high,
          ));
          issuesWeight += 30;
        }
      }
    });

    // Calculate score
    double score = 100 - (issuesWeight / (totalChecks > 0 ? totalChecks : 1) * 2);
    score = score.clamp(0, 100);

    if (mounted) {
      setState(() {
        _issues = foundIssues;
        _healthScore = score;
        _isAuditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault Security Audit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isAuditing ? null : _performAudit,
          ),
        ],
      ),
      body: _isAuditing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'Auditing your vault...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Checking for leaks and re-use'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoreHeader(),
                  const SizedBox(height: 32),
                  const Text(
                    'Security Recommendations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_issues.isEmpty)
                    _buildEmptyState()
                  else
                    ..._issues.map((issue) => _buildIssueTile(issue)),
                ],
              ),
            ),
    );
  }

  Widget _buildScoreHeader() {
    Color scoreColor = Colors.green;
    if (_healthScore < 40) {
      scoreColor = Colors.red;
    } else if (_healthScore < 75) {
      scoreColor = Colors.orange;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: scoreColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _healthScore / 100,
                  strokeWidth: 12,
                  backgroundColor: scoreColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Text(
                '${_healthScore.toInt()}%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _getHealthMessage(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _getHealthMessage() {
    if (_healthScore >= 90) return 'Your vault is in excellent shape! Your secrets are well protected.';
    if (_healthScore >= 75) return 'Good overall security, but there is room for improvement.';
    if (_healthScore >= 40) return 'Moderate security risks found. Consider updating weak or reused passwords.';
    return 'Critical security issues detected. Please review the recommendations below immediately.';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.check_circle_outline_rounded, size: 64, color: Colors.green.shade300),
          const SizedBox(height: 16),
          const Text(
            'No security issues found!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text('Your vault follows all security best practices.'),
        ],
      ),
    );
  }

  Widget _buildIssueTile(AuditIssue issue) {
    IconData icon;
    Color color;
    switch (issue.type) {
      case AuditIssueType.weak:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case AuditIssueType.reused:
        icon = Icons.copy_all_rounded;
        color = Colors.blue;
        break;
      case AuditIssueType.leaked:
        icon = Icons.gpp_bad_rounded;
        color = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(issue.entry.serviceName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(issue.message),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          // Navigate to entry detail
        },
      ),
    );
  }
}

/// The type of security issue detected.
enum AuditIssueType { 
  /// Password is too short or predictable (low entropy).
  weak, 
  /// Password is used in multiple entries.
  reused, 
  /// Password has been exposed in a data breach.
  leaked 
}

/// The severity level of a security issue.
enum AuditSeverity { medium, high, critical }

/// Represents a single security issue found during an audit.
class AuditIssue {
  /// The entry associated with the issue.
  final VaultEntry entry;

  /// The category of the issue.
  final AuditIssueType type;

  /// A descriptive message for the user.
  final String message;

  /// The severity of the issue, affecting the health score calculation.
  final AuditSeverity severity;

  /// Creates an [AuditIssue].
  AuditIssue({
    required this.entry,
    required this.type,
    required this.message,
    required this.severity,
  });
}
