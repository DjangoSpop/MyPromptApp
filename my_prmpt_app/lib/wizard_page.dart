// lib/presentation/pages/wizard/prompt_wizard_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_prmpt_app/presentation/controllers/wizard_controller.dart';
import 'package:my_prmpt_app/presentation/widgets/field_input_widget.dart';
import '../../../data/models/template_model.dart';

/// Page for building prompts step by step from templates
class PromptWizardPage extends StatelessWidget {
  const PromptWizardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final template = Get.arguments as TemplateModel;

    return GetBuilder<WizardController>(
      init: WizardController()..initializeWithTemplate(template),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: Text(template.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showTemplateInfo(context, template),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(controller),
              Expanded(
                child: _buildContent(controller),
              ),
              _buildBottomNavigation(controller),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the progress indicator bar
  Widget _buildProgressIndicator(WizardController controller) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${controller.currentStep.value + 1} of ${controller.template!.fields.length}',
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
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: controller.progress,
                backgroundColor: Colors.grey[300],
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ));
  }

  /// Builds the main content area based on current step
  Widget _buildContent(WizardController controller) {
    return Obx(() {
      // If we're at the final review step
      if (controller.isComplete) {
        return _buildReviewStep(controller);
      }

      // Regular field input step
      final field = controller.currentField;
      if (field == null) {
        return const Center(child: Text('No fields found in this template'));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field header
            Text(
              field.label,
              style: const TextStyle(
                fontSize: 22,
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

            // Live preview section
            _buildPreviewSection(controller),
          ],
        ),
      );
    });
  }

  /// Builds the preview section showing template with current inputs
  Widget _buildPreviewSection(WizardController controller) {
    return Obx(() {
      final previewText = controller.previewPrompt.value;

      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.remove_red_eye, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Live Preview',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  previewText.isEmpty
                      ? 'Fill in the fields to see your prompt preview...'
                      : previewText,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontFamily: 'monospace',
                    color: previewText.isEmpty
                        ? Colors.grey[500]
                        : Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Builds the review step after all fields are filled
  Widget _buildReviewStep(WizardController controller) {
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
            'Check your inputs and generate the final prompt.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Input summary card
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Inputs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // List all fields and their values
                  ...controller.template!.fields.map((field) {
                    final value = controller.userInputs[field.id];
                    String displayValue = 'Not provided';

                    if (value != null) {
                      if (value is List) {
                        displayValue = value.join(', ');
                      } else {
                        displayValue = value.toString();
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            field.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              displayValue,
                              style: TextStyle(
                                color: value != null
                                    ? Colors.black87
                                    : Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _generatePrompt(controller),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Generate Prompt'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Generated prompt section (conditionally shown)
          Obx(() {
            if (controller.builtPrompt.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return Card(
              elevation: 2,
              color: Colors.green[50],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Generated Prompt',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: SelectableText(
                        controller.builtPrompt.value,
                        style: const TextStyle(
                          height: 1.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyPrompt(controller),
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _viewPromptDetails(controller),
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Full'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Builds bottom navigation buttons
  Widget _buildBottomNavigation(WizardController controller) {
    return Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Back button (conditionally shown)
              if (controller.currentStep.value > 0)
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: controller.previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Previous'),
                  ),
                ),

              if (controller.currentStep.value > 0) const SizedBox(width: 16),

              // Next button (not shown on review step)
              if (!controller.isComplete)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _handleNextStep(controller),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      controller.currentStep.value >=
                              controller.template!.fields.length - 1
                          ? 'Review'
                          : 'Next',
                    ),
                  ),
                ),

              // Edit button (only shown on review step)
              if (controller.isComplete)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.goToStep(0),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Edit Inputs'),
                  ),
                ),
            ],
          ),
        ));
  }

  /// Handles next button press with validation
  void _handleNextStep(WizardController controller) {
    if (!controller.nextStep()) {
      // Show validation error
      Get.snackbar(
        'Validation Error',
        'Please fix the errors before continuing',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Generates the final prompt
  void _generatePrompt(WizardController controller) {
    if (controller.buildFinalPrompt()) {
      Get.snackbar(
        'Success',
        'Prompt generated successfully!',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        margin: const EdgeInsets.all(16),
      );
    } else {
      Get.dialog(
        AlertDialog(
          title: const Text('Validation Errors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please fix the following issues:'),
              const SizedBox(height: 16),
              ...controller.validationErrors.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Copies the prompt to clipboard
  void _copyPrompt(WizardController controller) async {
    await Clipboard.setData(ClipboardData(text: controller.builtPrompt.value));
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

/// Opens the full prompt viewer
void _viewPromptDetails(WizardController controller) {
  Get.toNamed('/viewer', arguments: {
    'prompt': controller.builtPrompt.value,
    'template': controller.template,
  });
}

/// Shows template information dialog
void _showTemplateInfo(BuildContext context, TemplateModel template) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(template.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              template.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  template.category,
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  template.author ?? 'Unknown',
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
            ),
            if (template.tags != null && template.tags!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: template.tags!
                    .map((tag) => Chip(
                          label: Text(tag),
                          labelStyle: const TextStyle(fontSize: 12),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
