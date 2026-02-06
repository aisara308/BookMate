import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/keys.dart';
import 'package:http/http.dart' as http;
import 'package:epubx/epubx.dart' as epub;

class BookReviewScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookReviewScreen({super.key, required this.book});

  @override
  State<BookReviewScreen> createState() => _BookReviewScreenState();
}

class _BookReviewScreenState extends State<BookReviewScreen> {
  bool loadingEpub = true;
  String firstChapterText = '';
  List<String> chapters = [];
  Uint8List? coverBytes; // для обложки из epub

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  Future<void> _loadEpub() async {
    try {
      final filePath = widget.book['filePath'];
      if (filePath == null) return;

      final url = 'http://10.0.2.2:3000$filePath';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Uint8List bytes = response.bodyBytes;
        epub.EpubBook epubBook = await epub.EpubReader.readBook(bytes);

        if (epubBook.CoverImage != null) {
          coverBytes = epubBook.CoverImage as Uint8List?;
        }

        chapters =
            epubBook.Chapters?.map((c) => c.Title ?? 'No title').toList() ?? [];

        if (epubBook.Chapters != null && epubBook.Chapters!.isNotEmpty) {
          firstChapterText = epubBook.Chapters!.first.HtmlContent ?? '';
        }
      }
    } catch (e) {
      print('Error loading epub: $e');
    } finally {
      setState(() => loadingEpub = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    double progress = (book['progress'] ?? 0).toDouble();

    if (progress > 1) {
      progress = progress / 100;
    }

    progress = progress.clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              "assets/bg3.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Color.fromRGBO(60, 57, 103, 1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 100,
                          height: 150,
                          child: coverBytes != null
                              ? Image.memory(coverBytes!, fit: BoxFit.cover)
                              : (book['filePath'] != null
                                    ? Image.network(
                                        'http://10.0.2.2:3000/assets/covers/${book['filePath'].split('/').last.split('.').first}.jpeg',
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.book),
                                      )),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['title'] ?? tr(Keys.unknownTitle),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(60, 57, 103, 1),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book['author'] ?? tr(Keys.unknownAuthor),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(194, 60, 57, 103),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.menu_book,
                                      size: 18,
                                      color: Color.fromRGBO(60, 57, 103, 1),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tr(
                                        Keys.readingProgress,
                                        args: [
                                          (progress * 100).toInt().toString(),
                                        ],
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color.fromRGBO(60, 57, 103, 1),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: progress),
                                  duration: const Duration(milliseconds: 600),
                                  builder: (context, value, _) {
                                    return LinearProgressIndicator(
                                      value: value,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey[300],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color.fromRGBO(90, 120, 255, 1),
                                          ),
                                      borderRadius: BorderRadius.circular(4),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  book['isFavorite'] == true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  book['isFinished'] == true
                                      ? Icons.done_all
                                      : Icons.done,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr(Keys.description),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book['description'] ?? tr(Keys.noDescription),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          if (loadingEpub)
                            const Center(child: CircularProgressIndicator())
                          else ...[
                            if (chapters.isNotEmpty) ...[
                              Text(
                                tr(
                                  Keys.chapters,
                                  args: [chapters.length.toString()],
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...chapters
                                  .map(
                                    (c) => Text(
                                      "• $c",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  )
                                  .toList(),
                              const SizedBox(height: 16),
                              Text(
                                tr(Keys.firstChapterPreview),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                firstChapterText,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ] else
                              const Text(""),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
