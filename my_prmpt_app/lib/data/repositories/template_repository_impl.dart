import '../../domain/models/template_model.dart' as domain;
import '../../domain/repositories/template_repository.dart';
import '../models/template_model.dart' as data;
import '../providers/api_client.dart';
import '../providers/local_storage.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final ApiClient apiClient;
  final LocalStorage localStorage;

  TemplateRepositoryImpl({
    required this.apiClient,
    required this.localStorage,
  });

  @override
  Future<List<domain.TemplateModel>> getAllTemplates() async {
    try {
      final List<dynamic> response = await apiClient.get('templates');
      return response
          .map((jsonData) =>
              _convertToDomainModel(data.TemplateModel.fromJson(jsonData)))
          .toList();
    } catch (e) {
      // Fallback to cached templates
      final cachedTemplates = await localStorage.getTemplates();
      if (cachedTemplates != null) {
        return (cachedTemplates as List<dynamic>)
            .map((jsonData) =>
                _convertToDomainModel(data.TemplateModel.fromJson(jsonData)))
            .toList();
      }
      throw Exception('Failed to get templates: ${e.toString()}');
    }
  }

  @override
  Future<domain.TemplateModel?> getTemplateById(String id) async {
    try {
      final response = await apiClient.get('templates/$id');
      return _convertToDomainModel(data.TemplateModel.fromJson(response));
    } catch (e) {
      // Check local cache for this specific template
      final cachedTemplates = await localStorage.getTemplates();
      if (cachedTemplates != null) {
        final templateData = (cachedTemplates as List<dynamic>).firstWhere(
          (t) => t['id'] == id,
          orElse: () => null,
        );
        if (templateData != null) {
          return _convertToDomainModel(
              data.TemplateModel.fromJson(templateData));
        }
      }
      return null;
    }
  }

  @override
  Future<void> saveTemplate(domain.TemplateModel template) async {
    try {
      final dataTemplate = _convertToDataModel(template);
      await apiClient.post('templates', dataTemplate.toJson());
      // Also save to local cache
      final cachedTemplates = await localStorage.getTemplates() ?? [];
      final updatedTemplates = List<dynamic>.from(cachedTemplates);

      // Update existing or add new
      final existingIndex =
          updatedTemplates.indexWhere((t) => t['id'] == template.id);
      if (existingIndex != -1) {
        updatedTemplates[existingIndex] = dataTemplate.toJson();
      } else {
        updatedTemplates.add(dataTemplate.toJson());
      }

      await localStorage.saveTemplates(updatedTemplates);
    } catch (e) {
      throw Exception('Failed to save template: ${e.toString()}');
    }
  }

  Future<void> deleteTemplateFromCache(String id) async {
    try {
      await apiClient.delete('templates/$id');
      // Also remove from local cache
      final cachedTemplates = await localStorage.getTemplates() ?? [];
      final updatedTemplates = List<dynamic>.from(cachedTemplates)
        ..removeWhere((t) => t['id'] == id);
      await localStorage.saveTemplates(updatedTemplates);
    } catch (e) {
      throw Exception('Failed to delete template: ${e.toString()}');
    }
  }

  Future<List<domain.TemplateModel>> getTemplatesByCategory(
      String category) async {
    try {
      final List<dynamic> response =
          await apiClient.get('templates/category/$category');
      return response
          .map((jsonData) =>
              _convertToDomainModel(data.TemplateModel.fromJson(jsonData)))
          .toList();
    } catch (e) {
      // Filter cached templates by category
      final cachedTemplates = await localStorage.getTemplates();
      if (cachedTemplates != null) {
        return (cachedTemplates as List<dynamic>)
            .where((t) => t['category'] == category)
            .map((jsonData) =>
                _convertToDomainModel(data.TemplateModel.fromJson(jsonData)))
            .toList();
      }
      throw Exception('Failed to get templates by category: ${e.toString()}');
    }
  }

  Future<domain.TemplateModel> createTemplate(
      domain.TemplateModel template) async {
    try {
      final dataTemplate = _convertToDataModel(template);
      final response = await apiClient.post('templates', dataTemplate.toJson());
      final newTemplate =
          _convertToDomainModel(data.TemplateModel.fromJson(response));

      // Update local cache
      await _addTemplateToLocalCache(_convertToDataModel(newTemplate));

      return newTemplate;
    } catch (e) {
      throw Exception('Failed to create template: ${e.toString()}');
    }
  }

  Future<domain.TemplateModel> updateTemplate(
      String id, domain.TemplateModel template) async {
    try {
      final dataTemplate = _convertToDataModel(template);
      final response =
          await apiClient.put('templates/$id', dataTemplate.toJson());
      final updatedTemplate =
          _convertToDomainModel(data.TemplateModel.fromJson(response));

      // Update local cache
      await _updateTemplateInLocalCache(_convertToDataModel(updatedTemplate));

      return updatedTemplate;
    } catch (e) {
      throw Exception('Failed to update template: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTemplate(String id) async {
    try {
      await apiClient.delete('templates/$id');

      // Update local cache
      await _removeTemplateFromLocalCache(id);
    } catch (e) {
      throw Exception('Failed to delete template: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getCategories() async {
    try {
      final List<dynamic> response =
          await apiClient.get('templates/categories');
      return response.map((category) => category as String).toList();
    } catch (e) {
      // Extract categories from cached templates
      final cachedTemplates = await localStorage.getTemplates();
      if (cachedTemplates != null) {
        final categories = (cachedTemplates as List<dynamic>)
            .map((t) => t['category'] as String)
            .toSet()
            .toList();
        return categories;
      }
      throw Exception('Failed to get categories: ${e.toString()}');
    }
  }

  // Helper methods for local cache management
  Future<void> _addTemplateToLocalCache(data.TemplateModel template) async {
    final cachedTemplates = await localStorage.getTemplates() ?? [];
    cachedTemplates.add(template.toJson());
    await localStorage.saveTemplates(cachedTemplates);
  }

  Future<void> _updateTemplateInLocalCache(data.TemplateModel template) async {
    final cachedTemplates = await localStorage.getTemplates();
    if (cachedTemplates != null) {
      final index = (cachedTemplates as List<dynamic>)
          .indexWhere((t) => t['id'] == template.id);

      if (index >= 0) {
        cachedTemplates[index] = template.toJson();
        await localStorage.saveTemplates(cachedTemplates);
      }
    }
  }

  Future<void> _removeTemplateFromLocalCache(String id) async {
    final cachedTemplates = await localStorage.getTemplates();
    if (cachedTemplates != null) {
      final filtered = (cachedTemplates as List<dynamic>)
          .where((t) => t['id'] != id)
          .toList();
      await localStorage.saveTemplates(filtered);
    }
  }

  // Helper methods to convert between domain and data models
  domain.TemplateModel _convertToDomainModel(data.TemplateModel dataModel) {
    return domain.TemplateModel(
      id: dataModel.id,
      title: dataModel.title,
      description: dataModel.description,
      category: dataModel.category,
      content: dataModel.templateContent,
      tags: dataModel.tags ?? [],
      createdBy: dataModel.author ?? '',
      createdAt: dataModel.createdAt,
      updatedAt: dataModel.updatedAt,
      usageCount: 0, // Default value
      rating: 0.0, // Default value
      isPublic: false, // Default value
    );
  }

  data.TemplateModel _convertToDataModel(domain.TemplateModel domainModel) {
    return data.TemplateModel(
      id: domainModel.id,
      title: domainModel.title,
      description: domainModel.description,
      category: domainModel.category,
      templateContent: domainModel.content,
      fields: [], // Default empty fields for now
      createdAt: domainModel.createdAt,
      updatedAt: domainModel.updatedAt ?? DateTime.now(),
      author: domainModel.createdBy,
      version: '1.0.0',
      tags: domainModel.tags,
    );
  }
}
