// views/widgets/enhanced_prompt_card.dart - Enhanced version with benefits integration
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_prmpt_app/presentation/pages/viewer/learning_hub_view.dart';
import '../../data/models/prompt_model.dart';
import '../controllers/prompt_controller.dart';
import '../controllers/learning_controller.dart';
import 'prompt_card.dart';

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
                          controller.favoritePrompts
                                  .any((p) => p.id == prompt.id)
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
    final effectiveness =
        (prompt.rating * prompt.usageCount / 1000).clamp(0, 100);
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
    if (prompt.complexityLevel > 3)
      count++; // Better Understanding of AI Limitations
    if (prompt.isFeatured || prompt.isTrending)
      count++; // Innovation in AI Applications

    return count.clamp(1, 7);
  }

  String _getBenefitFromPrinciple(String principle) {
    switch (principle) {
      case 'Clarity':
        return 'Better Interaction';
      case 'Conciseness':
        return 'Efficiency';
      case 'Format':
        return 'Quality';
      case 'Context':
        return 'Understanding';
      case 'Specificity':
        return 'Customization';
      default:
        return 'Innovation';
    }
  }

  Color _getPrincipleColor(String principle) {
    switch (principle) {
      case 'Clarity':
        return Colors.blue;
      case 'Conciseness':
        return Colors.green;
      case 'Format':
        return Colors.orange;
      case 'Context':
        return Colors.purple;
      case 'Specificity':
        return Colors.teal;
      default:
        return Colors.grey;
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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
              Text('Prompt Template:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        Get.snackbar('Success',
                            'Prompt copied! Experience the benefits!');
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
            Text('7 Core Benefits Analysis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildBenefitItem('🚀 Improved AI Interaction',
                'Clear structure guides AI understanding', true),
            _buildBenefitItem(
                '⭐ Enhanced Output Quality',
                'High rating (${prompt.rating}) proves quality',
                prompt.rating > 4.0),
            _buildBenefitItem(
                '⚡ Increased Efficiency',
                'High usage (${prompt.usageCount}) shows efficiency',
                prompt.usageCount > 5000),
            _buildBenefitItem(
                '🎯 Perfect Customization',
                'Placeholders enable customization',
                prompt.placeholders.isNotEmpty),
            _buildBenefitItem(
                '🌍 Broader Applications',
                'Applies to ${prompt.category} domain',
                prompt.category != 'General'),
            _buildBenefitItem(
                '🧠 AI Limitations Mastery',
                'Complexity Level ${prompt.complexityLevel}',
                prompt.complexityLevel > 3),
            _buildBenefitItem(
                '💡 Innovation Unlocked',
                'Featured/trending status',
                prompt.isFeatured || prompt.isTrending),
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

// Create controller instance for functions outside of EnhancedPromptCard class
final PromptController controller = Get.find<PromptController>();

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
                DropdownMenuItem(
                    value: 'rating', child: Text('⭐ Highest Rated')),
                DropdownMenuItem(value: 'usage', child: Text('📈 Most Used')),
                DropdownMenuItem(
                    value: 'complexity', child: Text('🧠 Complexity')),
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
                Text('Favorite Prompts',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: controller.favoritePrompts.length,
                  itemBuilder: (context, index) {
                    return PromptCard(
                        prompt: controller.favoritePrompts[index]);
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
    icon: const Icon(Icons.construction, color: Colors.orange),
  );
}
