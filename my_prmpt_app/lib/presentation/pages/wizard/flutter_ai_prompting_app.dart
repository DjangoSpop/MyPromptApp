// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../../data/models/prompt_model.dart';
// import '../../controllers/prompt_controller.dart';


// class HomeView extends StatelessWidget {
//   final PromptController controller = Get.find<PromptController>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Icon(Icons.psychology, color: Theme.of(context).primaryColor),
//             SizedBox(width: 8),
//             Text('AI Prompt Engineering Hub'),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.school),
//             onPressed: () => Get.to(() => LearningHubView()),
//             tooltip: 'Learning Hub - Master 7 Core Benefits',
//           ),
//           IconButton(
//             icon: Icon(Icons.analytics),
//             onPressed: () => Get.to(() => StatsDashboard()),
//           ),
//           IconButton(
//             icon: Icon(Icons.favorite),
//             onPressed: () => _showFavorites(context),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Benefits Banner
//           _buildBenefitsBanner(),
          
//           // Search and Filter Section
//           Container(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 CustomSearchBar(),
//                 SizedBox(height: 12),
//                 CategoryChips(),
//                 SizedBox(height: 12),
//                 _buildSortOptions(),
//               ],
//             ),
//           ),
          
//           // Prompts Grid
//           Expanded(
//             child: Obx(() {// pubspec.yaml dependencies
// /*
// dependencies:
//   flutter:
//     sdk: flutter
//   get: ^4.6.6
//   hive: ^2.2.3
//   hive_flutter: ^1.1.0
//   dio: ^5.3.2
//   cached_network_image: ^3.3.0
//   flutter_staggered_grid_view: ^0.6.2
//   share_plus: ^7.2.1
//   url_launcher: ^6.2.1
//   flutter_animate: ^4.3.0
//   google_fonts: ^6.1.0
//   flutter_rating_bar: ^4.0.1
//   flutter_typeahead: ^4.8.0

// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   hive_generator: ^2.0.1
//   build_runner: ^2.4.7
// */

// // main.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'controllers/prompt_controller.dart';
// import 'models/prompt_model.dart';
// import 'views/home_view.dart';
// import 'utils/app_theme.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
  
//   // Initialize Hive
//   await Hive.initFlutter();
//   Hive.registerAdapter(PromptModelAdapter());
//   await Hive.openBox<PromptModel>('prompts');
//   await Hive.openBox('settings');
//   await Hive.openBox('favorites');
  
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'AI Prompt Engineering Hub',
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: ThemeMode.system,
//       home: HomeView(),
//       initialBinding: InitialBinding(),
//     );
//   }
// }

// class InitialBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.put(PromptController(), permanent: true);
//   }
// }

// // models/prompt_model.dart
// import 'package:hive/hive.dart';

// part 'prompt_model.g.dart';

// @HiveType(typeId: 0)
// class PromptModel extends HiveObject {
//   @HiveField(0)
//   String id;

//   @HiveField(1)
//   String title;

//   @HiveField(2)
//   String description;

//   @HiveField(3)
//   String template;

//   @HiveField(4)
//   String category;

//   @HiveField(5)
//   List<String> tags;

//   @HiveField(6)
//   double rating;

//   @HiveField(7)
//   int usageCount;

//   @HiveField(8)
//   String author;

//   @HiveField(9)
//   DateTime createdAt;

//   @HiveField(10)
//   bool isPremium;

//   @HiveField(11)
//   bool isFeatured;

//   @HiveField(12)
//   bool isTrending;

//   @HiveField(13)
//   Map<String, String> placeholders;

//   @HiveField(14)
//   String engineeringPrinciple; // Clarity, Conciseness, Format

//   @HiveField(15)
//   String contextType; // Task Specificity level

//   @HiveField(16)
//   int complexityLevel; // 1-5 scale

//   PromptModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.template,
//     required this.category,
//     required this.tags,
//     required this.rating,
//     required this.usageCount,
//     required this.author,
//     required this.createdAt,
//     this.isPremium = false,
//     this.isFeatured = false,
//     this.isTrending = false,
//     this.placeholders = const {},
//     this.engineeringPrinciple = 'Clarity',
//     this.contextType = 'General',
//     this.complexityLevel = 1,
//   });
// }

// // controllers/prompt_controller.dart
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import '../models/prompt_model.dart';
// import '../services/prompt_service.dart';

// class PromptController extends GetxController {
//   final PromptService _promptService = PromptService();
  
//   // Observable variables
//   final RxList<PromptModel> allPrompts = <PromptModel>[].obs;
//   final RxList<PromptModel> filteredPrompts = <PromptModel>[].obs;
//   final RxList<PromptModel> favoritePrompts = <PromptModel>[].obs;
//   final RxString searchQuery = ''.obs;
//   final RxString selectedCategory = 'All'.obs;
//   final RxString sortBy = 'trending'.obs;
//   final RxBool isLoading = false.obs;
//   final RxInt currentPage = 1.obs;
//   final RxBool hasMore = true.obs;
  
