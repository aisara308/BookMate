import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/start/redirect_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BookMateApp());
}

class BookMateApp extends StatelessWidget {
  const BookMateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RedirectPage(),
    );
  }
}
