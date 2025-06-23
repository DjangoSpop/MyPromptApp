// lib/app/bindings/initial_bindings.dart
import 'package:get/get.dart';

import '../data/datasources/local_storage_service.dart';
import '../data/repositories/template_repository_impl.dart';
import '../data/services/auth_service.dart';
import '../data/services/hybrid_template_service.dart';
import '../data/services/template_api_service.dart';
import '../domain/repositories/template_repository.dart';
import '../domain/services/ads_service.dart';
import '../domain/services/ai_context_engine.dart';
import '../domain/services/prompt_builder.dart';
import '../domain/services/template_analytics_service.dart';
import '../domain/services/template_service.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/template_controller.dart';

/// Initial dependency injection bindings for app startup
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core network layer
    // Get.put<ApiClient>(ApiClient(), permanent: true);

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

    // API Services
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<TemplateApiService>(TemplateApiService(), permanent: true);

    // Hybrid service for online/offline template management
    Get.put<HybridTemplateService>(HybridTemplateService(), permanent: true);

    // Controllers
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<TemplateController>(TemplateController(), permanent: true);

    // Gamification and Ads
    Get.put<AdsService>(AdsService(), permanent: true);
  }
}
