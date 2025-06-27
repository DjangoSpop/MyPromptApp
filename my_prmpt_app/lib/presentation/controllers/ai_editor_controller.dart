// lib/presentation/controllers/ai_editor_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_prmpt_app/domain/models/template_model.dart';
import 'package:my_prmpt_app/domain/models/ai_metadata.dart';
import 'package:my_prmpt_app/domain/models/ai_insight.dart';

import '../../data/models/enhanced_template_model.dart';
import '../../data/models/prompt_field.dart';
import '../../domain/services/ai_context_engine.dart';
import '../../domain/services/template_service.dart';

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
  final TemplateService _templateService = Get.find<TemplateService>();

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
  final RxBool isGeneratingInsights = false.obs;

  // Private observable for current template
  final Rx<EnhancedTemplateModel?> _currentTemplate =
      Rx<EnhancedTemplateModel?>(null);
  EnhancedTemplateModel? get currentTemplate => _currentTemplate.value;

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
            id: 'title_short_${DateTime.now().millisecondsSinceEpoch}',
            type: InsightType.optimization,
            title: 'Title Too Short',
            description:
                'Consider making the title more descriptive. Add more context to help users understand the template purpose.',
            confidence: 0.8,
            timestamp: DateTime.now(),
          ));
        }
      }

      // Description analysis
      if (description.value.isNotEmpty) {
        if (description.value.length < 50) {
          insights.add(AIInsight(
            id: 'desc_short_${DateTime.now().millisecondsSinceEpoch}',
            type: InsightType.optimization,
            title: 'Description Needs Detail',
            description:
                'The description could be more comprehensive. Explain what the template helps users accomplish.',
            confidence: 0.7,
            timestamp: DateTime.now(),
          ));
        }
      }

      // Field analysis
      if (fields.length < 3) {
        insights.add(AIInsight(
          id: 'fields_few_${DateTime.now().millisecondsSinceEpoch}',
          type: InsightType.recommendation,
          title: 'Consider More Fields',
          description:
              'Templates with more fields tend to be more comprehensive. Add fields that capture important details for your use case.',
          confidence: 0.6,
          timestamp: DateTime.now(),
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
        id: 'domain_practices_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.trend,
        title: 'Domain Best Practices',
        description:
            'This template aligns with ${topContext.domain} best practices. Consider incorporating: ${topContext.keywords.take(2).join(", ")}',
        confidence: topContext.relevanceScore,
        timestamp: DateTime.now(),
      ));
    }
  }

  /// Generate enhanced AI-powered template suggestions
  Future<void> generateEnhancedTemplateSuggestions(String userInput) async {
    if (!aiAssistantEnabled.value) return;

    try {
      isGeneratingInsights.value = true;
      final suggestions =
          await _aiContextEngine.generateTemplateSuggestions(userInput);

      aiSuggestions.clear();
      aiSuggestions.addAll(suggestions.take(5)); // Top 5 suggestions

      // Add insight about suggestions
      if (suggestions.isNotEmpty) {
        _addInsight(AIInsight(
          id: 'suggestions_generated_${DateTime.now().millisecondsSinceEpoch}',
          type: InsightType.recommendation,
          title: 'AI Suggestions Ready',
          description:
              'Generated ${suggestions.length} template suggestions based on your input',
          confidence: 0.9,
          timestamp: DateTime.now(),
          metadata: {
            'suggestionsCount': suggestions.length,
            'userInput': userInput,
          },
        ));
      }
    } catch (e) {
      _addInsight(AIInsight(
        id: 'suggestion_error_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.warning,
        title: 'AI Suggestion Error',
        description: 'Unable to generate suggestions: ${e.toString()}',
        confidence: 0.5,
        timestamp: DateTime.now(),
      ));
    } finally {
      isGeneratingInsights.value = false;
    }
  }

  /// Perform real-time content analysis and provide insights
  void performRealTimeAnalysis() {
    if (!aiAssistantEnabled.value) return;

    final insights = <AIInsight>[];

    // Analyze template completeness
    final completeness = _calculateTemplateCompleteness();
    if (completeness < 0.7) {
      insights.add(AIInsight(
        id: 'completeness_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.suggestion,
        title: 'Template Needs Enhancement',
        description:
            'Your template is ${(completeness * 100).toInt()}% complete',
        confidence: 0.85,
        timestamp: DateTime.now(),
        metadata: {
          'completeness': completeness,
          'recommendation': 'Add more detailed content and dynamic fields',
        },
      ));
    }

    // Analyze field usage
    final fieldPattern = RegExp(r'\{\{([^}]+)\}\}');
    final fieldMatches = fieldPattern.allMatches(templateContent.value);
    if (fieldMatches.length < 3 && templateContent.value.length > 100) {
      insights.add(AIInsight(
        id: 'fields_${DateTime.now().millisecondsSinceEpoch}',
        type: InsightType.suggestion,
        title: 'Add More Dynamic Fields',
        description: 'Templates with more fields provide better customization',
        confidence: 0.8,
        timestamp: DateTime.now(),
        metadata: {
          'currentFields': fieldMatches.length,
          'recommendation': 'Add {{field_name}} placeholders for user input',
        },
      ));
    }

    // Category optimization
    if (category.value == 'General' && title.value.isNotEmpty) {
      final suggestedCategory = _suggestOptimalCategory(title.value);
      if (suggestedCategory != 'General') {
        insights.add(AIInsight(
          id: 'category_opt_${DateTime.now().millisecondsSinceEpoch}',
          type: InsightType.recommendation,
          title: 'Category Optimization',
          description:
              'Consider moving to "$suggestedCategory" for better discoverability',
          confidence: 0.75,
          timestamp: DateTime.now(),
          metadata: {
            'suggestedCategory': suggestedCategory,
            'currentCategory': category.value,
          },
        ));
      }
    }

    _addInsights(insights);
  }

  /// Enhanced chat with contextual AI responses
  void sendEnhancedChatMessage(String message) {
    if (message.trim().isEmpty) return;

    // Add user message
    chatMessages.add(ChatMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    chatController.clear();

    // Generate contextual AI response
    _generateEnhancedAIResponse(message);
  }

  /// Generate sophisticated AI response based on context
  Future<void> _generateEnhancedAIResponse(String userMessage) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    String response = _generateContextualResponse(userMessage.toLowerCase());

    // Add AI response with typing effect simulation
    chatMessages.add(ChatMessage(
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  /// Generate intelligent contextual responses
  String _generateContextualResponse(String message) {
    // Template structure questions
    if (message.contains('structure') || message.contains('organize')) {
      return """🏗️ **Template Structure Best Practices:**

• **Clear Headings**: Use # for main sections
• **Logical Flow**: Introduction → Main Content → Conclusion
• **Dynamic Fields**: Add {{field_name}} for customization
• **Instructions**: Include helpful guidance for users
• **Examples**: Show sample outputs where helpful

Would you like me to suggest a specific structure for your template?""";
    }

    // Field-related questions
    else if (message.contains('field') || message.contains('placeholder')) {
      return """📝 **Dynamic Field Guidelines:**

• **Descriptive Names**: {{project_name}} not {{name}}
• **Clear Context**: {{target_audience}} not {{audience}}
• **Required vs Optional**: Mark clearly in instructions
• **Field Types**: Text, dropdown, date, number, etc.
• **Validation**: Consider input constraints

Current fields detected: ${_getFieldCount()} 
Suggested minimum: 3-5 fields for good customization""";
    }

    // Content improvement
    else if (message.contains('improve') ||
        message.contains('better') ||
        message.contains('enhance')) {
      final completeness = _calculateTemplateCompleteness();
      return """✨ **Enhancement Suggestions:**

**Current Completeness**: ${(completeness * 100).toInt()}%

**Quick Wins**:
• Add more descriptive field labels
• Include usage examples
• Provide clear instructions
• Use consistent formatting
• Add helpful prompts and tips

**Advanced**:
• Create field dependencies
• Add validation rules
• Include output examples
• Consider accessibility

What specific area would you like to focus on?""";
    }

    // Category and tagging
    else if (message.contains('category') ||
        message.contains('tag') ||
        message.contains('organize')) {
      return """🏷️ **Categorization Tips:**

**Current Category**: ${category.value}
**Suggested**: ${_suggestOptimalCategory(title.value)}

**Good Tags Include**:
• Primary use case (planning, analysis, creative)
• Target audience (developer, manager, student)
• Output type (document, code, presentation)
• Industry (tech, business, education)

**Tag Examples**: project-planning, code-review, content-strategy, business-analysis""";
    }

    // Analytics and performance
    else if (message.contains('analytics') ||
        message.contains('performance') ||
        message.contains('usage')) {
      return """📊 **Template Performance Insights:**

• **Completion Rate**: Higher with 3-7 fields
• **User Engagement**: Clear instructions increase usage by 40%
• **Discoverability**: Good tags improve findability by 60%
• **Quality Score**: Based on structure, fields, and clarity

**Optimization Tips**:
• Test with different user groups
• Monitor completion rates
• Gather user feedback
• Iterate based on usage patterns""";
    }

    // General help
    else {
      return """🤖 **AI Assistant Ready to Help!**

I can assist with:
• **Template Structure** - Organization and flow
• **Dynamic Fields** - Placeholders and customization  
• **Content Quality** - Writing and clarity
• **Categorization** - Tags and discoverability
• **Best Practices** - Industry standards
• **Performance** - Analytics and optimization

**Quick Actions**:
• Say "analyze my template" for comprehensive review
• Ask "suggest fields" for field recommendations
• Type "best practices" for expert tips

What would you like to work on?""";
    }
  }

  /// Apply AI suggestion with enhanced integration
  void applyEnhancedSuggestion(TemplateSuggestion suggestion) {
    final structure = suggestion.templateStructure;

    // Apply template content with user confirmation
    Get.dialog(
      AlertDialog(
        title: Text('Apply AI Suggestion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${suggestion.title}'),
            const SizedBox(height: 8),
            Text('Confidence: ${(suggestion.confidence * 100).toInt()}%'),
            const SizedBox(height: 8),
            Text('This will update your template content. Continue?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Apply the suggestion
              if (structure['template'] != null) {
                templateContent.value = structure['template'];
              }

              // Update metadata
              if (structure['fields'] != null) {
                final aiFields = structure['fields'] as List;
                for (final fieldData in aiFields) {
                  fields.add(PromptField(
                    id: fieldData['id'],
                    label: fieldData['label'],
                    placeholder: fieldData['placeholder'],
                    type: _parseFieldType(fieldData['type']),
                    isRequired: fieldData['isRequired'] ?? false,
                  ));
                }
              }

              // Track usage
              _aiContextEngine.updateContextUsage(suggestion.aiContext.id);

              // Remove applied suggestion
              aiSuggestions.remove(suggestion);

              // Add success insight
              _addInsight(AIInsight(
                id: 'applied_${DateTime.now().millisecondsSinceEpoch}',
                type: InsightType.recommendation,
                title: 'AI Enhancement Applied',
                description: 'Template updated with AI recommendations',
                confidence: 1.0,
                timestamp: DateTime.now(),
                metadata: {
                  'appliedSuggestion': suggestion.title,
                  'confidence': suggestion.confidence,
                },
              ));

              Get.back();
              Get.snackbar(
                'Success',
                'AI suggestion applied successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  /// Enhanced template saving with AI metadata
  Future<void> saveEnhancedTemplate() async {
    if (!_validateEnhancedTemplate()) return;

    try {
      // Create enhanced template with AI metadata
      final aiMetadata = AIMetadata(
        isAIGenerated: aiSuggestions.isNotEmpty,
        confidence: _calculateOverallConfidence(),
        aiModel: 'PromptForge-AI-v2',
        extractedKeywords: _extractKeywords(),
        smartSuggestions: _getSmartSuggestions(),
        contextDomain: _identifyContextDomain(),
        aiProcessedAt: DateTime.now(),
      );

      final enhancedTemplate = EnhancedTemplateModel(
        id: templateId.value,
        title: title.value,
        description: description.value,
        category: category.value,
        templateContent: templateContent.value,
        fields: fields.toList(),
        createdAt: isEditMode.value
            ? currentTemplate?.createdAt ?? DateTime.now()
            : DateTime.now(),
        updatedAt: DateTime.now(),
        author: author.value,
        tags: tags.toList(),
        aiMetadata: aiMetadata,
        analytics: _getAnalyticsData(),
      ); // Save through template service - convert to TemplateModel
      final templateModel = TemplateModel(
        id: enhancedTemplate.id,
        title: enhancedTemplate.title,
        description: enhancedTemplate.description,
        category: enhancedTemplate.category,
        content: enhancedTemplate.templateContent,
        tags: enhancedTemplate.tags ?? [],
        createdBy: enhancedTemplate.author ?? 'anonymous',
        createdAt: enhancedTemplate.createdAt,
        updatedAt: enhancedTemplate.updatedAt,
        usageCount: 0,
        rating: 0.0,
        isPublic: false,
      );

      await _templateService.saveTemplate(templateModel);

      // Track analytics
      _trackTemplateEvent('template_saved', {
        'aiAssisted': aiMetadata.isAIGenerated,
        'confidence': aiMetadata.confidence,
        'suggestionsUsed': aiSuggestions.length,
        'insightsGenerated': aiInsights.length,
      });

      Get.snackbar(
        'Success',
        'Enhanced template saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save template: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Legacy method compatibility for UI
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
      case 'author':
        author.value = value;
        break;
      case 'templateContent':
        templateContent.value = value;
        // Trigger real-time analysis when content changes
        performRealTimeAnalysis();
        break;
    }
  }

  /// Preview template functionality
  void previewTemplate() {
    // Implementation for template preview
    Get.snackbar(
      'Preview',
      'Template preview functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Save template - delegates to enhanced save
  Future<void> saveTemplate() async {
    await saveEnhancedTemplate();
  }

  /// Add a new field to the template
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

  /// Remove a field from the template
  void removeField(int index) {
    if (index >= 0 && index < fields.length) {
      fields.removeAt(index);
    }
  }

  /// Apply AI suggestion (legacy method)
  void applySuggestion(dynamic suggestion) {
    if (suggestion is TemplateSuggestion) {
      applyEnhancedSuggestion(suggestion);
    }
  }

  /// Send chat message (legacy method)
  void sendChatMessage(String message) {
    sendEnhancedChatMessage(message);
  }

  // Enhanced helper methods
  double _calculateTemplateCompleteness() {
    double score = 0.0;

    if (title.value.isNotEmpty) score += 0.2;
    if (description.value.length > 20) score += 0.2;
    if (templateContent.value.length > 50) score += 0.3;
    if (category.value != 'General') score += 0.1;
    if (tags.isNotEmpty) score += 0.1;
    if (fields.isNotEmpty) score += 0.1;

    return score;
  }

  String _suggestOptimalCategory(String title) {
    final titleLower = title.toLowerCase();

    if (titleLower.contains('system') ||
        titleLower.contains('architecture') ||
        titleLower.contains('design')) {
      return 'Software Engineering';
    } else if (titleLower.contains('business') ||
        titleLower.contains('plan') ||
        titleLower.contains('strategy')) {
      return 'Business Strategy';
    } else if (titleLower.contains('content') ||
        titleLower.contains('marketing') ||
        titleLower.contains('brand')) {
      return 'Creative & Content';
    } else if (titleLower.contains('research') ||
        titleLower.contains('analysis') ||
        titleLower.contains('study')) {
      return 'Research & Analysis';
    } else if (titleLower.contains('education') ||
        titleLower.contains('learning') ||
        titleLower.contains('course')) {
      return 'Education & Learning';
    } else if (titleLower.contains('project') ||
        titleLower.contains('management') ||
        titleLower.contains('planning')) {
      return 'Project Management';
    }

    return 'General';
  }

  int _getFieldCount() {
    final fieldPattern = RegExp(r'\{\{([^}]+)\}\}');
    return fieldPattern.allMatches(templateContent.value).length;
  }

  FieldType _parseFieldType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'textarea':
        return FieldType.textarea;
      case 'dropdown':
        return FieldType.dropdown;
      case 'number':
        return FieldType.number;
      case 'checkbox':
        return FieldType.checkbox;
      case 'radio':
        return FieldType.radio;
      default:
        return FieldType.text;
    }
  }

  double _calculateOverallConfidence() {
    if (aiSuggestions.isEmpty) return 0.5;

    final avgConfidence =
        aiSuggestions.map((s) => s.confidence).reduce((a, b) => a + b) /
            aiSuggestions.length;

    return avgConfidence;
  }

  List<String> _extractKeywords() {
    final content =
        '${title.value} ${description.value} ${templateContent.value}'
            .toLowerCase();

    // Extract meaningful keywords (simplified approach)
    final words = content.split(RegExp(r'\W+'));
    final meaningfulWords = words
        .where((word) =>
            word.length > 3 &&
            !['this', 'that', 'with', 'from', 'they', 'have', 'will', 'been']
                .contains(word))
        .toSet();

    return meaningfulWords.take(10).toList();
  }

  Map<String, dynamic> _getSmartSuggestions() {
    return {
      'fieldSuggestions': _getFieldSuggestions(),
      'structureSuggestions': _getStructureSuggestions(),
      'contentSuggestions': _getContentSuggestions(),
    };
  }

  String _identifyContextDomain() {
    final content = '${title.value} ${description.value}'.toLowerCase();

    if (content.contains('code') ||
        content.contains('software') ||
        content.contains('development')) {
      return 'Software Development';
    } else if (content.contains('business') ||
        content.contains('marketing') ||
        content.contains('strategy')) {
      return 'Business';
    } else if (content.contains('creative') ||
        content.contains('design') ||
        content.contains('content')) {
      return 'Creative';
    } else if (content.contains('research') ||
        content.contains('analysis') ||
        content.contains('study')) {
      return 'Research';
    } else if (content.contains('education') ||
        content.contains('learning') ||
        content.contains('training')) {
      return 'Education';
    }

    return 'General';
  }

  Map<String, dynamic> _getAnalyticsData() {
    return {
      'creationTime': DateTime.now().toIso8601String(),
      'aiAssisted': aiAssistantEnabled.value,
      'suggestionsGenerated': aiSuggestions.length,
      'insightsProvided': aiInsights.length,
      'completeness': _calculateTemplateCompleteness(),
      'fieldCount': fields.length,
      'contentLength': templateContent.value.length,
    };
  }

  List<String> _getFieldSuggestions() {
    final suggestions = <String>[];
    final domain = _identifyContextDomain();

    switch (domain) {
      case 'Software Development':
        suggestions.addAll(
            ['project_name', 'technology_stack', 'requirements', 'timeline']);
        break;
      case 'Business':
        suggestions
            .addAll(['company_name', 'target_market', 'budget', 'goals']);
        break;
      case 'Creative':
        suggestions
            .addAll(['brand_name', 'target_audience', 'message', 'style']);
        break;
      default:
        suggestions.addAll(['title', 'description', 'objective', 'outcome']);
    }

    return suggestions;
  }

  List<String> _getStructureSuggestions() {
    return [
      'Add clear section headings',
      'Include introduction and conclusion',
      'Use bullet points for lists',
      'Add examples where helpful',
      'Include next steps section',
    ];
  }

  List<String> _getContentSuggestions() {
    return [
      'Use active voice',
      'Keep sentences concise',
      'Add specific examples',
      'Include actionable items',
      'Use consistent terminology',
    ];
  }

  bool _validateEnhancedTemplate() {
    if (title.value.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Title is required');
      return false;
    }

    if (description.value.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Description is required');
      return false;
    }

    if (templateContent.value.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Template content is required');
      return false;
    }

    if (_calculateTemplateCompleteness() < 0.5) {
      Get.snackbar(
          'Validation Error', 'Template needs more details to be saved');
      return false;
    }

    return true;
  }

  void _trackTemplateEvent(String eventName, Map<String, dynamic> properties) {
    // Integration with analytics service
    print('Analytics Event: $eventName with properties: $properties');
  }

  /// Add a single insight to the collection
  void _addInsight(AIInsight insight) {
    aiInsights.add(insight);
    // Keep only the latest 20 insights
    if (aiInsights.length > 20) {
      aiInsights.removeRange(0, aiInsights.length - 20);
    }
  }

  /// Add multiple insights to the collection
  void _addInsights(List<AIInsight> insights) {
    for (final insight in insights) {
      _addInsight(insight);
    }
  }
}
