// ============================================
// PROMPTCRAFT INTEGRATION FIX
// ============================================
// This comprehensive fix addresses all integration issues
// and creates a production-ready Flutter application

// ============================================
// 1. API CLIENT WITH AUTH INTERCEPTOR
// ============================================
// lib/data/providers/api_client.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ApiClient extends GetxService {
  late Dio _dio;
  static const String baseUrl = 'https://api.promptcraft.com'; // Update with actual URL
  
  // Auth tokens storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  Dio get dio => _dio;

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add auth interceptor
    _dio.interceptors.add(AuthInterceptor());
    
    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // Save tokens to Hive
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final box = await Hive.openBox('auth');
    await box.put(_accessTokenKey, accessToken);
    await box.put(_refreshTokenKey, refreshToken);
  }

  // Get access token from Hive
  Future<String?> getAccessToken() async {
    final box = await Hive.openBox('auth');
    return box.get(_accessTokenKey);
  }

  // Get refresh token from Hive
  Future<String?> getRefreshToken() async {
    final box = await Hive.openBox('auth');
    return box.get(_refreshTokenKey);
  }

  // Clear tokens on logout
  Future<void> clearTokens() async {
    final box = await Hive.openBox('auth');
    await box.delete(_accessTokenKey);
    await box.delete(_refreshTokenKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

// Auth Interceptor to add token to requests
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/register endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/register')) {
      return handler.next(options);
    }

    // Add auth token to headers
    final apiClient = Get.find<ApiClient>();
    final token = await apiClient.getAccessToken();
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized - refresh token
    if (err.response?.statusCode == 401) {
      final apiClient = Get.find<ApiClient>();
      final refreshToken = await apiClient.getRefreshToken();
      
      if (refreshToken != null) {
        try {
          // Try to refresh token
          final response = await apiClient.dio.post(
            '/api/v1/auth/refresh/',
            data: {'refresh': refreshToken},
          );
          
          // Save new access token
          final newAccessToken = response.data['access'];
          await apiClient.saveTokens(newAccessToken, refreshToken);
          
          // Retry original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';
          
          final cloneReq = await apiClient.dio.fetch(opts);
          return handler.resolve(cloneReq);
        } catch (e) {
          // Refresh failed, redirect to login
          Get.offAllNamed('/login');
        }
      }
    }
    
    return handler.next(err);
  }
}

// ============================================
// 2. AUTH CONTROLLER
// ============================================
// lib/presentation/controllers/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/api_client.dart';
import '../../data/models/user_model.dart';

