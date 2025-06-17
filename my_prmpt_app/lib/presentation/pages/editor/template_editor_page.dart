// lib/presentation/pages/editor/template_editor_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/editor_controller.dart';

/// Page for creating and editing templates
class TemplateEditorPage extends GetView<EditorController> {
  const TemplateEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            controller.isEditMode.value ? 'Edit Template' : 'Create Template')),
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: controller.saveTemplate,
                    child: const Text('Save'),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 24),
            _buildTemplateContent(),
            const SizedBox(height: 24),
            _buildFieldsSection(),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  /// Builds basic template information form
  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Title field
            Obx(() => TextFormField(
                  initialValue: controller.title.value,
                  onChanged: (value) => controller.title.value = value,
                  decoration: const InputDecoration(
                    labelText: 'Template Title *',
                    border: OutlineInputBorder(),
                  ),
                )),

            const SizedBox(height: 16),

            // Description field
            Obx(() => TextFormField(
                  initialValue: controller.description.value,
                  onChanged: (value) => controller.description.value = value,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                )),

            const SizedBox(height: 16),

            // Category and Author row
            Row(
              children: [
                Expanded(
                  child: Obx(() => TextFormField(
                        initialValue: controller.category.value,
                        onChanged: (value) => controller.category.value = value,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => TextFormField(
                        initialValue: controller.author.value,
                        onChanged: (value) => controller.author.value = value,
                        decoration: const InputDecoration(
                          labelText: 'Author',
                          border: OutlineInputBorder(),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds template content editor
  Widget _buildTemplateContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Template Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use {{variable_name}} for placeholders',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => TextFormField(
                  initialValue: controller.templateContent.value,
                  onChanged: (value) =>
                      controller.templateContent.value = value,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText:
                        'Enter your template content with {{placeholders}}...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  style: const TextStyle(fontFamily: 'monospace'),
                )),
          ],
        ),
      ),
    );
  }

  /// Builds fields management section
  Widget _buildFieldsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Form Fields',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: controller.addField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Field'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.fields.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No fields added yet.\nClick "Add Field" to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.fields.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final field = controller.fields[index];
                  return Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  field.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => controller.removeField(index),
                              ),
                            ],
                          ),
                          // Basic field editing could be added here
                          Text(
                            'ID: ${field.id} | Type: ${field.type.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
