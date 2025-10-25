// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_study_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordStudyAdapter extends TypeAdapter<WordStudy> {
  @override
  final int typeId = 0;

  @override
  WordStudy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordStudy(
      id: fields[0] as String,
      passageReference: fields[1] as String,
      selectedWord: fields[2] as String,
      chosenDefinition: fields[3] as String?,
      definitionSource: fields[4] as String?,
      biblicalLanguageWord: fields[5] as String?,
      biblicalLanguageDefinition: fields[6] as String?,
      crossReferences: (fields[7] as List?)?.cast<String>(),
      notes: fields[8] as String?,
      refinedDefinition: fields[9] as String?,
      createdAt: fields[10] as DateTime,
      lessonName: fields[11] as String?,
      studySource: fields[12] as String?,
      contextThoughts: fields[13] as String?,
      crossReferencePassages: (fields[14] as List?)?.cast<String>(),
      crossReferenceNotes: fields[15] as String?,
      outsideSources: fields[16] as String?,
      summary: fields[17] as String?,
      personalResponse: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WordStudy obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.passageReference)
      ..writeByte(2)
      ..write(obj.selectedWord)
      ..writeByte(3)
      ..write(obj.chosenDefinition)
      ..writeByte(4)
      ..write(obj.definitionSource)
      ..writeByte(5)
      ..write(obj.biblicalLanguageWord)
      ..writeByte(6)
      ..write(obj.biblicalLanguageDefinition)
      ..writeByte(7)
      ..write(obj.crossReferences)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.refinedDefinition)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.lessonName)
      ..writeByte(12)
      ..write(obj.studySource)
      ..writeByte(13)
      ..write(obj.contextThoughts)
      ..writeByte(14)
      ..write(obj.crossReferencePassages)
      ..writeByte(15)
      ..write(obj.crossReferenceNotes)
      ..writeByte(16)
      ..write(obj.outsideSources)
      ..writeByte(17)
      ..write(obj.summary)
      ..writeByte(18)
      ..write(obj.personalResponse);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordStudyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
