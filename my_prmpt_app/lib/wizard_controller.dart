// lib/presentation/controllers/wizard_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../data/models/template_model.dart';
import '../../data/models/prompt_field.dart';
import '../../domain/services/prompt_builder.dart';

/// Controller for the prompt building wizard
class WizardController extends GetxController {
  final PromptBuilder _promptBuilder = Get.find<PromptBuilder>();

  late TemplateModel template;
  final RxMap<String, dynamic> userInputs = <String, dynamic>{}.obs;
  final RxMap<String, String> validationErrors = <String, String>{}.obs;
  final RxInt currentStep = 0.obs;
  final RxString builtPrompt = ''.obs;
  final RxString previewPrompt = ''.obs;
  final RxDouble completionPercentage = 0.0.obs;
  final RxBool isGenerating = false.obs;
  final RxBool hasAllRequiredFields = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Check if we need to restore state (e.g., after screen rotation)
    final args = Get.arguments;
    if (args is Map && args.containsKey('savedState')) {
      _restoreState(args['savedState']);
    }
  }

  /// Initializes the wizard with a template
  void initializeWithTemplate(TemplateModel templateModel) {
    template = templateModel;

    // Initialize default values
    for (final field in template.fields) {
      if (field.defaultValue != null) {
        userInputs[field.id] = field.defaultValue;
      } else if (field.type == FieldType.checkbox) {
        // Initialize empty list for checkboxes
        userInputs[field.id] = <String>[];
      }
    }

    _updatePreview();
    _updateCompletionPercentage();
    _checkRequiredFields();
  }

  /// Restores controller state
  void _restoreState(Map<String, dynamic> state) {
    if (state.containsKey('template')) {
      template = state['template'];
    }
    if (state.containsKey('userInputs')) {
      userInputs.value = Map<String, dynamic>.from(state['userInputs']);
    }
    if (state.containsKey('currentStep')) {
      currentStep.value = state['currentStep'];
    }
    if (state.containsKey('builtPrompt')) {
      builtPrompt.value = state['builtPrompt'];
    }
  }

  /// Updates input value for a field
  void updateInput(String fieldId, dynamic value) {
    userInputs[fieldId] = value;

    // Clear validation error for this field
    validationErrors.remove(fieldId);

    // Update preview and completion metrics
    _updatePreview();
    _updateCompletionPercentage();
    _checkRequiredFields();
  }

  /// Validates current step inputs
  bool validateCurrentStep() {
    if (currentStep.value >= template.fields.length) return true;

    final field = template.fields[currentStep.value];
    final value = userInputs[field.id];

    // Required field validation
    if (field.isRequired &&
        (value == null ||
            (value is String && value.trim().isEmpty) ||
            (value is List && value.isEmpty))) {
      validationErrors[field.id] = '${field.label} is required';
      return false;
    }

    // Pattern validation if provided
    if (field.validationPattern != null && value != null && value is String) {
      final pattern = RegExp(field.validationPattern!);
      if (!pattern.hasMatch(value)) {
        validationErrors[field.id] = 'Invalid format for ${field.label}';
        return false;
      }
    }

    // Clear any existing error for this field
    validationErrors.remove(field.id);
    return true;
  }

  /// Validates all inputs and builds final prompt
  bool buildFinalPrompt() {
    isGenerating.value = true;

    try {
      // Validate all required fields
      final errors = _promptBuilder.validateInputs(template, userInputs);
      validationErrors.value = errors;

      if (errors.isEmpty) {
        builtPrompt.value = _promptBuilder.buildPrompt(template, userInputs);
        return true;
      }

      return false;
    } finally {
      isGenerating.value = false;
    }
  }

  /// Copies the prompt to clipboard
  Future<void> copyPromptToClipboard() async {
    if (builtPrompt.value.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: builtPrompt.value));
      Get.snackbar(
        'Copied!',
        'Prompt copied to clipboard',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Moves to next step if current step is valid
  bool nextStep() {
    if (validateCurrentStep()) {
      if (currentStep.value < template.fields.length) {
        currentStep.value++;
        return true;
      }
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
    if (step >= 0 && step <= template.fields.length) {
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
    for (final field in template.fields) {
      if (field.defaultValue != null) {
        userInputs[field.id] = field.defaultValue;
      } else if (field.type == FieldType.checkbox) {
        userInputs[field.id] = <String>[];
      }
    }

    _updatePreview();
    _updateCompletionPercentage();
    _checkRequiredFields();
  }

  /// Updates the preview prompt with current inputs
  void _updatePreview() {
    previewPrompt.value = _promptBuilder.previewPrompt(template, userInputs);
  }

  /// Updates completion percentage based on filled fields
  void _updateCompletionPercentage() {
    completionPercentage.value =
        _promptBuilder.getCompletionPercentage(template, userInputs);
  }

  /// Checks if all required fields have values
  void _checkRequiredFields() {
    final requiredFields = template.fields.where((field) => field.isRequired);

    if (requiredFields.isEmpty) {
      hasAllRequiredFields.value = true;
      return;
    }

    bool allFilled = true;
    for (final field in requiredFields) {
      final value = userInputs[field.id];

      if (value == null ||
          (value is String && value.trim().isEmpty) ||
          (value is List && value.isEmpty)) {
        allFilled = false;
        break;
      }
    }

    hasAllRequiredFields.value = allFilled;
  }

  /// Gets the current field being edited
  PromptField? get currentField {
    if (currentStep.value < template.fields.length) {
      return template.fields[currentStep.value];
    }
    return null;
  }

  /// Checks if wizard is at the review step
  bool get isComplete => currentStep.value >= template.fields.length;

  /// Gets progress as a percentage (0.0 to 1.0)
  double get progress {
    return template.fields.isEmpty
        ? 1.0
        : currentStep.value / template.fields.length;
  }

  /// Export state for persistence
  Map<String, dynamic> exportState() {
    return {
      'template': template,
      'userInputs': userInputs,
      'currentStep': currentStep.value,
      'builtPrompt': builtPrompt.value,
    };
  }

  /// Returns if the wizard can go to next step
  bool get canGoNext {
    return currentStep.value < template.fields.length;
  }

  /// Returns if the wizard can go to previous step
  bool get canGoPrevious {
    return currentStep.value > 0;
  }
}
