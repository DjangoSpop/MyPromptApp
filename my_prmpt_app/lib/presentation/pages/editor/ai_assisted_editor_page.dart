// lib/presentation/pages/editor/ai_assisted_editor_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ai_editor_controller.dart';
import '../../widgets/ai_enhanced_widgets.dart';

class AIAssistedEditorPage extends GetView<AIEditorController> {
  const AIAssistedEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Row(
        children: [
          Expanded(
            flex: 7,
            child: _buildMainEditor(context),
          ),
          Container(
            width: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            flex: 3,
            child: _buildAIAssistantPanel(context),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Obx(() => Text(
          controller.isEditMode.value ? 'Edit Template' : 'Create Template')),
      actions: [
        Obx(() => IconButton(
              icon: Icon(
                controller.aiAssistantEnabled.value
                    ? Icons.psychology
                    : Icons.psychology_outlined,
                color: controller.aiAssistantEnabled.value
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              onPressed: controller.toggleAIAssistant,
              tooltip: 'AI Assistant',
            )),
        IconButton(
          icon: const Icon(Icons.preview),
          onPressed: controller.previewTemplate,
          tooltip: 'Preview',
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: controller.saveTemplate,
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildMainEditor(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTemplateInfo(context),
          const SizedBox(height: 24),
          _buildContentEditor(context),
          const SizedBox(height: 24),
          _buildFieldsEditor(context),
        ],
      ),
    );
  }

  Widget _buildTemplateInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Template Information',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Obx(() => TextFormField(
                  initialValue: controller.title.value,
                  onChanged: (value) =>
                      controller.updateProperty('title', value),
                  decoration: const InputDecoration(
                    labelText: 'Template Title',
                    hintText: 'Enter a descriptive title...',
                    border: OutlineInputBorder(),
                  ),
                )),
            const SizedBox(height: 16),
            Obx(() => TextFormField(
                  initialValue: controller.description.value,
                  onChanged: (value) =>
                      controller.updateProperty('description', value),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe what this template is for...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.category.value.isEmpty
                            ? null
                            : controller.category.value,
                        onChanged: (value) =>
                            controller.updateProperty('category', value ?? ''),
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'General', child: Text('General')),
                          DropdownMenuItem(
                              value: 'Software Engineering',
                              child: Text('Software Engineering')),
                          DropdownMenuItem(
                              value: 'Business Strategy',
                              child: Text('Business Strategy')),
                          DropdownMenuItem(
                              value: 'Creative Content',
                              child: Text('Creative Content')),
                          DropdownMenuItem(
                              value: 'Education', child: Text('Education')),
                          DropdownMenuItem(
                              value: 'Research', child: Text('Research')),
                          DropdownMenuItem(
                              value: 'Marketing', child: Text('Marketing')),
                        ],
                      )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => TextFormField(
                        initialValue: controller.author.value,
                        onChanged: (value) =>
                            controller.updateProperty('author', value),
                        decoration: const InputDecoration(
                          labelText: 'Author',
                          border: OutlineInputBorder(),
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTagsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              children: [
                ...controller.tags.map((tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => controller.tags.remove(tag),
                    )),
                ActionChip(
                  label: const Text('+ Add Tag'),
                  onPressed: _showAddTagDialog,
                ),
              ],
            )),
      ],
    );
  }

  void _showAddTagDialog() {
    final textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Enter tag name...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final tag = textController.text.trim();
              if (tag.isNotEmpty && !controller.tags.contains(tag)) {
                controller.tags.add(tag);
              }
              Get.back();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentEditor(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Template Content',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Use {{field_id}} to insert field placeholders',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => TextFormField(
                  initialValue: controller.templateContent.value,
                  onChanged: (value) =>
                      controller.updateProperty('templateContent', value),
                  maxLines: 15,
                  decoration: const InputDecoration(
                    hintText:
                        'Enter your template content here...\n\nUse {{field_name}} for placeholders',
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

  Widget _buildFieldsEditor(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Template Fields',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
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
                return Container(
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.input,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No fields added yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.fields.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final field = controller.fields[index];
                  return _buildFieldCard(field, index);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldCard(field, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  field.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _editField(field, index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                onPressed: () => controller.removeField(index),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('ID: ${field.id}'),
          Text('Type: ${field.type.name}'),
          if (field.isRequired)
            const Text(
              'Required',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (field.placeholder.isNotEmpty)
            Text('Placeholder: ${field.placeholder}'),
        ],
      ),
    );
  }

  void _editField(field, int index) {
    Get.snackbar('Info', 'Field editing will be implemented');
  }

  Widget _buildAIAssistantPanel(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: _buildAIContent(),
    );
  }

  Widget _buildAIContent() {
    return Obx(() {
      if (!controller.aiAssistantEnabled.value) {
        return const Center(
          child: Text('AI Assistant is disabled'),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAISuggestions(),
            const SizedBox(height: 16),
            _buildAIInsights(),
            const SizedBox(height: 16),
            _buildAIChat(),
          ],
        ),
      );
    });
  }

  Widget _buildAISuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'AI Suggestions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Obx(() => controller.isGeneratingInsights.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh, size: 16),
                    onPressed: () => controller.generateEnhancedTemplateSuggestions(
                        '${controller.title.value} ${controller.description.value}'),
                    tooltip: 'Generate AI suggestions',
                  )),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.aiSuggestions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 24, color: Colors.grey[400]),
                  const SizedBox(height: 4),
                  Text(
                    'No suggestions yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: controller.aiSuggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              return AISuggestionCard(
                suggestion: suggestion,
                onAccept: () => controller.applyEnhancedSuggestion(suggestion),
                onDismiss: () => controller.aiSuggestions.removeAt(index),
                index: index,
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildAIInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'AI Insights',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.analytics_outlined, size: 16),
              onPressed: () => controller.performRealTimeAnalysis(),
              tooltip: 'Analyze template',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.aiInsights.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.insights, size: 24, color: Colors.grey[400]),
                  const SizedBox(height: 4),
                  Text(
                    'No insights yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: controller.aiInsights.asMap().entries.map((entry) {
              final index = entry.key;
              final insight = entry.value;
              return AIInsightCard(
                insight: insight,
                onAction: () {
                  controller.aiInsights.removeAt(index);
                },
                isCompact: true,
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildAIChat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ask AI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Expanded(
                child: Obx(() => ListView.builder(
                      itemCount: controller.chatMessages.length,
                      itemBuilder: (context, index) {
                        final message = controller.chatMessages[index];
                        return _buildChatMessage(message);
                      },
                    )),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.chatController,
                        decoration: const InputDecoration(
                          hintText: 'Ask about your template...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 12),
                        onSubmitted: controller.sendChatMessage,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, size: 16),
                      onPressed: () => controller
                          .sendChatMessage(controller.chatController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessage(dynamic message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: message.isUser ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              message.isUser ? Icons.person : Icons.smart_toy,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.content,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
