// lib/data/models/prompt_model.dart
import 'package:hive/hive.dart';

part 'prompt_model.g.dart';

@HiveType(typeId: 4)
class PromptModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String template;

  @HiveField(4)
  String category;

  @HiveField(5)
  List<String> tags;

  @HiveField(6)
  double rating;

  @HiveField(7)
  int usageCount;

  @HiveField(8)
  String author;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  bool isPremium;

  @HiveField(11)
  bool isFeatured;

  @HiveField(12)
  bool isTrending;

  @HiveField(13)
  Map<String, String> placeholders;

  @HiveField(14)
  String engineeringPrinciple; // Clarity, Conciseness, Format

  @HiveField(15)
  String contextType; // Task Specificity level

  @HiveField(16)
  int complexityLevel; // 1-5 scale

  PromptModel({
    required this.id,
    required this.title,
    required this.description,
    required this.template,
    required this.category,
    required this.tags,
    required this.rating,
    required this.usageCount,
    required this.author,
    required this.createdAt,
    this.isPremium = false,
    this.isFeatured = false,
    this.isTrending = false,
    this.placeholders = const {},
    this.engineeringPrinciple = 'Clarity',
    this.contextType = 'General',
    this.complexityLevel = 1,
  });

  // JSON serialization
  factory PromptModel.fromJson(Map<String, dynamic> json) {
    return PromptModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      template: json['template'] ?? '',
      category: json['category'] ?? 'General',
      tags: List<String>.from(json['tags'] ?? []),
      rating: (json['rating'] ?? 0.0).toDouble(),
      usageCount: json['usageCount'] ?? 0,
      author: json['author'] ?? 'Unknown',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isPremium: json['isPremium'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      isTrending: json['isTrending'] ?? false,
      placeholders: Map<String, String>.from(json['placeholders'] ?? {}),
      engineeringPrinciple: json['engineeringPrinciple'] ?? 'Clarity',
      contextType: json['contextType'] ?? 'General',
      complexityLevel: json['complexityLevel'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'template': template,
      'category': category,
      'tags': tags,
      'rating': rating,
      'usageCount': usageCount,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'placeholders': placeholders,
      'engineeringPrinciple': engineeringPrinciple,
      'contextType': contextType,
      'complexityLevel': complexityLevel,
    };
  }
}
