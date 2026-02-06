import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/local_book.dart';
import 'package:epubx/epubx.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;

class LocalBookService {
  static const String boxName = "local_books";

  /// Инициализация Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(LocalBookAdapter());
    await Hive.openBox<LocalBook>(boxName);
  }

  /// Сканы EPUB из папки assets/books
  static Future<List<LocalBook>> scanLocalBooks() async {
    final box = Hive.box<LocalBook>(boxName);

    // Путь к ассетам
    Directory appDir = await getApplicationDocumentsDirectory();
    final booksDir = Directory(p.join(appDir.path, "assets", "books"));

    if (!await booksDir.exists()) return [];

    final files = booksDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith(".epub"))
        .toList();

    List<LocalBook> books = [];

    for (var file in files) {
      try {
        final epub = await EpubReader.readBook(await file.readAsBytes());

        // создаем путь для обложки
        String? coverPath;
        if (epub.CoverImage != null) {
          final coverFile = File(
            p.join(
              appDir.path,
              "covers",
              p.basenameWithoutExtension(file.path) + ".png",
            ),
          );
          if (!await coverFile.parent.exists()) {
            await coverFile.parent.create(recursive: true);
          }

          final img.Image coverImage = epub.CoverImage!;
          final bytes = img.encodePng(coverImage);
          await coverFile.writeAsBytes(bytes);
          coverPath = coverFile.path;
        }

        final book = LocalBook(
          filePath: file.path,
          title: epub.Title ?? p.basenameWithoutExtension(file.path),
          author: epub.Author ?? "Unknown",
          description: "",
          cover: coverPath,
        );

        await box.put(file.path, book); // сохраняем в Hive
        books.add(book);
      } catch (e) {
        debugPrint("⚠️ Failed to parse EPUB: ${file.path} -> $e");
      }
    }

    return books;
  }

  /// Получить все книги
  static List<LocalBook> getAllBooks() {
    final box = Hive.box<LocalBook>(boxName);
    return box.values.toList();
  }

  /// Обновить прогресс
  static Future<void> updateProgress(String filePath, int progress) async {
    final box = Hive.box<LocalBook>(boxName);
    final book = box.get(filePath);
    if (book != null) {
      book.progress = progress;
      await book.save();
    }
  }

  /// Переключить избранное
  static Future<void> toggleFavorite(String filePath) async {
    final box = Hive.box<LocalBook>(boxName);
    final book = box.get(filePath);
    if (book != null) {
      book.isFavorite = !book.isFavorite;
      await book.save();
    }
  }
}
