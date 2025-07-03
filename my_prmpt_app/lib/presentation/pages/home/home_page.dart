// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../data/models/template_api_models.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/template_card.dart' as template;

/// Home page displaying template gallery
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom app bar content
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Prompt Forge',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // Refresh button
              Obx(() => IconButton(
                    onPressed: controller.isRefreshing.value
                        ? null
                        : controller.refreshTemplates,
                    icon: controller.isRefreshing.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    tooltip: 'Refresh Templates',
                  )),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => Get.toNamed('/editor'),
              ),
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'import',
                    child: ListTile(
                      leading: Icon(Icons.file_upload),
                      title: Text('Import Templates'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.file_download),
                      title: Text('Export All'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Template body content
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.filteredTemplates.isEmpty) {
              return _buildEmptyState();
            }

            return CustomScrollView(
              slivers: [
                // Template Status Card
                SliverToBoxAdapter(child: _buildTemplateStatusCard()),

                // Search + Category Filter
                SliverToBoxAdapter(child: _buildSearchAndFilter()),

                // Templates Grid
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = controller.filteredTemplates[index];
                        return template.TemplateCard(
                          template: item,
                          onTap: () => _openWizard(item),
                          onEdit: () => _editTemplate(item),
                          onDuplicate: () => controller.duplicateTemplate(item),
                          onDelete: () => _confirmDelete(item),
                        );
                      },
                      childCount: controller.filteredTemplates.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  /// Builds search bar and category filter
  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            decoration: InputDecoration(
              hintText: 'Search templates...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 12),
          // Category filter
          SizedBox(
            height: 40,
            child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    final isSelected =
                        controller.selectedCategory.value == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) =>
                            controller.selectedCategory.value = category,
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  /// Builds the template grid
  Widget _buildTemplateGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredTemplates.isEmpty) {
        return _buildEmptyState();
      }

      return AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: controller.filteredTemplates.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: template.TemplateCard(
                    template: controller.filteredTemplates[index],
                    onTap: () =>
                        _openWizard(controller.filteredTemplates[index]),
                    onEdit: () =>
                        _editTemplate(controller.filteredTemplates[index]),
                    onDuplicate: () => controller
                        .duplicateTemplate(controller.filteredTemplates[index]),
                    onDelete: () =>
                        _confirmDelete(controller.filteredTemplates[index]),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// Builds empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No templates found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first template or import existing ones',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed('/editor'),
            icon: const Icon(Icons.add),
            label: const Text('Create Template'),
          ),
        ],
      ),
    );
  }

  /// Builds template status card
  Widget _buildTemplateStatusCard() {
    return Obx(() {
      if (controller.templates.isEmpty && !controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Get.theme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Template Library',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    controller.templateStatus,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (controller.totalTemplates.value > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatItem(
                      icon: Icons.library_books,
                      label: 'Total',
                      value: controller.totalTemplates.value.toString(),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.category,
                      label: 'Categories',
                      value: (controller.categories.length - 1).toString(),
                      color: Colors.green,
                    ),
                    const Spacer(),
                    if (controller.templatesByCategory.isNotEmpty)
                      Text(
                        'Most: ${controller.templatesByCategory.entries.fold<MapEntry<String, int>>(
                              controller.templatesByCategory.entries.first,
                              (a, b) => a.value > b.value ? a : b,
                            ).key}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Handles menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'import':
        _showImportDialog();
        break;
      case 'export':
        _exportAllTemplates();
        break;
    }
  }

  /// Opens template wizard
  void _openWizard(TemplateListItem template) {
    Get.toNamed('/wizard', arguments: template.toTemplateModel());
  }

  /// Opens template editor
  void _editTemplate(template) {
    Get.toNamed('/editor', arguments: template);
  }

  /// Confirms template deletion
  void _confirmDelete(template) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteTemplate(template.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Shows import dialog
  void _showImportDialog() {
    final textController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Import Templates'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: textController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste JSON content here...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Get.back();
                controller.importTemplates(textController.text);
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  /// Exports all templates
  void _exportAllTemplates() async {
    final templateIds = controller.templates.map((t) => t.id).toList();
    if (templateIds.isNotEmpty) {
      final json = await controller.exportTemplates(templateIds);
      if (json.isNotEmpty) {
        _showExportDialog(json);
      }
    }
  }

  /// Shows export result dialog
  void _showExportDialog(String json) {
    Get.dialog(
      AlertDialog(
        title: const Text('Export Templates'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: SelectableText(
              json,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Copy to clipboard or share
              Get.back();
              Get.snackbar('Success', 'Templates exported successfully');
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}
