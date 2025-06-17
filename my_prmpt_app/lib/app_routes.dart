// lib/app/routes/app_routes.dart
import 'package:get/get.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/wizard/prompt_wizard_page.dart';
import '../presentation/pages/editor/template_editor_page.dart';
import '../presentation/pages/editor/ai_assisted_editor_page.dart';
import '../presentation/pages/discovery/smart_discovery_page.dart';
import '../presentation/pages/viewer/result_viewer_page.dart';
import '../presentation/controllers/home_controller.dart';
import '../presentation/controllers/wizard_controller.dart';
import '../presentation/controllers/editor_controller.dart';
import '../presentation/controllers/ai_editor_controller.dart';
import '../presentation/controllers/discovery_controller.dart';

/// Application routes configuration
class AppRoutes {
  static const String home = '/home';
  static const String wizard = '/wizard';
  static const String editor = '/editor';
  static const String aiEditor = '/ai-editor';
  static const String discovery = '/discovery';
  static const String viewer = '/viewer';

  static List<GetPage> routes = [
    GetPage(
      name: home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: wizard,
      page: () => const PromptWizardPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WizardController>(() => WizardController());
      }),
    ),
    GetPage(
      name: editor,
      page: () => const TemplateEditorPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<EditorController>(() => EditorController());
      }),
    ),
    GetPage(
      name: viewer,
      page: () => const ResultViewerPage(),
    ),
    GetPage(
      name: aiEditor,
      page: () => const AIAssistedEditorPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AIEditorController>(() => AIEditorController());
      }),
    ),
    GetPage(
      name: discovery,
      page: () => const SmartDiscoveryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DiscoveryController>(() => DiscoveryController());
      }),
    ),
  ];
}
