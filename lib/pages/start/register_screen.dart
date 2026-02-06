import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/pages/mybooks_screen.dart';
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
      home: const RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage = '';
  bool _obscure = true;

  String? validatePassword(String password) {
    if (password.isEmpty) return tr(Keys.enterProperPassword);
    if (password.length < 8) return tr(Keys.passwordTooShort);
    if (!RegExp(r'[0-9]').hasMatch(password)) return tr(Keys.passwordNoDigit);
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password))
      return tr(Keys.passwordNoSpecial);
    return null;
  }

  Future<bool> registerUser() async {
    final error = validatePassword(passwordController.text);
    if (error != null) {
      showError(context, error);
      return false;
    }

    if (_formKey.currentState!.validate()) {
      var regBody = {
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
      };

      var responce = await http.post(
        Uri.parse(registration),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      var jsonResponce = jsonDecode(responce.body);

      if (responce.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', jsonResponce['token']);
        await prefs.setString('uid', jsonResponce['uid'] ?? '');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyBooksScreen()),
        );
        return true;
      } else {
        showError(context, tr(Keys.registrationError, args: [responce.body]));
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) =>
      value == null || value.trim().isEmpty ? tr(Keys.enterProperName) : null;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return tr(Keys.enterProperEmail);
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    if (!RegExp(pattern).hasMatch(value.trim()))
      return tr(Keys.enterProperEmail);
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty)
      return tr(Keys.enterProperPassword);
    if (value.length < 8) return tr(Keys.passwordTooShort);
    return null;
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
              child: Form(
                key: _formKey,
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

                    TextFormField(
                      controller: nameController,
                      validator: _validateName,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color.fromARGB(194, 60, 57, 103),
                        ),
                        labelText: tr(Keys.name),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: emailController,
                      validator: _validateEmail,
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
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: passwordController,
                      validator: _validatePassword,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color.fromARGB(194, 60, 57, 103),
                        ),
                        labelText: tr(Keys.password),
                        filled: true,
                        fillColor: Colors.white,
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
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color.fromRGBO(
                            60,
                            57,
                            103,
                            0.75,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () async {
                          bool success = await registerUser();
                          await getInfoAndCache();
                          if (success) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MyBooksScreen(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          tr(Keys.signUp),
                          style: TextStyle(fontSize: 18),
                        ),
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
                        Navigator.pop(context);
                      },
                      child: Text(tr(Keys.alreadyHaveAccount)),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
