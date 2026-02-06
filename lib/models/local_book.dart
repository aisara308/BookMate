import 'package:hive/hive.dart';

part 'local_book.g.dart';

@HiveType(typeId: 0)
class LocalBook extends HiveObject {
  @HiveField(0)
  String filePath;

  @HiveField(1)
  String title;

  @HiveField(2)
  String author;

  @HiveField(3)
  String description;

  @HiveField(4)
  String? cover; // путь к локальной обложке

  @HiveField(5)
  int progress;

  @HiveField(6)
  bool isFavorite;

  LocalBook({
    required this.filePath,
    required this.title,
    required this.author,
    required this.description,
    this.cover,
    this.progress = 0,
    this.isFavorite = false,
  });
}
