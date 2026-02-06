import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/start/register_screen.dart';
import 'package:flutter_application_1/pages/mybooks_screen.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/utils/keys.dart';
import 'package:flutter_application_1/utils/show_error.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookMateApp extends StatelessWidget {
  const BookMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isNotValidate = false;
  String? errorMessage = '';
  bool _obscure = true;

  Future<bool> loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var regBody = {
        "email": emailController.text,
        "password": passwordController.text,
      };
      var responce = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );
      final jsonResponce = jsonDecode(responce.body);

      if (responce.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', jsonResponce['token']);
        await prefs.setString('uid', jsonResponce['uid'] ?? '');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyBooksScreen()),
        );
        return true;
      } else {
        setState(() {
          errorMessage = tr(Keys.loginError, args: [responce.body]);
          showError(context, errorMessage!);
        });
        return false;
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white),
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              "assets/bg1.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    tr(Keys.joinTitle),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(60, 57, 103, 1),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    tr(Keys.joinSubtitle),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(194, 60, 57, 103),
                    ),
                  ),
                  const SizedBox(height: 40),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Color.fromARGB(194, 60, 57, 103),
                      ),
                      labelText: tr(Keys.email),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      errorStyle: TextStyle(color: Colors.white),
                      errorText: _isNotValidate
                          ? tr(Keys.enterProperEmail)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: tr(Keys.password),
                      filled: true,
                      fillColor: Colors.white,
                      errorStyle: TextStyle(color: Colors.white),
                      errorText: _isNotValidate
                          ? tr(Keys.enterProperPassword)
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          color: Color.fromARGB(194, 60, 57, 103),
                          _obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                        color: Color.fromARGB(194, 60, 57, 103),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: const Color.fromRGBO(
                              60,
                              57,
                              103,
                              0.75,
                            ),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            await loginUser();
                            await getInfoAndCache();
                          },
                          child: Text(
                            tr(Keys.signIn),
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Color.fromRGBO(60, 57, 103, 1),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                tr(Keys.or),
                                style: TextStyle(
                                  color: Color.fromRGBO(60, 57, 103, 1),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                thickness: 1,
                                color: Color.fromRGBO(60, 57, 103, 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(tr(Keys.dontHaveAccount)),
                        ),
                      ],
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
