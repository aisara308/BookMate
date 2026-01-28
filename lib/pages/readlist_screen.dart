import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/menu_button.dart';

class BookMateApp extends StatelessWidget {
  const BookMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ReadlistScreen(),
    );
  }
}

class ReadlistScreen extends StatefulWidget {
  const ReadlistScreen({super.key});
  @override
  State<ReadlistScreen> createState() => _ReadlistScreenState();
}

class _ReadlistScreenState extends State<ReadlistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(),
      body: Stack(
        children: [
          Container(color: Colors.white),
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              "assets/bg7.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
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
                    Row(
                      children: const [
                        MenuButton(),
                        Text(
                          "Readlist",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(60, 57, 103, 1),
                          ),
                        ),
                      ],
                    ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
