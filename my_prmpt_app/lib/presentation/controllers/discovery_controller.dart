// lib/presentation/controllers/discovery_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/services/ai_context_engine.dart' as ai_engine;
import '../../domain/services/template_analytics_service.dart';
import '../../domain/models/ai_context.dart';
import '../../data/models/template_model.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;
  final int templateCount;

  Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.templateCount,
  });
}

class DiscoveryController extends GetxController {
  final ai_engine.AIContextEngine _aiContextEngine = Get.find<ai_engine.AIContextEngine>();
  final TemplateAnalyticsService _analyticsService =
      Get.find<TemplateAnalyticsService>();

  final RxList<TemplateSuggestion> aiSuggestions = <TemplateSuggestion>[].obs;
  final RxList<String> quickFilters = <String>[].obs;
  final RxList<String> selectedFilters = <String>[].obs;
  final RxList<TemplateModel> trendingTemplates = <TemplateModel>[].obs;
  final RxList<TemplateModel> personalizedTemplates = <TemplateModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isVoiceSearchActive = false.obs;

  final List<Category> categories = [
    Category(
      name: 'Software Engineering',
      icon: Icons.code,
      color: Colors.blue,
      templateCount: 15,
    ),
    Category(
      name: 'Business Strategy',
      icon: Icons.business,
      color: Colors.green,
      templateCount: 12,
    ),
    Category(
      name: 'Creative Content',
      icon: Icons.brush,
      color: Colors.purple,
      templateCount: 10,
    ),
    Category(
      name: 'Education',
      icon: Icons.school,
      color: Colors.orange,
      templateCount: 8,
    ),
    Category(
      name: 'Research',
      icon: Icons.science,
      color: Colors.red,
      templateCount: 6,
    ),
    Category(
      name: 'Marketing',
      icon: Icons.campaign,
      color: Colors.pink,
      templateCount: 9,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeQuickFilters();
    _loadInitialData();
  }

  void _initializeQuickFilters() {
    quickFilters.assignAll([
      'AI Generated',
      'Popular',
      'Recent',
      'High Rated',
      'Trending',
      'Business',
      'Technical',
      'Creative',
    ]);
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;

    try {
      // Load trending templates based on analytics
      await _loadTrendingTemplates();

      // Load personalized recommendations
      await _loadPersonalizedRecommendations();

      // Generate initial AI suggestions
      await _generateInitialAISuggestions();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTrendingTemplates() async {
    // TODO: Load actual template models from repository
    // For now, using placeholder data
    trendingTemplates.clear();
  }

  Future<void> _loadPersonalizedRecommendations() async {
    // TODO: Implement personalized recommendations based on user history
    personalizedTemplates.clear();
  }

  Future<void> _generateInitialAISuggestions() async {
    final suggestions = await _aiContextEngine
        .generateTemplateSuggestions('help me create professional templates');
    aiSuggestions.assignAll(suggestions as Iterable<TemplateSuggestion>);
  }

  /// Perform AI-powered search
  Future<void> performAISearch(String query) async {
    if (query.trim().isEmpty) return;

    searchQuery.value = query;
    isLoading.value = true;

    try {
      final suggestions =
          await _aiContextEngine.generateTemplateSuggestions(query);
      aiSuggestions.assignAll(suggestions as Iterable<TemplateSuggestion>);

      // TODO: Also search existing templates
    } catch (e) {
      Get.snackbar('Error', 'Search failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Start voice search
  void startVoiceSearch() {
    isVoiceSearchActive.value = true;
    // TODO: Implement voice recognition
    Get.snackbar('Voice Search', 'Voice search not implemented yet');
    isVoiceSearchActive.value = false;
  }

  /// Toggle filter selection
  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    _applyFilters();
  }

  void _applyFilters() {
    // TODO: Apply filters to search results
    // This would filter the displayed templates based on selected filters
  }

  /// Accept an AI suggestion
  void acceptSuggestion(TemplateSuggestion suggestion) {
    // Update context usage
    _aiContextEngine.updateContextUsage(suggestion.aiContext.id);

    // Navigate to template creation with the suggestion
    Get.toNamed('/template-editor', arguments: {
      'suggestion': suggestion,
      'aiGenerated': true,
    });
  }

  /// Dismiss an AI suggestion
  void dismissSuggestion(TemplateSuggestion suggestion) {
    aiSuggestions.remove(suggestion);
    Get.snackbar(
      'Suggestion Dismissed',
      'The suggestion has been removed',
      duration: const Duration(seconds: 2),
    );
  }

  /// Navigate to category
  void navigateToCategory(Category category) {
    Get.toNamed(
        '/category/${category.name.toLowerCase().replaceAll(' ', '-')}');
  }

  /// Clear search and filters
  void clearSearch() {
    searchQuery.value = '';
    selectedFilters.clear();
    _generateInitialAISuggestions();
  }

  /// Refresh discovery data
  @override
  Future<void> refresh() async {
    await _loadInitialData();
  }

  /// Get filtered suggestions based on current filters
  List<TemplateSuggestion> get filteredSuggestions {
    if (selectedFilters.isEmpty) return aiSuggestions;

    return aiSuggestions.where((suggestion) {
      // Apply filter logic
      if (selectedFilters.contains('AI Generated') &&
          !suggestion.aiContext.domain.contains('AI')) {
        return false;
      }

      if (selectedFilters.contains('High Rated') &&
          suggestion.confidence < 0.8) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Get search suggestions based on current query
  List<String> getSearchSuggestions() {
    if (searchQuery.value.isEmpty) return [];

    // TODO: Implement recent queries storage or use available AIContextEngine methods
    final recentQueries = <String>[
      'Software engineering templates',
      'Business strategy planning',
      'Creative writing prompts',
      'Code review checklist',
      'Meeting agenda template'
    ];
    return recentQueries
        .where((query) =>
            query.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .take(5)
        .toList();
  }
}