class AuthController extends GetxController {
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isAuthenticated = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  // Form controllers
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }

  /// Check if user is authenticated on app start
  Future<void> checkAuthStatus() async {
    isAuthenticated.value = await _apiClient.isAuthenticated();
    if (isAuthenticated.value) {
      await fetchUserProfile();
    }
  }

  /// Login user
  Future<void> login() async {
    if (!_validateLoginForm()) return;

    try {
      isLoading.value = true;
      
      final response = await _apiClient.dio.post(
        '/api/v1/auth/login/',
        data: {
          'username': usernameController.text.trim(),
          'password': passwordController.text,
        },
      );

      // Save tokens
      await _apiClient.saveTokens(
        response.data['access'],
        response.data['refresh'],
      );
      
      isAuthenticated.value = true;
      
      // Fetch user profile
      await fetchUserProfile();
      
      // Navigate to home
      Get.offAllNamed('/mobile');
      
      Get.snackbar(
        'Success',
        'Welcome back!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new user
  Future<void> register() async {
    if (!_validateRegisterForm()) return;

    try {
      isLoading.value = true;
      
      final response = await _apiClient.dio.post(
        '/api/v1/auth/register/',
        data: {
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'password_confirm': passwordConfirmController.text,
          'first_name': firstNameController.text.trim(),
          'last_name': lastNameController.text.trim(),
        },
      );

      // Registration successful
      Get.snackbar(
        'Success',
        'Account created successfully! Please login.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Navigate to login
      Get.offNamed('/login');
    } on DioException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Call logout endpoint
      await _apiClient.dio.post('/api/v1/auth/logout/');
      
      // Clear local tokens
      await _apiClient.clearTokens();
      
      // Reset state
      isAuthenticated.value = false;
      currentUser.value = null;
      
      // Clear form controllers
      _clearControllers();
      
      // Navigate to login
      Get.offAllNamed('/login');
      
      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Even if API call fails, clear local session
      await _apiClient.clearTokens();
      isAuthenticated.value = false;
      currentUser.value = null;
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user profile
  Future<void> fetchUserProfile() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/auth/profile/');
      currentUser.value = UserModel.fromJson(response.data);
    } catch (e) {
      print('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      
      final response = await _apiClient.dio.patch(
        '/api/v1/auth/profile/',
        data: data,
      );
      
      currentUser.value = UserModel.fromJson(response.data);
      
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      _handleApiError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate login form
  bool _validateLoginForm() {
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Username is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Password is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    
    return true;
  }

  /// Validate registration form
  bool _validateRegisterForm() {
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Username is required',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Email is required',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Invalid email format',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    if (passwordController.text.length < 8) {
      Get.snackbar('Error', 'Password must be at least 8 characters',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    if (passwordController.text != passwordConfirmController.text) {
      Get.snackbar('Error', 'Passwords do not match',
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    return true;
  }

  /// Handle auth errors
  void _handleAuthError(DioException e) {
    String message = 'Authentication failed';
    
    if (e.response?.data != null) {
      if (e.response!.data is Map) {
        // Extract error message from response
        final errors = e.response!.data as Map<String, dynamic>;
        if (errors.containsKey('detail')) {
          message = errors['detail'];
        } else if (errors.containsKey('non_field_errors')) {
          message = errors['non_field_errors'][0];
        } else {
          // Get first error message
          message = errors.values.first.toString();
        }
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout. Please check your internet.';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Unable to connect to server.';
    }
    
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// Handle general API errors
  void _handleApiError(DioException e) {
    String message = 'Something went wrong';
    
    if (e.response?.data != null && e.response!.data is Map) {
      final errors = e.response!.data as Map<String, dynamic>;
      message = errors.values.first.toString();
    }
    
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Clear all form controllers
  void _clearControllers() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    passwordConfirmController.clear();
    firstNameController.clear();
    lastNameController.clear();
  }
}

// ============================================
// 3. USER MODEL
// ============================================
// lib/data/models/user_model.dart

class UserModel {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String? bio;
  final int credits;
  final int level;
  final int experiencePoints;
  final int dailyStreak;
  final String userRank;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final int templatesCreated;
  final int templatesCompleted;
  final int totalPromptsGenerated;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    this.bio,
    required this.credits,
    required this.level,
    required this.experiencePoints,
    required this.dailyStreak,
    required this.userRank,
    required this.isPremium,
    this.premiumExpiresAt,
    required this.templatesCreated,
    required this.templatesCompleted,
    required this.totalPromptsGenerated,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatar: json['avatar'],
      bio: json['bio'],
      credits: json['credits'] ?? 0,
      level: json['level'] ?? 1,
      experiencePoints: json['experience_points'] ?? 0,
      dailyStreak: json['daily_streak'] ?? 0,
      userRank: json['user_rank'] ?? 'Novice',
      isPremium: json['is_premium'] ?? false,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.parse(json['premium_expires_at'])
          : null,
      templatesCreated: json['templates_created'] ?? 0,
      templatesCompleted: json['templates_completed'] ?? 0,
      totalPromptsGenerated: json['total_prompts_generated'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get displayName {
    if (firstName != null || lastName != null) {
      return '${firstName ?? ''} ${lastName ?? ''}'.trim();
    }
    return username;
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    } else if (firstName != null) {
      return firstName![0].toUpperCase();
    }
    return username[0].toUpperCase();
  }
}

// ============================================
// 4. TEMPLATE API SERVICE
// ============================================
// lib/data/services/template_api_service.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../providers/api_client.dart';
import '../models/template_api_models.dart';

class TemplateApiService extends GetxService {
  final ApiClient _apiClient = Get.find<ApiClient>();

  /// Get all templates with pagination
  Future<TemplateListResponse> getTemplates({
    int page = 1,
    String? search,
    String? category,
    bool? isPublic,
    bool? isFeatured,
    String? ordering,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/templates/',
        queryParameters: {
          'page': page,
          if (search != null) 'search': search,
          if (category != null) 'category': category,
          if (isPublic != null) 'is_public': isPublic,
          if (isFeatured != null) 'is_featured': isFeatured,
          if (ordering != null) 'ordering': ordering,
        },
      );

      return TemplateListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get single template by ID
  Future<TemplateDetail> getTemplateById(String id) async {
    try {
      final response = await _apiClient.dio.get('/api/v1/templates/$id/');
      return TemplateDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new template
  Future<TemplateDetail> createTemplate(TemplateCreateRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/templates/',
        data: request.toJson(),
      );
      return TemplateDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update existing template
  Future<TemplateDetail> updateTemplate(String id, TemplateCreateRequest request) async {
    try {
      final response = await _apiClient.dio.put(
        '/api/v1/templates/$id/',
        data: request.toJson(),
      );
      return TemplateDetail.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete template
  Future<void> deleteTemplate(String id) async {
    try {
      await _apiClient.dio.delete('/api/v1/templates/$id/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get featured templates
  Future<List<TemplateListItem>> getFeaturedTemplates() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/templates/featured/');
      return (response.data as List)
          .map((item) => TemplateListItem.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get trending templates
  Future<List<TemplateListItem>> getTrendingTemplates() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/templates/trending/');
      return (response.data as List)
          .map((item) => TemplateListItem.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user's templates
  Future<List<TemplateListItem>> getMyTemplates() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/templates/my_templates/');
      return (response.data as List)
          .map((item) => TemplateListItem.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Start template usage (for analytics)
  Future<void> startTemplateUsage(String templateId) async {
    try {
      await _apiClient.dio.post('/api/v1/templates/$templateId/start_usage/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Complete template usage (for gamification)
  Future<Map<String, dynamic>> completeTemplateUsage(String templateId) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/templates/$templateId/complete_usage/',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get template categories
  Future<List<TemplateCategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/templates/categories/');
      return (response.data as List)
          .map((item) => TemplateCategoryModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Error handling
  String _handleError(DioException e) {
    if (e.response?.data != null) {
      if (e.response!.data is Map) {
        final error = e.response!.data as Map<String, dynamic>;
        if (error.containsKey('detail')) {
          return error['detail'];
        }
        return error.values.first.toString();
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

// ============================================
// 5. TEMPLATE API MODELS
// ============================================
// lib/data/models/template_api_models.dart

import 'package:hive/hive.dart';
import '../../domain/models/template_model.dart';

/// Template list response with pagination
class TemplateListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<TemplateListItem> results;

  TemplateListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory TemplateListResponse.fromJson(Map<String, dynamic> json) {
    return TemplateListResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((item) => TemplateListItem.fromJson(item))
          .toList(),
    );
  }
}

/// Template list item (lightweight)
@HiveType(typeId: 20)
class TemplateListItem extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final String author;
  
  @HiveField(5)
  final String version;
  
  @HiveField(6)
  final List<String> tags;
  
  @HiveField(7)
  final int usageCount;
  
  @HiveField(8)
  final double completionRate;
  
  @HiveField(9)
  final double averageRating;
  
  @HiveField(10)
  final double popularityScore;
  
  @HiveField(11)
  final bool isFeatured;
  
  @HiveField(12)
  final int fieldCount;
  
  @HiveField(13)
  final DateTime createdAt;
  
  @HiveField(14)
  final DateTime updatedAt;

  TemplateListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.author,
    required this.version,
    required this.tags,
    required this.usageCount,
    required this.completionRate,
    required this.averageRating,
    required this.popularityScore,
    required this.isFeatured,
    required this.fieldCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TemplateListItem.fromJson(Map<String, dynamic> json) {
    return TemplateListItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category']['name'] ?? json['category'],
      author: json['author'] ?? 'Unknown',
      version: json['version'] ?? '1.0.0',
      tags: List<String>.from(json['tags'] ?? []),
      usageCount: json['usage_count'] ?? 0,
      completionRate: (json['completion_rate'] ?? 0).toDouble(),
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      popularityScore: (json['popularity_score'] ?? 0).toDouble(),
      isFeatured: json['is_featured'] ?? false,
      fieldCount: json['field_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert to domain TemplateModel for compatibility
  TemplateModel toTemplateModel() {
    return TemplateModel(
      id: id,
      title: title,
      description: description,
      category: category,
      content: '', // Will be fetched when needed
      tags: tags,
      createdBy: author,
      createdAt: createdAt,
      updatedAt: updatedAt,
      usageCount: usageCount,
      rating: averageRating,
      isPublic: true,
    );
  }

  double get rating => averageRating;
}

/// Template detail (full data)
class TemplateDetail {
  final String id;
  final String title;
  final String description;
  final TemplateCategory category;
  final String templateContent;
  final Author author;
  final List<TemplateField> fields;
  final String version;
  final List<String> tags;
  final bool isAiGenerated;
  final double? aiConfidence;
  final List<String>? extractedKeywords;
  final Map<String, dynamic>? smartSuggestions;
  final int usageCount;
  final double completionRate;
  final double averageRating;
  final double popularityScore;
  final bool isPublic;
  final bool isFeatured;
  final Map<String, String>? localizations;
  final DateTime createdAt;
  final DateTime updatedAt;

  TemplateDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.templateContent,
    required this.author,
    required this.fields,
    required this.version,
    required this.tags,
    required this.isAiGenerated,
    this.aiConfidence,
    this.extractedKeywords,
    this.smartSuggestions,
    required this.usageCount,
    required this.completionRate,
    required this.averageRating,
    required this.popularityScore,
    required this.isPublic,
    required this.isFeatured,
    this.localizations,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TemplateDetail.fromJson(Map<String, dynamic> json) {
    return TemplateDetail(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: TemplateCategory.fromJson(json['category']),
      templateContent: json['template_content'],
      author: Author.fromJson(json['author']),
      fields: (json['fields'] as List)
          .map((f) => TemplateField.fromJson(f))
          .toList(),
      version: json['version'] ?? '1.0.0',
      tags: List<String>.from(json['tags'] ?? []),
      isAiGenerated: json['is_ai_generated']