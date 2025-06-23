// lib/models/api_models.dart

// ====================
// AUTHENTICATION MODELS
// ====================

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserProfile? user;
  final String tokenType;
  final int expiresIn;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.user,
    this.tokenType = 'Bearer',
    this.expiresIn = 3600,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] ?? json['access'] ?? '',
      refreshToken: json['refresh_token'] ?? json['refresh'] ?? '',
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user?.toJson(),
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}

class TokenRefreshRequest {
  final String refresh;

  TokenRefreshRequest({required this.refresh});

  Map<String, dynamic> toJson() {
    return {'refresh': refresh};
  }
}

class TokenRefreshResponse {
  final String access;

  TokenRefreshResponse({required this.access});

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(access: json['access']);
  }
}

class UserRegistrationRequest {
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;
  final String? firstName;
  final String? lastName;

  UserRegistrationRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirm,
    this.firstName,
    this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'password_confirm': passwordConfirm,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
    };
  }
}

class LoginRequest {
  final String username; // Can be email or username
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

// ====================
// USER MODELS
// ====================

enum ThemePreference { light, dark, system }

class UserProfile {
  final String id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  final bool isActive;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final int experiencePoints;
  final int level;
  final int nextLevelXp;
  final int credits;
  final int dailyStreak;
  final int templatesCreated;
  final int templatesCompleted;
  final int totalPromptsGenerated;
  final double completionRate;
  final String userRank;
  final Map<String, dynamic>? rankInfo;
  final String avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ThemePreference? themePreference;

  UserProfile({
    required this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.dateJoined,
    this.lastLogin,
    this.isActive = true,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.experiencePoints = 0,
    this.level = 1,
    this.nextLevelXp = 100,
    this.credits = 0,
    this.dailyStreak = 0,
    this.templatesCreated = 0,
    this.templatesCompleted = 0,
    this.totalPromptsGenerated = 0,
    this.completionRate = 0.0,
    this.userRank = 'Beginner',
    this.rankInfo,
    required this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.themePreference,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profileImage: json['profile_image'],
      dateJoined: json['date_joined'] != null
          ? DateTime.tryParse(json['date_joined'])
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'])
          : null,
      isActive: json['is_active'] ?? true,
      isPremium: json['is_premium'] ?? false,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.tryParse(json['premium_expires_at'])
          : null,
      experiencePoints: json['experience_points'] ?? 0,
      level: json['level'] ?? 1,
      nextLevelXp: json['next_level_xp'] ?? 100,
      credits: json['credits'] ?? 0,
      dailyStreak: json['daily_streak'] ?? 0,
      templatesCreated: json['templates_created'] ?? 0,
      templatesCompleted: json['templates_completed'] ?? 0,
      totalPromptsGenerated: json['total_prompts_generated'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0.0).toDouble(),
      userRank: json['user_rank'] ?? 'Beginner',
      rankInfo: json['rank_info'],
      avatarUrl: json['avatar_url'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      themePreference: json['theme_preference'] != null
          ? ThemePreference.values.firstWhere(
              (e) => e.name == json['theme_preference'],
              orElse: () => ThemePreference.system,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
      'date_joined': dateJoined?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'is_active': isActive,
      'is_premium': isPremium,
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
      'experience_points': experiencePoints,
      'level': level,
      'next_level_xp': nextLevelXp,
      'credits': credits,
      'daily_streak': dailyStreak,
      'templates_created': templatesCreated,
      'templates_completed': templatesCompleted,
      'total_prompts_generated': totalPromptsGenerated,
      'completion_rate': completionRate,
      'user_rank': userRank,
      'rank_info': rankInfo,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'theme_preference': themePreference?.name,
    };
  }

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    return username;
  }
}

class UserMinimal {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final int level;
  final String userRank;

  UserMinimal({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.level,
    required this.userRank,
  });

  factory UserMinimal.fromJson(Map<String, dynamic> json) {
    return UserMinimal(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      level: json['level'] ?? 1,
      userRank: json['user_rank'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'level': level,
      'user_rank': userRank,
    };
  }
}

class UserUpdateRequest {
  final String? firstName;
  final String? lastName;
  final String? email;
  final ThemePreference? themePreference;

  UserUpdateRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.themePreference,
  });

