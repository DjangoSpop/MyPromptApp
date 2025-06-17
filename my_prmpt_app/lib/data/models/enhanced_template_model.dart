// lib/data/models/enhanced_template_model.dart
import 'package:hive/hive.dart';
import 'prompt_field.dart';
import '../../domain/models/ai_metadata.dart';

part 'enhanced_template_model.g.dart';

@HiveType(typeId: 10)
class EnhancedTemplateModel extends HiveObject {
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
  String version;

  @HiveField(10)
  List<String>? tags;

  // Enhanced AI Features
  @HiveField(11)
  AIMetadata? aiMetadata;

  @HiveField(12)
  List<String>? collaborators;

  @HiveField(13)
  Map<String, dynamic>? analytics;

  @HiveField(14)
  List<TemplateVersion>? versionHistory;

  @HiveField(15)
  TemplateSettings? settings;

  @HiveField(16)
  List<String>? relatedTemplates;

  @HiveField(17)
  double? popularityScore;

  @HiveField(18)
  Map<String, String>? localizations;

  EnhancedTemplateModel({
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
    this.aiMetadata,
    this.collaborators,
    this.analytics,
    this.versionHistory,
    this.settings,
    this.relatedTemplates,
    this.popularityScore,
    this.localizations,
  });

  // Enhanced methods for AI integration
  bool get isAIGenerated => aiMetadata?.isAIGenerated ?? false;
  double get aiConfidence => aiMetadata?.confidence ?? 0.0;

  List<String> get extractedKeywords {
    return aiMetadata?.extractedKeywords ?? [];
  }

  Map<String, dynamic> get smartSuggestions {
    return aiMetadata?.smartSuggestions ?? {};
  }

  /// Creates EnhancedTemplateModel from JSON map
  factory EnhancedTemplateModel.fromJson(Map<String, dynamic> json) {
    return EnhancedTemplateModel(
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
      aiMetadata: json['aiMetadata'] != null
          ? AIMetadata.fromJson(json['aiMetadata'] as Map<String, dynamic>)
          : null,
      collaborators: (json['collaborators'] as List?)?.cast<String>(),
      analytics: json['analytics'] as Map<String, dynamic>?,
      versionHistory: (json['versionHistory'] as List?)
          ?.map((v) => TemplateVersion.fromJson(v as Map<String, dynamic>))
          .toList(),
      settings: json['settings'] != null
          ? TemplateSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      relatedTemplates: (json['relatedTemplates'] as List?)?.cast<String>(),
      popularityScore: (json['popularityScore'] as num?)?.toDouble(),
      localizations: (json['localizations'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// Converts EnhancedTemplateModel to JSON map
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
      if (aiMetadata != null) 'aiMetadata': aiMetadata!.toJson(),
      if (collaborators != null) 'collaborators': collaborators,
      if (analytics != null) 'analytics': analytics,
      if (versionHistory != null)
        'versionHistory': versionHistory!.map((v) => v.toJson()).toList(),
      if (settings != null) 'settings': settings!.toJson(),
      if (relatedTemplates != null) 'relatedTemplates': relatedTemplates,
      if (popularityScore != null) 'popularityScore': popularityScore,
      if (localizations != null) 'localizations': localizations,
    };
  }

  /// Creates a copy with updated fields
  EnhancedTemplateModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? templateContent,
    List<PromptField>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? author,
    String? version,
    List<String>? tags,
    AIMetadata? aiMetadata,
    List<String>? collaborators,
    Map<String, dynamic>? analytics,
    List<TemplateVersion>? versionHistory,
    TemplateSettings? settings,
    List<String>? relatedTemplates,
    double? popularityScore,
    Map<String, String>? localizations,
  }) {
    return EnhancedTemplateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      templateContent: templateContent ?? this.templateContent,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      version: version ?? this.version,
      tags: tags ?? this.tags,
      aiMetadata: aiMetadata ?? this.aiMetadata,
      collaborators: collaborators ?? this.collaborators,
      analytics: analytics ?? this.analytics,
      versionHistory: versionHistory ?? this.versionHistory,
      settings: settings ?? this.settings,
      relatedTemplates: relatedTemplates ?? this.relatedTemplates,
      popularityScore: popularityScore ?? this.popularityScore,
      localizations: localizations ?? this.localizations,
    );
  }
}
