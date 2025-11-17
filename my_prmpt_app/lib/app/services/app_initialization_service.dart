import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:promptcraft/data/models/template_model.dart';
import 'package:promptcraft/data/models/enhanced_template_model.dart';
import 'package:promptcraft/data/datasources/local_storage_service.dart';

/// Service responsible for initializing the application
/// Handles Hive setup, adapter registration, and initial data loading
class AppInitializationService {
  static const String _templatesBox = 'templates';
  static const String _settingsBox = 'app_settings';
  static const String _userDataBox = 'user_data';
  static const String _analyticsBox = 'analytics';
  static const String _favoritesBox = 'favorites';

  /// Initialize all app services and dependencies
  static Future<void> initialize() async {
    try {
      if (kDebugMode) {
        print('🚀 Starting app initialization...');
      }

      // Step 1: Initialize Hive with Flutter support
      await _initializeHive();

      // Step 2: Register Hive type adapters
      await _registerAdapters();

      // Step 3: Open all required Hive boxes
      await _openBoxes();

      // Step 4: Initialize local storage service
      await _initializeServices();

      // Step 5: Load initial data if needed
      await _loadInitialData();

      if (kDebugMode) {
        print('✅ App initialization complete');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ App initialization failed: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Initialize Hive database
  static Future<void> _initializeHive() async {
    try {
      await Hive.initFlutter();
      if (kDebugMode) {
        print('  ✓ Hive initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('  ✗ Hive initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Register Hive type adapters
  static Future<void> _registerAdapters() async {
    try {
      // Register TemplateModel adapter (typeId: 0)
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TemplateModelAdapter());
        if (kDebugMode) {
          print('  ✓ TemplateModel adapter registered');
        }
      }

      // Register EnhancedTemplateModel adapter (typeId: 1)
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(EnhancedTemplateModelAdapter());
        if (kDebugMode) {
          print('  ✓ EnhancedTemplateModel adapter registered');
        }
      }

      // TODO: Register additional adapters as needed
      // UserModel, Achievement, Badge, etc.
    } catch (e) {
      if (kDebugMode) {
        print('  ✗ Adapter registration failed: $e');
      }
      rethrow;
    }
  }

  /// Open all required Hive boxes
  static Future<void> _openBoxes() async {
    try {
      // Open templates box
      await Hive.openBox<TemplateModel>(_templatesBox);
      if (kDebugMode) {
        print('  ✓ Templates box opened');
      }

      // Open settings box
      await Hive.openBox(_settingsBox);
      if (kDebugMode) {
        print('  ✓ Settings box opened');
      }

      // Open user data box
      await Hive.openBox(_userDataBox);
      if (kDebugMode) {
        print('  ✓ User data box opened');
      }

      // Open analytics box
      await Hive.openBox(_analyticsBox);
      if (kDebugMode) {
        print('  ✓ Analytics box opened');
      }

      // Open favorites box
      await Hive.openBox(_favoritesBox);
      if (kDebugMode) {
        print('  ✓ Favorites box opened');
      }
    } catch (e) {
      if (kDebugMode) {
        print('  ✗ Box opening failed: $e');
      }
      rethrow;
    }
  }

  /// Initialize core services
  static Future<void> _initializeServices() async {
    try {
      final storageService = LocalStorageService();
      await storageService.init();

      if (kDebugMode) {
        print('  ✓ Local storage service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('  ✗ Service initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Load initial data if boxes are empty
  static Future<void> _loadInitialData() async {
    try {
      final templatesBox = Hive.box<TemplateModel>(_templatesBox);

      if (templatesBox.isEmpty) {
        if (kDebugMode) {
          print('  ℹ Templates box is empty - will load from repository');
        }
        // Templates will be loaded lazily by TemplateRepository
      } else {
        if (kDebugMode) {
          print('  ✓ Found ${templatesBox.length} cached templates');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('  ⚠ Initial data loading warning: $e');
      }
      // Non-critical error - continue initialization
    }
  }

  /// Clean up resources on app disposal
  static Future<void> dispose() async {
    try {
      await Hive.close();
      if (kDebugMode) {
        print('✅ App cleanup complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ App cleanup failed: $e');
      }
    }
  }

  /// Get initialization status for debugging
  static Map<String, dynamic> getStatus() {
    return {
      'hive_initialized': Hive.isBoxOpen(_templatesBox),
      'templates_count': Hive.isBoxOpen(_templatesBox)
          ? Hive.box<TemplateModel>(_templatesBox).length
          : 0,
      'boxes_open': [
        _templatesBox,
        _settingsBox,
        _userDataBox,
        _analyticsBox,
        _favoritesBox,
      ].where((box) => Hive.isBoxOpen(box)).toList(),
    };
  }
}
