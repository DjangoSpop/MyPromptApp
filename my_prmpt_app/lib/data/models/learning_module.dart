// models/learning_module.dart
import 'package:hive/hive.dart';

part 'learning_module.g.dart';

@HiveType(typeId: 1)
class LearningModule extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String benefit; // One of the 7 core benefits

  @HiveField(4)
  List<String> keyPoints;

  @HiveField(5)
  List<String> examples;

  @HiveField(6)
  String practicalExercise;

  @HiveField(7)
  int difficultyLevel;

  @HiveField(8)
  int estimatedMinutes;

  @HiveField(9)
  bool isCompleted;

  LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.benefit,
    required this.keyPoints,
    required this.examples,
    required this.practicalExercise,
    required this.difficultyLevel,
    required this.estimatedMinutes,
    this.isCompleted = false,
  });

  // JSON serialization
  factory LearningModule.fromJson(Map<String, dynamic> json) {
    return LearningModule(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      benefit: json['benefit'] ?? '',
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      examples: List<String>.from(json['examples'] ?? []),
      practicalExercise: json['practicalExercise'] ?? '',
      difficultyLevel: json['difficultyLevel'] ?? 1,
      estimatedMinutes: json['estimatedMinutes'] ?? 10,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'benefit': benefit,
      'keyPoints': keyPoints,
      'examples': examples,
      'practicalExercise': practicalExercise,
      'difficultyLevel': difficultyLevel,
      'estimatedMinutes': estimatedMinutes,
      'isCompleted': isCompleted,
    };
  }
}
