// lib/data/models/prompt_field.dart
import 'package:hive/hive.dart';

part 'prompt_field.g.dart';

@HiveType(typeId: 0)
class PromptField extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String label;

  @HiveField(2)
  String placeholder;

  @HiveField(3)
  FieldType type;

  @HiveField(4)
  bool isRequired;

  @HiveField(5)
  List<String>? options; // For dropdown/radio fields

  @HiveField(6)
  String? defaultValue;

  @HiveField(7)
  String? validationPattern;

  @HiveField(8)
  String? helpText;

  PromptField({
    required this.id,
    required this.label,
    required this.placeholder,
    this.type = FieldType.text,
    this.isRequired = false,
    this.options,
    this.defaultValue,
    this.validationPattern,
    this.helpText,
  });

  /// Creates PromptField from JSON map
  factory PromptField.fromJson(Map<String, dynamic> json) {
    return PromptField(
      id: json['id'] as String,
      label: json['label'] as String,
      placeholder: json['placeholder'] as String? ?? '',
      type: FieldType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FieldType.text,
      ),
      isRequired: json['isRequired'] as bool? ?? false,
      options: (json['options'] as List?)?.cast<String>(),
      defaultValue: json['defaultValue'] as String?,
      validationPattern: json['validationPattern'] as String?,
      helpText: json['helpText'] as String?,
    );
  }

  /// Converts PromptField to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'placeholder': placeholder,
      'type': type.name,
      'isRequired': isRequired,
      if (options != null) 'options': options,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (validationPattern != null) 'validationPattern': validationPattern,
      if (helpText != null) 'helpText': helpText,
    };
  }
}

@HiveType(typeId: 1)
enum FieldType {
  @HiveField(0)
  text,
  @HiveField(1)
  textarea,
  @HiveField(2)
  dropdown,
  @HiveField(3)
  checkbox,
  @HiveField(4)
  radio,
  @HiveField(5)
  number,
}
