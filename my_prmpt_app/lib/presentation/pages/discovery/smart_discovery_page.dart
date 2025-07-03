// lib/presentation/pages/discovery/smart_discovery_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/discovery_controller.dart';
import '../../widgets/ai_suggestion_card.dart';
import '../../widgets/trending_templates_section.dart';
import '../../widgets/personalized_recommendations.dart';

class SmartDiscoveryPage extends GetView<DiscoveryController> {
  const SmartDiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        _buildSearchSection(),
        _buildAISuggestionsSection(),
        _buildTrendingSection(),
        _buildPersonalizedSection(),
        _buildCategoriesSection(),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Discover Templates'),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              const Positioned(
                bottom: 80,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AI-Powered Discovery',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSmartSearchBar(),
            const SizedBox(height: 16),
            _buildQuickFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: TextField(
          onChanged: controller.performAISearch,
          decoration: InputDecoration(
            hintText: 'Describe what you want to create...',
            prefixIcon: const Icon(Icons.psychology),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => controller.isVoiceSearchActive.value
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : IconButton(
                          icon: const Icon(Icons.mic),
                          onPressed: controller.startVoiceSearch,
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: controller.clearSearch,
                ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return SizedBox(
      height: 40,
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.quickFilters.length,
            itemBuilder: (context, index) {
              final filter = controller.quickFilters[index];
              final isSelected = controller.selectedFilters.contains(filter);

              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) => controller.toggleFilter(filter),
                    backgroundColor: Colors.grey[100],
                    selectedColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          )),
    );
  }

  Widget _buildAISuggestionsSection() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.aiSuggestions.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Get.theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI Suggestions for You',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: controller.aiSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = controller.aiSuggestions[index];
                  return SizedBox(
                    width: 300,
                    child: AISuggestionCard(
                      suggestion: suggestion,
                      index: index,
                      onAccept: () => controller.acceptSuggestion(suggestion),
                      onDismiss: () => controller.dismissSuggestion(suggestion),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTrendingSection() {
    return const SliverToBoxAdapter(
      child: TrendingTemplatesSection(),
    );
  }

  Widget _buildPersonalizedSection() {
    return const SliverToBoxAdapter(
      child: PersonalizedRecommendations(),
    );
  }

  Widget _buildCategoriesSection() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final category = controller.categories[index];
            return _buildCategoryCard(context, category);
          },
          childCount: controller.categories.length,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color.withOpacity(0.8),
            category.color.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.navigateToCategory(category),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  category.icon,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.templateCount} templates',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
