// lib/presentation/controllers/template_detail_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/template_api_models.dart';
import '../../data/services/api/django_api_service.dart';
import '../../data/services/auth_service.dart';

/// Controller for template detail page
class TemplateDetailController extends GetxController {
  final DjangoApiService _apiService = DjangoApiService();
  final AuthService _authService = Get.find<AuthService>();

  // Template data
  final Rx<TemplateListItem?> template = Rx<TemplateListItem?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFavorite = false.obs;
  final RxDouble userRating = 0.0.obs;

  // Reviews
  final RxList<Map<String, dynamic>> reviews = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingReviews = false.obs;

  // Rating modal
  final RxDouble tempRating = 0.0.obs;
  final TextEditingController reviewController = TextEditingController();

  String? templateId;

  @override
  void onInit() {
    super.onInit();

    // Get template from arguments
    final args = Get.arguments;
    if (args is TemplateListItem) {
      template.value = args;
      templateId = args.id;
      loadTemplateDetails();
    } else if (args is Map && args['id'] != null) {
      templateId = args['id'];
      loadTemplateDetails();
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }

  /// Load full template details from backend
  Future<void> loadTemplateDetails() async {
    if (templateId == null) return;

    try {
      isLoading.value = true;

      // Fetch template details
      final response = await _apiService.getTemplate(templateId!);

      if (response.success && response.data != null) {
        final data = response.data!;

        // Update template
        template.value = TemplateListItem(
          id: data['id']?.toString() ?? templateId!,
          title: data['title']?.toString() ?? 'Untitled',
          description: data['description']?.toString() ?? '',
          category: data['category']?.toString() ?? 'General',
          tags: (data['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
          rating: (data['rating_avg'] ?? 0.0).toDouble(),
          usageCount: data['usage_count'] ?? 0,
          createdAt: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
          isPublic: data['is_public'] ?? true,
          isPremium: data['is_premium'] ?? false,
          fields: [],
        );

        // Check if user has favorited this template
        await checkFavoriteStatus();

        // Load reviews
        await loadReviews();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load template details: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Check if current user has favorited this template
  Future<void> checkFavoriteStatus() async {
    if (!_authService.isAuthenticated || templateId == null) return;

    try {
      final response = await _apiService.getUserFavorites();

      if (response.success && response.data != null) {
        final favorites = response.data as List;
        isFavorite.value = favorites.any((fav) => fav['template']?['id'] == templateId);
      }
    } catch (e) {
      debugPrint('Failed to check favorite status: $e');
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    if (!_authService.isAuthenticated) {
      Get.snackbar(
        'Authentication Required',
        'Please login to favorite templates',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      return;
    }

    if (templateId == null) return;

    try {
      final response = await _apiService.toggleFavorite(templateId!);

      if (response.success) {
        isFavorite.value = !isFavorite.value;

        Get.snackbar(
          'Success',
          isFavorite.value ? 'Added to favorites' : 'Removed from favorites',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorite: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  /// Load reviews for this template
  Future<void> loadReviews() async {
    if (templateId == null) return;

    try {
      isLoadingReviews.value = true;

      final response = await _apiService.getTemplateRatings(templateId!);

      if (response.success && response.data != null) {
        final data = response.data as List;
        reviews.value = data.cast<Map<String, dynamic>>();

        // Check if user has rated this template
        if (_authService.isAuthenticated) {
          final userReview = reviews.firstWhereOrNull(
            (review) => review['user']?['id'] == _authService.currentUser.value?.id,
          );

          if (userReview != null) {
            userRating.value = (userReview['rating'] ?? 0.0).toDouble();
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to load reviews: $e');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  /// Submit rating and review
  Future<void> submitRating() async {
    if (!_authService.isAuthenticated) {
      Get.snackbar(
        'Authentication Required',
        'Please login to rate templates',
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      return;
    }

    if (templateId == null || tempRating.value == 0) return;

    try {
      final response = await _apiService.rateTemplate(
        templateId!,
        tempRating.value.toInt(),
        reviewController.text.trim(),
      );

      if (response.success) {
        Get.back(); // Close rating modal

        // Update user rating
        userRating.value = tempRating.value;

        // Reload template details and reviews
        await loadTemplateDetails();

        Get.snackbar(
          'Success',
          'Thank you for your rating!',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
        );

        // Reset form
        tempRating.value = 0.0;
        reviewController.clear();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit rating: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  /// Track template usage and award XP
  Future<void> useTemplate() async {
    if (templateId == null) return;

    try {
      final response = await _apiService.trackTemplateUsage(templateId!);

      if (response.success && response.data != null) {
        final xpGained = response.data['xp_gained'] ?? 5;

        Get.snackbar(
          'Template Used!',
          'You earned $xpGained XP',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[800],
          icon: const Icon(Icons.star, color: Colors.amber),
        );

        // Reload template to update usage count
        await loadTemplateDetails();

        // Navigate to wizard or editor
        Get.toNamed('/wizard', arguments: template.value);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to use template: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  /// Show rating modal
  void showRatingModal() {
    tempRating.value = userRating.value;

    Get.dialog(
      AlertDialog(
        title: const Text('Rate Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How would you rate this template?'),
            const SizedBox(height: 16),

            // Star rating
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1.0;
                return GestureDetector(
                  onTap: () => tempRating.value = starValue,
                  child: Icon(
                    starValue <= tempRating.value
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            )),

            const SizedBox(height: 16),

            // Review text (optional)
            TextField(
              controller: reviewController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write a review (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: submitRating,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  /// Share template
  Future<void> shareTemplate() async {
    // TODO: Implement share functionality
    Get.snackbar(
      'Share',
      'Share functionality coming soon!',
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
    );
  }

  /// Edit template (if user is owner)
  void editTemplate() {
    Get.toNamed('/editor', arguments: template.value);
  }
}
