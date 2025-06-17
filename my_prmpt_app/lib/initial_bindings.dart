// lib/app/bindings/initial_bindings.dart
import 'package:get/get.dart';
import '../data/datasources/local_storage_service.dart';
import '../data/repositories/template_repository_impl.dart';
import '../domain/repositories/template_repository.dart';
import '../domain/services/template_service.dart';
import '../domain/services/prompt_builder.dart';
import '../domain/services/ai_context_engine.dart';
import '../domain/services/template_analytics_service.dart';

/// Initial dependency injection bindings for app startup
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Data layer
    Get.put<LocalStorageService>(LocalStorageService(), permanent: true);

    // Repository layer
    Get.put<TemplateRepository>(
      TemplateRepositoryImpl(Get.find<LocalStorageService>()),
      permanent: true,
    );

    // Service layer
    Get.put<TemplateService>(
      TemplateService(Get.find<TemplateRepository>()),
      permanent: true,
    );

    Get.put<PromptBuilder>(PromptBuilder(), permanent: true);

    // AI Services
    Get.put<AIContextEngine>(AIContextEngine(), permanent: true);
    Get.put<TemplateAnalyticsService>(TemplateAnalyticsService(),
        permanent: true);
  }
}
