// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_template_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnhancedTemplateModelAdapter extends TypeAdapter<EnhancedTemplateModel> {
  @override
  final int typeId = 8;

  @override
  EnhancedTemplateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnhancedTemplateModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      templateContent: fields[4] as String,
      fields: (fields[5] as List).cast<PromptField>(),
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      author: fields[8] as String?,
      version: fields[9] as String,
      tags: (fields[10] as List?)?.cast<String>(),
      aiMetadata: fields[11] as AIMetadata?,
      collaborators: (fields[12] as List?)?.cast<String>(),
      analytics: (fields[13] as Map?)?.cast<String, dynamic>(),
      versionHistory: (fields[14] as List?)?.cast<TemplateVersion>(),
      settings: fields[15] as TemplateSettings?,
      relatedTemplates: (fields[16] as List?)?.cast<String>(),
      popularityScore: fields[17] as double?,
      localizations: (fields[18] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, EnhancedTemplateModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.templateContent)
      ..writeByte(5)
      ..write(obj.fields)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.author)
      ..writeByte(9)
      ..write(obj.version)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.aiMetadata)
      ..writeByte(12)
      ..write(obj.collaborators)
      ..writeByte(13)
      ..write(obj.analytics)
      ..writeByte(14)
      ..write(obj.versionHistory)
      ..writeByte(15)
      ..write(obj.settings)
      ..writeByte(16)
      ..write(obj.relatedTemplates)
      ..writeByte(17)
      ..write(obj.popularityScore)
      ..writeByte(18)
      ..write(obj.localizations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnhancedTemplateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
