import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/menu_button.dart';

class BookMateApp extends StatelessWidget {
  const BookMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BuyABookScreen(),
    );
  }
}

class BuyABookScreen extends StatefulWidget {
  const BuyABookScreen({super.key});
  @override
  State<BuyABookScreen> createState() => _BuyABookScreenState();
}

class _BuyABookScreenState extends State<BuyABookScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(),
      body: Stack(
        children: [
          Container(color: Colors.white),
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              "assets/bg4.png",
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
                          "Buy a book",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(60, 57, 103, 1),
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundImage: AssetImage("assets/avatar.png"),
                      radius: 18,
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
