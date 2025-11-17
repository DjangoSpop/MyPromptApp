// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// App imports
import 'app/routes/app_routes.dart';
import 'app/bindings/app_bindings.dart';
import 'app/themes/discord_design_system.dart';
import 'app/services/app_initialization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app services (Hive, adapters, boxes)
  await AppInitializationService.initialize();

  runApp(const PromptCraftApp());
}

class PromptCraftApp extends StatelessWidget {
  const PromptCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PromptCraft - AI Prompt Engineering Platform',

      // Theme
      theme: DiscordDesignSystem.lightTheme,
      darkTheme: DiscordDesignSystem.darkTheme,
      themeMode: ThemeMode.dark,

      // Dependency Injection
      initialBinding: AppBindings(),

      // Routing
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,

      // Debug & Transitions
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 250),

      // Error handling
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => Scaffold(
          backgroundColor: DiscordDesignSystem.backgroundPrimary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: DiscordDesignSystem.red,
                ),
                const SizedBox(height: 16),
                Text(
                  '404 - Page Not Found',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: DiscordDesignSystem.textNormal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The page you\'re looking for doesn\'t exist.',
                  style: TextStyle(
                    fontSize: 14,
                    color: DiscordDesignSystem.textMuted,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  icon: const Icon(Icons.home),
                  label: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
