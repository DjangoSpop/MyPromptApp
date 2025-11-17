// lib/presentation/widgets/template_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/discord_design_system.dart';
import '../../data/models/template_model.dart';
import '../../data/models/template_api_models.dart';

/// Enhanced Template Card with Discord Design
///
/// Features:
/// - Discord-inspired design
/// - Rating display
/// - Usage count
/// - Premium badge
/// - Favorite button
/// - Hover effects
class TemplateCard extends StatefulWidget {
  final dynamic template; // Can be TemplateModel or TemplateListItem
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onFavorite;
  final bool? isFavorite;

  const TemplateCard({
    super.key,
    required this.template,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onFavorite,
    this.isFavorite,
  });

  @override
  State<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<TemplateCard> {
  bool _isHovering = false;

  String get title {
    if (widget.template is TemplateModel) {
      return (widget.template as TemplateModel).title;
    } else if (widget.template is TemplateListItem) {
      return (widget.template as TemplateListItem).title;
    }
    return 'Untitled';
  }

  String get description {
    if (widget.template is TemplateModel) {
      return (widget.template as TemplateModel).description;
    } else if (widget.template is TemplateListItem) {
      return (widget.template as TemplateListItem).description;
    }
    return '';
  }

  String get category {
    if (widget.template is TemplateModel) {
      return (widget.template as TemplateModel).category;
    } else if (widget.template is TemplateListItem) {
      return (widget.template as TemplateListItem).category;
    }
    return 'General';
  }

  List<String> get tags {
    if (widget.template is TemplateModel) {
      return (widget.template as TemplateModel).tags ?? [];
    } else if (widget.template is TemplateListItem) {
      return (widget.template as TemplateListItem).tags;
    }
    return [];
  }

  double get rating {
    if (widget.template is TemplateListItem) {
      return (widget.template as TemplateListItem).rating;
    }
    return 0.0;
  }

  int get usageCount {
    if (widget.template is TemplateListItem) {
      return (widget.template as TemplateListItem).usageCount;
    }
    return 0;
  }

  bool get isPremium {
    if (widget.template is TemplateListItem) {
      return (widget.template as TemplateListItem).isPremium;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovering ? -4.0 : 0.0),
        child: Card(
          elevation: _isHovering ? 8 : 2,
          color: DiscordDesignSystem.backgroundSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusM),
            side: BorderSide(
              color: _isHovering
                  ? DiscordDesignSystem.blurple.withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusM),
            child: Padding(
              padding: const EdgeInsets.all(DiscordDesignSystem.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header: Title + Favorite
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: DiscordDesignSystem.textNormal,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.onFavorite != null)
                        GestureDetector(
                          onTap: widget.onFavorite,
                          child: Icon(
                            widget.isFavorite == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.isFavorite == true
                                ? DiscordDesignSystem.red
                                : DiscordDesignSystem.textMuted,
                            size: 20,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: DiscordDesignSystem.spacingS),

                  // Description
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: DiscordDesignSystem.textMuted,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  const SizedBox(height: DiscordDesignSystem.spacingM),

                  // Tags (show first 2)
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: DiscordDesignSystem.spacingS,
                      runSpacing: DiscordDesignSystem.spacingS,
                      children: tags.take(2).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DiscordDesignSystem.spacingS,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: DiscordDesignSystem.blurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              DiscordDesignSystem.radiusS,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: DiscordDesignSystem.blurple,
                                  fontSize: 11,
                                ),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: DiscordDesignSystem.spacingM),

                  // Footer: Category, Stats, Actions
                  Row(
                    children: [
                      // Category
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DiscordDesignSystem.spacingS,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: DiscordDesignSystem.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            DiscordDesignSystem.radiusS,
                          ),
                        ),
                        child: Text(
                          category,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: DiscordDesignSystem.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                        ),
                      ),

                      if (isPremium) ...[
                        const SizedBox(width: DiscordDesignSystem.spacingS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DiscordDesignSystem.spacingS,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: DiscordDesignSystem.yellow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              DiscordDesignSystem.radiusS,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 12,
                                color: DiscordDesignSystem.yellow,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'PRO',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: DiscordDesignSystem.yellow,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Rating
                      if (rating > 0) ...[
                        Icon(
                          Icons.star,
                          size: 14,
                          color: DiscordDesignSystem.yellow,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: DiscordDesignSystem.textMuted,
                                    fontSize: 11,
                                  ),
                        ),
                        const SizedBox(width: DiscordDesignSystem.spacingS),
                      ],

                      // Usage count
                      if (usageCount > 0) ...[
                        Icon(
                          Icons.trending_up,
                          size: 14,
                          color: DiscordDesignSystem.textMuted,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatCount(usageCount),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: DiscordDesignSystem.textMuted,
                                    fontSize: 11,
                                  ),
                        ),
                      ],
                    ],
                  ),

                  // Action buttons (shown on hover)
                  if (_isHovering &&
                      (widget.onEdit != null ||
                          widget.onDuplicate != null ||
                          widget.onDelete != null)) ...[
                    const SizedBox(height: DiscordDesignSystem.spacingS),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.onEdit != null)
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            onPressed: widget.onEdit!,
                            color: DiscordDesignSystem.blurple,
                          ),
                        if (widget.onDuplicate != null)
                          _buildActionButton(
                            icon: Icons.content_copy_outlined,
                            onPressed: widget.onDuplicate!,
                            color: DiscordDesignSystem.green,
                          ),
                        if (widget.onDelete != null)
                          _buildActionButton(
                            icon: Icons.delete_outline,
                            onPressed: widget.onDelete!,
                            color: DiscordDesignSystem.red,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: DiscordDesignSystem.spacingS),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusS),
        child: Container(
          padding: const EdgeInsets.all(DiscordDesignSystem.spacingS),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusS),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}