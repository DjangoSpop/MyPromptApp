import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:promptcraft/data/models/user_model.dart';

/// Authentication Service
/// Manages user authentication, session, and profile data
/// Uses local storage (Hive) for offline-first approach
class AuthService extends GetxService {
  // Observable user state
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;

  // Storage keys
  static const String _userBox = 'user_data';
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

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
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Failed to load saved user: $e');
      }
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      // TODO: Replace with actual API call
      // final response = await _apiService.login(email, password);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // For now, create a mock user
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        username: email.split('@').first,
        displayName: email.split('@').first.toUpperCase(),
        avatarUrl: null,
        level: 1,
        xp: 0,
        createdAt: DateTime.now(),
      );

      // Save user to storage
      await _saveUser(user);

      currentUser.value = user;
      isAuthenticated.value = true;

      if (kDebugMode) {
        print('✅ Login successful: ${user.username}');
      }

      Get.snackbar(
        'Welcome!',
        'Successfully logged in as ${user.displayName}',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login failed: $e');
      }

      Get.snackbar(
        'Login Failed',
        'Invalid credentials. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      isLoading.value = true;

      // TODO: Replace with actual API call
      // final response = await _apiService.register(email, password, username);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Create new user
      final user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        username: username,
        displayName: username.toUpperCase(),
        avatarUrl: null,
        level: 1,
        xp: 0,
        createdAt: DateTime.now(),
      );

      // Save user to storage
      await _saveUser(user);

      currentUser.value = user;
      isAuthenticated.value = true;

      if (kDebugMode) {
        print('✅ Registration successful: ${user.username}');
      }

      Get.snackbar(
        'Account Created!',
        'Welcome to PromptCraft, ${user.displayName}!',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Registration failed: $e');
      }

      Get.snackbar(
        'Registration Failed',
        'Could not create account. Please try again.',
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

  /// Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      if (currentUser.value == null) return false;

      isLoading.value = true;

      // TODO: Replace with actual API call
      // final response = await _apiService.updateProfile(...);

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update local user
      final updatedUser = UserModel(
        id: currentUser.value!.id,
        email: currentUser.value!.email,
        username: currentUser.value!.username,
        displayName: displayName ?? currentUser.value!.displayName,
        avatarUrl: avatarUrl ?? currentUser.value!.avatarUrl,
        level: currentUser.value!.level,
        xp: currentUser.value!.xp,
        createdAt: currentUser.value!.createdAt,
      );

      await _saveUser(updatedUser);
      currentUser.value = updatedUser;

      Get.snackbar(
        'Profile Updated',
        'Your profile has been updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
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

  /// Add XP to user (gamification)
  Future<void> addXP(int amount) async {
    if (currentUser.value == null) return;

    try {
      final currentXP = currentUser.value!.xp;
      final newXP = currentXP + amount;
      final currentLevel = currentUser.value!.level;

      // Calculate new level (100 XP per level)
      final newLevel = (newXP / 100).floor() + 1;

      // Check for level up
      final leveledUp = newLevel > currentLevel;

      // Update user
      final updatedUser = UserModel(
        id: currentUser.value!.id,
        email: currentUser.value!.email,
        username: currentUser.value!.username,
        displayName: currentUser.value!.displayName,
        avatarUrl: currentUser.value!.avatarUrl,
        level: newLevel,
        xp: newXP,
        createdAt: currentUser.value!.createdAt,
      );

      await _saveUser(updatedUser);
      currentUser.value = updatedUser;

      if (leveledUp) {
        Get.snackbar(
          '🎉 Level Up!',
          'You reached level $newLevel!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Failed to add XP: $e');
      }
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => isAuthenticated.value && currentUser.value != null;

  /// Get current user ID
  String? get userId => currentUser.value?.id;

  /// Get current username
  String? get username => currentUser.value?.username;
}
