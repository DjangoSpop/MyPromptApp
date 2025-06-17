// lib/domain/services/template_analytics_service.dart
import 'package:get/get.dart';

/// Template analytics data model
class TemplateAnalytics {
  final String templateId;
  int usageCount = 0;
  int completionCount = 0;
  Set<String> uniqueUsers = {};
  DateTime? lastUsed;
  Map<String, int> fieldCompletionRates = {};

  TemplateAnalytics({required this.templateId});

  double get completionRate =>
      usageCount > 0 ? completionCount / usageCount : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'usageCount': usageCount,
      'completionCount': completionCount,
      'uniqueUsers': uniqueUsers.toList(),
      'lastUsed': lastUsed?.toIso8601String(),
      'fieldCompletionRates': fieldCompletionRates,
    };
  }

  factory TemplateAnalytics.fromJson(Map<String, dynamic> json) {
    final analytics =
        TemplateAnalytics(templateId: json['templateId'] as String);
    analytics.usageCount = json['usageCount'] as int? ?? 0;
    analytics.completionCount = json['completionCount'] as int? ?? 0;
    analytics.uniqueUsers =
        (json['uniqueUsers'] as List?)?.cast<String>().toSet() ?? {};
    analytics.lastUsed = json['lastUsed'] != null
        ? DateTime.parse(json['lastUsed'] as String)
        : null;
    analytics.fieldCompletionRates =
        (json['fieldCompletionRates'] as Map<String, dynamic>?)
                ?.cast<String, int>() ??
            {};
    return analytics;
  }
}

/// Usage pattern model
class UsagePattern {
  final String templateId;
  final DateTime timestamp;
  final int hourOfDay;
  final int dayOfWeek;

  UsagePattern({
    required this.templateId,
    required this.timestamp,
    required this.hourOfDay,
    required this.dayOfWeek,
  });

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'timestamp': timestamp.toIso8601String(),
      'hourOfDay': hourOfDay,
      'dayOfWeek': dayOfWeek,
    };
  }

  factory UsagePattern.fromJson(Map<String, dynamic> json) {
    return UsagePattern(
      templateId: json['templateId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      hourOfDay: json['hourOfDay'] as int,
      dayOfWeek: json['dayOfWeek'] as int,
    );
  }
}

/// AI insight model
class AIInsight {
  final InsightType type;
  final String title;
  final String description;
  final double confidence;
  final bool actionable;
  final String? recommendation;

  AIInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.confidence,
    this.actionable = false,
    this.recommendation,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'confidence': confidence,
      'actionable': actionable,
      'recommendation': recommendation,
    };
  }

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      type: InsightType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      actionable: json['actionable'] as bool? ?? false,
      recommendation: json['recommendation'] as String?,
    );
  }
}

enum InsightType {
  popularity,
  optimization,
  trend,
  recommendation,
}

/// Service for template analytics and insights
class TemplateAnalyticsService extends GetxService {
  final RxMap<String, TemplateAnalytics> _analytics =
      <String, TemplateAnalytics>{}.obs;
  final RxList<UsagePattern> _usagePatterns = <UsagePattern>[].obs;
  final RxMap<String, double> _templatePopularity = <String, double>{}.obs;

  /// Track template usage
  void trackTemplateUsage(
      String templateId, String userId, DateTime timestamp) {
    if (!_analytics.containsKey(templateId)) {
      _analytics[templateId] = TemplateAnalytics(templateId: templateId);
    }

    final analytics = _analytics[templateId]!;
    analytics.usageCount++;
    analytics.lastUsed = timestamp;
    analytics.uniqueUsers.add(userId);

    _updatePopularityScore(templateId);
    _identifyUsagePatterns(templateId, timestamp);
  }

  /// Track template completion
  void trackTemplateCompletion(
      String templateId, String userId, Map<String, dynamic> fieldData) {
    if (!_analytics.containsKey(templateId)) {
      _analytics[templateId] = TemplateAnalytics(templateId: templateId);
    }

    final analytics = _analytics[templateId]!;
    analytics.completionCount++;

    // Track field completion rates
    for (final fieldId in fieldData.keys) {
      analytics.fieldCompletionRates[fieldId] =
          (analytics.fieldCompletionRates[fieldId] ?? 0) + 1;
    }

    _updatePopularityScore(templateId);
  }

  /// Generate AI insights for template performance
  Future<List<AIInsight>> generateTemplateInsights(String templateId) async {
    final analytics = _analytics[templateId];
    if (analytics == null) return [];

    final insights = <AIInsight>[];

    // Usage trend analysis
    if (analytics.usageCount > 50) {
      insights.add(AIInsight(
        type: InsightType.popularity,
        title: 'High Usage Template',
        description:
            'This template is performing well with ${analytics.usageCount} uses',
        confidence: 0.9,
        actionable: true,
        recommendation: 'Consider creating similar templates or variations',
      ));
    }

    // Completion rate analysis
    final completionRate = analytics.completionRate;
    if (completionRate < 0.7) {
      insights.add(AIInsight(
        type: InsightType.optimization,
        title: 'Low Completion Rate',
        description:
            'Only ${(completionRate * 100).toInt()}% of users complete this template',
        confidence: 0.85,
        actionable: true,
        recommendation:
            'Consider simplifying fields or improving field descriptions',
      ));
    }

    // Field-specific insights
    final fieldInsights = _generateFieldInsights(analytics);
    insights.addAll(fieldInsights);

    // Trend analysis
    final trendInsights = _generateTrendInsights(templateId);
    insights.addAll(trendInsights);

    return insights;
  }

