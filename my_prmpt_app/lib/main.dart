// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/routes/app_routes.dart';
import 'app/bindings/initial_bindings.dart';
import 'data/models/template_model.dart';
import 'data/models/prompt_field.dart';
import 'data/models/user_models.dart';
import 'domain/services/gamification_service.dart';
import 'data/datasources/local_storage_service.dart';
import 'core/design_system/discord_design_system.dart';
import 'data/managers/advanced_template_manager.dart';
import 'presentation/mobile/enhanced_mobile_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  // Register adapters
  Hive.registerAdapter(TemplateModelAdapter());
  Hive.registerAdapter(PromptFieldAdapter());
  Hive.registerAdapter(FieldTypeAdapter());

  // Register user model adapters
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(UserProfileAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(UserStatsAdapter());
  }

  // Register gamification adapters
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(AchievementAdapter());
  }

  // Open boxes
  await Hive.openBox<TemplateModel>('templates');

  // Initialize templates on first run
  await _initializeTemplates();

  // Initialize advanced template manager
  final advancedTemplateManager = AdvancedTemplateManager();
  advancedTemplateManager.initializeTemplates();

  runApp(const PromptForgeUltimateApp());
}

/// Initialize default templates if the box is empty or has fewer than expected
Future<void> _initializeTemplates() async {
  try {
    final templatesBox = Hive.box<TemplateModel>('templates');
    const expectedTemplateCount = 5; // We have 5 JSON template files

    // Check if templates need to be loaded
    if (templatesBox.isEmpty || templatesBox.length < expectedTemplateCount) {
      debugPrint(
          'Templates box has ${templatesBox.length} templates, expected $expectedTemplateCount. Loading default templates...');

      // Clear existing templates to avoid duplicates
      await templatesBox.clear();

      // Create LocalStorageService instance and load templates
      final localStorageService = LocalStorageService();
      await localStorageService.loadDefaultTemplates();

      debugPrint(
          'Successfully loaded ${templatesBox.length} default templates');
    } else {
      debugPrint(
          'Templates already loaded: ${templatesBox.length} templates found');
    }
  } catch (e) {
    debugPrint('Error initializing templates: $e');
    // App should still run even if template loading fails
  }
}

class PromptForgeUltimateApp extends StatelessWidget {
  const PromptForgeUltimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Prompt Forge Ultimate',
      theme: DiscordDesignSystem.darkTheme,
      darkTheme: DiscordDesignSystem.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/mobile', // Start with enhanced mobile interface
      getPages: [
        ...AppRoutes.routes,
        GetPage(
          name: '/discord',
          page: () => const PromptForgeHomePage(),
        ),
        GetPage(
          name: '/mobile',
          page: () => const EnhancedMobileInterface(),
        ),
      ],
      initialBinding: InitialBindings(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}

class PromptForgeHomePage extends StatefulWidget {
  const PromptForgeHomePage({super.key});

  @override
  State<PromptForgeHomePage> createState() => _PromptForgeHomePageState();
}

class _PromptForgeHomePageState extends State<PromptForgeHomePage>
    with TickerProviderStateMixin {
  late AnimationController _splashController;
  late Animation<double> _fadeAnimation;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeSplashAnimation();
    _showSplashScreen();
  }

  void _initializeSplashAnimation() {
    _splashController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _splashController,
      curve: Curves.easeInOut,
    ));
  }

  void _showSplashScreen() {
    _splashController.forward();
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return _buildSplashScreen();
    }

    return const EnhancedMobileInterface();
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: DiscordDesignSystem.darkGrey,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DiscordDesignSystem.darkGrey,
                  DiscordDesignSystem.darkButNotBlack,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: _fadeAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            DiscordDesignSystem.blurple,
                            DiscordDesignSystem.fuchsia,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: DiscordDesignSystem.blurple.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Opacity(
                    opacity: _fadeAnimation.value,
                    child: const Column(
                      children: [
                        Text(
                          'Prompt Forge',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'Ultimate',
                          style: TextStyle(
                            color: DiscordDesignSystem.blurple,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Advanced Prompt Engineering Platform',
                          style: TextStyle(
                            color: DiscordDesignSystem.greyple,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Opacity(
                    opacity: _fadeAnimation.value * 0.7,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          DiscordDesignSystem.blurple.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Opacity(
                    opacity: _fadeAnimation.value * 0.8,
                    child: const Text(
                      'Loading advanced templates...',
                      style: TextStyle(
                        color: DiscordDesignSystem.greyple,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }
}
