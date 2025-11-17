import 'package:hive/hive.dart';

part 'user_model.g.dart';

/// User Model
/// Represents a user in the system with authentication and gamification data
@HiveType(typeId: 10)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String displayName;

  @HiveField(4)
  final String? avatarUrl;

  @HiveField(5)
  final int level;

  @HiveField(6)
  final int xp;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? lastLoginAt;

  @HiveField(9)
  final bool isPremium;

  @HiveField(10)
  final int templatesCreated;

  @HiveField(11)
  final int templatesUsed;

  @HiveField(12)
  final List<String> badges;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    DateTime? createdAt,
    this.lastLoginAt,
    this.isPremium = false,
    this.templatesCreated = 0,
    this.templatesUsed = 0,
    List<String>? badges,
  })  : createdAt = createdAt ?? DateTime.now(),
        badges = badges ?? [];

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'level': level,
        'xp': xp,
        'created_at': createdAt.toIso8601String(),
        'last_login_at': lastLoginAt?.toIso8601String(),
        'is_premium': isPremium,
        'templates_created': templatesCreated,
        'templates_used': templatesUsed,
        'badges': badges,
      };

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        username: json['username'] as String,
        displayName: json['display_name'] as String,
        avatarUrl: json['avatar_url'] as String?,
        level: json['level'] as int? ?? 1,
        xp: json['xp'] as int? ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        lastLoginAt: json['last_login_at'] != null
            ? DateTime.parse(json['last_login_at'] as String)
            : null,
        isPremium: json['is_premium'] as bool? ?? false,
        templatesCreated: json['templates_created'] as int? ?? 0,
        templatesUsed: json['templates_used'] as int? ?? 0,
        badges: json['badges'] != null
            ? List<String>.from(json['badges'] as List)
            : [],
      );

  /// Copy with new values
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? avatarUrl,
    int? level,
    int? xp,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPremium,
    int? templatesCreated,
    int? templatesUsed,
    List<String>? badges,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      templatesCreated: templatesCreated ?? this.templatesCreated,
      templatesUsed: templatesUsed ?? this.templatesUsed,
      badges: badges ?? this.badges,
    );
  }

  /// Get XP progress to next level (0.0 to 1.0)
  double get xpProgress {
    final xpInCurrentLevel = xp % 100;
    return xpInCurrentLevel / 100.0;
  }

  /// Get XP needed for next level
  int get xpToNextLevel {
    final xpInCurrentLevel = xp % 100;
    return 100 - xpInCurrentLevel;
  }

  /// Get total achievements count
  int get achievementsCount => badges.length;

  /// Check if user has specific badge
  bool hasBadge(String badgeId) => badges.contains(badgeId);

  @override
  String toString() => 'UserModel(id: $id, username: $username, level: $level)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.username == username;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ username.hashCode;
}
