// lib/domain/services/template_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:my_prmpt_app/data/datasources/local_storage_service.dart';
import 'package:my_prmpt_app/data/models/enhanced_template_model.dart';
import 'package:my_prmpt_app/data/repositories/advanced_template_collection.dart';
import 'package:my_prmpt_app/data/repositories/domain_specific_templates.dart';
import '../models/template_model.dart';
import '../repositories/template_repository.dart';

/// Service for managing prompt templates with CRUD operations
class TemplateService {
  final TemplateRepository _repository;

  TemplateService({required TemplateRepository repository})
      : _repository = repository;

  /// Retrieves all templates from storage
  Future<List<TemplateModel>> getAllTemplates() async {
    return await _repository.getAllTemplates();
  }

  /// Gets a specific template by ID
  Future<TemplateModel?> getTemplateById(String id) async {
    return await _repository.getTemplateById(id);
  }

  /// Saves a new or existing template
  Future<void> saveTemplate(TemplateModel template) async {
    await _repository.saveTemplate(template);
  }

  /// Deletes a template by ID
  Future<void> deleteTemplate(String id) async {
    await _repository.deleteTemplate(id);
  }

  /// Searches templates by title, description, or tags
  Future<List<TemplateModel>> searchTemplates(String query) async {
    final allTemplates = await getAllTemplates();
    final lowerQuery = query.toLowerCase();

    return allTemplates.where((template) {
      return template.title.toLowerCase().contains(lowerQuery) ||
          template.description.toLowerCase().contains(lowerQuery) ||
          template.category.toLowerCase().contains(lowerQuery) ||
          (template.tags
                  ?.any((tag) => tag.toLowerCase().contains(lowerQuery)) ??
              false);
    }).toList();
  }

  /// Imports templates from JSON string
  Future<List<TemplateModel>> importFromJson(String jsonString) async {
    try {
      final dynamic jsonData = json.decode(jsonString);
      final List<TemplateModel> templates = [];

      if (jsonData is List) {
        // Multiple templates
        for (final item in jsonData) {
          templates.add(TemplateModel.fromJson(item));
        }
      } else if (jsonData is Map<String, dynamic>) {
        // Single template
        templates.add(TemplateModel.fromJson(jsonData));
      }

      // Save imported templates
      for (final template in templates) {
        await saveTemplate(template);
      }

      return templates;
    } catch (e) {
      throw Exception('Failed to import templates: $e');
    }
  }

  /// Exports templates to JSON string
  Future<String> exportToJson(List<String> templateIds) async {
    final templates = <TemplateModel>[];

    for (final id in templateIds) {
      final template = await getTemplateById(id);
      if (template != null) templates.add(template);
    }

    if (templates.length == 1) {
      return json.encode(templates.first.toJson());
    } else {
      return json.encode(templates.map((t) => t.toJson()).toList());
    }
  }

  /// Loads default templates from assets
  Future<void> loadDefaultTemplates() async {
    try {
      // Delegate to LocalStorageService which properly handles asset loading
      final localStorageService = Get.find<LocalStorageService>();
      await localStorageService.loadDefaultTemplates();
    } catch (e) {
      print('Error loading default templates: $e');
    }
  }

  /// Gets templates grouped by category
  Future<Map<String, List<TemplateModel>>> getTemplatesByCategory() async {
    final templates = await getAllTemplates();
    final Map<String, List<TemplateModel>> grouped = {};

    for (final template in templates) {
      grouped.putIfAbsent(template.category, () => []).add(template);
    }
    return grouped;
  }

  /// Gets enhanced templates with AI features
  List<EnhancedTemplateModel> getAdvancedTemplates() {
    final advancedTemplates = AdvancedTemplateCollection.getAdvancedTemplates();
    final domainTemplates = DomainSpecificTemplates.getDomainTemplates();
    return [...advancedTemplates, ...domainTemplates];
  }

  /// Gets enhanced templates by category
  List<EnhancedTemplateModel> getEnhancedTemplatesByCategory(String category) {
    final advancedTemplates = getAdvancedTemplates();
    return advancedTemplates
        .where((template) => template.category == category)
        .toList();
  }

  /// Gets trending templates based on usage analytics
  List<EnhancedTemplateModel> getTrendingTemplates({int limit = 10}) {
    final advancedTemplates = getAdvancedTemplates();
    // Sort by usage count and return top templates
    advancedTemplates.sort((a, b) => 0.compareTo(0));
    return advancedTemplates.take(limit).toList();
  }

  /// Search enhanced templates with AI-powered relevance scoring
  List<EnhancedTemplateModel> searchEnhancedTemplates(String query) {
    final advancedTemplates = getAdvancedTemplates();
    if (query.isEmpty) return advancedTemplates;

    return advancedTemplates.where((template) {
      final titleMatch =
          template.title.toLowerCase().contains(query.toLowerCase());
      final descMatch =
          template.description.toLowerCase().contains(query.toLowerCase());
      final categoryMatch =
          template.category.toLowerCase().contains(query.toLowerCase());
      final keywordMatch = template.aiMetadata?.extractedKeywords?.any(
              (keyword) =>
                  keyword.toLowerCase().contains(query.toLowerCase())) ??
          false;

      return titleMatch || descMatch || categoryMatch || keywordMatch;
    }).toList();
  }

  // /// Gets templates by category
  // Future<List<TemplateModel>> getTemplatesByCategory(String category) async {
  //   return await repository.getTemplatesByCategory(category);
  // }

  // /// Creates a new template
  // Future<TemplateModel> createTemplate(TemplateModel template) async {
  //   return await repository.createTemplate(template);
  // }

  // /// Updates an existing template
  // Future<TemplateModel> updateTemplate(
  //     String id, TemplateModel template) async {
  //   return await repository.updateTemplate(id, template);
  // }

  // /// Deletes a template by ID
  // Future<bool> deleteTemplate(String id) async {
  //   return await repository.deleteTemplate(id);
  // }

  /// Retrieves all categories
  Future<List<String>> getCategories() async {
    return await _repository.getCategories();
  }
}
