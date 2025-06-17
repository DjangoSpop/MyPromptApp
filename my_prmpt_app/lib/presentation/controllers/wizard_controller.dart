// lib/presentation/controllers/wizard_controller.dart
import 'package:get/get.dart';
import '../../data/models/template_model.dart';
import '../../data/models/prompt_field.dart';
import '../../domain/services/prompt_builder.dart';
import '../../domain/services/ai_context_engine.dart';
import '../../domain/services/template_analytics_service.dart';

/// Controller for the prompt building wizard
class WizardController extends GetxController {
  final PromptBuilder _promptBuilder = Get.find<PromptBuilder>();
  final AIContextEngine _aiContextEngine = Get.find<AIContextEngine>();
  final TemplateAnalyticsService _analyticsService =
      Get.find<TemplateAnalyticsService>();

  TemplateModel? _template;
  TemplateModel? get template => _template;
  bool get isTemplateInitialized => _template != null;

  final RxMap<String, dynamic> userInputs = <String, dynamic>{}.obs;
  final RxMap<String, String> validationErrors = <String, String>{}.obs;
  final RxInt currentStep = 0.obs;
  final RxString builtPrompt = ''.obs;
  final RxString previewPrompt = ''.obs;
  final RxDouble completionPercentage = 0.0.obs;

  // Enhanced AI Features
  final RxList<String> aiSuggestions = <String>[].obs;
  final RxBool aiAssistanceEnabled = true.obs;
  final RxString aiInsight = ''.obs;
  final RxBool isAnalyzing = false.obs;

  /// Initializes the wizard with a template
  void initializeWithTemplate(TemplateModel templateModel) {
    _template = templateModel;

    // Track template usage
    _analyticsService.trackTemplateUsage(
      templateModel.id,
      'current_user', // TODO: Get actual user ID
      DateTime.now(),
    );

    // Initialize default values
    for (final field in _template!.fields) {
      if (field.defaultValue != null) {
        userInputs[field.id] = field.defaultValue;
      }
    }

    _updatePreview();
    _updateCompletionPercentage();
    _generateAIInsights();
  }

  /// Updates input value for a field
  void updateInput(String fieldId, dynamic value) {
    userInputs[fieldId] = value;
    validationErrors.remove(fieldId); // Clear previous error
    _updatePreview();
    _updateCompletionPercentage();

    // Generate AI suggestions for the current field
    if (aiAssistanceEnabled.value) {
      _generateFieldSuggestions(fieldId, value);
    }
  }

  /// Validates current step inputs
  bool validateCurrentStep() {
    if (!isTemplateInitialized) return false;
    if (currentStep.value >= _template!.fields.length) return true;

    final field = _template!.fields[currentStep.value];
    final value = userInputs[field.id];

    // Required field validation
    if (field.isRequired &&
        (value == null || (value is String && value.trim().isEmpty))) {
      validationErrors[field.id] = '${field.label} is required';
      return false;
    }

    // Pattern validation
    if (field.validationPattern != null && value != null) {
      final pattern = RegExp(field.validationPattern!);
      if (!pattern.hasMatch(value.toString())) {
        validationErrors[field.id] = 'Invalid format for ${field.label}';
        return false;
      }
    }

    validationErrors.remove(field.id);
    return true;
  }

  /// Validates all inputs and builds final prompt
  bool buildFinalPrompt() {
    if (!isTemplateInitialized) return false;

    final errors = _promptBuilder.validateInputs(_template!, userInputs);
    validationErrors.value = errors;

    if (errors.isEmpty) {
      builtPrompt.value = _promptBuilder.buildPrompt(_template!, userInputs);

      // Track successful completion
      _analyticsService.trackTemplateCompletion(
        _template!.id,
        'current_user', // TODO: Get actual user ID
        userInputs,
      );

      return true;
    }

    return false;
  }

  /// Moves to next step if current step is valid
  bool nextStep() {
    if (!isTemplateInitialized) return false;
    if (validateCurrentStep() && currentStep.value < _template!.fields.length) {
      currentStep.value++;
      return true;
    }
    return false;
  }

  /// Moves to previous step
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Jumps to specific step
  void goToStep(int step) {
    if (!isTemplateInitialized) return;
    if (step >= 0 && step <= _template!.fields.length) {
      currentStep.value = step;
    }
  }

  /// Resets the wizard
  void reset() {
    userInputs.clear();
    validationErrors.clear();
    currentStep.value = 0;
    builtPrompt.value = '';
    previewPrompt.value = '';
    completionPercentage.value = 0.0;

    // Restore default values
    if (isTemplateInitialized) {
      for (final field in _template!.fields) {
        if (field.defaultValue != null) {
          userInputs[field.id] = field.defaultValue;
        }
      }
    }

    _updatePreview();
  }

  /// Updates the preview prompt
  void _updatePreview() {
    if (isTemplateInitialized) {
      previewPrompt.value =
          _promptBuilder.previewPrompt(_template!, userInputs);
    }
  }

  /// Updates completion percentage
  void _updateCompletionPercentage() {
    if (isTemplateInitialized) {
      completionPercentage.value =
          _promptBuilder.getCompletionPercentage(_template!, userInputs);
    }
  }

