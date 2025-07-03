// lib/data/models/learning_module.dart
import 'package:hive/hive.dart';

part 'learning_module.g.dart';

@HiveType(typeId: 3)
class LearningModule extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String benefit;

  @HiveField(4)
  int difficultyLevel;

  @HiveField(5)
  int estimatedMinutes;

  @HiveField(6)
  List<String> keyPoints;

  @HiveField(7)
  List<String> examples;

  @HiveField(8)
  String practicalExercise;

  @HiveField(9)
  bool isCompleted;

  @HiveField(10)
  bool isInBox;

  @HiveField(11)
  DateTime? completedAt;

  @HiveField(12)
  String category;

  @HiveField(13)
  List<String> tags;

  LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.benefit,
    this.difficultyLevel = 1,
    this.estimatedMinutes = 15,
    this.keyPoints = const [],
    this.examples = const [],
    this.practicalExercise = '',
    this.isCompleted = false,
    this.isInBox = false,
    this.completedAt,
    this.category = 'General',
    this.tags = const [],
  });

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    try {
      return LearningModule(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Untitled Module',
        description: json['description'] as String? ?? '',
        benefit: json['benefit'] as String? ?? 'General Learning',
        difficultyLevel: json['difficultyLevel'] as int? ?? 1,
        estimatedMinutes: json['estimatedMinutes'] as int? ?? 15,
        keyPoints: (json['keyPoints'] as List<dynamic>?)?.cast<String>() ?? [],
        examples: (json['examples'] as List<dynamic>?)?.cast<String>() ?? [],
        practicalExercise: json['practicalExercise'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
        isInBox: json['isInBox'] as bool? ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
        category: json['category'] as String? ?? 'General',
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );
    } catch (e) {
      throw FormatException('Invalid LearningModule JSON: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'benefit': benefit,
      'difficultyLevel': difficultyLevel,
      'estimatedMinutes': estimatedMinutes,
      'keyPoints': keyPoints,
      'examples': examples,
      'practicalExercise': practicalExercise,
      'isCompleted': isCompleted,
      'isInBox': isInBox,
      'completedAt': completedAt?.toIso8601String(),
      'category': category,
      'tags': tags,
    };
  }

  LearningModule copyWith({
    String? id,
    String? title,
    String? description,
    String? benefit,
    int? difficultyLevel,
    int? estimatedMinutes,
    List<String>? keyPoints,
    List<String>? examples,
    String? practicalExercise,
    bool? isCompleted,
    bool? isInBox,
    DateTime? completedAt,
    String? category,
    List<String>? tags,
  }) {
    return LearningModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      benefit: benefit ?? this.benefit,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      keyPoints: keyPoints ?? List<String>.from(this.keyPoints),
      examples: examples ?? List<String>.from(this.examples),
      practicalExercise: practicalExercise ?? this.practicalExercise,
      isCompleted: isCompleted ?? this.isCompleted,
      isInBox: isInBox ?? this.isInBox,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      tags: tags ?? List<String>.from(this.tags),
    );
  }

  bool isValid() {
    return id.isNotEmpty &&
        title.trim().isNotEmpty &&
        description.trim().isNotEmpty &&
        difficultyLevel > 0 &&
        estimatedMinutes > 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LearningModule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
