import 'package:get/get.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/wizard/prompt_wizard_page.dart';
import '../../presentation/pages/editor/template_editor_page.dart';
import '../../presentation/pages/viewer/result_viewer_page.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/wizard_controller.dart';
import '../../presentation/controllers/editor_controller.dart';

/// Application routes configuration
class AppRoutes {
  static const String home = '/home';
  static const String wizard = '/wizard';
  static const String editor = '/editor';
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
  ];
}
