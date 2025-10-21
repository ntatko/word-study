// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passage_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PassageAdapter extends TypeAdapter<Passage> {
  @override
  final int typeId = 1;

  @override
  Passage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Passage(
      id: fields[0] as int,
      passage: fields[1] as String,
      study: fields[2] as String,
      lesson: fields[3] as String,
      rollout: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Passage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.passage)
      ..writeByte(2)
      ..write(obj.study)
      ..writeByte(3)
      ..write(obj.lesson)
      ..writeByte(4)
      ..write(obj.rollout);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PassageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
