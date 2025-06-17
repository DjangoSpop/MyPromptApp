// lib/presentation/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/template_model.dart';
import '../../domain/services/template_service.dart';

/// Controller for home page template management
class HomeController extends GetxController {
  final TemplateService _templateService = Get.find<TemplateService>();

  final RxList<TemplateModel> templates = <TemplateModel>[].obs;
  final RxList<TemplateModel> filteredTemplates = <TemplateModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxList<String> categories = <String>['All'].obs;

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
      templates.value = await _templateService.getAllTemplates();

      // If no templates are found, try to load default templates
      if (templates.isEmpty) {
        debugPrint('No templates found, loading default templates...');
        await _templateService.loadDefaultTemplates();
        templates.value = await _templateService.getAllTemplates();
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
            (template.tags?.any((tag) => tag.toLowerCase().contains(query)) ??
                false);
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
  Future<void> duplicateTemplate(TemplateModel template) async {
    try {
      final duplicated = template.copyWith(
        title: '${template.title} (Copy)',
      );
      // Generate new ID
      duplicated.id = DateTime.now().millisecondsSinceEpoch.toString();

      await _templateService.saveTemplate(duplicated);
      await loadTemplates();
      Get.snackbar('Success', 'Template duplicated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to duplicate template: $e');
    }
  }

  /// Imports templates from JSON
  Future<void> importTemplates(String jsonString) async {
    try {
      isLoading.value = true;
      final imported = await _templateService.importFromJson(jsonString);
      await loadTemplates();
      Get.snackbar(
          'Success', 'Imported ${imported.length} template(s) successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to import templates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Exports selected templates
  Future<String> exportTemplates(List<String> templateIds) async {
    try {
      return await _templateService.exportToJson(templateIds);
    } catch (e) {
      Get.snackbar('Error', 'Failed to export templates: $e');
      return '';
    }
  }

  /// Loads default templates on first run
  Future<void> loadDefaultTemplatesIfEmpty() async {
    if (templates.isEmpty) {
      try {
        await _templateService.loadDefaultTemplates();
        await loadTemplates();
      } catch (e) {
        print('Failed to load default templates: $e');
      }
    }
  }
}
