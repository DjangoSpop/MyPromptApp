import 'package:get/get.dart';
import 'package:my_prmpt_app/domain/services/ai_context_engine.dart';
import 'package:my_prmpt_app/domain/services/template_analytics_service.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../data/repositories/template_repository_impl.dart';
import '../../domain/repositories/template_repository.dart';
import '../../domain/services/template_service.dart';
import '../../domain/services/prompt_builder.dart';

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
    Get.put<PromptBuilder>(PromptBuilder(), permanent: true);
  }
}
