import 'package:get/get.dart';
import 'package:my_prmpt_app/presentation/controllers/discovery_controller.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/home/gamified_home_page.dart';
import '../../presentation/pages/wizard/prompt_wizard_page.dart';
import '../../presentation/pages/wizard/enhanced_wizard_page.dart';
import '../../presentation/pages/editor/template_editor_page.dart';
import '../../presentation/pages/editor/ai_assisted_editor_page.dart';
import '../../presentation/pages/viewer/result_viewer_page.dart';
import '../../presentation/pages/viewer/learning_hub_view.dart';
import '../../presentation/pages/templates/template_list_page.dart';
import '../../presentation/pages/discovery/smart_discovery_page.dart';
import '../../presentation/pages/auth/discord_login_page.dart';
import '../../presentation/pages/auth/discord_register_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/profile/discord_profile_page.dart';
import '../../presentation/pages/settings/discord_settings_page.dart';
import '../../presentation/mobile/enhanced_mobile_interface.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/wizard_controller.dart';
import '../../presentation/controllers/editor_controller.dart';
import '../../presentation/controllers/ai_editor_controller.dart';
import '../../presentation/controllers/auth_controller.dart';

/// Application routes configuration
class AppRoutes {
  // Main navigation routes
  static const String home = '/home';
  static const String gamifiedHome = '/gamified-home';
  static const String discovery = '/discovery';
  static const String templates = '/templates';
  static const String profile = '/profile';

  // Feature routes
  static const String wizard = '/wizard';
  static const String enhancedWizard = '/enhanced-wizard';
  static const String editor = '/editor';
  static const String aiEditor = '/ai-editor';
  static const String viewer = '/viewer';
  static const String learningHub = '/learning-hub';

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String discordLogin = '/discord-login';
  static const String discordRegister = '/discord-register';

  // Settings routes
  static const String settings = '/settings';

  // Main app interface
  static const String mobileInterface = '/mobile';
  static List<GetPage> routes = [
    // Main Navigation Routes
    GetPage(
      name: mobileInterface,
      page: () => const EnhancedMobileInterface(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: gamifiedHome,
      page: () => const GamifiedHomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
    GetPage(
      name: discovery,
      page: () => const SmartDiscoveryPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DiscoveryController>(() => DiscoveryController());
      }),
    ),
    GetPage(
      name: templates,
      page: () => const TemplateListPage(),
    ),

    // Feature Routes
    GetPage(
      name: wizard,
      page: () => const PromptWizardPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<WizardController>(() => WizardController());
      }),
    ),
    GetPage(
      name: enhancedWizard,
      page: () => const EnhancedWizardPage(),
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
      name: aiEditor,
      page: () => const AIAssistedEditorPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AIEditorController>(() => AIEditorController());
      }),
    ),
    GetPage(
      name: viewer,
      page: () => const ResultViewerPage(),
    ),
    GetPage(
      name: learningHub,
      page: () => LearningHubView(),
    ),

    // Auth Routes
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: discordLogin,
      page: () => const DiscordLoginPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: discordRegister,
      page: () => const DiscordRegisterPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),

    // Profile & Settings
    GetPage(
      name: profile,
      page: () => const DiscordProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: settings,
      page: () => const DiscordSettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
  ];
}
