// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/themes/app_themes.dart';
import 'app/routes/app_routes.dart';
import 'app/bindings/initial_bindings.dart';
import 'data/models/template_model.dart';
import 'data/models/prompt_field.dart';
import 'data/datasources/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TemplateModelAdapter());
  Hive.registerAdapter(PromptFieldAdapter());
  Hive.registerAdapter(FieldTypeAdapter());

  // Open boxes
  await Hive.openBox<TemplateModel>('templates');

  // Initialize templates on first run
  await _initializeTemplates();

  runApp(const PromptForgeApp());
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

class PromptForgeApp extends StatelessWidget {
  const PromptForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Prompt Forge',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/home',
      getPages: AppRoutes.routes,
      initialBinding: InitialBindings(),
      debugShowCheckedModeBanner: false,
    );
  }
}
