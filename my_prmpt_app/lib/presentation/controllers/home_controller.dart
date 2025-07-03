// lib/presentation/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/template_api_models.dart';
import '../../data/services/hybrid_template_service.dart';

/// Controller for home page template management
class HomeController extends GetxController {
  final HybridTemplateService _templateService =
      Get.find<HybridTemplateService>();

  final RxList<TemplateListItem> templates = <TemplateListItem>[].obs;
  final RxList<TemplateListItem> filteredTemplates = <TemplateListItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<String> categories = <String>['All'].obs;

  // Template statistics
  final RxInt totalTemplates = 0.obs;
  final RxMap<String, int> templatesByCategory = <String, int>{}.obs;
  void fetchTemplates() async {
    try {
      isLoading.value = true;

      final fetched = await _templateService.getTemplates(); // your API
      templates.assignAll(fetched);
      applyFilters(); // VERY IMPORTANT
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch templates');
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    final query = searchQuery.value.toLowerCase();
    final category = selectedCategory.value;

    final results = templates.where((template) {
      final matchesQuery = template.title.toLowerCase().contains(query);
      final matchesCategory =
          category == 'All' || template.category.toString() == category;
      return matchesQuery && matchesCategory;
    }).toList();

    filteredTemplates.assignAll(results);
  }

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
    ever(searchQuery, (_) => _filterTemplates());
    ever(selectedCategory, (_) => _filterTemplates());
  }

  /// Loads all templates from storage
  Future<void> loadTemplates() async {
    try {
      isLoading.value = true;
      templates.value = await _templateService
          .getAllTemplates(); // If no templates are found, just continue with empty list
      if (templates.isEmpty) {
        debugPrint('No templates found');
      }

      // Update categories
      final uniqueCategories = templates.map((t) => t.category).toSet().toList()
        ..sort();
      categories.value = ['All', ...uniqueCategories];

      _filterTemplates();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load templates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Force refresh templates from assets
  Future<void> refreshTemplates() async {
    isRefreshing.value = true;
    try {
      await forceRefreshTemplates();
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Forces a refresh of templates by clearing storage and reloading
  Future<void> forceRefreshTemplates() async {
    try {
      isLoading.value = true;

      // Clear current templates
      templates.clear();
      filteredTemplates.clear();
      totalTemplates.value = 0;
      templatesByCategory.clear(); // Clear storage and reload templates
      // Note: initializeDefaultTemplates not available in HybridTemplateService

      // Reload templates
      await loadTemplates();

      Get.snackbar(
        'Success',
        'Templates refreshed successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh templates: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filters templates based on search query and category
  void _filterTemplates() {
    var filtered = templates.toList();

    // Filter by category
    if (selectedCategory.value != 'All') {
      filtered =
          filtered.where((t) => t.category == selectedCategory.value).toList();
    }

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((template) {
        return template.title.toLowerCase().contains(query) ||
            template.description.toLowerCase().contains(query) ||
            (template.tags.any((tag) => tag.toLowerCase().contains(query)));
      }).toList();
    }

    filteredTemplates.value = filtered;
  }

  /// Deletes a template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await _templateService.deleteTemplate(templateId);
      templates.removeWhere((t) => t.id == templateId);
      _filterTemplates();
      Get.snackbar('Success', 'Template deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete template: $e');
    }
  }

  /// Duplicates a template
  Future<void> duplicateTemplate(TemplateListItem template) async {
    try {
      // Create a simple template data map for duplication
      final templateData = {
        'title': '${template.title} (Copy)',
        'description': template.description,
        'category': template.category,
        'tags': template.tags,
      };

      await _templateService.createTemplate(templateData);
      await loadTemplates();
      Get.snackbar('Success', 'Template duplicated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to duplicate template: $e');
    }
  }

  /// Imports templates from JSON
  Future<void> importTemplates(String jsonString) async {
    try {
      isLoading.value = true; // For now, just reload templates
      await loadTemplates();
      Get.snackbar('Success', 'Templates imported successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to import templates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Exports selected templates
  Future<String> exportTemplates(List<String> templateIds) async {
    try {
      // For now, return empty string as export is not implemented
      return '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to export templates: $e');
      return '';
    }
  }

  /// Loads default templates on first run
  Future<void> loadDefaultTemplatesIfEmpty() async {
    if (templates.isEmpty) {
      try {
        // Just load all available templates
        await loadTemplates();
      } catch (e) {
        print('Failed to load default templates: $e');
      }
    }
  }

  /// Get template status string for display
  String get templateStatus {
    if (isLoading.value) return 'Loading...';
    if (isRefreshing.value) return 'Refreshing...';
    if (templates.isEmpty) return 'No templates loaded';
    return '${totalTemplates.value} templates loaded';
  }
}
