// lib/presentation/controllers/learning_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/learning_module.dart';
import '../../data/models/prompt_model.dart';
import '../../domain/services/learning_service.dart';

class LearningController extends GetxController {
  final LearningService _learningService = Get.find<LearningService>();

  // Observable lists and properties
  final RxList<LearningModule> learningModules = <LearningModule>[].obs;
  final RxList<PromptModel> prompts = <PromptModel>[].obs;
  final RxDouble progressPercentage = 0.0.obs;
  final RxMap<String, int> benefitProgress = <String, int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Seven core benefits - Fixed the naming and structure
  final List<String> sevenCoreBenefits = [
    'Improved AI Interaction',
    'Enhanced Output Quality',
    'Increased Efficiency',
    'Perfect Customization',
    'Broader Applications',
    'AI Limitations Mastery',
    'Innovation Unlocked',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeLearningData();
  }

  /// Initialize learning data and load modules
  Future<void> _initializeLearningData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _loadLearningModules();
      await _loadPrompts();
      _calculateProgress();
      _calculateBenefitProgress();
    } catch (e) {
      errorMessage.value = 'Failed to load learning data: $e';
      _loadDefaultData(); // Fallback to default data
    } finally {
      isLoading.value = false;
    }
  }

  /// Load learning modules from service
  Future<void> _loadLearningModules() async {
    try {
      final modules = await _learningService.getAllModules();
      learningModules.assignAll(modules);

      // If no modules exist, create default ones
      if (learningModules.isEmpty) {
        await _createDefaultModules();
      }
    } catch (e) {
      print('Error loading learning modules: $e');
      await _createDefaultModules();
    }
  }

  /// Load prompts from service
  Future<void> _loadPrompts() async {
    try {
      final promptList = await _learningService.getAllPrompts();
      prompts.assignAll(promptList);
    } catch (e) {
      print('Error loading prompts: $e');
      // Continue without prompts for now
    }
  }

  /// Calculate overall progress percentage
  void _calculateProgress() {
    if (learningModules.isEmpty) {
      progressPercentage.value = 0.0;
      return;
    }

    final completedCount = learningModules.where((m) => m.isCompleted).length;
    progressPercentage.value = (completedCount / learningModules.length) * 100;
  }

  /// Calculate progress for each benefit category
  void _calculateBenefitProgress() {
    benefitProgress.clear();

    for (int i = 0; i < sevenCoreBenefits.length; i++) {
      final benefit = sevenCoreBenefits[i];
      // Count modules related to each benefit
      final relatedModules = learningModules
          .where((module) =>
              module.benefit.toLowerCase().contains(benefit.toLowerCase()) ||
              module.category.toLowerCase().contains(benefit.toLowerCase()))
          .length;

      benefitProgress[benefit] = relatedModules;
    }
  }

  /// Complete a learning module
  Future<void> completeModule(String moduleId) async {
    try {
      final moduleIndex = learningModules.indexWhere((m) => m.id == moduleId);

      if (moduleIndex == -1) {
        throw Exception('Module not found: $moduleId');
      }

      final module = learningModules[moduleIndex];

      if (module.isCompleted) {
        Get.snackbar(
          'Already Completed',
          'This module has already been completed!',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Update module completion status
      final updatedModule = module.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      // Update in service
      await _learningService.updateModule(updatedModule);

      // Update local state
      learningModules[moduleIndex] = updatedModule;

      // Recalculate progress
      _calculateProgress();
      _calculateBenefitProgress();

      // Show success message
      Get.snackbar(
        'Module Completed! 🎉',
        'Great job! You\'ve completed "${module.title}"',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
        colorText: Get.theme.primaryColor,
      );

      // Check for achievement unlocks
      _checkAchievements();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to complete module: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.cardColor.withOpacity(0.1),
        colorText: Get.theme.disabledColor,
      );
    }
  }

  /// Reset module completion (for testing/admin purposes)
  Future<void> resetModule(String moduleId) async {
    try {
      final moduleIndex = learningModules.indexWhere((m) => m.id == moduleId);

      if (moduleIndex == -1) return;

      final module = learningModules[moduleIndex];
      final updatedModule = module.copyWith(
        isCompleted: false,
        completedAt: null,
      );

      await _learningService.updateModule(updatedModule);
      learningModules[moduleIndex] = updatedModule;

      _calculateProgress();
      _calculateBenefitProgress();
    } catch (e) {
      print('Error resetting module: $e');
    }
  }

  /// Get modules by difficulty level
  List<LearningModule> getModulesByDifficulty(int difficulty) {
    return learningModules
        .where((m) => m.difficultyLevel == difficulty)
        .toList();
  }

  /// Get modules by benefit category
  List<LearningModule> getModulesByBenefit(String benefit) {
    return learningModules
        .where((m) => m.benefit.toLowerCase().contains(benefit.toLowerCase()))
        .toList();
  }

  /// Get recommended next module
  LearningModule? getRecommendedModule() {
    final incompleteModules =
        learningModules.where((m) => !m.isCompleted).toList();

    if (incompleteModules.isEmpty) return null;

    // Sort by difficulty and return the easiest incomplete module
    incompleteModules
        .sort((a, b) => a.difficultyLevel.compareTo(b.difficultyLevel));
    return incompleteModules.first;
  }

  /// Check for achievement unlocks
  void _checkAchievements() {
    final completedCount = learningModules.where((m) => m.isCompleted).length;

    if (completedCount == 1) {
      _showAchievement('First Steps', 'You completed your first module!');
    } else if (completedCount == 5) {
      _showAchievement('Learning Streak', 'You completed 5 modules!');
    } else if (completedCount == learningModules.length) {
      _showAchievement('Master Learner', 'You completed all modules! 🏆');
    }
  }

  /// Show achievement dialog
  void _showAchievement(String title, String description) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('Achievement Unlocked!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  /// Create default learning modules if none exist
  Future<void> _createDefaultModules() async {
    final defaultModules = [
      LearningModule(
        id: 'clarity_foundations',
        title: 'Clarity Foundations',
        description:
            'Master the art of clear, specific prompts that get exactly what you want.',
        benefit: 'Improved AI Interaction',
        difficultyLevel: 1,
        estimatedMinutes: 15,
        keyPoints: [
          'Write specific, unambiguous prompts',
          'Use concrete examples and context',
          'Avoid vague language and assumptions',
          'Structure requests logically'
        ],
        examples: [
          'Template: "Generate {output_type} for {target_audience} about {topic}"',
          'Bad: "Write something good" → Good: "Write a 300-word blog intro about renewable energy for homeowners"',
          'Use context: "Acting as a marketing expert, create..."'
        ],
        practicalExercise:
            'Create 5 reusable prompt templates for your most common AI tasks.',
        category: 'Fundamentals',
        tags: ['clarity', 'fundamentals', 'templates'],
      ),
      LearningModule(
        id: 'efficiency_mastery',
        title: 'Reducing Iteration Cycles',
        description:
            'Learn to get desired outputs faster with fewer back-and-forth attempts.',
        benefit: 'Increased Efficiency',
        difficultyLevel: 3,
        estimatedMinutes: 25,
        keyPoints: [
          'Front-load context and requirements',
          'Use chain-of-thought prompting',
          'Implement progressive refinement',
          'Create reusable prompt patterns'
        ],
        examples: [
          'Chain: "First analyze, then synthesize, finally recommend"',
          'Pattern: "Problem → Context → Requirements → Format → Examples"',
          'Template: "Generate {output_type} for {target_audience} that {specific_goal}"'
        ],
        practicalExercise:
            'Create 5 reusable prompt templates that reduce your iteration cycles by 50%.',
        category: 'Efficiency',
        tags: ['efficiency', 'patterns', 'optimization'],
      ),
      LearningModule(
        id: 'quality_enhancement',
        title: 'Output Quality Optimization',
        description:
            'Techniques for consistently generating high-quality, professional outputs.',
        benefit: 'Enhanced Output Quality',
        difficultyLevel: 2,
        estimatedMinutes: 20,
        keyPoints: [
          'Specify quality criteria explicitly',
          'Use role-based prompting',
          'Implement quality checkpoints',
          'Leverage expert perspectives'
        ],
        examples: [
          'Role: "As a senior copywriter with 10 years experience..."',
          'Quality criteria: "Ensure accuracy, clarity, and engagement"',
          'Checkpoint: "Review for factual accuracy before proceeding"'
        ],
        practicalExercise:
            'Design a quality framework for your specific use case and test it.',
        category: 'Quality',
        tags: ['quality', 'standards', 'professional'],
      ),
      LearningModule(
        id: 'customization_mastery',
        title: 'Perfect Customization',
        description:
            'Tailor AI outputs precisely to your specific needs and preferences.',
        benefit: 'Perfect Customization',
        difficultyLevel: 4,
        estimatedMinutes: 30,
        keyPoints: [
          'Define your unique requirements',
          'Create personal style guides',
          'Implement conditional logic',
          'Build adaptive templates'
        ],
        examples: [
          'Style guide: "Use conversational tone, short paragraphs, bullet points"',
          'Conditional: "If technical audience, include data; if general, use analogies"',
          'Adaptive: "Adjust complexity based on user expertise level"'
        ],
        practicalExercise:
            'Create a personalized prompt library that reflects your unique style and needs.',
        category: 'Customization',
        tags: ['customization', 'personalization', 'style'],
      ),
      LearningModule(
        id: 'applications_expansion',
        title: 'Broader Applications',
        description:
            'Discover creative ways to apply prompt engineering across different domains.',
        benefit: 'Broader Applications',
        difficultyLevel: 3,
        estimatedMinutes: 25,
        keyPoints: [
          'Cross-domain pattern recognition',
          'Creative prompt combinations',
          'Multi-step workflows',
          'Integration strategies'
        ],
        examples: [
          'Cross-domain: "Apply design thinking to content creation"',
          'Combination: "Research + Analysis + Creative writing"',
          'Workflow: "Plan → Execute → Review → Refine"'
        ],
        practicalExercise:
            'Identify 3 new domains where you can apply your prompt engineering skills.',
        category: 'Applications',
        tags: ['applications', 'creativity', 'integration'],
      ),
    ];

    try {
      for (final module in defaultModules) {
        await _learningService.saveModule(module);
      }
      learningModules.assignAll(defaultModules);
    } catch (e) {
      print('Error creating default modules: $e');
    }
  }

  /// Load fallback data if service fails
  void _loadDefaultData() {
    // This provides basic functionality even if the service fails
    learningModules.assignAll([
      LearningModule(
        id: 'basic_prompting',
        title: 'Basic Prompting',
        description: 'Learn the fundamentals of effective prompting.',
        benefit: 'Improved AI Interaction',
        difficultyLevel: 1,
        estimatedMinutes: 10,
        keyPoints: ['Be specific', 'Provide context'],
        examples: [
          'Example: "Write a summary of..." instead of "Summarize this"'
        ],
        practicalExercise: 'Practice writing 3 specific prompts.',
        category: 'Basics',
      ),
    ]);

    progressPercentage.value = 0.0;
    _calculateBenefitProgress();
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await _initializeLearningData();
  }

  /// Search modules by query
  List<LearningModule> searchModules(String query) {
    if (query.trim().isEmpty) return learningModules.toList();

    final lowercaseQuery = query.toLowerCase();
    return learningModules
        .where((module) =>
            module.title.toLowerCase().contains(lowercaseQuery) ||
            module.description.toLowerCase().contains(lowercaseQuery) ||
            module.benefit.toLowerCase().contains(lowercaseQuery) ||
            module.keyPoints
                .any((point) => point.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }
}
