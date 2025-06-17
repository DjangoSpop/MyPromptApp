// lib/data/models/template_model.dart
import 'package:hive/hive.dart';
import 'prompt_field.dart';

part 'template_model.g.dart';

@HiveType(typeId: 2)
class TemplateModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  String templateContent;

  @HiveField(5)
  List<PromptField> fields;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  @HiveField(8)
  String? author;

  @HiveField(9)
  String? version;

  @HiveField(10)
  List<String>? tags;

  TemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.templateContent,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.version = '1.0.0',
    this.tags,
  });

  /// Creates TemplateModel from JSON map
  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      templateContent: json['templateContent'] as String,
      fields: (json['fields'] as List)
          .map((field) => PromptField.fromJson(field))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      author: json['author'] as String?,
      version: json['version'] as String? ?? '1.0.0',
      tags: (json['tags'] as List?)?.cast<String>(),
    );
  }

  /// Converts TemplateModel to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'templateContent': templateContent,
      'fields': fields.map((field) => field.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (author != null) 'author': author,
      'version': version,
      if (tags != null) 'tags': tags,
    };
  }

  /// Creates a copy with updated fields
  TemplateModel copyWith({
    String? title,
    String? description,
    String? category,
    String? templateContent,
    List<PromptField>? fields,
    String? author,
    String? version,
    List<String>? tags,
  }) {
    return TemplateModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      templateContent: templateContent ?? this.templateContent,
      fields: fields ?? this.fields,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      author: author ?? this.author,
      version: version ?? this.version,
      tags: tags ?? this.tags,
    );
  }
}
