// lib/presentation/controllers/editor_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/template_model.dart';
import '../../data/models/prompt_field.dart';
import '../../domain/services/template_service.dart';

/// Controller for template editor functionality
class EditorController extends GetxController {
  final TemplateService _templateService = Get.find<TemplateService>();

  final RxBool isEditMode = false.obs;
  final RxBool isLoading = false.obs;

  // Template properties
  final RxString templateId = ''.obs;
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxString category = ''.obs;
  final RxString templateContent = ''.obs;
  final RxString author = ''.obs;
  final RxList<String> tags = <String>[].obs;
  final RxList<PromptField> fields = <PromptField>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Check if editing existing template
    final existingTemplate = Get.arguments as TemplateModel?;
    if (existingTemplate != null) {
      _loadTemplate(existingTemplate);
    } else {
      _initializeNewTemplate();
    }
  }

  /// Loads existing template for editing
  void _loadTemplate(TemplateModel template) {
    isEditMode.value = true;
    templateId.value = template.id;
    title.value = template.title;
    description.value = template.description;
    category.value = template.category;
    templateContent.value = template.content;
    author.value = template.createdBy;
    tags.value = template.tags;
    fields.value = []; // Domain model doesn't have fields, so default to empty
  }

  /// Initializes new template
  void _initializeNewTemplate() {
    isEditMode.value = false;
    templateId.value = DateTime.now().millisecondsSinceEpoch.toString();
    title.value = '';
    description.value = '';
    category.value = 'General';
    templateContent.value = '';
    author.value = 'User';
    tags.clear();
    fields.clear();
  }

  /// Saves the template
  Future<void> saveTemplate() async {
    if (!_validateTemplate()) return;

    try {
      isLoading.value = true;

      final template = TemplateModel(
        id: templateId.value,
        title: title.value,
        description: description.value,
        category: category.value,
        content: templateContent.value,
        tags: tags.toList(),
        createdBy: author.value.isEmpty ? 'anonymous' : author.value,
        createdAt: isEditMode.value ? DateTime.now() : DateTime.now(),
        updatedAt: DateTime.now(),
        usageCount: 0,
        rating: 0.0,
        isPublic: false,
      );

      await _templateService.saveTemplate(template);

      Get.back();
      Get.snackbar(
        'Success',
        isEditMode.value
            ? 'Template updated successfully'
            : 'Template created successfully',
        backgroundColor: Colors.green[100],
        colorText: Colors.green[800],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save template: $e',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Validates template data
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

  /// Adds a new field to the template
  void addField() {
    final newField = PromptField(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}',
      label: 'New Field',
      placeholder: 'Enter value...',
      type: FieldType.text,
    );

    fields.add(newField);
  }

  /// Removes a field from the template
  void removeField(int index) {
    if (index >= 0 && index < fields.length) {
      fields.removeAt(index);
    }
  }

  /// Updates a field
  void updateField(int index, PromptField updatedField) {
    if (index >= 0 && index < fields.length) {
      fields[index] = updatedField;
    }
  }

  /// Adds a tag
  void addTag(String tag) {
    if (tag.trim().isNotEmpty && !tags.contains(tag.trim())) {
      tags.add(tag.trim());
    }
  }

  /// Removes a tag
  void removeTag(String tag) {
    tags.remove(tag);
  }

  /// Updates a template property
  void updateProperty(String property, dynamic value) {
    switch (property) {
      case 'title':
        title.value = value.toString();
        break;
      case 'description':
        description.value = value.toString();
        break;
      case 'category':
        category.value = value.toString();
        break;
      case 'templateContent':
        templateContent.value = value.toString();
        _updateDetectedPlaceholders();
        break;
      case 'author':
        author.value = value.toString();
        break;
    }
  }

  /// Detected placeholders from template content
  final RxList<String> detectedPlaceholders = <String>[].obs;

  /// Map to track which placeholders are mapped to fields
  final RxMap<String, bool> placeholdersMapped = <String, bool>{}.obs;

  /// Updates detected placeholders when template content changes
  void _updateDetectedPlaceholders() {
    final regex = RegExp(r'\{\{([^}]+)\}\}');
    final matches = regex.allMatches(templateContent.value);
    final placeholders =
        matches.map((match) => match.group(1)!.trim()).toSet().toList();

    detectedPlaceholders.value = placeholders;
    _updatePlaceholderMapping();
  }

  /// Updates placeholder mapping based on current fields
  void _updatePlaceholderMapping() {
    final fieldIds = fields.map((field) => field.id).toSet();
    placeholdersMapped.clear();

    for (final placeholder in detectedPlaceholders) {
      placeholdersMapped[placeholder] = fieldIds.contains(placeholder);
    }
  }

  /// Checks if there are unmapped placeholders
  bool hasUnmappedPlaceholders() {
    return placeholdersMapped.values.any((mapped) => !mapped);
  }

  /// Creates fields for all unmapped placeholders
  void createFieldsForAllPlaceholders() {
    for (final placeholder in detectedPlaceholders) {
      if (placeholdersMapped[placeholder] != true) {
        addFieldForPlaceholder(placeholder);
      }
    }
  }

  /// Adds a field for a specific placeholder
  void addFieldForPlaceholder(String placeholder) {
    final newField = PromptField(
      id: placeholder,
      label: _formatLabel(placeholder),
      placeholder: 'Enter ${_formatLabel(placeholder).toLowerCase()}...',
      type: FieldType.text,
    );
    fields.add(newField);
    _updatePlaceholderMapping();
  }

  /// Formats placeholder name into readable label
  String _formatLabel(String placeholder) {
    return placeholder
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Edits a field at given index
  void editField(int index) {
    if (index >= 0 && index < fields.length) {
      // This would typically open a field editor dialog
      // For now, we'll just add a placeholder implementation
      Get.dialog(
        AlertDialog(
          title: const Text('Edit Field'),
          content: const Text('Field editor dialog would open here'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  /// Moves field up in the list
  void moveFieldUp(int index) {
    if (index > 0 && index < fields.length) {
      final field = fields.removeAt(index);
      fields.insert(index - 1, field);
    }
  }

  /// Moves field down in the list
  void moveFieldDown(int index) {
    if (index >= 0 && index < fields.length - 1) {
      final field = fields.removeAt(index);
      fields.insert(index + 1, field);
    }
  }

  /// Confirms discard changes
  Future<bool> confirmDiscardChanges() async {
    if (_hasUnsavedChanges()) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
              'You have unsaved changes. Are you sure you want to leave?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  /// Checks if there are unsaved changes
  bool _hasUnsavedChanges() {
    // Simple check - in a real app, you'd compare with the original template
    return title.value.isNotEmpty ||
        description.value.isNotEmpty ||
        templateContent.value.isNotEmpty ||
        fields.isNotEmpty;
  }
}
