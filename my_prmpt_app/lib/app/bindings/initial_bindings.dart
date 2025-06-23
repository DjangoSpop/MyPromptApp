import 'package:get/get.dart';
import 'package:my_prmpt_app/data/services/hybrid_template_service.dart';
import 'package:my_prmpt_app/domain/services/ads_service.dart';
import 'package:my_prmpt_app/domain/services/ai_context_engine.dart';
import 'package:my_prmpt_app/domain/services/template_analytics_service.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../data/repositories/template_repository_impl.dart';
import '../../domain/repositories/template_repository.dart';
import '../../domain/services/template_service.dart';
import '../../domain/services/prompt_builder.dart';
import '../../domain/services/gamification_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../../presentation/controllers/navigation_controller.dart';
import '../../presentation/controllers/template_controller.dart';
import '../../presentation/controllers/home_controller.dart';
// import '../../domain/services/ads_service.dart'; // Disabled for now

/// Initial dependency injection bindings
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
    Get.put<AIContextEngine>(
      AIContextEngine(),
      permanent: true,
    );
    Get.put<TemplateAnalyticsService>(
      TemplateAnalyticsService(),
      permanent: true,
    );
    Get.put<PromptBuilder>(PromptBuilder(),
        permanent: true); // Gamification services
    Get.put<GamificationService>(GamificationService(), permanent: true);
    // API and Authentication services
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true); // Controller layer
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<NavigationController>(NavigationController(), permanent: true);
    Get.put<TemplateController>(TemplateController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
    // AdsService disabled for now - uncomment when google_mobile_ads is enabled
    Get.put<AdsService>(AdsService(), permanent: true);
    Get.put<HybridTemplateService>(HybridTemplateService(), permanent: true);
  }
}
