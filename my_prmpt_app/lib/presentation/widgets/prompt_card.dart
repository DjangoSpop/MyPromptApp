// views/widgets/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/prompt_model.dart';
import '../controllers/prompt_controller.dart';

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
