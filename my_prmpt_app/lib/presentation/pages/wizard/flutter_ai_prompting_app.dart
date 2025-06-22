import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controllers/prompt_controller.dart';
import '../controllers/learning_controller.dart';
import '../models/prompt_model.dart';
import 'widgets/prompt_card.dart';
import 'widgets/search_bar.dart';
import 'widgets/category_chips.dart';
import 'widgets/stats_dashboard.dart';
import 'learning_hub_view.dart';

class HomeView extends StatelessWidget {
  final PromptController controller = Get.find<PromptController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('AI Prompt Engineering Hub'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.school),
            onPressed: () => Get.to(() => LearningHubView()),
            tooltip: 'Learning Hub - Master 7 Core Benefits',
          ),
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () => Get.to(() => StatsDashboard()),
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => _showFavorites(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Benefits Banner
          _buildBenefitsBanner(),
          
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                CustomSearchBar(),
                SizedBox(height: 12),
                CategoryChips(),
                SizedBox(height: 12),
                _buildSortOptions(),
              ],
            ),
          ),
          
          // Prompts Grid
          Expanded(
            child: Obx(() {// pubspec.yaml dependencies
/*
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  dio: ^5.3.2
  cached_network_image: ^3.3.0
  flutter_staggered_grid_view: ^0.6.2
  share_plus: ^7.2.1
  url_launcher: ^6.2.1
  flutter_animate: ^4.3.0
  google_fonts: ^6.1.0
  flutter_rating_bar: ^4.0.1
  flutter_typeahead: ^4.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
*/

// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'controllers/prompt_controller.dart';
import 'models/prompt_model.dart';
import 'views/home_view.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(PromptModelAdapter());
  await Hive.openBox<PromptModel>('prompts');
  await Hive.openBox('settings');
  await Hive.openBox('favorites');
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AI Prompt Engineering Hub',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: HomeView(),
      initialBinding: InitialBinding(),
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PromptController(), permanent: true);
  }
}

// models/prompt_model.dart
import 'package:hive/hive.dart';

part 'prompt_model.g.dart';

@HiveType(typeId: 0)
class PromptModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String template;

  @HiveField(4)
  String category;

  @HiveField(5)
  List<String> tags;

  @HiveField(6)
  double rating;

  @HiveField(7)
  int usageCount;

  @HiveField(8)
  String author;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  bool isPremium;

  @HiveField(11)
  bool isFeatured;

  @HiveField(12)
  bool isTrending;

  @HiveField(13)
  Map<String, String> placeholders;

  @HiveField(14)
  String engineeringPrinciple; // Clarity, Conciseness, Format

  @HiveField(15)
  String contextType; // Task Specificity level

  @HiveField(16)
  int complexityLevel; // 1-5 scale

  PromptModel({
    required this.id,
    required this.title,
    required this.description,
    required this.template,
    required this.category,
    required this.tags,
    required this.rating,
    required this.usageCount,
    required this.author,
    required this.createdAt,
    this.isPremium = false,
    this.isFeatured = false,
    this.isTrending = false,
    this.placeholders = const {},
    this.engineeringPrinciple = 'Clarity',
    this.contextType = 'General',
    this.complexityLevel = 1,
  });
}

// controllers/prompt_controller.dart
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/prompt_model.dart';
import '../services/prompt_service.dart';

class PromptController extends GetxController {
  final PromptService _promptService = PromptService();
  
  // Observable variables
  final RxList<PromptModel> allPrompts = <PromptModel>[].obs;
  final RxList<PromptModel> filteredPrompts = <PromptModel>[].obs;
  final RxList<PromptModel> favoritePrompts = <PromptModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString sortBy = 'trending'.obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  
  // Prompt Engineering Analytics
  final RxMap<String, int> engineeringPrincipleStats = <String, int>{}.obs;
  final RxMap<String, double> categoryEffectiveness = <String, double>{}.obs;
  
  final categories = [
    'All', 'Software Development', 'Creative Writing', 'Video Production',
    'Marketing', 'Data Analysis', 'Design', 'Business Strategy',
    'Education', 'Research', 'Content Creation'
  ];

  @override
  void onInit() {
    super.onInit();
    loadPrompts();
    loadFavorites();
    setupSearchListener();
  }

  void setupSearchListener() {
    debounce(searchQuery, (_) => filterPrompts(), time: Duration(milliseconds: 300));
    debounce(selectedCategory, (_) => filterPrompts(), time: Duration(milliseconds: 100));
  }

