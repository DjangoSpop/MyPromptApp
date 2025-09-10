// lib/domain/services/ai_context_engine.dart
import 'package:get/get.dart';
import '../models/ai_context.dart';
import '../../data/models/template_model.dart';

/// AI-powered context engine for intelligent template suggestions with RAG integration
class AIContextEngine extends GetxService {
  final Map<String, List<AIContext>> _contextDatabase = {};
  final RxList<String> _recentQueries = <String>[].obs;
  final RxMap<String, double> _contextRelevanceScores = <String, double>{}.obs;
  final RxList<TemplateSuggestion> _cachedSuggestions =
      <TemplateSuggestion>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeContextDatabase();
  }

  /// Initialize the AI context database with domain knowledge
  void _initializeContextDatabase() {
    // Software Development Contexts
    _contextDatabase['software_development'] = [
      AIContext(
        id: 'dev_001',
        domain: 'Software Development',
        context:
            'Clean Architecture principles, SOLID design patterns, microservices architecture',
        keywords: [
          'architecture',
          'design patterns',
          'microservices',
          'clean code'
        ],
        relevanceScore: 0.95,
        usageCount: 150,
      ),
      AIContext(
        id: 'dev_002',
        domain: 'Software Development',
        context:
            'Agile methodologies, Scrum framework, DevOps practices, CI/CD pipelines',
        keywords: ['agile', 'scrum', 'devops', 'cicd', 'testing'],
        relevanceScore: 0.92,
        usageCount: 120,
      ),
      AIContext(
        id: 'dev_003',
        domain: 'Software Development',
        context:
            'API design, RESTful services, GraphQL, microservices communication',
        keywords: ['api', 'rest', 'graphql', 'microservices', 'endpoints'],
        relevanceScore: 0.90,
        usageCount: 95,
      ),
      AIContext(
        id: 'dev_004',
        domain: 'Software Development',
        context:
            'Database design, normalization, performance optimization, indexing',
        keywords: ['database', 'sql', 'optimization', 'indexing', 'schema'],
        relevanceScore: 0.88,
        usageCount: 110,
      ),
    ];

    // Business & Marketing Contexts
    _contextDatabase['business'] = [
      AIContext(
        id: 'bus_001',
        domain: 'Business Strategy',
        context:
            'Market analysis, competitive intelligence, business model canvas, value propositions',
        keywords: ['strategy', 'market', 'competition', 'business model'],
        relevanceScore: 0.88,
        usageCount: 89,
      ),
      AIContext(
        id: 'bus_002',
        domain: 'Business Strategy',
        context:
            'Financial planning, revenue models, cost analysis, ROI calculations',
        keywords: ['finance', 'revenue', 'costs', 'roi', 'budget'],
        relevanceScore: 0.85,
        usageCount: 75,
      ),
      AIContext(
        id: 'bus_003',
        domain: 'Marketing',
        context:
            'Digital marketing, content strategy, social media, customer acquisition',
        keywords: [
          'marketing',
          'digital',
          'content',
          'social media',
          'customers'
        ],
        relevanceScore: 0.87,
        usageCount: 65,
      ),
    ];

    // Creative & Content Contexts
    _contextDatabase['creative'] = [
      AIContext(
        id: 'cre_001',
        domain: 'Content Creation',
        context:
            'Storytelling frameworks, narrative structures, content strategy, audience engagement',
        keywords: ['storytelling', 'content', 'narrative', 'engagement'],
        relevanceScore: 0.91,
        usageCount: 75,
      ),
      AIContext(
        id: 'cre_002',
        domain: 'Creative Writing',
        context:
            'Creative writing techniques, character development, plot structures',
        keywords: ['writing', 'characters', 'plot', 'creative', 'story'],
        relevanceScore: 0.89,
        usageCount: 60,
      ),
    ];

    // Education & Learning Contexts
    _contextDatabase['education'] = [
      AIContext(
        id: 'edu_001',
        domain: 'Education',
        context:
            'Learning objectives, curriculum design, assessment strategies, pedagogical approaches',
        keywords: [
          'education',
          'learning',
          'curriculum',
          'assessment',
          'teaching'
        ],
        relevanceScore: 0.86,
        usageCount: 45,
      ),
      AIContext(
        id: 'edu_002',
        domain: 'Training',
        context:
            'Professional development, skill assessment, training methodologies',
        keywords: [
          'training',
          'skills',
          'development',
          'professional',
          'methodology'
        ],
        relevanceScore: 0.84,
        usageCount: 55,
      ),
    ];

    // Research & Analysis Contexts
    _contextDatabase['research'] = [
      AIContext(
        id: 'res_001',
        domain: 'Research',
        context:
            'Research methodologies, data collection, statistical analysis, literature review',
        keywords: ['research', 'data', 'analysis', 'methodology', 'statistics'],
        relevanceScore: 0.90,
        usageCount: 40,
      ),
      AIContext(
        id: 'res_002',
        domain: 'Data Science',
        context:
            'Data science workflows, machine learning, data visualization, predictive modeling',
        keywords: [
          'data science',
          'machine learning',
          'visualization',
          'modeling'
        ],
        relevanceScore: 0.93,
        usageCount: 35,
      ),
    ];
  }

  /// Retrieve relevant context based on user input and template type
  Future<List<AIContext>> getRelevantContext(
      String query, String templateCategory) async {
    final relevantContexts = <AIContext>[];
    final queryLower = query.toLowerCase();

    // Add query to recent searches
    _recentQueries.add(query);
    if (_recentQueries.length > 10) {
      _recentQueries.removeAt(0);
    }

    // Search across all context domains
    for (final contextList in _contextDatabase.values) {
      for (final context in contextList) {
        double score =
            _calculateRelevanceScore(queryLower, context, templateCategory);
        if (score > 0.3) {
          context.relevanceScore = score;
          relevantContexts.add(context);
        }
      }
    }

    // Sort by relevance score
    relevantContexts
        .sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

    return relevantContexts.take(5).toList();
  }

  /// Calculate relevance score using semantic analysis
  double _calculateRelevanceScore(
      String query, AIContext context, String category) {
    double score = 0.0;

    // Keyword matching
    for (final keyword in context.keywords) {
      if (query.contains(keyword.toLowerCase())) {
        score += 0.2;
      }
    }

    // Category matching
    if (context.domain.toLowerCase().contains(category.toLowerCase())) {
      score += 0.3;
    }

    // Context relevance
    if (context.context.toLowerCase().contains(query)) {
      score += 0.4;
    }

    // Usage frequency boost
    score += (context.usageCount / 1000) * 0.1;

    return score.clamp(0.0, 1.0);
  }

  /// Generate AI-powered template suggestions based on user input
  Future<List<TemplateSuggestion>> generateTemplateSuggestions(
      String userInput) async {
    final contexts = await getRelevantContext(userInput, 'general');
    final suggestions = <TemplateSuggestion>[];

    for (final context in contexts) {
      suggestions.add(TemplateSuggestion(
        title: _generateSuggestionTitle(userInput, context),
        description: _generateSuggestionDescription(context),
        templateStructure: _generateTemplateStructure(context),
        confidence: context.relevanceScore,
        aiContext: context,
      ));
    }

    // Cache suggestions for performance
    _cachedSuggestions.clear();
    _cachedSuggestions.addAll(suggestions);

    return suggestions;
  }

  String _generateSuggestionTitle(String input, AIContext context) {
    return "${input.split(' ').take(3).join(' ')} - ${context.domain} Assistant";
  }

  String _generateSuggestionDescription(AIContext context) {
    return "AI-generated template incorporating ${context.context.split(',').take(2).join(' and')}";
  }

  Map<String, dynamic> _generateTemplateStructure(AIContext context) {
    return {
      'fields': _generateFieldsFromContext(context),
      'template': _generateTemplateFromContext(context),
      'metadata': {
        'aiGenerated': true,
        'contextId': context.id,
        'confidence': context.relevanceScore,
      }
    };
  }

  List<Map<String, dynamic>> _generateFieldsFromContext(AIContext context) {
    // Generate intelligent fields based on context
    final fields = <Map<String, dynamic>>[];

    for (final keyword in context.keywords.take(4)) {
      fields.add({
        'id': keyword.replaceAll(' ', '_').toLowerCase(),
        'label': keyword.split(' ').map((w) => w.capitalize).join(' '),
        'placeholder': 'Enter ${keyword.toLowerCase()}...',
        'type': _determineFieldType(keyword),
        'isRequired': true,
        'aiGenerated': true,
      });
    }

    return fields;
  }

  String _determineFieldType(String keyword) {
    if (keyword.contains('description') || keyword.contains('content')) {
      return 'textarea';
    } else if (keyword.contains('type') || keyword.contains('category')) {
      return 'dropdown';
    }
    return 'text';
  }

  String _generateTemplateFromContext(AIContext context) {
    return """
# AI-Enhanced ${context.domain} Template

## Context Analysis
${context.context}

## Primary Focus
{{${context.keywords.first.replaceAll(' ', '_').toLowerCase()}}}

## Detailed Analysis
Please provide comprehensive information for:
${context.keywords.map((k) => '- {{${k.replaceAll(' ', '_').toLowerCase()}}}').join('\n')}

## AI Recommendations
This template leverages ${context.domain} best practices and incorporates intelligent suggestions based on your specific requirements.

## Additional Considerations
- Consider industry standards and best practices
- Ensure compliance with relevant regulations
- Optimize for user experience and clarity
- Incorporate measurable outcomes where applicable

---
*Generated with AI assistance • Confidence: ${(context.relevanceScore * 100).toInt()}%*
*Template ID: ${context.id} • Generated: ${DateTime.now().toString().split('.')[0]}*
""";
  }

  /// Update usage statistics for machine learning
  void updateContextUsage(String contextId) {
    for (final contextList in _contextDatabase.values) {
      for (final context in contextList) {
        if (context.id == contextId) {
          context.usageCount++;
          context.lastUsed = DateTime.now();
          // Update relevance score based on usage
          context.relevanceScore =
              (context.relevanceScore + 0.01).clamp(0.0, 1.0);
          break;
        }
      }
    }
  }

  /// Get trending contexts based on recent usage patterns
  List<AIContext> getTrendingContexts() {
    final allContexts = <AIContext>[];
    for (final contextList in _contextDatabase.values) {
      allContexts.addAll(contextList);
    }

    // Sort by recent usage and frequency
    allContexts.sort((a, b) {
      final aScore = a.usageCount +
          (a.lastUsed != null
              ? (DateTime.now().difference(a.lastUsed!).inDays < 7 ? 50 : 0)
              : 0);
      final bScore = b.usageCount +
          (b.lastUsed != null
              ? (DateTime.now().difference(b.lastUsed!).inDays < 7 ? 50 : 0)
              : 0);
      return bScore.compareTo(aScore);
    });

    return allContexts.take(10).toList();
  }

  /// Perform advanced semantic search with context awareness
  Future<List<AIContext>> performSemanticSearch(String query,
      {int limit = 5}) async {
    final results = <AIContext>[];
    final queryTerms = query.toLowerCase().split(' ');

    for (final contextList in _contextDatabase.values) {
      for (final context in contextList) {
        double score = 0.0;

        // Exact keyword matches (high weight)
        for (final keyword in context.keywords) {
          if (queryTerms.any((term) => keyword.toLowerCase().contains(term))) {
            score += 0.4;
          }
        }

        // Context description matches (medium weight)
        final contextWords = context.context.toLowerCase().split(' ');
        for (final term in queryTerms) {
          if (contextWords.any((word) => word.contains(term))) {
            score += 0.2;
          }
        }

        // Domain relevance (low weight)
        if (context.domain.toLowerCase().contains(query.toLowerCase())) {
          score += 0.1;
        }

        // Usage popularity boost
        score += (context.usageCount / 1000) * 0.1;

        if (score > 0.1) {
          context.relevanceScore = score;
          results.add(context);
        }
      }
    }

    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return results.take(limit).toList();
  }

  /// Get cached suggestions for performance
  List<TemplateSuggestion> get cachedSuggestions => _cachedSuggestions.toList();

  /// Clear cached suggestions
  void clearCache() {
    _cachedSuggestions.clear();
  }

  /// Get analytics data for dashboard
  Map<String, dynamic> getAnalyticsData() {
    final totalContexts =
        _contextDatabase.values.fold(0, (sum, list) => sum + list.length);
    final totalUsage = _contextDatabase.values
        .expand((list) => list)
        .fold(0, (sum, context) => sum + context.usageCount);

    return {
      'totalContexts': totalContexts,
      'totalUsage': totalUsage,
      'recentQueries': _recentQueries.length,
      'trendingContexts': getTrendingContexts().length,
      'cacheSize': _cachedSuggestions.length,
    };
  }
}
