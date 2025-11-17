import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:promptcraft/data/models/user_model.dart';
import 'package:promptcraft/data/services/api/django_api_service.dart';

/// Enhanced Authentication Service with Django Backend Integration
///
/// Manages user authentication, session, and profile data
/// with both local storage (offline) and API sync (online)
class AuthService extends GetxService {
  final DjangoApiService _apiService = DjangoApiService();

  // Observable user state
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;

  // Storage keys
  static const String _userBox = 'user_data';
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  void onInit() {
    super.onInit();
    _loadSavedUser();
  }

  /// Load saved user from local storage
  Future<void> _loadSavedUser() async {
    try {
      final box = await Hive.openBox(_userBox);
      final userData = box.get(_userKey);

      if (userData != null) {
        currentUser.value = UserModel.fromJson(
          Map<String, dynamic>.from(userData as Map),
        );
        isAuthenticated.value = true;

        if (kDebugMode) {
          print('✅ User loaded: ${currentUser.value?.username}');
        }

        // Sync with backend if online
        await _syncWithBackend();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Failed to load saved user: $e');
      }
    }
  }

  /// Sync local user data with backend
  Future<void> _syncWithBackend() async {
    try {
      final response = await _apiService.getCurrentUser();
      if (response.success && response.data != null) {
        final userData = response.data!;
        currentUser.value = UserModel.fromJson(userData);
        await _saveUser(currentUser.value!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Backend sync failed (offline mode): $e');
      }
    }
  }

  /// Login with email and password (Django API)
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      // Call Django API
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (!response.success || response.data == null) {
        Get.snackbar(
          'Login Failed',
          response.error ?? 'Invalid credentials',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Extract tokens
      final String? accessToken = response.data!['access'] as String?;
      final String? refreshToken = response.data!['refresh'] as String?;

      if (accessToken == null) {
        Get.snackbar(
          'Login Failed',
          'No access token received',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Save tokens
      await _saveTokens(accessToken, refreshToken);

      // Get user profile
      final profileResponse = await _apiService.getCurrentUser();
      if (profileResponse.success && profileResponse.data != null) {
        final user = UserModel.fromJson(profileResponse.data!);
        currentUser.value = user;
        isAuthenticated.value = true;

        await _saveUser(user);

        if (kDebugMode) {
          print('✅ Login successful: ${user.username}');
        }

        Get.snackbar(
          'Welcome Back!',
          'Successfully logged in as ${user.displayName}',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Log activity (update streak)
        await _apiService.logActivity();

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login failed: $e');
      }

      Get.snackbar(
        'Login Failed',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new user (Django API)
  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      isLoading.value = true;

      // Call Django API
      final response = await _apiService.register(
        email: email,
        username: username,
        password: password,
        passwordConfirm: password,
      );

      if (!response.success || response.data == null) {
        Get.snackbar(
          'Registration Failed',
          response.error ?? 'Could not create account',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      if (kDebugMode) {
        print('✅ Registration successful');
      }

      Get.snackbar(
        'Account Created!',
        'Welcome to PromptCraft! Please log in.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Auto-login after registration
      return await login(email, password);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Registration failed: $e');
      }

      Get.snackbar(
        'Registration Failed',
        'Network error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Clear storage
      final box = await Hive.openBox(_userBox);
      await box.delete(_userKey);
      await box.delete(_tokenKey);
      await box.delete(_refreshTokenKey);

      // Clear state
      currentUser.value = null;
      isAuthenticated.value = false;

      if (kDebugMode) {
        print('✅ User logged out');
      }

      Get.snackbar(
        'Logged Out',
        'You have been successfully logged out',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Logout failed: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Save user to local storage
  Future<void> _saveUser(UserModel user) async {
    try {
      final box = await Hive.openBox(_userBox);
      await box.put(_userKey, user.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Failed to save user: $e');
      }
    }
  }

  /// Save authentication tokens
  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    try {
      final box = await Hive.openBox(_userBox);
      await box.put(_tokenKey, accessToken);
      if (refreshToken != null) {
        await box.put(_refreshTokenKey, refreshToken);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Failed to save tokens: $e');
      }
    }
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    try {
      final box = await Hive.openBox(_userBox);
      return box.get(_tokenKey) as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    try {
      final box = await Hive.openBox(_userBox);
      return box.get(_refreshTokenKey) as String?;
    } catch (e) {
      return null;
    }
  }

  /// Refresh access token
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.refreshToken(refreshToken);
      if (response.success && response.data != null) {
        final newAccessToken = response.data!['access'] as String?;
        if (newAccessToken != null) {
          await _saveTokens(newAccessToken, null);
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    if (currentUser.value == null) return false;

    try {
      isLoading.value = true;

      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await _apiService.updateProfile(data);

      if (response.success && response.data != null) {
        final updatedUser = UserModel.fromJson(response.data!['user']);
        currentUser.value = updatedUser;
        await _saveUser(updatedUser);

        Get.snackbar(
          'Profile Updated',
          'Your profile has been updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Profile update failed: $e');
      }

      Get.snackbar(
        'Update Failed',
        'Could not update profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Add XP to user (synced with backend)
  Future<void> addXP(int amount) async {
    if (currentUser.value == null) return;

    // Update locally first
    final currentXP = currentUser.value!.xp;
    final newXP = currentXP + amount;
    final currentLevel = currentUser.value!.level;
    final newLevel = (newXP / 100).floor() + 1;
    final leveledUp = newLevel > currentLevel;

    currentUser.value = currentUser.value!.copyWith(
      xp: newXP,
      level: newLevel,
    );

    await _saveUser(currentUser.value!);

    if (leveledUp) {
      Get.snackbar(
        '🎉 Level Up!',
        'You reached level $newLevel!',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    // Sync with backend
    await _syncWithBackend();
  }

  /// Check if user is logged in
  bool get isLoggedIn => isAuthenticated.value && currentUser.value != null;

  /// Get current user ID
  String? get userId => currentUser.value?.id;

  /// Get current username
  String? get username => currentUser.value?.username;
}
