import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/bookreview_screen.dart';
import 'package:flutter_application_1/pages/menu_button.dart';
import 'package:flutter_application_1/pages/readbook_screen.dart';

class BookMateApp extends StatelessWidget {
  const BookMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyBooksScreen(),
    );
  }
}

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({super.key});
  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  final List<Map<String, dynamic>> books = [
    {
      "title": "The Secret Garden",
      "author": "Frances Hodgson Burnett",
      "cover": "assets/book1.png",
      "progress": 0.3,
    },
    {
      "title": "1984",
      "author": "George Orwell",
      "cover": "assets/book2.png",
      "progress": 0.6,
    },
    {
      "title": "DandaDan",
      "author": "Yukinobu Tatsu",
      "cover": "assets/book3.png",
      "progress": 0.8,
    },
    {
      "title": "Lolita",
      "author": "Vladimir Nabokov",
      "cover": "assets/book4.png",
      "progress": 0.5,
    },
  ];

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
                "assets/bg2.png",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MenuButton(),
                    Row(
                      children: const [
                        Icon(
                          Icons.search,
                          size: 28,
                          color: Color.fromRGBO(60, 57, 103, 1),
                        ),
                        SizedBox(width: 16),
                        CircleAvatar(
                          backgroundImage: AssetImage("assets/avatar.png"),
                          radius: 18,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "My books(4)",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(60, 57, 103, 1),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
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
                                      builder: (context) => const ReadbookScreen(),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    book["cover"],
                                    width: 80,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BookReviewScreen(),
                                      ),
                                    );
                                  },

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book["title"],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(60, 57, 103, 1),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book["author"],
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
                                        alignment: Alignment.centerLeft,
                                        children: [
                                          Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: book["progress"],
                                            child: Container(
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(
                                            "assets/favourites.png",
                                            height: 18,
                                          ),
                                          Image.asset(
                                            "assets/readlist.png",
                                            height: 18,
                                          ),
                                          Image.asset(
                                            "assets/finished.png",
                                            height: 18,
                                          ),
                                          Image.asset(
                                            "assets/collections.png",
                                            height: 18,
                                          ),
                                          Image.asset(
                                            "assets/other.png",
                                            height: 18,
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
}
