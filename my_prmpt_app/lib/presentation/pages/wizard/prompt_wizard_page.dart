// lib/presentation/pages/wizard/prompt_wizard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/wizard_controller.dart';
import '../../widgets/field_input_widget.dart';
import '../viewer/result_viewer_page.dart';

/// Wizard page for building prompts step by step
class PromptWizardPage extends GetView<WizardController> {
  const PromptWizardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final template = Get.arguments;

    // Put the controller if not already initialized
    if (!Get.isRegistered<WizardController>()) {
      Get.put(WizardController()..initializeWithTemplate(template));
    } else {
      controller.initializeWithTemplate(template);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(template.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(child: _buildWizardContent()),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// Builds the progress indicator
  Widget _buildProgressIndicator() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: controller.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Get.theme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),

              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${controller.currentStep.value + 1} of ${controller.template?.fields.length ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${(controller.completionPercentage.value * 100).toInt()}% complete',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  /// Builds the main wizard content
  Widget _buildWizardContent() {
    return Obx(() {
      if (controller.isComplete) {
        return _buildSummaryStep();
      }

      final field = controller.currentField;
      if (field == null) return const SizedBox();

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field label and help text
            Text(
              field.label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (field.helpText != null) ...[
              const SizedBox(height: 8),
              Text(
                field.helpText!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Field input
            FieldInputWidget(
              field: field,
              value: controller.userInputs[field.id],
              onChanged: (value) => controller.updateInput(field.id, value),
              errorText: controller.validationErrors[field.id],
            ),

            const SizedBox(height: 32),

            // Preview section
            _buildPreviewSection(),
          ],
        ),
      );
    });
  }

  /// Builds the preview section
  Widget _buildPreviewSection() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.preview, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                controller.previewPrompt.value.isEmpty
                    ? 'Fill in the fields to see your prompt preview...'
                    : controller.previewPrompt.value,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: controller.previewPrompt.value.isEmpty
                      ? Colors.grey[500]
                      : Colors.grey[800],
                ),
              ),
            ],
          ),
        ));
  }

  /// Builds the summary step
  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Prompt',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your inputs and generate the final prompt.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Input summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Inputs',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...controller.template?.fields.map((field) {
                        final value = controller.userInputs[field.id];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  '${field.label}:',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  value?.toString() ?? 'Not provided',
                                  style: TextStyle(
                                    color: value != null
                                        ? Colors.grey[800]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList() ??
                      [],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generatePrompt,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Prompt'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          // Show built prompt if available
          Obx(() {
            if (controller.builtPrompt.value.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Generated Prompt',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      controller.builtPrompt.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _copyPrompt,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _viewResult,
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Full'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  /// Builds navigation buttons
  Widget _buildNavigationButtons() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Previous button
              if (controller.currentStep.value > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.previousStep,
                    child: const Text('Previous'),
                  ),
                ),

              if (controller.currentStep.value > 0) const SizedBox(width: 16),

              // Next/Finish button
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isComplete ? null : _handleNext,
                  child: Text(
                    controller.currentStep.value >=
                            (controller.template?.fields.length ?? 0) - 1
                        ? 'Review'
                        : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  /// Handles next button press
  void _handleNext() {
    if (!controller.nextStep()) {
      // Show validation error
      Get.snackbar(
        'Validation Error',
        'Please fix the errors before continuing',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  /// Generates the final prompt
  void _generatePrompt() {
    if (controller.buildFinalPrompt()) {
      Get.snackbar(
        'Success',
        'Prompt generated successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    } else {
      Get.snackbar(
        'Validation Error',
        'Please fix all validation errors',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  /// Copies prompt to clipboard
  void _copyPrompt() async {
    try {
      await Clipboard.setData(
          ClipboardData(text: controller.builtPrompt.value));
      Get.snackbar(
        'Success',
        'Prompt copied to clipboard successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        icon: const Icon(Icons.check_circle, color: Colors.green),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to copy prompt to clipboard',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Opens result viewer
  void _viewResult() {
    Get.to(() => ResultViewerPage(
          prompt: controller.builtPrompt.value,
          template: controller.template,
        ));
  }
}
