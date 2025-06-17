// lib/presentation/pages/editor/ai_assisted_editor_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/ai_editor_controller.dart';
import '../../widgets/ai_suggestion_card.dart';
import '../../../domain/services/template_analytics_service.dart';

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
        Obx(
          () => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: controller.saveTemplate,
                  tooltip: 'Save',
                ),
        ),
      ],
    );
  }

  Widget _buildMainEditor(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBasicInfoSection(context),
          const SizedBox(height: 24),
          _buildContentEditor(context),
          const SizedBox(height: 24),
          _buildFieldsEditor(context),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
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
    // TODO: Implement field editing dialog
    Get.snackbar('Info', 'Field editing will be implemented');
  }

  Widget _buildAIAssistantPanel(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          _buildAIAssistantHeader(context),
          Expanded(
            child: _buildAIAssistantContent(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAssistantHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          const Text(
            'AI Assistant',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Obx(() => Switch(
                value: controller.aiAssistantEnabled.value,
                onChanged: (_) => controller.toggleAIAssistant(),
              )),
        ],
      ),
    );
  }

  Widget _buildAIAssistantContent(BuildContext context) {
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
    return Obx(() {
      if (controller.aiSuggestions.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Suggestions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...controller.aiSuggestions.map((suggestion) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  Icons.lightbulb,
                  color: Colors.amber[600],
                  size: 20,
                ),
                title: Text(
                  suggestion.title,
                  style: const TextStyle(fontSize: 12),
                ),
                subtitle: Text(
                  suggestion.description,
                  style: const TextStyle(fontSize: 10),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () => controller.applySuggestion(suggestion),
                ),
              ),
            );
          }).toList(),
        ],
      );
    });
  }

  Widget _buildAIInsights() {
    return Obx(() {
      if (controller.aiInsights.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Insights',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...controller.aiInsights.map((insight) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: _getInsightColor(insight.type),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      insight.description,
                      style: const TextStyle(fontSize: 10),
                    ),
                    if (insight.recommendation != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        insight.recommendation!,
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      );
    });
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
                      padding: const EdgeInsets.all(8),
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
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
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
                          contentPadding: EdgeInsets.all(8),
                        ),
                        style: const TextStyle(fontSize: 12),
                        onSubmitted: controller.sendChatMessage,
                      ),
                    ),
                    Obx(
                      () => controller.isGeneratingResponse.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send, size: 16),
                              onPressed: () => controller.sendChatMessage(
                                  controller.chatController.text),
                            ),
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

  Widget _buildChatMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: message.isUser ? Get.theme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 10,
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.optimization:
        return Colors.orange[50]!;
      case InsightType.popularity:
        return Colors.green[50]!;
      case InsightType.trend:
        return Colors.blue[50]!;
      case InsightType.recommendation:
        return Colors.purple[50]!;
    }
  }
}
