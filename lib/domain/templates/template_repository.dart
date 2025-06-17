import 'package:get/get.dart';
import 'dart:convert';

class TemplateRepository extends GetxService {
  // Template collections by domain
  final Map<String, RxList<TemplateModel>> _domainTemplates = {};
  
  // Template categories
  final RxList<String> categories = <String>[].obs;
  
  // Recently used templates
  final RxList<String> recentTemplates = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTemplateCollections();
    _loadRecentTemplates();
  }

  void _initializeTemplateCollections() {
    // Initialize base collections
    _domainTemplates['enterprise'] = <TemplateModel>[].obs;
    _domainTemplates['marketing'] = <TemplateModel>[].obs;
    _domainTemplates['research'] = <TemplateModel>[].obs;
    _domainTemplates['healthcare'] = <TemplateModel>[].obs;
    _domainTemplates['legal'] = <TemplateModel>[].obs;
    
    // Load templates for each domain
    _loadDomainTemplates();
    
    // Extract unique categories
    _updateCategories();
  }
  
  Future<void> _loadDomainTemplates() async {
    // Load enterprise templates
    await _loadEnterpriseTemplates();
    
    // Load marketing templates
    await _loadMarketingTemplates();
    
    // Load research templates
    await _loadResearchTemplates();
    
    // Load healthcare templates
    await _loadHealthcareTemplates();
    
    // Load legal templates
    await _loadLegalTemplates();
  }
  
  void _updateCategories() {
    final Set<String> uniqueCategories = {};
    
    // Extract categories from all templates
    _domainTemplates.forEach((domain, templates) {
      for (var template in templates) {
        uniqueCategories.add(template.category);
      }
    });
    
    categories.value = uniqueCategories.toList()..sort();
  }
  
  Future<void> _loadRecentTemplates() async {
    // Load recently used templates from local storage
    // Implementation depends on storage mechanism
  }
  
  List<TemplateModel> getTemplatesByDomain(String domain) {
    return _domainTemplates[domain] ?? [];
  }
  
  List<TemplateModel> getTemplatesByCategory(String category) {
    final results = <TemplateModel>[];
    
    _domainTemplates.forEach((domain, templates) {
      results.addAll(templates.where((t) => t.category == category));
    });
    
    return results;
  }
  
  Future<List<TemplateModel>> searchTemplates(String query) async {
    final results = <TemplateModel>[];
    final lowercaseQuery = query.toLowerCase();
    
    _domainTemplates.forEach((domain, templates) {
      results.addAll(templates.where((t) => 
        t.title.toLowerCase().contains(lowercaseQuery) ||
        t.description.toLowerCase().contains(lowercaseQuery) ||
        t.category.toLowerCase().contains(lowercaseQuery)
      ));
    });
    
    return results;
  }
  
  Future<List<String>> getSuggestedTemplateIds(String context, List<String> userTags) async {
    // Implement template recommendation algorithm
    // This could use recent templates, user tags, and context
    final recommendations = <String>[];
    
    // Add context-based recommendations
    // Implementation would depend on specific recommendation algorithm
    
    return recommendations;
  }
  
  // Implementation for loading specific domain templates
  Future<void> _loadEnterpriseTemplates() async {
    // Load enterprise templates from assets or API
  }
  
  // Similar methods for other domains
  Future<void> _loadMarketingTemplates() async {
    // Load marketing templates
  }
  
  Future<void> _loadResearchTemplates() async {
    // Load research templates
  }
  
  Future<void> _loadHealthcareTemplates() async {
    // Load healthcare templates
  }
  
  Future<void> _loadLegalTemplates() async {
    // Load legal templates
  }
}

class TemplateModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String domain;
  final String templateContent;
  final List<TemplateField> fields;
  final Map<String, dynamic> metadata;
  
  TemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.domain,
    required this.templateContent,
    required this.fields,
    this.metadata = const {},
  });
  
  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      domain: json['domain'] ?? 'general',
      templateContent: json['templateContent'],
      fields: (json['fields'] as List?)
          ?.map((f) => TemplateField.fromJson(f))
          .toList() ?? [],
      metadata: json['metadata'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'domain': domain,
      'templateContent': templateContent,
      'fields': fields.map((f) => f.toJson()).toList(),
      'metadata': metadata,
    };
  }
}

class TemplateField {
  final String id;
  final String label;
  final String? placeholder;
  final String type;
  final bool isRequired;
  final List<String>? options;
  final Map<String, dynamic>? validations;
  final Map<String, dynamic>? aiGenerated;
  
  TemplateField({
    required this.id,
    required this.label,
    this.placeholder,
    required this.type,
    this.isRequired = false,
    this.options,
    this.validations,
    this.aiGenerated,
  });
  
  factory TemplateField.fromJson(Map<String, dynamic> json) {
    return TemplateField(
      id: json['id'],
      label: json['label'],
      placeholder: json['placeholder'],
      type: json['type'],
      isRequired: json['isRequired'] ?? false,
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      validations: json['validations'],
      aiGenerated: json['aiGenerated'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'placeholder': placeholder,
      'type': type,
      'isRequired': isRequired,
      'options': options,
      'validations': validations,
      'aiGenerated': aiGenerated,
    };
  }
}