  Map<String, dynamic> toJson() {
    return {
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (themePreference != null) 'theme_preference': themePreference!.name,
    };
  }
}

// ====================
// TEMPLATE MODELS
// ====================

enum FieldType { text, textarea, dropdown, checkbox, radio, number }

class TemplateField {
  final String id;
  final String label;
  final FieldType type;
  final String? placeholder;
  final bool required;
  final List<String>? options;
  final String? defaultValue;
  final String? helpText;
  final Map<String, dynamic>? validation;

  TemplateField({
    required this.id,
    required this.label,
    required this.type,
    this.placeholder,
    this.required = false,
    this.options,
    this.defaultValue,
    this.helpText,
    this.validation,
  });

  factory TemplateField.fromJson(Map<String, dynamic> json) {
    return TemplateField(
      id: json['id']?.toString() ?? '',
      label: json['label'] ?? '',
      type: FieldType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FieldType.text,
      ),
      placeholder: json['placeholder'],
      required: json['required'] ?? false,
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      defaultValue: json['default_value'],
      helpText: json['help_text'],
      validation: json['validation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type.name,
      'placeholder': placeholder,
      'required': required,
      'options': options,
      'default_value': defaultValue,
      'help_text': helpText,
      'validation': validation,
    };
  }
}

class TemplateCategory {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final int templateCount;

  TemplateCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    required this.templateCount,
  });

  factory TemplateCategory.fromJson(Map<String, dynamic> json) {
    return TemplateCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      icon: json['icon'],
      templateCount: json['template_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'template_count': templateCount,
    };
  }
}

class TemplateModel {
  final String id;
  final String title;
  final String description;
  final String templateContent;
  final TemplateCategory category;
  final String? version;
  final List<String> tags;
  final bool isPublic;
  final bool isFeatured;
  final UserMinimal author;
  final List<TemplateField> fields;
  final int fieldCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rating;
  final int? usageCount;

  TemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.templateContent,
    required this.category,
    this.version,
    this.tags = const [],
    this.isPublic = true,
    this.isFeatured = false,
    required this.author,
    this.fields = const [],
    required this.fieldCount,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.usageCount,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      templateContent: json['template_content'] ?? '',
      category: TemplateCategory.fromJson(json['category'] ?? {}),
      version: json['version'],
      tags: List<String>.from(json['tags'] ?? []),
      isPublic: json['is_public'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      author: UserMinimal.fromJson(json['author'] ?? {}),
      fields: (json['fields'] as List?)
              ?.map((field) => TemplateField.fromJson(field))
              .toList() ??
          [],
      fieldCount: json['field_count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      rating: json['rating']?.toDouble(),
      usageCount: json['usage_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'template_content': templateContent,
      'category': category.toJson(),
      'version': version,
      'tags': tags,
      'is_public': isPublic,
      'is_featured': isFeatured,
      'author': author.toJson(),
      'fields': fields.map((field) => field.toJson()).toList(),
      'field_count': fieldCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'rating': rating,
      'usage_count': usageCount,
    };
  }
}

class TemplateCreateRequest {
  final String title;
  final String description;
  final String templateContent;
  final int category;
  final String? version;
  final List<String>? tags;
  final bool? isPublic;
  final List<Map<String, dynamic>>? fieldsData;

  TemplateCreateRequest({
    required this.title,
    required this.description,
    required this.templateContent,
    required this.category,
    this.version,
    this.tags,
    this.isPublic,
    this.fieldsData,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'template_content': templateContent,
      'category': category,
      if (version != null) 'version': version,
      if (tags != null) 'tags': tags,
      if (isPublic != null) 'is_public': isPublic,
      if (fieldsData != null) 'fields_data': fieldsData,
    };
  }
}

// ====================
// GAMIFICATION MODELS
// ====================

class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredCount;
  final String category;
  final int rewardCredits;
  final int rewardXp;
  final bool isUnlocked;
  final int currentProgress;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.category,
    required this.rewardCredits,
    required this.rewardXp,
    this.isUnlocked = false,
    this.currentProgress = 0,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      requiredCount: json['required_count'] ?? 0,
      category: json['category'] ?? '',
      rewardCredits: json['reward_credits'] ?? 0,
      rewardXp: json['reward_xp'] ?? 0,
      isUnlocked: json['is_unlocked'] ?? false,
      currentProgress: json['current_progress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'required_count': requiredCount,
      'category': category,
      'reward_credits': rewardCredits,
      'reward_xp': rewardXp,
      'is_unlocked': isUnlocked,
      'current_progress': currentProgress,
    };
  }

  double get progressPercentage => 
      requiredCount > 0 ? (currentProgress / requiredCount).clamp(0.0, 1.0) : 0.0;
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final int targetCount;
  final int currentProgress;
  final int rewardCredits;
  final int rewardXp;
  final DateTime expiresAt;
  final bool isCompleted;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetCount,
    this.currentProgress = 0,
    required this.rewardCredits,
    required this.rewardXp,
    required this.expiresAt,
    this.isCompleted = false,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      targetCount: json['target_count'] ?? 0,
      currentProgress: json['current_progress'] ?? 0,
      rewardCredits: json['reward_credits'] ?? 0,
      rewardXp: json['reward_xp'] ?? 0,
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now(),
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'target_count': targetCount,
      'current_progress': currentProgress,
      'reward_credits': rewardCredits,
      'reward_xp': rewardXp,
      'expires_at': expiresAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  double get progressPercentage => 
      targetCount > 0 ? (currentProgress / targetCount).clamp(0.0, 1.0) : 0.0;
}

