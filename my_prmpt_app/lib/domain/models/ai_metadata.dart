// lib/domain/models/ai_metadata.dart
import 'package:hive/hive.dart';

part 'ai_metadata.g.dart';

@HiveType(typeId: 11)
class AIMetadata extends HiveObject {
  @HiveField(0)
  bool isAIGenerated;

  @HiveField(1)
  double confidence;

  @HiveField(2)
  String? aiModel;

  @HiveField(3)
  List<String>? extractedKeywords;

  @HiveField(4)
  Map<String, dynamic>? smartSuggestions;

  @HiveField(5)
  String? contextDomain;

  @HiveField(6)
  DateTime? aiProcessedAt;

  AIMetadata({
    this.isAIGenerated = false,
    this.confidence = 0.0,
    this.aiModel,
    this.extractedKeywords,
    this.smartSuggestions,
    this.contextDomain,
    this.aiProcessedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'isAIGenerated': isAIGenerated,
      'confidence': confidence,
      'aiModel': aiModel,
      'extractedKeywords': extractedKeywords,
      'smartSuggestions': smartSuggestions,
      'contextDomain': contextDomain,
      'aiProcessedAt': aiProcessedAt?.toIso8601String(),
    };
  }

  factory AIMetadata.fromJson(Map<String, dynamic> json) {
    return AIMetadata(
      isAIGenerated: json['isAIGenerated'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      aiModel: json['aiModel'] as String?,
      extractedKeywords: (json['extractedKeywords'] as List?)?.cast<String>(),
      smartSuggestions: json['smartSuggestions'] as Map<String, dynamic>?,
      contextDomain: json['contextDomain'] as String?,
      aiProcessedAt: json['aiProcessedAt'] != null
          ? DateTime.parse(json['aiProcessedAt'] as String)
          : null,
    );
  }
}

@HiveType(typeId: 12)
class TemplateVersion extends HiveObject {
  @HiveField(0)
  String version;

  @HiveField(1)
  String changelog;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  String? author;

  @HiveField(4)
  Map<String, dynamic>? templateData;

  TemplateVersion({
    required this.version,
    required this.changelog,
    required this.createdAt,
    this.author,
    this.templateData,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'changelog': changelog,
      'createdAt': createdAt.toIso8601String(),
      'author': author,
      'templateData': templateData,
    };
  }

  factory TemplateVersion.fromJson(Map<String, dynamic> json) {
    return TemplateVersion(
      version: json['version'] as String,
      changelog: json['changelog'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      author: json['author'] as String?,
      templateData: json['templateData'] as Map<String, dynamic>?,
    );
  }
}

@HiveType(typeId: 13)
class TemplateSettings extends HiveObject {
  @HiveField(0)
  bool isPublic;

  @HiveField(1)
  bool allowCollaboration;

  @HiveField(2)
  List<String>? accessPermissions;

  @HiveField(3)
  Map<String, dynamic>? customizations;

  TemplateSettings({
    this.isPublic = false,
    this.allowCollaboration = false,
    this.accessPermissions,
    this.customizations,
  });

  Map<String, dynamic> toJson() {
    return {
      'isPublic': isPublic,
      'allowCollaboration': allowCollaboration,
      'accessPermissions': accessPermissions,
      'customizations': customizations,
    };
  }

  factory TemplateSettings.fromJson(Map<String, dynamic> json) {
    return TemplateSettings(
      isPublic: json['isPublic'] as bool? ?? false,
      allowCollaboration: json['allowCollaboration'] as bool? ?? false,
      accessPermissions: (json['accessPermissions'] as List?)?.cast<String>(),
      customizations: json['customizations'] as Map<String, dynamic>?,
    );
  }
}
