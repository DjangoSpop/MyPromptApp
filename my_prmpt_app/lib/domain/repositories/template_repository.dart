// lib/domain/repositories/template_repository.dart
import '../../data/models/template_model.dart';

/// Repository interface for template operations
abstract class TemplateRepository {
  /// Retrieves all templates from storage
  Future<List<TemplateModel>> getAllTemplates();

  /// Gets a specific template by ID
  Future<TemplateModel?> getTemplateById(String id);

  /// Saves a template to storage
  Future<void> saveTemplate(TemplateModel template);

  /// Deletes a template by ID
  Future<void> deleteTemplate(String id);
}