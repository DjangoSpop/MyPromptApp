// lib/presentation/controllers/ai_editor_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_prmpt_app/domain/models/ai_metadata.dart';
import '../../data/models/enhanced_template_model.dart';
import '../../data/models/prompt_field.dart';
import '../../domain/services/ai_context_engine.dart';
import '../../domain/services/template_analytics_service.dart';
import '../../domain/models/ai_context.dart';

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class AIEditorController extends GetxController {
  final AIContextEngine _aiContextEngine = Get.find<AIContextEngine>();
  final TemplateAnalyticsService _analyticsService =
      Get.find<TemplateAnalyticsService>();

  // Template properties
  final RxBool isEditMode = false.obs;
  final RxBool isLoading = false.obs;
  final RxString templateId = ''.obs;
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxString category = ''.obs;
  final RxString templateContent = ''.obs;
  final RxString author = ''.obs;
  final RxList<String> tags = <String>[].obs;
  final RxList<PromptField> fields = <PromptField>[].obs;

  // AI Assistant properties
  final RxBool aiAssistantEnabled = true.obs;
  final RxList<TemplateSuggestion> aiSuggestions = <TemplateSuggestion>[].obs;
  final RxList<AIInsight> aiInsights = <AIInsight>[].obs;
  final RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;
  final TextEditingController chatController = TextEditingController();
  final RxBool isGeneratingResponse = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTemplate();
    _initializeAIAssistant();
  }

  @override
  void onClose() {
    chatController.dispose();
    super.onClose();
  }

  void _initializeTemplate() {
    final existingTemplate = Get.arguments as EnhancedTemplateModel?;
    if (existingTemplate != null) {
      _loadTemplate(existingTemplate);
    } else {
      _createNewTemplate();
    }
  }

  void _loadTemplate(EnhancedTemplateModel template) {
    isEditMode.value = true;
    templateId.value = template.id;
    title.value = template.title;
    description.value = template.description;
    category.value = template.category;
    templateContent.value = template.templateContent;
    author.value = template.author ?? '';
    tags.assignAll(template.tags ?? []);
    fields.assignAll(template.fields);
  }

  void _createNewTemplate() {
    isEditMode.value = false;
    templateId.value = 'template_${DateTime.now().millisecondsSinceEpoch}';
    title.value = '';
    description.value = '';
    category.value = 'General';
    templateContent.value = '';
    author.value = 'User';
    tags.clear();
    fields.clear();
  }

  void _initializeAIAssistant() {
    if (aiAssistantEnabled.value) {
      _generateInitialSuggestions();
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    chatMessages.add(ChatMessage(
      content:
          'Hello! I\'m your AI assistant. I can help you create better templates by providing suggestions, insights, and answering questions about template design.',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  /// Toggle AI assistant on/off
  void toggleAIAssistant() {
    aiAssistantEnabled.value = !aiAssistantEnabled.value;
    if (aiAssistantEnabled.value) {
      _generateInitialSuggestions();
      if (chatMessages.isEmpty) {
        _addWelcomeMessage();
      }
    } else {
      aiSuggestions.clear();
      aiInsights.clear();
    }
  }

  /// Generate initial AI suggestions
  Future<void> _generateInitialSuggestions() async {
    if (!aiAssistantEnabled.value) return;

    try {
      final suggestions = await _aiContextEngine.generateTemplateSuggestions(
        '${title.value} ${description.value} ${category.value}'.trim(),
      );
      aiSuggestions.assignAll(suggestions.take(3));

      // Generate insights
      await _generateAIInsights();
    } catch (e) {
      print('Error generating initial suggestions: $e');
    }
  }

  /// Generate AI insights for the current template
  Future<void> _generateAIInsights() async {
    if (!aiAssistantEnabled.value) return;

    try {
      final insights = <AIInsight>[];

      // Title analysis
      if (title.value.isNotEmpty) {
        if (title.value.length < 10) {
          insights.add(AIInsight(
            type: InsightType.optimization,
            title: 'Title Too Short',
            description: 'Consider making the title more descriptive',
            confidence: 0.8,
            actionable: true,
            recommendation:
                'Add more context to help users understand the template purpose',
          ));
        }
      }

      // Description analysis
      if (description.value.isNotEmpty) {
        if (description.value.length < 50) {
          insights.add(AIInsight(
            type: InsightType.optimization,
            title: 'Description Needs Detail',
            description: 'The description could be more comprehensive',
            confidence: 0.7,
            actionable: true,
            recommendation: 'Explain what the template helps users accomplish',
          ));
        }
      }

      // Field analysis
      if (fields.length < 3) {
        insights.add(AIInsight(
          type: InsightType.recommendation,
          title: 'Consider More Fields',
          description:
              'Templates with more fields tend to be more comprehensive',
          confidence: 0.6,
          actionable: true,
          recommendation:
              'Add fields that capture important details for your use case',
        ));
      }

      // Category-specific insights
      await _generateCategorySpecificInsights(insights);

      aiInsights.assignAll(insights);
    } catch (e) {
      print('Error generating AI insights: $e');
    }
  }

  Future<void> _generateCategorySpecificInsights(
      List<AIInsight> insights) async {
    final contexts = await _aiContextEngine.getRelevantContext(
      description.value,
      category.value,
    );

    if (contexts.isNotEmpty) {
      final topContext = contexts.first;
      insights.add(AIInsight(
        type: InsightType.trend,
        title: 'Domain Best Practices',
        description:
            'This template aligns with ${topContext.domain} best practices',
        confidence: topContext.relevanceScore,
        actionable: false,
        recommendation:
            'Consider incorporating: ${topContext.keywords.take(2).join(", ")}',
      ));
    }
  }

  /// Apply an AI suggestion
  void applySuggestion(TemplateSuggestion suggestion) {
    final structure = suggestion.templateStructure;

    // Update template with suggestion
    if (title.value.isEmpty) {
      title.value = suggestion.title;
    }

    if (description.value.isEmpty) {
      description.value = suggestion.description;
    }

    // Add suggested fields
    if (structure['fields'] != null) {
      final suggestedFields = structure['fields'] as List;
      for (final fieldData in suggestedFields) {
        final field = PromptField(
          id: fieldData['id'] as String,
          label: fieldData['label'] as String,
          placeholder: fieldData['placeholder'] as String,
          type: _parseFieldType(fieldData['type'] as String),
          isRequired: fieldData['isRequired'] as bool? ?? false,
        );
        fields.add(field);
      }
    }

    // Update template content
    if (structure['template'] != null && templateContent.value.isEmpty) {
      templateContent.value = structure['template'] as String;
    }

    // Remove the applied suggestion
    aiSuggestions.remove(suggestion);

    Get.snackbar(
      'Suggestion Applied',
      'Template updated with AI suggestions',
      duration: const Duration(seconds: 2),
    );

    // Regenerate insights after applying suggestion
    _generateAIInsights();
  }

  FieldType _parseFieldType(String type) {
    switch (type.toLowerCase()) {
      case 'textarea':
        return FieldType.textarea;
      case 'dropdown':
        return FieldType.dropdown;
      case 'checkbox':
        return FieldType.checkbox;
      case 'radio':
        return FieldType.radio;
      case 'number':
        return FieldType.number;
      default:
        return FieldType.text;
    }
  }

  /// Send chat message to AI
  Future<void> sendChatMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    chatMessages.add(ChatMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    chatController.clear();
    isGeneratingResponse.value = true;

    try {
      // Generate AI response
      final response = await _generateAIResponse(message);

      chatMessages.add(ChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      chatMessages.add(ChatMessage(
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      isGeneratingResponse.value = false;
    }
  }

  Future<String> _generateAIResponse(String userMessage) async {
    // Simple AI response generation based on keywords
    final message = userMessage.toLowerCase();

    if (message.contains('field') || message.contains('input')) {
      return 'For fields, consider the user\'s workflow. Required fields should capture essential information, while optional fields can provide additional context. Use clear labels and helpful placeholders.';
    } else if (message.contains('template') || message.contains('content')) {
      return 'Template content should use placeholders like {{field_name}} that match your field IDs. Structure your template logically with clear sections and helpful formatting.';
    } else if (message.contains('category') || message.contains('type')) {
      return 'Choose a category that best represents your template\'s purpose. This helps users discover your template and enables better AI suggestions.';
    } else if (message.contains('title') || message.contains('name')) {
      return 'A good title is descriptive and specific. It should immediately tell users what the template helps them accomplish.';
    } else if (message.contains('description')) {
      return 'The description should explain the template\'s purpose, who should use it, and what outcome they can expect. Be specific about the use case.';
    } else {
      return 'I can help you with template structure, field design, content organization, and best practices. What specific aspect would you like assistance with?';
    }
  }

  /// Preview template
  void previewTemplate() {
    if (title.value.isEmpty) {
      Get.snackbar('Error', 'Please add a title first');
      return;
    }

    // Navigate to preview
    Get.toNamed('/template-preview', arguments: {
      'template': _buildTemplateModel(),
    });
  }

  /// Save template
  Future<void> saveTemplate() async {
    if (!_validateTemplate()) return;

    isLoading.value = true;

    try {
      final template = _buildTemplateModel();
      // TODO: Save to repository

      Get.snackbar('Success', 'Template saved successfully');

      if (!isEditMode.value) {
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save template: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateTemplate() {
    if (title.value.trim().isEmpty) {
      Get.snackbar('Error', 'Title is required');
      return false;
    }

    if (description.value.trim().isEmpty) {
      Get.snackbar('Error', 'Description is required');
      return false;
    }

    if (templateContent.value.trim().isEmpty) {
      Get.snackbar('Error', 'Template content is required');
      return false;
    }

    return true;
  }

  EnhancedTemplateModel _buildTemplateModel() {
    return EnhancedTemplateModel(
      id: templateId.value,
      title: title.value,
      description: description.value,
      category: category.value,
      templateContent: templateContent.value,
      fields: fields.toList(),
      createdAt: isEditMode.value ? DateTime.now() : DateTime.now(),
      updatedAt: DateTime.now(),
      author: author.value,
      tags: tags.toList(),
      aiMetadata: aiAssistantEnabled.value
          ? AIMetadata(
              isAIGenerated: false,
              confidence: 0.0,
              aiModel: 'PromptForge-AI-v2',
              aiProcessedAt: DateTime.now(),
            )
          : null,
    );
  }

  /// Update template property
  void updateProperty(String property, String value) {
    switch (property) {
      case 'title':
        title.value = value;
        break;
      case 'description':
        description.value = value;
        break;
      case 'category':
        category.value = value;
        break;
      case 'templateContent':
        templateContent.value = value;
        break;
      case 'author':
        author.value = value;
        break;
    }

    // Regenerate suggestions when key properties change
    if (['title', 'description', 'category'].contains(property)) {
      _generateInitialSuggestions();
    }
  }

  /// Add a new field
  void addField() {
    final newField = PromptField(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}',
      label: 'New Field',
      placeholder: 'Enter value...',
      type: FieldType.text,
      isRequired: false,
    );
    fields.add(newField);
  }

  /// Remove a field
  void removeField(int index) {
    if (index >= 0 && index < fields.length) {
      fields.removeAt(index);
    }
  }

  /// Update a field
  void updateField(int index, PromptField updatedField) {
    if (index >= 0 && index < fields.length) {
      fields[index] = updatedField;
    }
  }
}
