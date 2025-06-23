// lib/presentation/widgets/template_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../data/models/template_api_models.dart';

/// Card widget for displaying template information with slide actions
class TemplateCard extends StatelessWidget {
  final TemplateListItem template;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.75,
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: const Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            label: 'Edit',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onDuplicate(),
            backgroundColor: const Color(0xFF50C878),
            foregroundColor: Colors.white,
            icon: Icons.content_copy_outlined,
            label: 'Copy',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: const Color(0xFFE74C3C),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and category
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        template.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        template.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: _getCategoryColor(template.category),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      elevation: 1,
                      side: BorderSide.none,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  template.description,
                  style: const TextStyle(
                    color: Color(0xFF5D6D7E),
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Footer with field count and date
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${template.rating.toStringAsFixed(1)} rating',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(template.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ), // Tags if available
                if (template.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 20,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          (template.tags.length > 3) ? 3 : template.tags.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 4),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECF0F1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFBDC3C7),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            template.tags[index],
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Gets color for category chip based on category name
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'business':
      case 'business strategy':
        return const Color(0xFF3498DB);
      case 'creative':
      case 'creativity':
        return const Color(0xFF9B59B6);
      case 'communication':
        return const Color(0xFF1ABC9C);
      case 'career':
        return const Color(0xFF2ECC71);
      case 'email':
        return const Color(0xFFE67E22);
      case 'technical':
      case 'software':
        return const Color(0xFF34495E);
      case 'character':
      case 'character development':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  /// Formats date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
