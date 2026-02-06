import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/keys.dart';
import 'package:flutter_application_1/utils/menu_button.dart';
import 'package:flutter_application_1/pages/readbook_screen.dart';
import 'package:flutter_application_1/pages/bookreview_screen.dart';
import 'package:flutter_application_1/config.dart';
import 'package:http/http.dart' as http;

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({super.key});

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  List<dynamic> allBooks = [];
  List<dynamic> filteredBooks = [];
  bool loading = true;
  bool showSearch = false;
  String searchQuery = '';
  Map<String, String?>? user;

  Future<void> _loadUser() async {
    final data = await getCachedUser();
    setState(() {
      user = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _loadUser();
  }

  Future<void> _loadBooks() async {
    try {
      final uid = await api.getUid();
      if (uid == null) return;

      final response = await http.get(Uri.parse('$getMyBooks?uid=$uid'));

      if (response.statusCode == 200) {
        allBooks = jsonDecode(response.body);
        _applySearch();
      } else {
        allBooks = [];
        filteredBooks = [];
      }
    } catch (e) {
      allBooks = [];
      filteredBooks = [];
      debugPrint('❌ Failed to load books: $e');
    } finally {
      setState(() => loading = false);
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

  Future<void> toggleFavorite(String title) async {
    try {
      final uid = await api.getUid();
      final response = await http.patch(
        Uri.parse('${url}books/favorite'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": uid, "title": title}),
      );

      if (response.statusCode == 200) {
        await _loadBooks(); // обновляем состояние
      } else {
        print('Failed to toggle favorite: ${response.body}');
      }
    } catch (e) {
      print('Error toggleFavorite: $e');
    }
  }

  Future<void> toggleFinished(String title) async {
    try {
      final uid = await api.getUid();
      final response = await http.patch(
        Uri.parse('${url}books/finished'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": uid, "title": title}),
      );

      if (response.statusCode == 200) {
        await _loadBooks(); // обновляем состояние
      } else {
        print('Failed to toggle finished: ${response.body}');
      }
    } catch (e) {
      print('Error toggleFinished: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = user;
    return Scaffold(
      drawer: const MenuDrawer(),
      body: Stack(
        children: [
          Container(color: Colors.white),
          IgnorePointer(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                "assets/bg2.png",
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
                        children: [
                          const MenuButton(),
                          Row(
                            children: [
                              // Кнопка поиска
                              IconButton(
                                icon: const Icon(
                                  Icons.search,
                                  size: 28,
                                  color: Color.fromRGBO(60, 57, 103, 1),
                                ),
                                onPressed: () {
                                  setState(() {
                                    showSearch = !showSearch;
                                    if (!showSearch) searchQuery = '';
                                    _applySearch();
                                  });
                                },
                              ),
                              const SizedBox(width: 16),
                              u == null
                                  ? const CircleAvatar(
                                      backgroundImage: AssetImage(
                                        'assets/avatar.png',
                                      ),
                                    )
                                  : CircleAvatar(
                                      backgroundImage:
                                          u['avatar'] != null &&
                                              u['avatar']!.isNotEmpty
                                          ? NetworkImage(
                                              '${url.replaceAll(RegExp(r"/$"), "")}${u['avatar']}',
                                            )
                                          : const AssetImage(
                                                  'assets/avatar.png',
                                                )
                                                as ImageProvider,
                                    ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        tr(
                          Keys.myBooksTitle,
                          namedArgs: {"count": filteredBooks.length.toString()},
                        ),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(60, 57, 103, 1),
                        ),
                      ),
                      if (showSearch)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: TextField(
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
                        ),
                      Expanded(
                        child: filteredBooks.isEmpty
                            ? Center(child: Text(tr(Keys.noBooksFound)))
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
                                                    book['title'],
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
                                                    book['author'],
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