// ====================
// AI MODELS
// ====================

class AIAnalysisResponse {
  final String templateId;
  final Map<String, dynamic> analysis;
  final List<String> suggestions;
  final double optimizationScore;
  final Map<String, dynamic> metadata;

  AIAnalysisResponse({
    required this.templateId,
    required this.analysis,
    required this.suggestions,
    required this.optimizationScore,
    required this.metadata,
  });

  factory AIAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResponse(
      templateId: json['template_id'] ?? '',
      analysis: json['analysis'] ?? {},
      suggestions: List<String>.from(json['suggestions'] ?? []),
      optimizationScore: (json['optimization_score'] ?? 0.0).toDouble(),
      metadata: json['metadata'] ?? {},
    );
  }
}

// ====================
// UTILITY MODELS
// ====================

class PaginatedResponse<T> {
  final List<T> results;
  final int count;
  final String? next;
  final String? previous;

  PaginatedResponse({
    required this.results,
    required this.count,
    this.next,
    this.previous,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      results: (json['results'] as List?)
              ?.map((item) => fromJsonT(item))
              .toList() ??
          [],
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
    );
  }

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}

class APIException implements Exception {
  final String message;
  final int? statusCode;
  final String? type;

  APIException({
    required this.message,
    this.statusCode,
    this.type,
  });

  factory APIException.fromDioError(dynamic error) {
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      
      String message = 'An error occurred';
      
      if (data is Map<String, dynamic>) {
        message = data['detail'] ?? 
                 data['message'] ?? 
                 data['error'] ?? 
                 'Server error occurred';
      } else if (data is String) {
        message = data;
      }
      
      return APIException(
        message: message,
        statusCode: statusCode,
        type: 'response_error',
      );
    } else if (error.type.toString().contains('connectTimeout')) {
      return APIException(
        message: 'Connection timeout. Please check your internet connection.',
        type: 'timeout',
      );
    } else if (error.type.toString().contains('receiveTimeout')) {
      return APIException(
        message: 'Server response timeout. Please try again.',
        type: 'timeout',
      );
    } else {
      return APIException(
        message: error.message ?? 'Network error occurred',
        type: 'network_error',
      );
    }
  }

  @override
  String toString() {
    return 'APIException: $message (Status: $statusCode, Type: $type)';
  }
}

// Template Usage Models
class TemplateUsageResponse {
  final String usageId;
  final String templateId;
  final DateTime startedAt;
  final Map<String, dynamic>? metadata;

  TemplateUsageResponse({
    required this.usageId,
    required this.templateId,
    required this.startedAt,
    this.metadata,
  });

  factory TemplateUsageResponse.fromJson(Map<String, dynamic> json) {
    return TemplateUsageResponse(
      usageId: json['usage_id'] ?? '',
      templateId: json['template_id'] ?? '',
      startedAt: DateTime.tryParse(json['started_at'] ?? '') ?? DateTime.now(),
      metadata: json['metadata'],
    );
  }
}

// Credit Transaction Model
class CreditTransaction {
  final String id;
  final int amount;
  final String type;
  final String description;
  final DateTime createdAt;

  CreditTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id']?.toString() ?? '',
      amount: json['amount'] ?? 0,
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

// User Achievement Model
class UserAchievement {
  final String id;
  final Achievement achievement;
  final DateTime unlockedAt;
  final bool claimed;

