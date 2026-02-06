import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/pages/readbook_screen.dart';
import 'package:flutter_application_1/pages/bookreview_screen.dart';
import 'package:flutter_application_1/utils/keys.dart';
import 'package:flutter_application_1/utils/menu_button.dart';
import 'package:http/http.dart' as http;

class FavoriteBooksScreen extends StatefulWidget {
  const FavoriteBooksScreen({super.key});

  @override
  State<FavoriteBooksScreen> createState() => _FavoriteBooksScreenState();
}

class _FavoriteBooksScreenState extends State<FavoriteBooksScreen> {
  List<dynamic> allBooks = [];
  List<dynamic> filteredBooks = [];
  bool loading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavoriteBooks();
  }

  Future<void> _loadFavoriteBooks() async {
    setState(() => loading = true);
    try {
      final uid = await api.getUid();
      if (uid == null) return;

      final response = await http.get(Uri.parse('$getMyBooks?uid=$uid'));

      if (response.statusCode == 200) {
        final books = jsonDecode(response.body) as List<dynamic>;
        allBooks = books.where((b) => b['isFavorite'] == true).toList();
        _applySearch();
      } else {
        allBooks = [];
        filteredBooks = [];
      }
    } catch (e) {
      allBooks = [];
      filteredBooks = [];
      debugPrint('❌ Failed to load favorite books: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  // Только обновляем любимое через сервер
  Future<void> toggleFavorite(String title) async {
    try {
      final uid = await api.getUid();
      final response = await http.patch(
        Uri.parse('${url}books/favorite'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": uid, "title": title}),
      );

      if (response.statusCode == 200) {
        // Перезагружаем любимые книги после изменения
        await _loadFavoriteBooks();
      } else {
        print('Failed to toggle favorite: ${response.body}');
      }
    } catch (e) {
      print('Error toggleFavorite: $e');
    }
  }

  // Завершение книги обновляет только на сервере, не удаляем с экрана
  Future<void> toggleFinished(String title) async {
    try {
      final uid = await api.getUid();
      final response = await http.patch(
        Uri.parse('${url}books/finished'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": uid, "title": title}),
      );

      if (response.statusCode == 200) {
        await _loadFavoriteBooks(); // заново подгружаем только завершенные книги
      } else {
        print('Failed to toggle finished: ${response.body}');
      }
    } catch (e) {
      print('Error toggleFinished: $e');
    }
  }

  void _applySearch() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredBooks = allBooks;
      } else {
        filteredBooks = allBooks.where((b) {
          final title = (b['title'] ?? '').toString().toLowerCase();
          final author = (b['author'] ?? '').toString().toLowerCase();
          final query = searchQuery.toLowerCase();
          return title.contains(query) || author.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(),
      body: Stack(
        children: [
          Container(color: Colors.white),
          IgnorePointer(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                "assets/bg7.png",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [MenuButton()],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        tr(
                          Keys.favoritesTitle,
                          args: [filteredBooks.length.toString()],
                        ),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(60, 57, 103, 1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // поиск
                      TextField(
                        decoration: InputDecoration(
                          hintText: tr(Keys.searchHint),
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          searchQuery = value;
                          _applySearch();
                        },
                      ),
                      Expanded(
                        child: filteredBooks.isEmpty
                            ? Center(child: Text(tr(Keys.noFavoriteBooksFound)))
                            : ListView.builder(
                                itemCount: filteredBooks.length,
                                itemBuilder: (context, index) {
                                  final book = filteredBooks[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ReadbookScreen(
                                                    fileUrl:
                                                        'http://10.0.2.2:3000${book['filePath']}',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: book['filePath'] != null
                                                  ? Image.network(
                                                      'http://10.0.2.2:3000/assets${coverFromFilePath(book['filePath'])}',
                                                      width: 80,
                                                      height: 120,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(
                                                      width: 80,
                                                      height: 120,
                                                      color: Colors.grey[300],
                                                      child: const Icon(
                                                        Icons.book,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        BookReviewScreen(
                                                          book: book,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    book['title'] ??
                                                        tr(Keys.unknownTitle),
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color.fromRGBO(
                                                        60,
                                                        57,
                                                        103,
                                                        1,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    book['author'] ??
                                                        tr(Keys.unknownAuthor),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color.fromARGB(
                                                        194,
                                                        60,
                                                        57,
                                                        103,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Stack(
                                                    children: [
                                                      Container(
                                                        height: 6,
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                3,
                                                              ),
                                                        ),
                                                      ),
                                                      FractionallySizedBox(
                                                        widthFactor:
                                                            (book['progress'] ??
                                                                0) /
                                                            100,
                                                        child: Container(
                                                          height: 6,
                                                          decoration: BoxDecoration(
                                                            color: Colors.blue,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  3,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          book['isFavorite'] ??
                                                                  false
                                                              ? Icons.favorite
                                                              : Icons
                                                                    .favorite_border,
                                                          color: Colors.red,
                                                        ),
                                                        onPressed: () =>
                                                            toggleFavorite(
                                                              book['title'],
                                                            ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          book['isFinished'] ??
                                                                  false
                                                              ? Icons.done_all
                                                              : Icons.done,
                                                          color: Colors.green,
                                                        ),
                                                        onPressed: () =>
                                                            toggleFinished(
                                                              book['title'],
                                                            ),
                                                      ),
                                                      IconButton(
                                                        icon: Icon(Icons.info),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  BookReviewScreen(
                                                                    book: book,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                        tooltip: tr(
                                                          Keys.moreInfo,
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.remove_red_eye,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String coverFromFilePath(String filePath) {
    final fileName = filePath.split('/').last.split('.').first; // "117640"
    return '/covers/$fileName.jpeg'; // путь относительно /assets на сервере
  }
}
