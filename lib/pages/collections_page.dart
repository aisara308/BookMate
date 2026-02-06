import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/pages/readbook_screen.dart';
import 'package:flutter_application_1/pages/bookreview_screen.dart';
import 'package:flutter_application_1/utils/keys.dart';
import 'package:flutter_application_1/utils/menu_button.dart';
import 'package:http/http.dart' as http;

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  List<dynamic> allBooks = [];
  bool loading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => loading = true);
    try {
      final uid = await api.getUid();
      if (uid == null) return;

      final response = await http.get(Uri.parse('$getMyBooks?uid=$uid'));

      if (response.statusCode == 200) {
        final books = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          allBooks = books;
        });
      } else {
        setState(() => allBooks = []);
      }
    } catch (e) {
      debugPrint('❌ Failed to load books: $e');
      setState(() => allBooks = []);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> toggleFavorite(String title) async {
    try {
      final uid = await api.getUid();
      final response = await http.patch(
        Uri.parse('${url}books/favorite'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"uid": uid, "title": title}),
      );
      if (response.statusCode == 200) _loadBooks();
    } catch (e) {
      debugPrint('Error toggleFavorite: $e');
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
      if (response.statusCode == 200) _loadBooks();
    } catch (e) {
      debugPrint('Error toggleFinished: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // группируем книги по авторам
    Map<String, List<dynamic>> booksByAuthor = {};
    for (var book in allBooks) {
      final author = (book['author'] ?? tr(Keys.unknownAuthor)).toString();
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!author.toLowerCase().contains(query) &&
            !(book['title'] ?? '').toString().toLowerCase().contains(query)) {
          continue;
        }
      }
      if (!booksByAuthor.containsKey(author)) {
        booksByAuthor[author] = [];
      }
      booksByAuthor[author]!.add(book);
    }

    return Scaffold(
      drawer: const MenuDrawer(),
      body: Stack(
        children: [
          Container(color: Colors.white),
          IgnorePointer(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                "assets/bg7.png",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
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
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            hintText: tr(Keys.searchHint),
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: booksByAuthor.isEmpty
                              ? Center(child: Text(tr(Keys.noBooksFound)))
                              : ListView.builder(
                                  itemCount: booksByAuthor.keys.length,
                                  itemBuilder: (context, index) {
                                    final author = booksByAuthor.keys.elementAt(
                                      index,
                                    );
                                    final books = booksByAuthor[author]!;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            author,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(
                                                60,
                                                57,
                                                103,
                                                1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 280,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  const ClampingScrollPhysics(),
                                              itemCount: books.length,
                                              itemBuilder: (context, idx) {
                                                final book = books[idx];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 12,
                                                      ),
                                                  child: SizedBox(
                                                    width: 140,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    ReadbookScreen(
                                                                      fileUrl:
                                                                          'http://10.0.2.2:3000${book['filePath']}',
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            child:
                                                                book['filePath'] !=
                                                                    null
                                                                ? Image.network(
                                                                    'http://10.0.2.2:3000/assets/covers/${book['filePath'].split('/').last.split('.').first}.jpeg',
                                                                    width: 140,
                                                                    height: 180,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : Container(
                                                                    width: 140,
                                                                    height: 180,
                                                                    color: Colors
                                                                        .grey[300],
                                                                    child: const Icon(
                                                                      Icons
                                                                          .book,
                                                                    ),
                                                                  ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            book['title'] ??
                                                                tr(
                                                                  Keys.noTitle,
                                                                ),
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                book['isFavorite'] ==
                                                                        true
                                                                    ? Icons
                                                                          .favorite
                                                                    : Icons
                                                                          .favorite_border,
                                                                color:
                                                                    Colors.red,
                                                                size: 20,
                                                              ),
                                                              onPressed: () =>
                                                                  toggleFavorite(
                                                                    book['title'],
                                                                  ),
                                                            ),
                                                            IconButton(
                                                              icon: Icon(
                                                                book['isFinished'] ==
                                                                        true
                                                                    ? Icons
                                                                          .done_all
                                                                    : Icons
                                                                          .done,
                                                                color: Colors
                                                                    .green,
                                                                size: 20,
                                                              ),
                                                              onPressed: () =>
                                                                  toggleFinished(
                                                                    book['title'],
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    BookReviewScreen(
                                                                      book:
                                                                          book,
                                                                    ),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            tr(Keys.details),
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .blue,
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
                                    );
                                  },
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
