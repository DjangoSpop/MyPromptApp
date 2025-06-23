// views/
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/learning_module.dart';
import '../../../data/models/prompt_model.dart';
import '../../controllers/learning_controller.dart';

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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
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
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Get.theme.primaryColor),
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
      {
        'title': 'Improved AI Interaction',
        'icon': Icons.chat,
        'color': Colors.blue
      },
      {
        'title': 'Enhanced Output Quality',
        'icon': Icons.star,
        'color': Colors.orange
      },
      {
        'title': 'Increased Efficiency',
        'icon': Icons.speed,
        'color': Colors.green
      },
      {
        'title': 'Perfect Customization',
        'icon': Icons.tune,
        'color': Colors.purple
      },
      {
        'title': 'Broader Applications',
        'icon': Icons.apps,
        'color': Colors.teal
      },
      {
        'title': 'AI Limitations Mastery',
        'icon': Icons.psychology,
        'color': Colors.indigo
      },
      {
        'title': 'Innovation Unlocked',
        'icon': Icons.lightbulb,
        'color': Colors.amber
      },
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
          children: controller.learningModules
              .map((module) => _buildModuleCard(module))
              .toList(),
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
                        module.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      children: List.generate(
        5,
        (index) => Icon(
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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
              Text('Key Learning Points:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...module.keyPoints.map(
                (point) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 16, color: Get.theme.primaryColor),
                      SizedBox(width: 8),
                      Expanded(child: Text(point)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Examples
              Text('Examples:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...module.examples.map(
                (example) => Container(
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
              Text('Practical Exercise:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Get.theme.primaryColor.withOpacity(0.3)),
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
                  child: Text(
                      module.isCompleted ? 'Completed ✓' : 'Mark as Complete'),
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
