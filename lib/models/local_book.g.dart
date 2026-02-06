// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalBookAdapter extends TypeAdapter<LocalBook> {
  @override
  final int typeId = 0;

  @override
  LocalBook read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalBook(
      filePath: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      description: fields[3] as String,
      cover: fields[4] as String?,
      progress: fields[5] as int,
      isFavorite: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalBook obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.filePath)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.cover)
      ..writeByte(5)
      ..write(obj.progress)
      ..writeByte(6)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalBookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
