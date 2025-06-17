// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/template_card.dart';

/// Home page displaying template gallery
class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Forge'),
        actions: [
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
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildTemplateGrid()),
        ],
      ),
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
                final isSelected = controller.selectedCategory.value == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => controller.selectedCategory.value = category,
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
                  child: TemplateCard(
                    template: controller.filteredTemplates[index],
                    onTap: () => _openWizard(controller.filteredTemplates[index]),
                    onEdit: () => _editTemplate(controller.filteredTemplates[index]),
                    onDuplicate: () => controller.duplicateTemplate(
                      controller.filteredTemplates[index]
                    ),
                    onDelete: () => _confirmDelete(
                      controller.filteredTemplates[index]
                    ),
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
  void _openWizard(template) {
    Get.toNamed('/wizard', arguments: template);
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