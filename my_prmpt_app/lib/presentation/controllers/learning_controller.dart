// controllers/learning_controller.dart
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../data/models/learning_module.dart';

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
        description:
            'Learn how to craft effective prompts that lead to better AI responses',
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
        practicalExercise:
            'Transform 5 vague prompts into clear, structured requests',
        difficultyLevel: 1,
        estimatedMinutes: 15,
      ),

      // Benefit 2: Enhanced Output Quality
      LearningModule(
        id: 'quality_enhancement',
        title: 'Achieving Superior AI Outputs',
        description:
            'Master techniques to significantly improve AI-generated content quality',
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
        practicalExercise:
            'Create 3 role-based prompts for different professions',
        difficultyLevel: 2,
        estimatedMinutes: 20,
      ),

      // Benefit 3: Increased Efficiency
      LearningModule(
        id: 'efficiency_mastery',
        title: 'Reducing Iteration Cycles',
        description:
            'Learn to get desired outputs faster with fewer prompt iterations',
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
        practicalExercise:
            'Create 5 reusable prompt templates for common tasks',
        difficultyLevel: 3,
        estimatedMinutes: 25,
      ),

      // Benefit 4: Customization
      LearningModule(
        id: 'customization_techniques',
        title: 'Tailoring AI for Specific Needs',
        description:
            'Master customization techniques for domain-specific applications',
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
        description:
            'Apply prompt engineering across various domains and use cases',
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
        description:
            'Learn AI model strengths, weaknesses, and realistic expectations',
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
        practicalExercise:
            'Test AI limits with 10 challenging prompts and document results',
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
        practicalExercise:
            'Design 3 innovative AI applications using advanced prompting',
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
      final completedBenefitModules =
          benefitModules.where((m) => m.isCompleted);
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
