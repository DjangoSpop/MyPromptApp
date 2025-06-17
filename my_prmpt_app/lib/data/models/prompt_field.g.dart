// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prompt_field.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PromptFieldAdapter extends TypeAdapter<PromptField> {
  @override
  final int typeId = 0;

  @override
  PromptField read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PromptField(
      id: fields[0] as String,
      label: fields[1] as String,
      placeholder: fields[2] as String,
      type: fields[3] as FieldType,
      isRequired: fields[4] as bool,
      options: (fields[5] as List?)?.cast<String>(),
      defaultValue: fields[6] as String?,
      validationPattern: fields[7] as String?,
      helpText: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PromptField obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.placeholder)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.isRequired)
      ..writeByte(5)
      ..write(obj.options)
      ..writeByte(6)
      ..write(obj.defaultValue)
      ..writeByte(7)
      ..write(obj.validationPattern)
      ..writeByte(8)
      ..write(obj.helpText);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptFieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FieldTypeAdapter extends TypeAdapter<FieldType> {
  @override
  final int typeId = 1;

  @override
  FieldType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FieldType.text;
      case 1:
        return FieldType.textarea;
      case 2:
        return FieldType.dropdown;
      case 3:
        return FieldType.checkbox;
      case 4:
        return FieldType.radio;
      case 5:
        return FieldType.number;
      default:
        return FieldType.text;
    }
  }

  @override
  void write(BinaryWriter writer, FieldType obj) {
    switch (obj) {
      case FieldType.text:
        writer.writeByte(0);
        break;
      case FieldType.textarea:
        writer.writeByte(1);
        break;
      case FieldType.dropdown:
        writer.writeByte(2);
        break;
      case FieldType.checkbox:
        writer.writeByte(3);
        break;
      case FieldType.radio:
        writer.writeByte(4);
        break;
      case FieldType.number:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
