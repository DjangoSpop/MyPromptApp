import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:my_prmpt_app/data/models/template_model.dart';
import 'package:share_plus/share_plus.dart';


/// Page for viewing and sharing generated prompts
class ResultViewerPage extends StatelessWidget {
  final String? prompt;
  final TemplateModel? template;

  const ResultViewerPage({
    super.key,
    this.prompt,
    this.template,
  });

  @override
  Widget build(BuildContext context) {
    final promptText = prompt ?? Get.arguments?['prompt'] ?? '';
    final templateData = template ?? Get.arguments?['template'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Prompt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(promptText),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePrompt(promptText),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (templateData != null) ...[
              _buildTemplateInfo(templateData),
              const SizedBox(height: 24),
            ],
            _buildPromptViewer(promptText),
            const SizedBox(height: 24),
            _buildActionButtons(promptText),
          ],
        ),
      ),
    );
  }

  /// Builds template information card
  Widget _buildTemplateInfo(TemplateModel template) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              template.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              template.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text(template.category),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Text(
                  '${template.fields.length} fields',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main prompt viewer
  Widget _buildPromptViewer(String promptText) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Generated Prompt',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${promptText.length} characters',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SelectableText(
                promptText.isEmpty ? 'No prompt generated yet.' : promptText,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds action buttons
  Widget _buildActionButtons(String promptText) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: promptText.isNotEmpty
                ? () => _copyToClipboard(promptText)
                : null,
            icon: const Icon(Icons.copy),
            label: const Text('Copy to Clipboard'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                promptText.isNotEmpty ? () => _sharePrompt(promptText) : null,
            icon: const Icon(Icons.share),
            label: const Text('Share Prompt'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Template'),
          ),
        ),
      ],
    );
  }

  /// Copies prompt to clipboard
  void _copyToClipboard(String text) {
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      Get.snackbar(
        'Copied',
        'Prompt copied to clipboard',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Shares prompt using platform share dialog
  void _sharePrompt(String text) {
    if (text.isNotEmpty) {
      Share.share(
        text,
        subject: 'Generated Prompt from Prompt Forge',
      );
    }
  }
}
