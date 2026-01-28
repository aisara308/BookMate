import 'package:flutter/material.dart';
import 'package:flutter_application_1/api_client.dart';
import 'package:flutter_application_1/pages/start/login_screen.dart';
import 'package:flutter_application_1/pages/mybooks_screen.dart';

class RedirectPage extends StatelessWidget {
  const RedirectPage({super.key});

  Future<bool> _hasToken() async {
    final api = ApiClient();
    final token = await api.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const MyBooksScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