  UserAchievement({
    required this.id,
    required this.achievement,
    required this.unlockedAt,
    this.claimed = false,
  });

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id']?.toString() ?? '',
      achievement: Achievement.fromJson(json['achievement'] ?? {}),
      unlockedAt: DateTime.tryParse(json['unlocked_at'] ?? '') ?? DateTime.now(),
      claimed: json['claimed'] ?? false,
    );
  }
}

// Claim Reward Response
class ClaimRewardResponse {
  final bool success;
  final int creditsAwarded;
  final int xpAwarded;
  final String message;

  ClaimRewardResponse({
    required this.success,
    required this.creditsAwarded,
    required this.xpAwarded,
    required this.message,
  });

  factory ClaimRewardResponse.fromJson(Map<String, dynamic> json) {
    return ClaimRewardResponse(
      success: json['success'] ?? false,
      creditsAwarded: json['credits_awarded'] ?? 0,
      xpAwarded: json['xp_awarded'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

// AI Recommendation Model
class AIRecommendation {
  final String id;
  final String title;
  final String description;
  final String type;
  final double confidence;
  final Map<String, dynamic> metadata;

  AIRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.confidence,
    required this.metadata,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      metadata: json['metadata'] ?? {},
    );
  }
}

// Content Enhancement Response
class ContentEnhancementResponse {
  final String originalContent;
  final String enhancedContent;
  final List<String> improvements;
  final double confidenceScore;

  ContentEnhancementResponse({
    required this.originalContent,
    required this.enhancedContent,
    required this.improvements,
    required this.confidenceScore,
  });

  factory ContentEnhancementResponse.fromJson(Map<String, dynamic> json) {
    return ContentEnhancementResponse(
      originalContent: json['original_content'] ?? '',
      enhancedContent: json['enhanced_content'] ?? '',
      improvements: List<String>.from(json['improvements'] ?? []),
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
    );
  }
}

// AI Quota Info
class AIQuotaInfo {
  final int dailyLimit;
  final int dailyUsed;
  final int monthlyLimit;
  final int monthlyUsed;
  final DateTime resetsAt;

  AIQuotaInfo({
    required this.dailyLimit,
    required this.dailyUsed,
    required this.monthlyLimit,
    required this.monthlyUsed,
    required this.resetsAt,
  });

  factory AIQuotaInfo.fromJson(Map<String, dynamic> json) {
    return AIQuotaInfo(
      dailyLimit: json['daily_limit'] ?? 0,
      dailyUsed: json['daily_used'] ?? 0,
      monthlyLimit: json['monthly_limit'] ?? 0,
      monthlyUsed: json['monthly_used'] ?? 0,
      resetsAt: DateTime.tryParse(json['resets_at'] ?? '') ?? DateTime.now(),
    );
  }

  int get dailyRemaining => (dailyLimit - dailyUsed).clamp(0, dailyLimit);
  int get monthlyRemaining => (monthlyLimit - monthlyUsed).clamp(0, monthlyLimit);
}

// User Stats Model
class UserStats {
  final int totalTemplatesUsed;
  final int totalTemplatesCreated;
  final int totalCreditsEarned;
  final int currentStreak;
  final int totalAchievements;
  final double averageRating;
  final DateTime? lastActivity;
  final Map<String, int> categoryUsage;

  UserStats({
    this.totalTemplatesUsed = 0,
    this.totalTemplatesCreated = 0,
    this.totalCreditsEarned = 0,
    this.currentStreak = 0,
    this.totalAchievements = 0,
    this.averageRating = 0.0,
    this.lastActivity,
    this.categoryUsage = const {},
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalTemplatesUsed: json['total_templates_used'] ?? 0,
      totalTemplatesCreated: json['total_templates_created'] ?? 0,
      totalCreditsEarned: json['total_credits_earned'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      totalAchievements: json['total_achievements'] ?? 0,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      lastActivity: json['last_activity'] != null
          ? DateTime.tryParse(json['last_activity'])
          : null,
      categoryUsage: Map<String, int>.from(json['category_usage'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_templates_used': totalTemplatesUsed,
      'total_templates_created': totalTemplatesCreated,
      'total_credits_earned': totalCreditsEarned,
      'current_streak': currentStreak,
      'total_achievements': totalAchievements,
      'average_rating': averageRating,
      'last_activity': lastActivity?.toIso8601String(),
      'category_usage': categoryUsage,
    };
  }
}
