import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/service_providers.dart';
import '../widgets/vault_card.dart';
import '../../domain/models/vault_entry.dart';
import 'add_entry_screen.dart';
import 'entry_detail_screen.dart';
import 'vault_health_screen.dart';
import '../../../auth/presentation/screens/profile_screen.dart';

/// Enum representing the different filter tabs in the vault.
enum VaultTab { myVault, shared, archived }

/// The main dashboard screen displaying the user's vault entries.
///
/// Features:
/// - Tab navigation (My Vault, Shared, Archived).
/// - Search functionality.
/// - Filtering entries.
/// - Navigation to [ProfileScreen], [AddEntryScreen], [EntryDetailScreen].
class VaultScreen extends ConsumerStatefulWidget {
  /// Creates a [VaultScreen].
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  VaultTab _selectedTab = VaultTab.myVault;
  String _username = 'User';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Loads the username from secure storage to display in the header.
  Future<void> _loadUsername() async {
    final storageService = ref.read(storageServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final username = await storageService.loadUsername();
      if (mounted && username != null && username.isNotEmpty) {
        setState(() {
          _username = username;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vaultManager = ref.watch(vaultManagerProvider);
    final allEntries = vaultManager.isLocked ? <VaultEntry>[] : vaultManager.entries;
    
    // Filter entries based on selected tab and search query
    final List<VaultEntry> entries;
    var filtered = allEntries;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) => 
        e.serviceName.toLowerCase().contains(_searchQuery) ||
        e.username.toLowerCase().contains(_searchQuery)
      ).toList();
    }

    switch (_selectedTab) {
      case VaultTab.myVault:
        entries = filtered.where((e) => !e.isArchived && !e.isShared).toList();
        break;
      case VaultTab.shared:
        entries = filtered.where((e) => e.isShared && !e.isArchived).toList();
        break;
      case VaultTab.archived:
        entries = filtered.where((e) => e.isArchived).toList();
        break;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $_username!',
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Everything important — safely encrypted',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.palePurple,
                          backgroundImage: ref.watch(profilePhotoProvider) != null
                              ? MemoryImage(ref.watch(profilePhotoProvider)!)
                              : null,
                          child: ref.watch(profilePhotoProvider) == null
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.deepPurple,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Security Alert Banner
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const VaultHealthScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.deepPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.deepPurple.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.security_rounded, color: AppColors.deepPurple, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Run Security Audit',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepPurple,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: AppColors.deepPurple),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search vault...',
                      prefixIcon: Icon(Icons.search, color: AppColors.mediumText),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab Pills
                  Row(
                    children: [
                      _buildTabPill('My Vault', VaultTab.myVault),
                      const SizedBox(width: 12),
                      _buildTabPill('Shared', VaultTab.shared),
                      const SizedBox(width: 12),
                      _buildTabPill('Archived', VaultTab.archived),
                    ],
                  ),
                ],
              ),
            ),
            
            // Entries Section
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.palePurple,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getEmptyIcon(),
                              size: 40,
                              color: AppColors.deepPurple,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _getEmptyTitle(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getEmptySubtitle(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        // Section Header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _getSectionTitle(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.palePurple,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${entries.length}',
                                  style: const TextStyle(
                                    color: AppColors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Entry Cards
                        ...entries.map((entry) => VaultCard(
                          entry: entry,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EntryDetailScreen(entry: entry),
                              ),
                            );
                          },
                          onArchive: _selectedTab != VaultTab.archived
                              ? () => _archiveEntry(entry)
                              : null,
                          onDelete: () => _deleteEntry(entry),
                        )),
                        
                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTab != VaultTab.archived
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddEntryScreen()),
                );
                setState(() {});
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Entry'),
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildTabPill(String label, VaultTab tab) {
    final isActive = _selectedTab == tab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.deepPurple.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.mediumText,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (_selectedTab) {
      case VaultTab.myVault:
        return Icons.lock_open_outlined;
      case VaultTab.shared:
        return Icons.people_outline_rounded;
      case VaultTab.archived:
        return Icons.archive_outlined;
    }
  }

  String _getEmptyTitle() {
    switch (_selectedTab) {
      case VaultTab.myVault:
        return 'No entries yet';
      case VaultTab.shared:
        return 'No shared entries';
      case VaultTab.archived:
        return 'No archived entries';
    }
  }

  String _getEmptySubtitle() {
    switch (_selectedTab) {
      case VaultTab.myVault:
        return 'Tap + to add your first password';
      case VaultTab.shared:
        return 'Shared passwords will appear here';
      case VaultTab.archived:
        return 'Archived passwords will appear here';
    }
  }

  String _getSectionTitle() {
    switch (_selectedTab) {
      case VaultTab.myVault:
        return 'Passwords';
      case VaultTab.shared:
        return 'Shared Passwords';
      case VaultTab.archived:
        return 'Archived';
    }
  }

  /// Archives an entry, hiding it from the main list.
  Future<void> _archiveEntry(VaultEntry entry) async {
    final updatedEntry = entry.copyWith(isArchived: true);
    await ref.read(vaultManagerProvider).updateEntry(updatedEntry);
    if (mounted) setState(() {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${entry.serviceName} archived'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () async {
              final revertedEntry = updatedEntry.copyWith(isArchived: false);
              await ref.read(vaultManagerProvider).updateEntry(revertedEntry);
              if (mounted) setState(() {});
            },
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// Permanently deletes an entry from the vault.
  Future<void> _deleteEntry(VaultEntry entry) async {
    await ref.read(vaultManagerProvider).deleteEntry(entry.id);
    if (mounted) setState(() {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${entry.serviceName} deleted'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