  Future<void> loadPrompts() async {
    try {
      isLoading.value = true;
      
      // Load from Hive cache first
      final box = Hive.box<PromptModel>('prompts');
      if (box.isNotEmpty) {
        allPrompts.assignAll(box.values.toList());
        filteredPrompts.assignAll(allPrompts);
      }
      
      // Fetch from API and update cache
      final apiPrompts = await _promptService.fetchPrompts(page: currentPage.value);
      
      // Simulate 190K prompts with intelligent generation
      if (allPrompts.isEmpty) {
        final generatedPrompts = await _generateIntelligentPrompts();
        allPrompts.addAll(generatedPrompts);
        
        // Cache in Hive
        for (final prompt in generatedPrompts) {
          await box.put(prompt.id, prompt);
        }
      }
      
      filterPrompts();
      calculateEngineeeringStats();
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to load prompts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<PromptModel>> _generateIntelligentPrompts() async {
    final List<PromptModel> prompts = [];
    
    // Engineering principles-based prompt generation
    final engineeringPrinciples = ['Clarity', 'Conciseness', 'Format', 'Context', 'Specificity'];
    final contextTypes = ['Task-Specific', 'Domain-Specific', 'Role-Based', 'Output-Focused'];
    
    final promptTemplates = [
      // Software Development - Clarity focused
      {
        'title': 'Clean Code Function Generator',
        'template': 'Generate a clean, well-documented {language} function that {task}. Include type hints, error handling, and follow {coding_standard} standards.',
        'category': 'Software Development',
        'principle': 'Clarity',
        'context': 'Task-Specific',
        'complexity': 3,
        'placeholders': {'language': 'Python', 'task': 'calculates fibonacci', 'coding_standard': 'PEP8'}
      },
      
      // Creative Writing - Format focused
      {
        'title': 'Story Structure Generator',
        'template': 'Write a {word_count}-word {genre} story following the three-act structure. Include: Setup ({setup_percentage}%), Confrontation ({confrontation_percentage}%), Resolution ({resolution_percentage}%). Theme: {theme}',
        'category': 'Creative Writing',
        'principle': 'Format',
        'context': 'Output-Focused',
        'complexity': 4,
        'placeholders': {'word_count': '1000', 'genre': 'sci-fi', 'setup_percentage': '25', 'confrontation_percentage': '50', 'resolution_percentage': '25', 'theme': 'artificial intelligence'}
      },
      
      // Business Strategy - Conciseness focused
      {
        'title': 'Strategic Analysis Framework',
        'template': 'Analyze {company} in {industry} using SWOT framework. Provide 3 key points for each quadrant. Focus on {timeframe} outlook.',
        'category': 'Business Strategy',
        'principle': 'Conciseness',
        'context': 'Domain-Specific',
        'complexity': 5,
        'placeholders': {'company': 'Tech Startup', 'industry': 'AI/ML', 'timeframe': '2-year'}
      },
      
      // Data Analysis - Context focused
      {
        'title': 'Data Insight Extractor',
        'template': 'Given dataset with {data_type} data, perform {analysis_type} analysis. Context: {business_context}. Output format: Executive summary, key findings, actionable recommendations.',
        'category': 'Data Analysis',
        'principle': 'Context',
        'context': 'Role-Based',
        'complexity': 4,
        'placeholders': {'data_type': 'sales', 'analysis_type': 'trend', 'business_context': 'quarterly review'}
      },
      
      // Marketing - Specificity focused
      {
        'title': 'Target Audience Campaign',
        'template': 'Create {campaign_type} campaign for {product} targeting {demographic}. Include: headline, 3 key messages, call-to-action, success metrics.',
        'category': 'Marketing',
        'principle': 'Specificity',
        'context': 'Output-Focused',
        'complexity': 3,
        'placeholders': {'campaign_type': 'social media', 'product': 'AI tool', 'demographic': 'developers 25-35'}
      }
    ];

    // Generate 190K+ prompts with variations
    for (int i = 0; i < 190000; i++) {
      final template = promptTemplates[i % promptTemplates.length];
      
      prompts.add(PromptModel(
        id: 'prompt_$i',
        title: '${template['title']} ${(i ~/ promptTemplates.length) + 1}',
        description: 'Professional ${template['principle']}-focused prompt following prompt engineering best practices',
        template: template['template'] as String,
        category: template['category'] as String,
        tags: [
          template['principle'] as String,
          template['context'] as String,
          template['category'] as String,
          'AI Engineering',
          'Professional'
        ],
        rating: 3.5 + (i % 15) * 0.1,
        usageCount: 100 + (i % 10000),
        author: 'AI Expert ${(i % 100) + 1}',
        createdAt: DateTime.now().subtract(Duration(days: i % 365)),
        isPremium: i % 5 == 0,
        isFeatured: i < 50,
        isTrending: i < 200,
        placeholders: Map<String, String>.from(template['placeholders'] as Map),
        engineeringPrinciple: template['principle'] as String,
        contextType: template['context'] as String,
        complexityLevel: template['complexity'] as int,
      ));
    }
    
    return prompts;
  }

  void filterPrompts() {
    List<PromptModel> filtered = allPrompts.where((prompt) {
      final matchesSearch = searchQuery.value.isEmpty ||
          prompt.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          prompt.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          prompt.tags.any((tag) => tag.toLowerCase().contains(searchQuery.value.toLowerCase()));
      
      final matchesCategory = selectedCategory.value == 'All' ||
          prompt.category == selectedCategory.value;
      
      return matchesSearch && matchesCategory;
    }).toList();

    // Sort by selected criteria
    switch (sortBy.value) {
      case 'trending':
        filtered.sort((a, b) => b.isTrending ? 1 : -1);
        break;
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'usage':
        filtered.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        break;
      case 'complexity':
        filtered.sort((a, b) => b.complexityLevel.compareTo(a.complexityLevel));
        break;
    }

    filteredPrompts.assignAll(filtered);
  }

  void calculateEngineeeringStats() {
    engineeringPrincipleStats.clear();
    categoryEffectiveness.clear();
    
    for (final prompt in allPrompts) {
      // Count engineering principles
      engineeringPrincipleStats[prompt.engineeringPrinciple] = 
          (engineeringPrincipleStats[prompt.engineeringPrinciple] ?? 0) + 1;
      
      // Calculate category effectiveness (rating * usage)
      final effectiveness = prompt.rating * (prompt.usageCount / 1000);
      categoryEffectiveness[prompt.category] = 
          (categoryEffectiveness[prompt.category] ?? 0) + effectiveness;
    }
  }

  void toggleFavorite(PromptModel prompt) {
    final favBox = Hive.box('favorites');
    if (favBox.containsKey(prompt.id)) {
      favBox.delete(prompt.id);
      favoritePrompts.removeWhere((p) => p.id == prompt.id);
    } else {
      favBox.put(prompt.id, prompt.id);
      favoritePrompts.add(prompt);
    }
  }

  void loadFavorites() {
    final favBox = Hive.box('favorites');
    final favIds = favBox.keys.cast<String>().toList();
    favoritePrompts.assignAll(
      allPrompts.where((prompt) => favIds.contains(prompt.id))
    );
  }

  void incrementUsage(PromptModel prompt) {
    prompt.usageCount++;
    final box = Hive.box<PromptModel>('prompts');
    box.put(prompt.id, prompt);
  }

  Future<void> sharePrompt(PromptModel prompt) async {
    // Implementation for sharing prompts
  }

  Future<void> downloadPrompt(PromptModel prompt) async {
    // Implementation for downloading prompts
  }
}

// services/prompt_service.dart
import 'package:dio/dio.dart';
import '../models/prompt_model.dart';

class PromptService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://api.aiprompts.com';

  Future<List<PromptModel>> fetchPrompts({int page = 1, int limit = 50}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/prompts',
        queryParameters: {'page': page, 'limit': limit},
      );
      
      // Convert API response to PromptModel list
      return (response.data['prompts'] as List)
          .map((json) => PromptModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch prompts: $e');
    }
  }

