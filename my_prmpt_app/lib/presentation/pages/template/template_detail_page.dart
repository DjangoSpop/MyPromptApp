// lib/presentation/pages/template/template_detail_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../app/themes/discord_design_system.dart';
import '../../controllers/template_detail_controller.dart';

/// Template Detail Page with Discord Design
///
/// Features:
/// - Full template information
/// - Rating system (5 stars)
/// - Favorite toggle
/// - Usage tracking with XP rewards
/// - Reviews section
/// - Professional Discord-inspired UI
class TemplateDetailPage extends GetView<TemplateDetailController> {
  const TemplateDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiscordDesignSystem.backgroundPrimary,
      body: Obx(() {
        if (controller.isLoading.value && controller.template.value == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(DiscordDesignSystem.blurple),
            ),
          );
        }

        final template = controller.template.value;
        if (template == null) {
          return _buildErrorState();
        }

        return CustomScrollView(
          slivers: [
            // App Bar
            _buildAppBar(template),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(DiscordDesignSystem.spacingM),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Template Info Card
                  _buildInfoCard(template),

                  const SizedBox(height: DiscordDesignSystem.spacingM),

                  // Description
                  _buildDescriptionSection(template),

                  const SizedBox(height: DiscordDesignSystem.spacingM),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: DiscordDesignSystem.spacingL),

                  // Stats Section
                  _buildStatsSection(template),

                  const SizedBox(height: DiscordDesignSystem.spacingL),

                  // Reviews Section
                  _buildReviewsSection(),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Build app bar
  Widget _buildAppBar(dynamic template) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: DiscordDesignSystem.backgroundSecondary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: DiscordDesignSystem.textNormal),
        onPressed: () => Get.back(),
      ),
      actions: [
        // Favorite button
        Obx(() => IconButton(
          icon: Icon(
            controller.isFavorite.value ? Icons.favorite : Icons.favorite_border,
            color: controller.isFavorite.value
                ? DiscordDesignSystem.red
                : DiscordDesignSystem.textMuted,
          ),
          onPressed: controller.toggleFavorite,
        )),

        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: DiscordDesignSystem.textNormal),
          onSelected: (value) {
            switch (value) {
              case 'share':
                controller.shareTemplate();
                break;
              case 'edit':
                controller.editTemplate();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 12),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 12),
                  Text('Edit'),
                ],
              ),
            ),
          ],
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          template.title,
          style: const TextStyle(
            color: DiscordDesignSystem.textNormal,
            fontWeight: FontWeight.w600,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16, right: 56),
      ),
    );
  }

  /// Build template info card
  Widget _buildInfoCard(dynamic template) {
    return Container(
      padding: const EdgeInsets.all(DiscordDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: DiscordDesignSystem.backgroundSecondary,
        borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category and Premium Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DiscordDesignSystem.spacingS,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: DiscordDesignSystem.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusS),
                ),
                child: Text(
                  template.category,
                  style: const TextStyle(
                    color: DiscordDesignSystem.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),

              if (template.isPremium) ...[
                const SizedBox(width: DiscordDesignSystem.spacingS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DiscordDesignSystem.spacingS,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DiscordDesignSystem.yellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusS),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: DiscordDesignSystem.yellow),
                      SizedBox(width: 4),
                      Text(
                        'PRO',
                        style: TextStyle(
                          color: DiscordDesignSystem.yellow,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: DiscordDesignSystem.spacingM),

          // Rating
          Row(
            children: [
              ...List.generate(5, (index) {
                final starValue = index + 1;
                return Icon(
                  starValue <= template.rating
                      ? Icons.star
                      : Icons.star_border,
                  color: DiscordDesignSystem.yellow,
                  size: 24,
                );
              }),
              const SizedBox(width: DiscordDesignSystem.spacingS),
              Text(
                template.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: DiscordDesignSystem.textNormal,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Obx(() => Text(
                '(${controller.reviews.length} reviews)',
                style: const TextStyle(
                  color: DiscordDesignSystem.textMuted,
                  fontSize: 14,
                ),
              )),
            ],
          ),

          const SizedBox(height: DiscordDesignSystem.spacingM),

          // Tags
          if (template.tags.isNotEmpty)
            Wrap(
              spacing: DiscordDesignSystem.spacingS,
              runSpacing: DiscordDesignSystem.spacingS,
              children: template.tags.map<Widget>((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DiscordDesignSystem.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: DiscordDesignSystem.blurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusS),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: DiscordDesignSystem.blurple,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Build description section
  Widget _buildDescriptionSection(dynamic template) {
    return Container(
      padding: const EdgeInsets.all(DiscordDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: DiscordDesignSystem.backgroundSecondary,
        borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              color: DiscordDesignSystem.textNormal,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DiscordDesignSystem.spacingS),
          Text(
            template.description,
            style: const TextStyle(
              color: DiscordDesignSystem.textMuted,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: controller.useTemplate,
            icon: const Icon(Icons.play_arrow, size: 20),
            label: const Text('Use Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DiscordDesignSystem.blurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusM),
              ),
            ),
          ),
        ),

        const SizedBox(width: DiscordDesignSystem.spacingS),

        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.showRatingModal,
            icon: const Icon(Icons.star_outline, size: 20),
            label: const Text('Rate'),
            style: OutlinedButton.styleFrom(
              foregroundColor: DiscordDesignSystem.blurple,
              side: const BorderSide(color: DiscordDesignSystem.blurple),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusM),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build stats section
  Widget _buildStatsSection(dynamic template) {
    return Container(
      padding: const EdgeInsets.all(DiscordDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: DiscordDesignSystem.backgroundSecondary,
        borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              color: DiscordDesignSystem.textNormal,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DiscordDesignSystem.spacingM),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Uses',
                  value: _formatCount(template.usageCount),
                  color: DiscordDesignSystem.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.favorite,
                  label: 'Favorites',
                  value: '0', // TODO: Get from backend
                  color: DiscordDesignSystem.red,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_today,
                  label: 'Created',
                  value: timeago.format(template.createdAt, locale: 'en_short'),
                  color: DiscordDesignSystem.blurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build stat item
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: DiscordDesignSystem.spacingS),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: DiscordDesignSystem.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Build reviews section
  Widget _buildReviewsSection() {
    return Container(
      padding: const EdgeInsets.all(DiscordDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: DiscordDesignSystem.backgroundSecondary,
        borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(
              color: DiscordDesignSystem.textNormal,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DiscordDesignSystem.spacingM),

          Obx(() {
            if (controller.isLoadingReviews.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(DiscordDesignSystem.spacingM),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(DiscordDesignSystem.blurple),
                  ),
                ),
              );
            }

            if (controller.reviews.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(DiscordDesignSystem.spacingL),
                  child: Text(
                    'No reviews yet. Be the first to review!',
                    style: TextStyle(
                      color: DiscordDesignSystem.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: controller.reviews.map((review) {
                return _buildReviewItem(review);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  /// Build review item
  Widget _buildReviewItem(Map<String, dynamic> review) {
    final rating = (review['rating'] ?? 0).toDouble();
    final comment = review['comment']?.toString() ?? '';
    final userName = review['user']?['username']?.toString() ?? 'Anonymous';
    final createdAt = DateTime.tryParse(review['created_at']?.toString() ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: DiscordDesignSystem.spacingM),
      padding: const EdgeInsets.all(DiscordDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: DiscordDesignSystem.backgroundPrimary,
        borderRadius: BorderRadius.circular(DiscordDesignSystem.radiusS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: DiscordDesignSystem.blurple,
                radius: 16,
                child: Text(
                  userName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: DiscordDesignSystem.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: DiscordDesignSystem.textNormal,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (createdAt != null)
                      Text(
                        timeago.format(createdAt),
                        style: const TextStyle(
                          color: DiscordDesignSystem.textMuted,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: DiscordDesignSystem.yellow,
                    size: 16,
                  );
                }),
              ),
            ],
          ),

          if (comment.isNotEmpty) ...[
            const SizedBox(height: DiscordDesignSystem.spacingS),
            Text(
              comment,
              style: const TextStyle(
                color: DiscordDesignSystem.textMuted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: DiscordDesignSystem.textMuted,
          ),
          const SizedBox(height: DiscordDesignSystem.spacingM),
          const Text(
            'Template not found',
            style: TextStyle(
              color: DiscordDesignSystem.textNormal,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DiscordDesignSystem.spacingS),
          const Text(
            'This template may have been deleted',
            style: TextStyle(
              color: DiscordDesignSystem.textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: DiscordDesignSystem.spacingL),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: DiscordDesignSystem.blurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  /// Format count (1K, 1M)
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
