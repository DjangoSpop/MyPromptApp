import 'package:get/get.dart';
import '../../domain/services/learning_service.dart';
import '../../presentation/controllers/discovery_controller.dart';
import '../../presentation/controllers/learning_controller.dart';
import '../../presentation/controllers/optimized_template_controller.dart';
import '../../presentation/controllers/gamified_home_controller.dart';
import '../../data/services/promptcraft_api_service.dart';

import '../../app/middleware/auth_middleware.dart';
import '../../core/bindings/app_bindings.dart';
import '../../domain/services/gamification_service.dart';
import '../../presentation/controllers/ai_editor_controller.dart';
import '../../presentation/controllers/editor_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../presentation/controllers/fixed_wizard_controller.dart';
import '../../presentation/mobile/enhanced_mobile_interface.dart';
import '../../presentation/pages/auth/discord_login_page.dart';
import '../../presentation/pages/auth/discord_register_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/discovery/smart_discovery_page.dart';
import '../../presentation/pages/editor/ai_assisted_editor_page_new.dart';
import '../../presentation/pages/editor/template_editor_page.dart';
import '../../presentation/pages/favorites/favorites_page.dart';
import '../../presentation/pages/help/help_center_page.dart';
import '../../presentation/pages/history/history_page.dart';
import '../../presentation/pages/home/gamified_home_page.dart';
import '../../presentation/pages/home/enhanced_gamified_home_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/profile/discord_profile_page.dart';
import '../../presentation/pages/settings/discord_settings_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/templates/template_list_page.dart';
import '../../presentation/pages/testing/django_connection_test_page.dart';
import '../../presentation/pages/viewer/learning_hub_view.dart';
import '../../presentation/pages/viewer/result_viewer_page.dart';
import '../../presentation/pages/wizard/enhanced_wizard_page.dart';
import '../../presentation/pages/wizard/prompt_wizard_page.dart';
import '../../presentation/pages/splash/splash_screen.dart';

/// Application routes configuration
class AppRoutes {
  // Main navigation routes
  static const String splash = '/splash';
  static const String home = '/home';
  static const String gamifiedHome = '/gamified-home';
  static const String enhancedGamifiedHome = '/enhanced-gamified-home';
  static const String discovery = '/discovery';
  static const String templates = '/templates';
  static const String favorites = '/favorites';
  static const String history = '/history';
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
  static const String help = '/help';
  static const String dashboard = '/dashboard';

  // Testing routes
  static const String djangoTest = '/django-test';

  // Main app interface
  static const String mobileInterface = '/mobile';
  static List<GetPage> routes = [
    // Splash Screen
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: AppBindings(),
    ),
    
    // Main Navigation Routes
    GetPage(
      name: mobileInterface,
      page: () => const EnhancedMobileInterface(),
      binding: AppBindings(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      binding: HomeBindings(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: gamifiedHome,
      page: () => const GamifiedHomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
        Get.lazyPut<GamificationService>(() => GamificationService());
      }),
    ),
    GetPage(
      name: enhancedGamifiedHome,
      page: () => const EnhancedGamifiedHomePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => Get.find<GamificationService>());
        Get.lazyPut(() => Get.find<PromptCraftApiService>());
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
      binding: BindingsBuilder(() {
        Get.lazyPut<OptimizedTemplateController>(
            () => OptimizedTemplateController());
      }),
    ),
    GetPage(
      name: favorites,
      page: () => const FavoritesPage(),
    ),
    GetPage(
      name: history,
      page: () => const HistoryPage(),
    ),

    // Feature Routes
    GetPage(
      name: wizard,
      page: () => const PromptWizardPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FixedWizardController>(() => FixedWizardController());
      }),
    ),
    GetPage(
      name: enhancedWizard,
      page: () => const EnhancedWizardPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<FixedWizardController>(() => FixedWizardController());
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
      page: () => const AINewAssistedEditorPage(),
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
      binding: BindingsBuilder(() {
        Get.lazyPut<LearningService>(() => LearningService());
        Get.lazyPut<LearningController>(() => LearningController());
      }),
    ),

    // Auth Routes
    GetPage(
      name: login,
      page: () => const LoginPage(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterPage(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: discordLogin,
      page: () => const DiscordLoginPage(),
      binding: AuthBindings(),
    ),
    GetPage(
      name: discordRegister,
      page: () => const DiscordRegisterPage(),
      binding: AuthBindings(),
    ),

    // Profile & Settings (protected routes)
    GetPage(
      name: profile,
      page: () => const DiscordProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DiscoveryController());
      }),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DiscoveryController());
      }),
      middlewares: [AuthMiddleware()],
    ),

    // Help & Support Routes
    GetPage(
      name: help,
      page: () => const HelpCenterPage(),
    ),

    // Dashboard Route
    GetPage(
      name: dashboard,
      page: () => const DashboardPage(),
      middlewares: [AuthMiddleware()],
    ),

    // Testing Routes
    GetPage(
      name: djangoTest,
      page: () => const DjangoConnectionTestPage(),
    ),
  ];
}