//   // Prompt Engineering Analytics
//   final RxMap<String, int> engineeringPrincipleStats = <String, int>{}.obs;
//   final RxMap<String, double> categoryEffectiveness = <String, double>{}.obs;
  
//   final categories = [
//     'All', 'Software Development', 'Creative Writing', 'Video Production',
//     'Marketing', 'Data Analysis', 'Design', 'Business Strategy',
//     'Education', 'Research', 'Content Creation'
//   ];

//   @override
//   void onInit() {
//     super.onInit();
//     loadPrompts();
//     loadFavorites();
//     setupSearchListener();
//   }

//   void setupSearchListener() {
//     debounce(searchQuery, (_) => filterPrompts(), time: Duration(milliseconds: 300));
//     debounce(selectedCategory, (_) => filterPrompts(), time: Duration(milliseconds: 100));
//   }

//   Future<void> loadPrompts() async {
//     try {
//       isLoading.value = true;
      
//       // Load from Hive cache first
//       final box = Hive.box<PromptModel>('prompts');
//       if (box.isNotEmpty) {
//         allPrompts.assignAll(box.values.toList());
//         filteredPrompts.assignAll(allPrompts);
//       }
      
//       // Fetch from API and update cache
//       final apiPrompts = await _promptService.fetchPrompts(page: currentPage.value);
      
//       // Simulate 190K prompts with intelligent generation
//       if (allPrompts.isEmpty) {
//         final generatedPrompts = await _generateIntelligentPrompts();
//         allPrompts.addAll(generatedPrompts);
        
//         // Cache in Hive
//         for (final prompt in generatedPrompts) {
//           await box.put(prompt.id, prompt);
//         }
//       }
      