  Future<List<PromptModel>> searchPrompts(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/prompts/search',
        queryParameters: {'q': query},
      );
      
      return (response.data['prompts'] as List)
          .map((json) => PromptModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search prompts: $e');
    }
  }
}

// utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C5CE7);
  static const Color accentColor = Color(0xFF00CEC9);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE74C3C);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.purple,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: Colors.black87,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.purple,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Color(0xFF1A1A1A),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF2D2D2D),
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: Color(0xFF2D2D2D),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

// views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controllers/prompt_controller.dart';
import '../models/prompt_model.dart';
import 'widgets/prompt_card.dart';
import 'widgets/search_bar.dart';
import 'widgets/category_chips.dart';
import 'widgets/stats_dashboard.dart';

class HomeView extends StatelessWidget {
  final PromptController controller = Get.find<PromptController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('AI Prompt Engineering Hub'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.school),
            onPressed: () => Get.to(() => LearningHubView()),
            tooltip: 'Learning Hub',
          ),
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () => Get.to(() => StatsDashboard()),
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () => _showFavorites(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                CustomSearchBar(),
                SizedBox(height: 12),
                CategoryChips(),
                SizedBox(height: 12),
                _buildSortOptions(),
              ],
            ),
          ),
          
          // Prompts Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.filteredPrompts.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }
              
              return MasonryGridView.count(
                crossAxisCount: _getCrossAxisCount(context),
                itemCount: controller.filteredPrompts.length,
                itemBuilder: (context, index) {
                  final prompt = controller.filteredPrompts[index];
                  return PromptCard(prompt: prompt);
                },
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => LearningHubView()),
        icon: Icon(Icons.school),
        label: Text('Master AI'),
        tooltip: 'Learn the 7 Core Benefits',
      ),
    );
  }

  Widget _buildBenefitsBanner() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Get.theme.primaryColor, Get.theme.primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Get.theme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Master AI with 7 Core Benefits',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Transform your AI interaction, enhance output quality, and unlock innovation',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildBenefitChip('🚀 Better AI Interaction'),
              SizedBox(width: 8),
              _buildBenefitChip('⭐ Enhanced Quality'),
              SizedBox(width: 8),
              _buildBenefitChip('⚡ Increased Efficiency'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _buildBenefitChip('🎯 Perfect Customization'),
              SizedBox(width: 8),
              _buildBenefitChip('🌍 Broader Applications'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              _buildBenefitChip('🧠 AI Limitations Mastery'),
              SizedBox(width: 8),
              _buildBenefitChip('💡 Innovation Unlocked'),
            ],
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Get.to(() => LearningHubView()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Get.theme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text('Start Learning Journey'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildSortOptions() {
    return Row(
      children: [
        Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Obx(() => DropdownButton<String>(
            value: controller.sortBy.value,
            isExpanded: true,
            onChanged: (value) {
              controller.sortBy.value = value!;
              controller.filterPrompts();
            },
            items: [
              DropdownMenuItem(value: 'trending', child: Text('🔥 Trending')),
              DropdownMenuItem(value: 'rating', child: Text('⭐ Highest Rated')),
              DropdownMenuItem(value: 'usage', child: Text('📈 Most Used')),
              DropdownMenuItem(value: 'complexity', child: Text('🧠 Complexity')),
            ],
          )),
        ),
      ],
    );
  }

  void _showFavorites(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Favorite Prompts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.favoritePrompts.length,
                itemBuilder: (context, index) {
                  return PromptCard(prompt: controller.favoritePrompts[index]);
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePrompt(BuildContext context) {
    // Implementation for creating new prompts
    Get.snackbar(
      'Coming Soon',
      'Prompt creation feature will be available in the next update!',
      icon: Icon(Icons.construction, color: Colors.orange),
    );
  }
}

// Enhanced InitialBinding to include LearningController
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PromptController(), permanent: true);
    Get.put(LearningController(), permanent: true);
  }
}

// views/widgets/enhanced_prompt_card.dart - Enhanced version with benefits integration
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/prompt_model.dart';
import '../../controllers/prompt_controller.dart';
import '../../controllers/learning_controller.dart';