  /// Generate AI insights for the current template and inputs
  Future<void> _generateAIInsights() async {
    if (!aiAssistanceEnabled.value || !isTemplateInitialized) return;

    isAnalyzing.value = true;

    try {
      final contexts = await _aiContextEngine.getRelevantContext(
        _template!.description,
        _template!.category,
      );

      if (contexts.isNotEmpty) {
        final topContext = contexts.first;
        aiInsight.value =
            'AI Tip: This template works best with ${topContext.context.split(',').first}';
      }
    } catch (e) {
      print('Error generating AI insights: $e');
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Generate AI suggestions for a specific field
  Future<void> _generateFieldSuggestions(String fieldId, dynamic value) async {
    if (!aiAssistanceEnabled.value ||
        value == null ||
        value.toString().isEmpty) {
      aiSuggestions.clear();
      return;
    }

    try {
      final field = _template!.fields.firstWhere((f) => f.id == fieldId);
      final contexts = await _aiContextEngine.getRelevantContext(
        '${field.label} ${value.toString()}',
        _template!.category,
      );

      final suggestions = <String>[];
      for (final context in contexts.take(3)) {
        // Generate contextual suggestions based on AI context
        suggestions.add(
            _generateContextualSuggestion(field, context, value.toString()));
      }

      aiSuggestions.assignAll(suggestions);
    } catch (e) {
      print('Error generating field suggestions: $e');
    }
  }

  String _generateContextualSuggestion(
      PromptField field, dynamic context, String currentValue) {
    // Simple suggestion generation - could be enhanced with actual AI
    switch (field.type) {
      case FieldType.textarea:
        return 'Consider expanding on: $currentValue with specific examples and detailed explanations.';
      case FieldType.text:
        return 'You might want to be more specific about: $currentValue';
      default:
        return 'Try to provide more context for: $currentValue';
    }
  }

  // /// Apply an AI suggestion
  // void applySuggestion(String suggestion) {
  //   final currentField = getCurrentField();
  //   if (currentField != null) {
  //     // Extract the suggested value from the suggestion
  //     // This is a simple implementation - could be more sophisticated
  //     final currentValue = userInputs[currentField.id]?.toString() ?? '';
  //     final enhancedValue = '$currentValue $suggestion';
  //     updateInput(currentField.id, enhancedValue);
  //   }
  // }

  /// Generate AI insights for the current template and inputs
  // Future<void> _generateAIInsights() async {
  //   if (!aiAssistanceEnabled.value || !isTemplateInitialized) return;

  //   isAnalyzing.value = true;

  //   try {
  //     final contexts = await _aiContextEngine.getRelevantContext(
  //       _template!.description,
  //       _template!.category,
  //     );

  //     if (contexts.isNotEmpty) {
  //       final topContext = contexts.first;
  //       aiInsight.value =
  //           'AI Tip: This template works best with ${topContext.context.split(',').first}';
  //     }
  //   } catch (e) {
  //     print('Error generating AI insights: $e');
  //   } finally {
  //     isAnalyzing.value = false;
  //   }
  // }

  /// Generate AI suggestions for a specific field
  // Future<void> _generateFieldSuggestions(String fieldId, dynamic value) async {
  //   if (!aiAssistanceEnabled.value ||
  //       value == null ||
  //       value.toString().isEmpty) {
  //     aiSuggestions.clear();
  //     return;
  //   }

  //   try {
  //     final field = _template!.fields.firstWhere((f) => f.id == fieldId);
  //     final contexts = await _aiContextEngine.getRelevantContext(
  //       '${field.label} ${value.toString()}',
  //       _template!.category,
  //     );

  //     final suggestions = <String>[];
  //     for (final context in contexts.take(3)) {
  //       // Generate contextual suggestions based on AI context
  //       suggestions.add(
  //           _generateContextualSuggestion(field, context, value.toString()));
  //     }

  //     aiSuggestions.assignAll(suggestions);
  //   } catch (e) {
  //     print('Error generating field suggestions: $e');
  //   }
  // }

  // String _generateContextualSuggestion(
  //     PromptField field, dynamic context, String currentValue) {
  //   // Simple suggestion generation - could be enhanced with actual AI
  //   switch (field.type) {
  //     case FieldType.textarea:
  //       return 'Consider expanding on: $currentValue with specific examples and detailed explanations.';
  //     case FieldType.text:
  //       return 'You might want to be more specific about: $currentValue';
  //     default:
  //       return 'Try to provide more context for: $currentValue';
  //   }
  // }

  /// Apply an AI suggestion
  // void applySuggestion(String suggestion) {
  //   final currentFieldData = currentField;
  //   if (currentFieldData != null) {
  //     // Extract the suggested value from the suggestion
  //     // This is a simple implementation - could be more sophisticated
  //     final currentValue = userInputs[currentFieldData.id]?.toString() ?? '';
  //     final enhancedValue = '$currentValue $suggestion';
  //     updateInput(currentFieldData.id, enhancedValue);
  //   }
  // }

  /// Toggle AI assistance
  void toggleAIAssistance() {
    aiAssistanceEnabled.value = !aiAssistanceEnabled.value;
    if (!aiAssistanceEnabled.value) {
      aiSuggestions.clear();
      aiInsight.value = '';
    } else {
      _generateAIInsights();
    }
  }

  /// Gets the current field being edited
  PromptField? get currentField {
    if (!isTemplateInitialized) return null;
    if (currentStep.value < _template!.fields.length) {
      return _template!.fields[currentStep.value];
    }
    return null;
  }

  /// Checks if wizard is complete
  bool get isComplete => isTemplateInitialized
      ? currentStep.value >= _template!.fields.length
      : false;

  /// Gets progress as a percentage (0.0 to 1.0)
  double get progress => !isTemplateInitialized || _template!.fields.isEmpty
      ? 0.0
      : currentStep.value / _template!.fields.length;
}
