import 'package:dio/dio.dart';
import 'package:promptcraft/data/services/api/http_client.dart';

/// Django API Service
///
/// Handles all communication with the Django REST API backend.
/// Provides methods for authentication, templates, users, and more.
class DjangoApiService {
  final HttpClient _httpClient = HttpClient();
  Dio get _dio => _httpClient.client;

  // ==================== AUTHENTICATION ====================

  /// Login with email and password
  /// Returns JWT access and refresh tokens
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/users/auth/login/',
        data: {
          'email': email,
          'password': password,
        },
      );

      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Register new user
  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String username,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await _dio.post(
        '/users/register/',
        data: {
          'email': email,
          'username': username,
          'password': password,
          'password_confirm': passwordConfirm,
        },
      );

      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Refresh JWT token
  Future<ApiResponse<Map<String, dynamic>>> refreshToken(
    String refreshToken,
  ) async {
    try {
      final response = await _dio.post(
        '/users/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Get current user info
  Future<ApiResponse<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me/');
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Get user profile with streak
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await _dio.get('/users/profile/');
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Update user profile
  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch('/users/update_profile/', data: data);
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Log activity (update streak)
  Future<ApiResponse<Map<String, dynamic>>> logActivity() async {
    try {
      final response = await _dio.post('/users/log_activity/');
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  // ==================== TEMPLATES ====================

  /// Get list of templates with optional filters
  Future<ApiResponse<Map<String, dynamic>>> getTemplates({
    int page = 1,
    int pageSize = 20,
    String? category,
    List<String>? tags,
    String? search,
    String? ordering,
    bool? isFeatured,
    bool? isPremium,
    bool? myTemplates,
    bool? favorites,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (category != null) queryParams['category'] = category;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (ordering != null) queryParams['ordering'] = ordering;
      if (isFeatured != null) queryParams['is_featured'] = isFeatured;
      if (isPremium != null) queryParams['is_premium'] = isPremium;
      if (myTemplates == true) queryParams['my_templates'] = 'true';
      if (favorites == true) queryParams['favorites'] = 'true';

      final response = await _dio.get(
        '/templates/',
        queryParameters: queryParams,
      );

      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Get single template details
  Future<ApiResponse<Map<String, dynamic>>> getTemplate(String id) async {
    try {
      final response = await _dio.get('/templates/$id/');
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Create new template
  Future<ApiResponse<Map<String, dynamic>>> createTemplate(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('/templates/', data: data);
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Update template
  Future<ApiResponse<Map<String, dynamic>>> updateTemplate(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch('/templates/$id/', data: data);
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Delete template
  Future<ApiResponse<void>> deleteTemplate(String id) async {
    try {
      await _dio.delete('/templates/$id/');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Toggle favorite
  Future<ApiResponse<Map<String, dynamic>>> toggleFavorite(String id) async {
    try {
      final response = await _dio.post('/templates/$id/favorite/');
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Rate template
  Future<ApiResponse<Map<String, dynamic>>> rateTemplate(
    String id, {
    required int rating,
    String? review,
  }) async {
    try {
      final response = await _dio.post(
        '/templates/$id/rate/',
        data: {
          'rating': rating,
          if (review != null) 'review': review,
        },
      );
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Track template usage
  Future<ApiResponse<Map<String, dynamic>>> useTemplate(
    String id, {
    Map<String, dynamic>? inputData,
    bool success = true,
  }) async {
    try {
      final response = await _dio.post(
        '/templates/$id/use/',
        data: {
          'input_data': inputData ?? {},
          'success': success,
        },
      );
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Get trending templates
  Future<ApiResponse<List<dynamic>>> getTrendingTemplates() async {
    try {
      final response = await _dio.get('/templates/trending/');
      return ApiResponse.success(response.data as List<dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  // ==================== CATEGORIES & TAGS ====================

  /// Get all categories
  Future<ApiResponse<List<dynamic>>> getCategories() async {
    try {
      final response = await _dio.get('/templates/categories/');
      return ApiResponse.success(response.data as List<dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }

  /// Get all tags
  Future<ApiResponse<List<dynamic>>> getTags() async {
    try {
      final response = await _dio.get('/templates/tags/');
      return ApiResponse.success(response.data as List<dynamic>);
    } on DioException catch (e) {
      return ApiResponse.error(e.error.toString());
    }
  }
}
