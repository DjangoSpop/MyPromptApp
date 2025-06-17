import '../../domain/repositories/template_repository.dart';
import '../models/template_model.dart';
import '../datasources/local_storage_service.dart';

/// Implementation of TemplateRepository using local storage
class TemplateRepositoryImpl implements TemplateRepository {
  final LocalStorageService _localStorageService;

  TemplateRepositoryImpl(this._localStorageService);

  @override
  Future<List<TemplateModel>> getAllTemplates() async {
    return await _localStorageService.getAllTemplates();
  }

  @override
  Future<TemplateModel?> getTemplateById(String id) async {
    return await _localStorageService.getTemplateById(id);
  }

  @override
  Future<void> saveTemplate(TemplateModel template) async {
    await _localStorageService.saveTemplate(template);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _localStorageService.deleteTemplate(id);
  }
}
