// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AIMetadataAdapter extends TypeAdapter<AIMetadata> {
  @override
  final int typeId = 11;

  @override
  AIMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AIMetadata(
      isAIGenerated: fields[0] as bool,
      confidence: fields[1] as double,
      aiModel: fields[2] as String?,
      extractedKeywords: (fields[3] as List?)?.cast<String>(),
      smartSuggestions: (fields[4] as Map?)?.cast<String, dynamic>(),
      contextDomain: fields[5] as String?,
      aiProcessedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AIMetadata obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.isAIGenerated)
      ..writeByte(1)
      ..write(obj.confidence)
      ..writeByte(2)
      ..write(obj.aiModel)
      ..writeByte(3)
      ..write(obj.extractedKeywords)
      ..writeByte(4)
      ..write(obj.smartSuggestions)
      ..writeByte(5)
      ..write(obj.contextDomain)
      ..writeByte(6)
      ..write(obj.aiProcessedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TemplateVersionAdapter extends TypeAdapter<TemplateVersion> {
  @override
  final int typeId = 12;

  @override
  TemplateVersion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemplateVersion(
      version: fields[0] as String,
      changelog: fields[1] as String,
      createdAt: fields[2] as DateTime,
      author: fields[3] as String?,
      templateData: (fields[4] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, TemplateVersion obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.version)
      ..writeByte(1)
      ..write(obj.changelog)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.templateData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateVersionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TemplateSettingsAdapter extends TypeAdapter<TemplateSettings> {
  @override
  final int typeId = 13;

  @override
  TemplateSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TemplateSettings(
      isPublic: fields[0] as bool,
      allowCollaboration: fields[1] as bool,
      accessPermissions: (fields[2] as List?)?.cast<String>(),
      customizations: (fields[3] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, TemplateSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.isPublic)
      ..writeByte(1)
      ..write(obj.allowCollaboration)
      ..writeByte(2)
      ..write(obj.accessPermissions)
      ..writeByte(3)
      ..write(obj.customizations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
