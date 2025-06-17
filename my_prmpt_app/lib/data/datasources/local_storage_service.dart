// lib/data/datasources/local_storage_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/template_model.dart';

/// Service for local data persistence using Hive
class LocalStorageService {
  static const String _templatesBoxName = 'templates';

  /// Loads default templates from assets
  Future<void> loadDefaultTemplates() async {
    debugPrint('Starting to load default templates...');

    try {
      final templateFiles = [
        'assets/templates/creative_templates.json',
        'assets/templates/email_polisher.json',
        'assets/templates/flutter_app.json',
        'assets/templates/software_templates.json',
        'assets/templates/star_interview.json',
      ];

      int totalLoaded = 0;

      for (final assetPath in templateFiles) {
        try {
          debugPrint('Loading templates from: $assetPath');

          // Load the JSON string from assets
          final jsonString = await rootBundle.loadString(assetPath);
          debugPrint('Successfully loaded JSON string from $assetPath');

          // Parse JSON
          final dynamic jsonData = json.decode(jsonString);

          // Handle both single template and array of templates
          List<dynamic> templatesList;
          if (jsonData is List) {
            templatesList = jsonData;
          } else if (jsonData is Map<String, dynamic>) {
            templatesList = [jsonData];
          } else {
            debugPrint('Invalid JSON format in $assetPath');
            continue;
          }

          debugPrint('Found ${templatesList.length} templates in $assetPath');

          // Process each template
          for (int i = 0; i < templatesList.length; i++) {
            try {
              final templateJson = templatesList[i];
              debugPrint(
                  'Processing template ${i + 1}/${templatesList.length}: ${templateJson['title'] ?? 'Unknown'}');

              final template =
                  TemplateModel.fromJson(templateJson as Map<String, dynamic>);
              await saveTemplate(template);
              totalLoaded++;

              debugPrint('Successfully saved template: ${template.title}');
            } catch (e, stackTrace) {
              debugPrint(
                  'Failed to process template ${i + 1} in $assetPath: $e');
              debugPrint('Stack trace: $stackTrace');
            }
          }
        } catch (e, stackTrace) {
          debugPrint('Failed to load $assetPath: $e');
          debugPrint('Stack trace: $stackTrace');

          // If it's an asset not found error, provide helpful message
          if (e.toString().contains('Unable to load asset')) {
            debugPrint('Asset file not found: $assetPath');
            debugPrint(
                'Make sure the file exists and is listed in pubspec.yaml under assets');
          }
        }
      }

      debugPrint(
          'Template loading completed. Total templates loaded: $totalLoaded');
    } catch (e, stackTrace) {
      debugPrint('Error loading default templates: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Gets the templates box
  Box<TemplateModel> get _templatesBox =>
      Hive.box<TemplateModel>(_templatesBoxName);

  /// Retrieves all templates
  Future<List<TemplateModel>> getAllTemplates() async {
    try {
      final templates = _templatesBox.values.toList();
      debugPrint('Retrieved ${templates.length} templates from storage');
      return templates;
    } catch (e) {
      debugPrint('Error retrieving templates: $e');
      return [];
    }
  }

  /// Gets a template by ID
  Future<TemplateModel?> getTemplateById(String id) async {
    try {
      return _templatesBox.get(id);
    } catch (e) {
      debugPrint('Error getting template by ID $id: $e');
      return null;
    }
  }

  /// Saves a template
  Future<void> saveTemplate(TemplateModel template) async {
    try {
      await _templatesBox.put(template.id, template);
      debugPrint('Saved template: ${template.title} (ID: ${template.id})');
    } catch (e) {
      debugPrint('Error saving template ${template.title}: $e');
      rethrow;
    }
  }

  /// Deletes a template
  Future<void> deleteTemplate(String id) async {
    try {
      await _templatesBox.delete(id);
      debugPrint('Deleted template with ID: $id');
    } catch (e) {
      debugPrint('Error deleting template $id: $e');
      rethrow;
    }
  }

  /// Clears all templates
  Future<void> clearAllTemplates() async {
    try {
      await _templatesBox.clear();
      debugPrint('Cleared all templates');
    } catch (e) {
      debugPrint('Error clearing templates: $e');
      rethrow;
    }
  }

  /// Check if templates are loaded
  bool get hasTemplates => _templatesBox.isNotEmpty;

  /// Get template count
  int get templateCount => _templatesBox.length;

  /// Force reload templates (for testing/debugging)
  Future<void> forceReloadTemplates() async {
    debugPrint('Force reloading templates...');
    await clearAllTemplates();
    await loadDefaultTemplates();
  }
}
