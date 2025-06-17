import '../../data/models/template_model.dart';
import '../../core/utils/string_utils.dart';

/// Service for building prompts from templates and user inputs
class PromptBuilder {
  static const String _placeholderPattern = r'\{\{(\w+)\}\}';

  /// Builds a prompt by replacing placeholders with user inputs
  String buildPrompt(
    TemplateModel template, 
    Map<String, dynamic> userInputs,
  ) {
    String result = template.templateContent;
    final regex = RegExp(_placeholderPattern);
    
    // Replace all placeholders with user inputs
    result = result.replaceAllMapped(regex, (match) {
      final placeholder = match.group(1);
      if (placeholder != null && userInputs.containsKey(placeholder)) {
        final value = userInputs[placeholder];
        return _formatValue(value);
      }
      return match.group(0) ?? ''; // Keep original if no replacement
    });
    
    return result.trim();
  }

  /// Extracts all placeholders from template content
  List<String> extractPlaceholders(String templateContent) {
    final regex = RegExp(_placeholderPattern);
    final matches = regex.allMatches(templateContent);
    
    return matches
        .map((match) => match.group(1))
        .where((placeholder) => placeholder != null)
        .cast<String>()
        .toSet() // Remove duplicates
        .toList();
  }

  /// Validates that all required fields have values
  Map<String, String> validateInputs(
    TemplateModel template,
    Map<String, dynamic> userInputs,
  ) {
    final errors = <String, String>{};
    
    for (final field in template.fields) {
      if (field.isRequired) {
        final value = userInputs[field.id];
        if (value == null || 
            (value is String && value.trim().isEmpty)) {
          errors[field.id] = '${field.label} is required';
        }
      }
      
      // Validate pattern if provided
      if (field.validationPattern != null && 
          userInputs[field.id] != null) {
        final pattern = RegExp(field.validationPattern!);
        final value = userInputs[field.id].toString();
        if (!pattern.hasMatch(value)) {
          errors[field.id] = 'Invalid format for ${field.label}';
        }
      }
    }
    
    return errors;
  }

  /// Formats a value for insertion into the prompt
  String _formatValue(dynamic value) {
    if (value == null) return '';
    
    if (value is List) {
      return value.map((item) => item.toString()).join(', ');
    }
    
    if (value is bool) {
      return value ? 'Yes' : 'No';
    }
    
    return value.toString();
  }

  /// Gets completion percentage for current inputs
  double getCompletionPercentage(
    TemplateModel template,
    Map<String, dynamic> userInputs,
  ) {
    if (template.fields.isEmpty) return 1.0;
    
    final completedFields = template.fields.where((field) {
      final value = userInputs[field.id];
      return value != null && 
             (value is! String || value.trim().isNotEmpty);
    }).length;
    
    return completedFields / template.fields.length;
  }

  /// Preview prompt with current inputs, showing placeholders for missing values
  String previewPrompt(
    TemplateModel template,
    Map<String, dynamic> userInputs,
  ) {
    String result = template.templateContent;
    final regex = RegExp(_placeholderPattern);
    
    result = result.replaceAllMapped(regex, (match) {
      final placeholder = match.group(1);
      if (placeholder != null) {
        final value = userInputs[placeholder];
        if (value != null && value.toString().trim().isNotEmpty) {
          return _formatValue(value);
        } else {
          return '[${placeholder.toTitleCase()}]';
        }
      }
      return match.group(0) ?? '';
    });
    
    return result.trim();
  }
}