  List<AIInsight> _generateFieldInsights(TemplateAnalytics analytics) {
    final insights = <AIInsight>[];

    for (final entry in analytics.fieldCompletionRates.entries) {
      final fieldId = entry.key;
      final completionCount = entry.value;
      final completionRate = completionCount / analytics.usageCount;

      if (completionRate < 0.5) {
        insights.add(AIInsight(
          type: InsightType.optimization,
          title: 'Low Field Completion',
          description:
              'Field "$fieldId" has only ${(completionRate * 100).toInt()}% completion rate',
          confidence: 0.8,
          actionable: true,
          recommendation:
              'Consider making this field optional or improving its description',
        ));
      }
    }

    return insights;
  }

  List<AIInsight> _generateTrendInsights(String templateId) {
    final insights = <AIInsight>[];
    final patterns =
        _usagePatterns.where((p) => p.templateId == templateId).toList();

    if (patterns.isEmpty) return insights;

    // Analyze usage by hour
    final hourUsage = <int, int>{};
    for (final pattern in patterns) {
      hourUsage[pattern.hourOfDay] = (hourUsage[pattern.hourOfDay] ?? 0) + 1;
    }

    final peakHour =
        hourUsage.entries.reduce((a, b) => a.value > b.value ? a : b);
    if (peakHour.value > patterns.length * 0.3) {
      insights.add(AIInsight(
        type: InsightType.trend,
        title: 'Peak Usage Time',
        description: 'Template is most used at ${peakHour.key}:00',
        confidence: 0.7,
        actionable: false,
        recommendation:
            'Consider optimizing for this time zone or promoting during peak hours',
      ));
    }

    return insights;
  }

  void _updatePopularityScore(String templateId) {
    final analytics = _analytics[templateId]!;
    double score = 0.0;

    // Usage frequency (40%)
    score += (analytics.usageCount / 100) * 0.4;

    // Unique users (30%)
    score += (analytics.uniqueUsers.length / 50) * 0.3;

    // Completion rate (20%)
    score += analytics.completionRate * 0.2;

    // Recency (10%)
    final daysSinceLastUse =
        DateTime.now().difference(analytics.lastUsed ?? DateTime.now()).inDays;
    score += (1 - (daysSinceLastUse / 30).clamp(0, 1)) * 0.1;

    _templatePopularity[templateId] = score.clamp(0, 1);
  }

  void _identifyUsagePatterns(String templateId, DateTime timestamp) {
    // Analyze usage patterns for AI insights
    final pattern = UsagePattern(
      templateId: templateId,
      timestamp: timestamp,
      hourOfDay: timestamp.hour,
      dayOfWeek: timestamp.weekday,
    );

    _usagePatterns.add(pattern);

    // Keep only recent patterns (last 30 days)
    _usagePatterns
        .removeWhere((p) => DateTime.now().difference(p.timestamp).inDays > 30);
  }

  /// Get analytics for a specific template
  TemplateAnalytics? getAnalytics(String templateId) {
    return _analytics[templateId];
  }

  /// Get popularity score for a template
  double getPopularityScore(String templateId) {
    return _templatePopularity[templateId] ?? 0.0;
  }

  /// Get trending templates
  List<String> getTrendingTemplates({int limit = 10}) {
    final sortedTemplates = _templatePopularity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTemplates.take(limit).map((e) => e.key).toList();
  }

  /// Get usage patterns for a template
  List<UsagePattern> getUsagePatterns(String templateId) {
    return _usagePatterns.where((p) => p.templateId == templateId).toList();
  }

  /// Export analytics data
  Map<String, dynamic> exportAnalytics() {
    return {
      'analytics':
          _analytics.map((key, value) => MapEntry(key, value.toJson())),
      'usagePatterns': _usagePatterns.map((p) => p.toJson()).toList(),
      'popularityScores': _templatePopularity,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import analytics data
  void importAnalytics(Map<String, dynamic> data) {
    if (data['analytics'] != null) {
      final analyticsData = data['analytics'] as Map<String, dynamic>;
      for (final entry in analyticsData.entries) {
        _analytics[entry.key] =
            TemplateAnalytics.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    if (data['usagePatterns'] != null) {
      final patternsData = data['usagePatterns'] as List;
      _usagePatterns.assignAll(patternsData
          .map((p) => UsagePattern.fromJson(p as Map<String, dynamic>))
          .toList());
    }

    if (data['popularityScores'] != null) {
      _templatePopularity.assignAll(
          (data['popularityScores'] as Map<String, dynamic>)
              .cast<String, double>());
    }
  }
}
