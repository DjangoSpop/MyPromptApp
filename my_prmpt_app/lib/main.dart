// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/routes/app_routes.dart';
import 'core/bindings/app_bindings.dart';
// Core imports
import 'core/bindings/initial_bindings.dart';
import 'core/design_system/discord_design_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize core services and controllers
  //aproching this for the application
  await _initializeServices();

  runApp(const PromptCraftApp());
}

/// Initialize all services and dependencies
Future<void> _initializeServices() async {
  try {
    // Initialize bindings which will setup all dependencies
    final bindings = InitialBindings();
    await bindings.initializeAsync();

    print('Services initialized successfully');
  } catch (e) {
    print('Service initialization error: $e');
  }
}

class PromptCraftApp extends StatelessWidget {
  const PromptCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PromptTemple - AI Prompt Management System',
      theme: DiscordDesignSystem.darkTheme,
      darkTheme: DiscordDesignSystem.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: '/mobile',
      getPages: AppRoutes.routes,
      initialBinding: AppBindings(),
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
      // Error handling for routing
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(
          body: Center(
            child: Text(
              'Page not found',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
