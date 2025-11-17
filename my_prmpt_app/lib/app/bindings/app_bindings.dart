import 'package:get/get.dart';
import 'package:promptcraft/data/datasources/local_storage_service.dart';
import 'package:promptcraft/data/repositories/template_repository_impl.dart';
import 'package:promptcraft/domain/repositories/template_repository.dart';
import 'package:promptcraft/domain/services/template_service.dart';
import 'package:promptcraft/domain/services/ai_context_engine.dart';
import 'package:promptcraft/domain/services/template_analytics_service.dart';
import 'package:promptcraft/data/services/auth_service.dart';

/// Global application bindings
/// Initializes all core services and dependencies using GetX dependency injection
class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Core Services (Singleton - Created once and reused)
    Get.lazyPut<LocalStorageService>(
      () => LocalStorageService(),
      fenix: true, // Keep in memory even after all controllers are disposed
    );

    // Authentication Service
    Get.lazyPut<AuthService>(
      () => AuthService(),
      fenix: true,
    );

    // Repositories (Singleton)
    Get.lazyPut<TemplateRepository>(
      () => TemplateRepositoryImpl(
        localStorageService: Get.find<LocalStorageService>(),
      ),
      fenix: true,
    );

    // Domain Services (Singleton)
    Get.lazyPut<AIContextEngine>(
      () => AIContextEngine(),
      fenix: true,
    );

    Get.lazyPut<TemplateAnalyticsService>(
      () => TemplateAnalyticsService(),
      fenix: true,
    );

    Get.lazyPut<TemplateService>(
      () => TemplateService(
        repository: Get.find<TemplateRepository>(),
        aiEngine: Get.find<AIContextEngine>(),
        analytics: Get.find<TemplateAnalyticsService>(),
      ),
      fenix: true,
    );
  }
}
