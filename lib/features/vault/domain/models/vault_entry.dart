import 'package:meta/meta.dart';

/// Represents a single credential entry stored securely within the vault.
///
/// This class holds login details, TOTP secrets, and metadata for a specific service.
@immutable
class VaultEntry {
  /// The unique identifier for this entry (UUID).
  final String id;

  /// The name of the service or website (e.g., "Google", "Facebook").
  final String serviceName;

  /// The username or email associated with this account.
  final String username;

  /// The password for the account. Can be null if only TOTP is used.
  final String? password;

  /// The Base32 encoded secret key for generating Time-based One-Time Passwords (TOTP).
  final String? totpSecret;

  /// Optional notes or comments about this entry.
  final String? notes;

  /// The timestamp when this entry was created.
  final DateTime createdAt;

  /// The timestamp when this entry was last updated.
  final DateTime updatedAt;

  /// A list of tags for organizing entries.
  final List<String> tags;

  /// Whether this entry is archived (hidden from main list).
  final bool isArchived;

  /// Whether this entry is shared with others (future feature).
  final bool isShared;

  /// The category of the entry (e.g., "Personal", "Work", "Finance"). Defaults to "Personal".
  final String category;

  /// Creates a [VaultEntry].
  const VaultEntry({
    required this.id,
    required this.serviceName,
    required this.username,
    this.password,
    this.totpSecret,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isArchived = false,
    this.isShared = false,
    this.category = 'Personal',
  });

  /// Creates a copy of this entry with the given fields replaced.
  VaultEntry copyWith({
    String? serviceName,
    String? username,
    String? password,
    String? totpSecret,
    String? notes,
    List<String>? tags,
    bool? isArchived,
    bool? isShared,
    String? category,
  }) {
    return VaultEntry(
      id: id,
      serviceName: serviceName ?? this.serviceName,
      username: username ?? this.username,
      password: password ?? this.password,
      totpSecret: totpSecret ?? this.totpSecret,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      tags: tags ?? this.tags,
      isArchived: isArchived ?? this.isArchived,
      isShared: isShared ?? this.isShared,
      category: category ?? this.category,
    );
  }

  /// Converts the entry to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceName': serviceName,
      'username': username,
      'password': password,
      'totpSecret': totpSecret,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'isArchived': isArchived,
      'isShared': isShared,
      'category': category,
    };
  }

  /// Creates a [VaultEntry] from a JSON map.
  factory VaultEntry.fromJson(Map<String, dynamic> json) {
    return VaultEntry(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      username: json['username'] as String,
      password: json['password'] as String?,
      totpSecret: json['totpSecret'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      isArchived: json['isArchived'] as bool? ?? false,
      isShared: json['isShared'] as bool? ?? false,
      category: json['category'] as String? ?? 'Personal',
    );
  }
}
