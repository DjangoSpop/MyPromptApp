// lib/domain/models/ai_context.dart

/// AI Context model for storing domain knowledge
class AIContext {
  final String id;
  final String domain;
  final String context;
  final List<String> keywords;
  double relevanceScore;
  int usageCount;
  DateTime? lastUsed;

  AIContext({
    required this.id,
    required this.domain,
    required this.context,
    required this.keywords,
    this.relevanceScore = 0.0,
    this.usageCount = 0,
    this.lastUsed,
  });

  AIContext copyWith({
    String? id,
    String? domain,
    String? context,
    List<String>? keywords,
    double? relevanceScore,
    int? usageCount,
    DateTime? lastUsed,
  }) {
    return AIContext(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      context: context ?? this.context,
      keywords: keywords ?? this.keywords,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domain': domain,
      'context': context,
      'keywords': keywords,
      'relevanceScore': relevanceScore,
      'usageCount': usageCount,
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  factory AIContext.fromJson(Map<String, dynamic> json) {
    return AIContext(
      id: json['id'] as String,
      domain: json['domain'] as String,
      context: json['context'] as String,
      keywords: (json['keywords'] as List).cast<String>(),
      relevanceScore: (json['relevanceScore'] as num?)?.toDouble() ?? 0.0,
      usageCount: json['usageCount'] as int? ?? 0,
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
    );
  }
}

/// Template suggestion generated by AI
class TemplateSuggestion {
  final String title;
  final String description;
  final Map<String, dynamic> templateStructure;
  final double confidence;
  final AIContext aiContext;

  TemplateSuggestion({
    required this.title,
    required this.description,
    required this.templateStructure,
    required this.confidence,
    required this.aiContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'templateStructure': templateStructure,
      'confidence': confidence,
      'aiContext': aiContext.toJson(),
    };
  }

  factory TemplateSuggestion.fromJson(Map<String, dynamic> json) {
    return TemplateSuggestion(
      title: json['title'] as String,
      description: json['description'] as String,
      templateStructure: json['templateStructure'] as Map<String, dynamic>,
      confidence: (json['confidence'] as num).toDouble(),
      aiContext: AIContext.fromJson(json['aiContext'] as Map<String, dynamic>),
    );
  }
}