//       filterPrompts();
//       calculateEngineeeringStats();
      
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to load prompts: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<List<PromptModel>> _generateIntelligentPrompts() async {
//     final List<PromptModel> prompts = [];
    
//     // Engineering principles-based prompt generation
//     final engineeringPrinciples = ['Clarity', 'Conciseness', 'Format', 'Context', 'Specificity'];
//     final contextTypes = ['Task-Specific', 'Domain-Specific', 'Role-Based', 'Output-Focused'];
    
//     final promptTemplates = [
//       // Software Development - Clarity focused
//       {
//         'title': 'Clean Code Function Generator',
//         'template': 'Generate a clean, well-documented {language} function that {task}. Include type hints, error handling, and follow {coding_standard} standards.',
//         'category': 'Software Development',
//         'principle': 'Clarity',
//         'context': 'Task-Specific',
//         'complexity': 3,
//         'placeholders': {'language': 'Python', 'task': 'calculates fibonacci', 'coding_standard': 'PEP8'}
//       },
      
//       // Creative Writing - Format focused
//       {
//         'title': 'Story Structure Generator',
//         'template': 'Write a {word_count}-word {genre} story following the three-act structure. Include: Setup ({setup_percentage}%), Confrontation ({confrontation_percentage}%), Resolution ({resolution_percentage}%). Theme: {theme}',
//         'category': 'Creative Writing',
//         'principle': 'Format',
//         'context': 'Output-Focused',
//         'complexity': 4,
//         'placeholders': {'word_count': '1000', 'genre': 'sci-fi', 'setup_percentage': '25', 'confrontation_percentage': '50', 'resolution_percentage': '25', 'theme': 'artificial intelligence'}
//       },
      
//       // Business Strategy - Conciseness focused
//       {
//         'title': 'Strategic Analysis Framework',
//         'template': 'Analyze {company} in {industry} using SWOT framework. Provide 3 key points for each quadrant. Focus on {timeframe} outlook.',
//         'category': 'Business Strategy',
//         'principle': 'Conciseness',
//         'context': 'Domain-Specific',
//         'complexity': 5,
//         'placeholders': {'company': 'Tech Startup', 'industry': 'AI/ML', 'timeframe': '2-year'}
//       },
      
//       // Data Analysis - Context focused
//       {
//         'title': 'Data Insight Extractor',
//         'template': 'Given dataset with {data_type} data, perform {analysis_type} analysis. Context: {business_context}. Output format: Executive summary, key findings, actionable recommendations.',
//         'category': 'Data Analysis',
//         'principle': 'Context',
//         'context': 'Role-Based',
//         'complexity': 4,
//         'placeholders': {'data_type': 'sales', 'analysis_type': 'trend', 'business_context': 'quarterly review'}
//       },
      
//       // Marketing - Specificity focused
//       {
//         'title': 'Target Audience Campaign',
//         'template': 'Create {campaign_type} campaign for {product} targeting {demographic}. Include: headline, 3 key messages, call-to-action, success metrics.',
//         'category': 'Marketing',
//         'principle': 'Specificity',
//         'context': 'Output-Focused',
//         'complexity': 3,
//         'placeholders': {'campaign_type': 'social media', 'product': 'AI tool', 'demographic': 'developers 25-35'}
//       }
//     ];

//     // Generate 190K+ prompts with variations
//     for (int i = 0; i < 190000; i++) {
//       final template = promptTemplates[i % promptTemplates.length];
      
//       prompts.add(PromptModel(
//         id: 'prompt_$i',
//         title: '${template['title']} ${(i ~/ promptTemplates.length) + 1}',
//         description: 'Professional ${template['principle']}-focused prompt following prompt engineering best practices',
//         template: template['template'] as String,
//         category: template['category'] as String,
//         tags: [
//           template['principle'] as String,
//           template['context'] as String,
//           template['category'] as String,
//           'AI Engineering',
//           'Professional'
//         ],
//         rating: 3.5 + (i % 15) * 0.1,
//         usageCount: 100 + (i % 10000),
//         author: 'AI Expert ${(i % 100) + 1}',
//         createdAt: DateTime.now().subtract(Duration(days: i % 365)),
//         isPremium: i % 5 == 0,
//         isFeatured: i < 50,
//         isTrending: i < 200,
//         placeholders: Map<String, String>.from(template['placeholders'] as Map),
//         engineeringPrinciple: template['principle'] as String,
//         contextType: template['context'] as String,
//         complexityLevel: template['complexity'] as int,
//       ));
//     }
    
//     return prompts;
//   }

//   void filterPrompts() {
//     List<PromptModel> filtered = allPrompts.where((prompt) {
//       final matchesSearch = searchQuery.value.isEmpty ||
//           prompt.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
//           prompt.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
//           prompt.tags.any((tag) => tag.toLowerCase().contains(searchQuery.value.toLowerCase()));
      
//       final matchesCategory = selectedCategory.value == 'All' ||
//           prompt.category == selectedCategory.value;
      
//       return matchesSearch && matchesCategory;
//     }).toList();

//     // Sort by selected criteria
//     switch (sortBy.value) {
//       case 'trending':
//         filtered.sort((a, b) => b.isTrending ? 1 : -1);
//         break;
//       case 'rating':
//         filtered.sort((a, b) => b.rating.compareTo(a.rating));
//         break;
//       case 'usage':
//         filtered.sort((a, b) => b.usageCount.compareTo(a.usageCount));
//         break;
//       case 'complexity':
//         filtered.sort((a, b) => b.complexityLevel.compareTo(a.complexityLevel));
//         break;
//     }

//     filteredPrompts.assignAll(filtered);
//   }

//   void calculateEngineeeringStats() {
//     engineeringPrincipleStats.clear();
//     categoryEffectiveness.clear();
    
//     for (final prompt in allPrompts) {
//       // Count engineering principles
//       engineeringPrincipleStats[prompt.engineeringPrinciple] = 
//           (engineeringPrincipleStats[prompt.engineeringPrinciple] ?? 0) + 1;
      
//       // Calculate category effectiveness (rating * usage)
//       final effectiveness = prompt.rating * (prompt.usageCount / 1000);
//       categoryEffectiveness[prompt.category] = 
//           (categoryEffectiveness[prompt.category] ?? 0) + effectiveness;
//     }
//   }

//   void toggleFavorite(PromptModel prompt) {
//     final favBox = Hive.box('favorites');
//     if (favBox.containsKey(prompt.id)) {
//       favBox.delete(prompt.id);
//       favoritePrompts.removeWhere((p) => p.id == prompt.id);
//     } else {
//       favBox.put(prompt.id, prompt.id);
//       favoritePrompts.add(prompt);
//     }
//   }

//   void loadFavorites() {
//     final favBox = Hive.box('favorites');
//     final favIds = favBox.keys.cast<String>().toList();
//     favoritePrompts.assignAll(
//       allPrompts.where((prompt) => favIds.contains(prompt.id))
//     );
//   }

//   void incrementUsage(PromptModel prompt) {
//     prompt.usageCount++;
//     final box = Hive.box<PromptModel>('prompts');
//     box.put(prompt.id, prompt);
//   }

//   Future<void> sharePrompt(PromptModel prompt) async {
//     // Implementation for sharing prompts
//   }

//   Future<void> downloadPrompt(PromptModel prompt) async {
//     // Implementation for downloading prompts
//   }
// }

// // services/prompt_service.dart
// import 'package:dio/dio.dart';
// import '../models/prompt_model.dart';

// class PromptService {
//   final Dio _dio = Dio();
//   final String baseUrl = 'https://api.aiprompts.com';

//   Future<List<PromptModel>> fetchPrompts({int page = 1, int limit = 50}) async {
//     try {
//       final response = await _dio.get(
//         '$baseUrl/prompts',
//         queryParameters: {'page': page, 'limit': limit},
//       );
      
//       // Convert API response to PromptModel list
//       return (response.data['prompts'] as List)
//           .map((json) => PromptModel.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to fetch prompts: $e');
//     }
//   }

//   Future<List<PromptModel>> searchPrompts(String query) async {
//     try {
//       final response = await _dio.get(
//         '$baseUrl/prompts/search',
//         queryParameters: {'q': query},
//       );
      
//       return (response.data['prompts'] as List)
//           .map((json) => PromptModel.fromJson(json))
//           .toList();
//     } catch (e) {
//       throw Exception('Failed to search prompts: $e');
//     }
//   }
// }