class EnhancedPromptCard extends StatelessWidget {
  final PromptModel prompt;
  final PromptController controller = Get.find<PromptController>();
  final LearningController learningController = Get.find<LearningController>();

  EnhancedPromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showEnhancedPromptDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badges and benefits indicator
              Row(
                children: [
                  if (prompt.isFeatured) _buildBadge('Featured', Colors.orange),
                  if (prompt.isTrending) _buildBadge('Trending', Colors.red),
                  if (prompt.isPremium) _buildBadge('Premium', Colors.purple),
                  _buildBenefitIndicator(),
                  Spacer(),
                  IconButton(
                    icon: Obx(() => Icon(
                      controller.favoritePrompts.any((p) => p.id == prompt.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    )),
                    onPressed: () => controller.toggleFavorite(prompt),
                  ),
                ],
              ),
              
              // Title and Description
              Text(
                prompt.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                prompt.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 12),
              
              // Engineering Principle with benefit connection
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPrincipleColor(prompt.engineeringPrinciple),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${prompt.engineeringPrinciple} → ${_getBenefitFromPrinciple(prompt.engineeringPrinciple)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              SizedBox(height: 12),
              
              // Stats Row with effectiveness indicator
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text('${prompt.rating}'),
                  SizedBox(width: 16),
                  Icon(Icons.trending_up, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text('${prompt.usageCount}'),
                  SizedBox(width: 16),
                  _buildEffectivenessIndicator(),
                  Spacer(),
                  Text('L${prompt.complexityLevel}', 
                       style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBenefitIndicator() {
    final benefitCount = _calculateBenefitCount();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Text(
        '${benefitCount}/7 Benefits',
        style: TextStyle(
          color: Colors.green[700],
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEffectivenessIndicator() {
    final effectiveness = (prompt.rating * prompt.usageCount / 1000).clamp(0, 100);
    return Row(
      children: [
        Icon(Icons.speed, size: 14, color: Colors.blue),
        SizedBox(width: 2),
        Text(
          '${effectiveness.toInt()}%',
          style: TextStyle(
            fontSize: 11,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  int _calculateBenefitCount() {
    // Calculate how many of the 7 core benefits this prompt addresses
    int count = 1; // Base benefit from engineering principle
    
    if (prompt.rating > 4.0) count++; // Enhanced Output Quality
    if (prompt.usageCount > 5000) count++; // Increased Efficiency
    if (prompt.placeholders.isNotEmpty) count++; // Customization
    if (prompt.category != 'General') count++; // Broader Application
    if (prompt.complexityLevel > 3) count++; // Better Understanding of AI Limitations
    if (prompt.isFeatured || prompt.isTrending) count++; // Innovation in AI Applications
    
    return count.clamp(1, 7);
  }

  String _getBenefitFromPrinciple(String principle) {
    switch (principle) {
      case 'Clarity': return 'Better Interaction';
      case 'Conciseness': return 'Efficiency';
      case 'Format': return 'Quality';
      case 'Context': return 'Understanding';
      case 'Specificity': return 'Customization';
      default: return 'Innovation';
    }
  }

  Color _getPrincipleColor(String principle) {
    switch (principle) {
      case 'Clarity': return Colors.blue;
      case 'Conciseness': return Colors.green;
      case 'Format': return Colors.orange;
      case 'Context': return Colors.purple;
      case 'Specificity': return Colors.teal;
      default: return Colors.grey;
    }
  }

  void _showEnhancedPromptDetails(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.95,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Header with Benefits
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prompt.title,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Demonstrates ${_calculateBenefitCount()}/7 Core Benefits',
                          style: TextStyle(
                            color: Get.theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Benefits Analysis Section
              _buildBenefitsAnalysis(),
              
              SizedBox(height: 20),
              
              // Template with syntax highlighting
              Text('Prompt Template:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  prompt.template,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 14,
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // How This Prompt Delivers Benefits
              _buildBenefitDelivery(),
              
              SizedBox(height: 20),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.incrementUsage(prompt);
                        Get.snackbar('Success', 'Prompt copied! Experience the benefits!');
                      },
                      icon: Icon(Icons.copy),
                      label: Text('Use Prompt'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.to(() => LearningHubView()),
                      icon: Icon(Icons.school),
                      label: Text('Learn More'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsAnalysis() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('7 Core Benefits Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildBenefitItem('🚀 Improved AI Interaction', 'Clear structure guides AI understanding', true),
            _buildBenefitItem('⭐ Enhanced Output Quality', 'High rating (${prompt.rating}) proves quality', prompt.rating > 4.0),
            _buildBenefitItem('⚡ Increased Efficiency', 'High usage (${prompt.usageCount}) shows efficiency', prompt.usageCount > 5000),
            _buildBenefitItem('🎯 Perfect Customization', 'Placeholders enable customization', prompt.placeholders.isNotEmpty),
            _buildBenefitItem('🌍 Broader Applications', 'Applies to ${prompt.category} domain', prompt.category != 'General'),
            _buildBenefitItem('🧠 AI Limitations Mastery', 'Complexity Level ${prompt.complexityLevel}', prompt.complexityLevel > 3),
            _buildBenefitItem('💡 Innovation Unlocked', 'Featured/trending status', prompt.isFeatured || prompt.isTrending),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String benefit, String description, bool isActive) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.circle_outlined,
            color: isActive ? Colors.green : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitDelivery() {
    return Card(
      color: Get.theme.primaryColor.withOpacity(0.05),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How This Prompt Delivers Benefits', 
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              'This prompt demonstrates ${prompt.engineeringPrinciple} principle, '
              'which directly contributes to ${_getBenefitFromPrinciple(prompt.engineeringPrinciple)}. '
              'With ${prompt.usageCount} successful uses and a ${prompt.rating}/5.0 rating, '
              'it proves the effectiveness of proper prompt engineering.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.to(() => LearningHubView()),
              child: Text('Master All 7 Benefits'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Widget _buildSortOptions() {
    return Row(
      children: [
        Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.w500)),
        Expanded(
          child: Obx(() => DropdownButton<String>(
            value: controller.sortBy.value,
            isExpanded: true,
            onChanged: (value) {
              controller.sortBy.value = value!;
              controller.filterPrompts();
            },
            items: [
              DropdownMenuItem(value: 'trending', child: Text('🔥 Trending')),
              DropdownMenuItem(value: 'rating', child: Text('⭐ Highest Rated')),
              DropdownMenuItem(value: 'usage', child: Text('📈 Most Used')),
              DropdownMenuItem(value: 'complexity', child: Text('🧠 Complexity')),
            ],
          )),
        ),
      ],
    );
  }

  void _showFavorites(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Favorite Prompts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.favoritePrompts.length,
                itemBuilder: (context, index) {
                  return PromptCard(prompt: controller.favoritePrompts[index]);
                },
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePrompt(BuildContext context) {
    // Implementation for creating new prompts
    Get.snackbar(
      'Coming Soon',
      'Prompt creation feature will be available in the next update!',
      icon: Icon(Icons.construction, color: Colors.orange),
    );
  }
}

// views/widgets/prompt_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/prompt_model.dart';
import '../../controllers/prompt_controller.dart';

class PromptCard extends StatelessWidget {
  final PromptModel prompt;
  final PromptController controller = Get.find<PromptController>();

  PromptCard({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showPromptDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badges
              Row(
                children: [
                  if (prompt.isFeatured) _buildBadge('Featured', Colors.orange),
                  if (prompt.isTrending) _buildBadge('Trending', Colors.red),
                  if (prompt.isPremium) _buildBadge('Premium', Colors.purple),
                  Spacer(),
                  IconButton(
                    icon: Obx(() => Icon(
                      controller.favoritePrompts.any((p) => p.id == prompt.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.red,
                    )),
                    onPressed: () => controller.toggleFavorite(prompt),
                  ),
                ],
              ),
              
              // Title and Description
              Text(
                prompt.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                prompt.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 12),
              
              // Engineering Principle
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPrincipleColor(prompt.engineeringPrinciple),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  prompt.engineeringPrinciple,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              SizedBox(height: 12),
              
              // Stats Row
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4),
                  Text('${prompt.rating}'),
                  SizedBox(width: 16),
                  Icon(Icons.trending_up, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text('${prompt.usageCount}'),
                  Spacer(),
                  Text('L${prompt.complexityLevel}', 
                       style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getPrincipleColor(String principle) {
    switch (principle) {
      case 'Clarity': return Colors.blue;
      case 'Conciseness': return Colors.green;
      case 'Format': return Colors.orange;
      case 'Context': return Colors.purple;
      case 'Specificity': return Colors.teal;
      default: return Colors.grey;
    }
  }

  void _showPromptDetails(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      prompt.title,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Template with syntax highlighting
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  prompt.template,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 14,
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Placeholders
              if (prompt.placeholders.isNotEmpty) ...[
                Text('Placeholders:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...prompt.placeholders.entries.map((entry) => 
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text('${entry.key}:', style: TextStyle(fontWeight: FontWeight.w500)),
                        SizedBox(width: 8),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
              
              // Engineering Analysis
              Text('Prompt Engineering Analysis:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _buildAnalysisChip('Principle', prompt.engineeringPrinciple, _getPrincipleColor(prompt.engineeringPrinciple)),
              _buildAnalysisChip('Context Type', prompt.contextType, Colors.indigo),
              _buildAnalysisChip('Complexity Level', 'Level ${prompt.complexityLevel}', Colors.deepOrange),
              
              SizedBox(height: 20),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.incrementUsage(prompt);
                        Get.snackbar('Success', 'Prompt copied to clipboard!');
                      },
                      icon: Icon(Icons.copy),
                      label: Text('Use Prompt'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.sharePrompt(prompt),
                      icon: Icon(Icons.share),
                      label: Text('Share'),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Stats and Metadata
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Metadata', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      _buildMetadataRow('Author', prompt.author),
                      _buildMetadataRow('Category', prompt.category),
                      _buildMetadataRow('Rating', '${prompt.rating} ⭐'),
                      _buildMetadataRow('Usage Count', '${prompt.usageCount} uses'),
                      _buildMetadataRow('Created', '${prompt.createdAt.day}/${prompt.createdAt.month}/${prompt.createdAt.year}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisChip(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(width: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label + ':', style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// views/widgets/search_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/prompt_controller.dart';

class CustomSearchBar extends StatelessWidget {
  final PromptController controller = Get.find<PromptController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => controller.searchQuery.value = value,
        decoration: InputDecoration(
          hintText: 'Search 190K+ intelligent prompts...',
          prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => controller.searchQuery.value = '',
                )
              : Icon(Icons.mic, color: Colors.grey)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

// views/widgets/category_chips.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/prompt_controller.dart';

class CategoryChips extends StatelessWidget {
  final PromptController controller = Get.find<PromptController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Obx(() => ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final isSelected = controller.selectedCategory.value == category;
          
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                controller.selectedCategory.value = category;
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      )),
    );
  }
}

// views/widgets/stats_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/prompt_controller.dart';

class StatsDashboard extends StatelessWidget {
  final PromptController controller = Get.find<PromptController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prompt Engineering Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Prompts', '190,000+', Icons.psychology, Colors.blue)),
                SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Categories', '10+', Icons.category, Colors.green)),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Avg Rating', '4.2/5.0', Icons.star, Colors.orange)),
                SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Total Usage', '2.5M+', Icons.trending_up, Colors.purple)),
              ],
            ),
            
            SizedBox(height: 24),
            
            // Engineering Principles Chart
            Text('Engineering Principles Distribution', 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: Obx(() => PieChart(
                PieChartData(
                  sections: controller.engineeringPrincipleStats.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: entry.key,
                      color: _getPrincipleColor(entry.key),
                      radius: 80,
                      titleStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                  centerSpaceRadius: 40,
                ),
              )),
            ),
            
            SizedBox(height: 24),
            
            // Category Effectiveness
            Text('Category Effectiveness', 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: Obx(() => BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: controller.categoryEffectiveness.entries.map((entry) {
                    return BarChartGroupData(
                      x: controller.categoryEffectiveness.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Theme.of(context).primaryColor,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final categories = controller.categoryEffectiveness.keys.toList();
                          if (value.toInt() < categories.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                categories[value.toInt()].split(' ').first,
                                style: TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              )),
            ),
            
            SizedBox(height: 24),
            
            // Prompt Engineering Best Practices
            Text('Prompt Engineering Best Practices', 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildBestPracticesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildBestPracticesCard() {
    final practices = [
      {'title': 'Clarity', 'description': 'Be clear and direct to avoid confusion', 'icon': Icons.clarity},
      {'title': 'Conciseness', 'description': 'Keep prompts concise while maintaining context', 'icon': Icons.compress},
      {'title': 'Format', 'description': 'Align with model training for better results', 'icon': Icons.format_align_left},
      {'title': 'Context', 'description': 'Provide relevant context for better understanding', 'icon': Icons.context_menu},
      {'title': 'Specificity', 'description': 'Be specific about desired outcomes', 'icon': Icons.target},
    ];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: practices.map((practice) => 
            ListTile(
              leading: Icon(practice['icon'] as IconData, color: Theme.of(Get.context!).primaryColor),
              title: Text(practice['title'] as String, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(practice['description'] as String),
              dense: true,
            ),
          ).toList(),
        ),
      ),
    );
  }

  Color _getPrincipleColor(String principle) {
    switch (principle) {
      case 'Clarity': return Colors.blue;
      case 'Conciseness': return Colors.green;
      case 'Format': return Colors.orange;
      case 'Context': return Colors.purple;
      case 'Specificity': return Colors.teal;
      default: return Colors.grey;
    }
  }
}

// models/learning_module.dart
import 'package:hive/hive.dart';

part 'learning_module.g.dart';

@HiveType(typeId: 1)
class LearningModule extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String benefit; // One of the 7 core benefits

  @HiveField(4)
  List<String> keyPoints;

  @HiveField(5)
  List<String> examples;

  @HiveField(6)
  String practicalExercise;

  @HiveField(7)
  int difficultyLevel;

  @HiveField(8)
  int estimatedMinutes;

  @HiveField(9)
  bool isCompleted;

  LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.benefit,
    required this.keyPoints,
    required this.examples,
    required this.practicalExercise,
    required this.difficultyLevel,
    required this.estimatedMinutes,
    this.isCompleted = false,
  });
}

// controllers/learning_controller.dart
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/learning_module.dart';

class LearningController extends GetxController {
  final RxList<LearningModule> learningModules = <LearningModule>[].obs;
  final RxList<LearningModule> completedModules = <LearningModule>[].obs;
  final RxInt currentModuleIndex = 0.obs;
  final RxDouble progressPercentage = 0.0.obs;
  final RxMap<String, int> benefitProgress = <String, int>{}.obs;

  final sevenCoreBenefits = [
    'Improved Interaction with AI',
    'Enhanced Output Quality',
    'Increased Efficiency',
    'Customization',
    'Broader Application',
    'Better Understanding of AI Limitations',
    'Innovation in AI Applications'
  ];

  @override
  void onInit() {
    super.onInit();
    initializeLearningModules();
    loadProgress();
  }

  void initializeLearningModules() {
    final modules = [
      // Benefit 1: Improved Interaction with AI
      LearningModule(
        id: 'interaction_basics',
        title: 'Mastering AI Communication',
        description: 'Learn how to craft effective prompts that lead to better AI responses',
        benefit: 'Improved Interaction with AI',
        keyPoints: [
          'Use clear, specific language',
          'Provide context and background information',
          'Structure requests logically',
          'Use examples to guide AI understanding'
        ],
        examples: [
          'Bad: "Write code"',
          'Good: "Write a Python function that calculates compound interest with error handling"',
          'Best: "Write a Python function that calculates compound interest. Include: 1) Input validation, 2) Docstring with examples, 3) Error handling for negative values"'
        ],
        practicalExercise: 'Transform 5 vague prompts into clear, structured requests',
        difficultyLevel: 1,
        estimatedMinutes: 15,
      ),

      // Benefit 2: Enhanced Output Quality
      LearningModule(
        id: 'quality_enhancement',
        title: 'Achieving Superior AI Outputs',
        description: 'Master techniques to significantly improve AI-generated content quality',
        benefit: 'Enhanced Output Quality',
        keyPoints: [
          'Use role-based prompting (Act as a...)',
          'Specify output format and structure',
          'Provide quality criteria and constraints',
          'Use iterative refinement techniques'
        ],
        examples: [
          'Role prompt: "Act as a senior software architect with 10 years experience"',
          'Format specification: "Provide response in JSON format with keys: analysis, recommendations, risks"',
          'Quality criteria: "Ensure code follows SOLID principles and includes unit tests"'
        ],
        practicalExercise: 'Create 3 role-based prompts for different professions',
        difficultyLevel: 2,
        estimatedMinutes: 20,
      ),

      // Benefit 3: Increased Efficiency
      LearningModule(
        id: 'efficiency_mastery',
        title: 'Reducing Iteration Cycles',
        description: 'Learn to get desired outputs faster with fewer prompt iterations',
        benefit: 'Increased Efficiency',
        keyPoints: [
          'Front-load context and requirements',
          'Use template-based approaches',
          'Chain prompts for complex tasks',
          'Create reusable prompt patterns'
        ],
        examples: [
          'Template: "Generate {output_type} for {target_audience} about {topic} in {format} with {constraints}"',
          'Chain: "First analyze, then synthesize, finally recommend"',
          'Pattern: "Problem → Context → Requirements → Format → Examples"'
        ],
        practicalExercise: 'Create 5 reusable prompt templates for common tasks',
        difficultyLevel: 3,
        estimatedMinutes: 25,
      ),

      // Benefit 4: Customization
      LearningModule(
        id: 'customization_techniques',
        title: 'Tailoring AI for Specific Needs',
        description: 'Master customization techniques for domain-specific applications',
        benefit: 'Customization',
        keyPoints: [
          'Domain-specific vocabulary and terminology',
          'Industry-standard formats and conventions',
          'Custom output structures',
          'Persona-based responses'
        ],
        examples: [
          'Medical: "Use ICD-10 codes and medical terminology"',
          'Legal: "Format as legal brief with citations"',
          'Technical: "Include code comments and architectural decisions"'
        ],
        practicalExercise: 'Customize prompts for 3 different industries',
        difficultyLevel: 4,
        estimatedMinutes: 30,
      ),

      // Benefit 5: Broader Application
      LearningModule(
        id: 'cross_domain_applications',
        title: 'Universal Prompt Engineering Skills',
        description: 'Apply prompt engineering across various domains and use cases',
        benefit: 'Broader Application',
        keyPoints: [
          'Content creation strategies',
          'Customer service automation',
          'Data analysis and reporting',
          'Educational content development'
        ],
        examples: [
          'Content: "Create SEO-optimized blog post with target keywords"',
          'Service: "Generate empathetic customer response for complaint about {issue}"',
          'Analysis: "Analyze dataset and identify top 3 trends with supporting evidence"'
        ],
        practicalExercise: 'Create prompts for 4 different business functions',
        difficultyLevel: 3,
        estimatedMinutes: 35,
      ),

      // Benefit 6: Better Understanding of AI Limitations
      LearningModule(
        id: 'ai_limitations_awareness',
        title: 'Understanding AI Boundaries',
        description: 'Learn AI model strengths, weaknesses, and realistic expectations',
        benefit: 'Better Understanding of AI Limitations',
        keyPoints: [
          'Recognizing hallucination patterns',
          'Understanding context window limits',
          'Identifying bias and inaccuracies',
          'Setting realistic expectations'
        ],
        examples: [
          'Limitation: "AI may hallucinate specific dates or statistics"',
          'Mitigation: "Request sources and verify critical information"',
          'Best practice: "Use AI for ideation, human for verification"'
        ],
        practicalExercise: 'Test AI limits with 10 challenging prompts and document results',
        difficultyLevel: 4,
        estimatedMinutes: 40,
      ),

      // Benefit 7: Innovation in AI Applications
      LearningModule(
        id: 'innovation_techniques',
        title: 'Creative AI Application Development',
        description: 'Discover innovative ways to leverage AI capabilities',
        benefit: 'Innovation in AI Applications',
        keyPoints: [
          'Multi-step reasoning chains',
          'Creative constraint applications',
          'Cross-modal prompt engineering',
          'Emergent behavior discovery'
        ],
        examples: [
          'Innovation: "Use AI as a debate partner to stress-test ideas"',
          'Creative: "Generate code that writes its own documentation"',
          'Novel: "Create prompts that help AI teach itself new concepts"'
        ],
        practicalExercise: 'Design 3 innovative AI applications using advanced prompting',
        difficultyLevel: 5,
        estimatedMinutes: 45,
      ),
    ];

    learningModules.assignAll(modules);
    calculateProgress();
  }

  void completeModule(String moduleId) {
    final moduleIndex = learningModules.indexWhere((m) => m.id == moduleId);
    if (moduleIndex != -1) {
      learningModules[moduleIndex].isCompleted = true;
      
      // Save to Hive
      final box = Hive.box('learning_progress');
      box.put(moduleId, true);
      
      calculateProgress();
      
      Get.snackbar(
        'Module Completed! 🎉',
        'You\'ve mastered ${learningModules[moduleIndex].benefit}',
        duration: Duration(seconds: 3),
      );
    }
  }

  void calculateProgress() {
    final completed = learningModules.where((m) => m.isCompleted).length;
    progressPercentage.value = (completed / learningModules.length) * 100;
    
    // Calculate progress per benefit
    benefitProgress.clear();
    for (final benefit in sevenCoreBenefits) {
      final benefitModules = learningModules.where((m) => m.benefit == benefit);
      final completedBenefitModules = benefitModules.where((m) => m.isCompleted);
      benefitProgress[benefit] = completedBenefitModules.length;
    }
  }

  void loadProgress() {
    final box = Hive.box('learning_progress');
    for (final module in learningModules) {
      module.isCompleted = box.get(module.id, defaultValue: false);
    }
    calculateProgress();
  }
}

// views/learning_hub_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/learning_controller.dart';
import '../models/learning_module.dart';

class LearningHubView extends StatelessWidget {
  final LearningController controller = Get.put(LearningController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Mastery Learning Hub'),
        actions: [
          Obx(() => Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                '${controller.progressPercentage.value.toInt()}% Complete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Overview Card
            _buildProgressCard(),
            SizedBox(height: 20),
            
            // Seven Core Benefits Section
            Text(
              '7 Core Benefits of Prompt Engineering Mastery',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildBenefitsGrid(),
            
            SizedBox(height: 24),
            
            // Learning Modules
            Text(
              'Interactive Learning Modules',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildLearningModules(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.school, size: 32, color: Get.theme.primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your AI Mastery Journey', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Master the art and science of prompt engineering',
                           style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Obx(() => LinearProgressIndicator(
              value: controller.progressPercentage.value / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Get.theme.primaryColor),
            )),
            SizedBox(height: 8),
            Obx(() => Text(
              '${controller.learningModules.where((m) => m.isCompleted).length} of ${controller.learningModules.length} modules completed',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsGrid() {
    final benefits = [
      {'title': 'Improved AI Interaction', 'icon': Icons.chat, 'color': Colors.blue},
      {'title': 'Enhanced Output Quality', 'icon': Icons.star, 'color': Colors.orange},
      {'title': 'Increased Efficiency', 'icon': Icons.speed, 'color': Colors.green},
      {'title': 'Perfect Customization', 'icon': Icons.tune, 'color': Colors.purple},
      {'title': 'Broader Applications', 'icon': Icons.apps, 'color': Colors.teal},
      {'title': 'AI Limitations Mastery', 'icon': Icons.psychology, 'color': Colors.indigo},
      {'title': 'Innovation Unlocked', 'icon': Icons.lightbulb, 'color': Colors.amber},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: benefits.length,
      itemBuilder: (context, index) {
        final benefit = benefits[index];
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  benefit['icon'] as IconData,
                  size: 32,
                  color: benefit['color'] as Color,
                ),
                SizedBox(height: 8),
                Text(
                  benefit['title'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Obx(() {
                  final benefitKey = controller.sevenCoreBenefits[index];
                  final progress = controller.benefitProgress[benefitKey] ?? 0;
                  return Text(
                    '$progress modules',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLearningModules() {
    return Obx(() => Column(
      children: controller.learningModules.map((module) => 
        _buildModuleCard(module)
      ).toList(),
    ));
  }

  Widget _buildModuleCard(LearningModule module) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showModuleDetails(module),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Obx(() => Icon(
                    module.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: module.isCompleted ? Colors.green : Colors.grey,
                  )),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          module.benefit,
                          style: TextStyle(
                            fontSize: 12,
                            color: Get.theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDifficultyIndicator(module.difficultyLevel),
                ],
              ),
              SizedBox(height: 8),
              Text(
                module.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    '${module.estimatedMinutes} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  if (!module.isCompleted)
                    ElevatedButton(
                      onPressed: () => _startModule(module),
                      child: Text('Start'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyIndicator(int level) {
    return Row(
      children: List.generate(5, (index) => 
        Icon(
          Icons.star,
          size: 12,
          color: index < level ? Colors.orange : Colors.grey[300],
        ),
      ),
    );
  }

  void _showModuleDetails(LearningModule module) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.9,
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          module.benefit,
                          style: TextStyle(
                            color: Get.theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Description
              Text(
                module.description,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              
              SizedBox(height: 24),
              
              // Key Points
              Text('Key Learning Points:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...module.keyPoints.map((point) => 
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline, size: 16, color: Get.theme.primaryColor),
                      SizedBox(width: 8),
                      Expanded(child: Text(point)),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Examples
              Text('Examples:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...module.examples.map((example) => 
                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    example,
                    style: TextStyle(fontFamily: 'Courier', fontSize: 12),
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Practical Exercise
              Text('Practical Exercise:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Get.theme.primaryColor.withOpacity(0.3)),
                ),
                child: Text(module.practicalExercise),
              ),
              
              SizedBox(height: 24),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: module.isCompleted 
                      ? null 
                      : () => controller.completeModule(module.id),
                  child: Text(module.isCompleted ? 'Completed ✓' : 'Mark as Complete'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startModule(LearningModule module) {
    _showModuleDetails(module);
  }
}

// Additional extension for PromptModel to handle JSON serialization
extension PromptModelExtension on PromptModel {
  static PromptModel fromJson(Map<String, dynamic> json) {
    return PromptModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      template: json['template'],
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] as num).toDouble(),
      usageCount: json['usageCount'],
      author: json['author'],
      createdAt: DateTime.parse(json['createdAt']),
      isPremium: json['isPremium'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      isTrending: json['isTrending'] ?? false,
      placeholders: Map<String, String>.from(json['placeholders'] ?? {}),
      engineeringPrinciple: json['engineeringPrinciple'] ?? 'Clarity',
      contextType: json['contextType'] ?? 'General',
      complexityLevel: json['complexityLevel'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'template': template,
      'category': category,
      'tags': tags,
      'rating': rating,
      'usageCount': usageCount,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'placeholders': placeholders,
      'engineeringPrinciple': engineeringPrinciple,
      'contextType': contextType,
      'complexityLevel': complexityLevel,
    };
  }
}