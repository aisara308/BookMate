import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/pages/collections_page.dart';
import 'package:flutter_application_1/pages/favourite_books.dart';
import 'package:flutter_application_1/pages/finished_books.dart';
import 'package:flutter_application_1/pages/start/login_screen.dart';
import 'package:flutter_application_1/pages/mybooks_screen.dart';

import 'package:flutter_application_1/pages/myprofile_screen.dart';
import 'package:flutter_application_1/pages/friends_screen.dart';
import 'package:flutter_application_1/api_client.dart';
import 'package:flutter_application_1/utils/keys.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => IconButton(
        icon: const Icon(
          Icons.menu,
          size: 30,
          color: Color.fromRGBO(60, 57, 103, 1),
        ),
        onPressed: () {
          Scaffold.of(ctx).openDrawer();
        },
      ),
    );
  }
}

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});
  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  Map<String, String?>? user;
  bool syncing = false;
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _syncLocalBooks() async {
    setState(() => syncing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(tr(Keys.uidNotFound))));
        ;
        return;
      }

      // 1️⃣ Получаем локальные книги
      final localRes = await http.get(Uri.parse('${url}books/local-scan'));
      if (localRes.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка сканирования локальных книг: ${localRes.body}',
            ),
          ),
        );
        return;
      }

      // 2️⃣ Синхронизируем в базу
      final syncRes = await http.post(
        Uri.parse('${url}books/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': uid}),
      );

      if (syncRes.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка синхронизации: ${syncRes.body}')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Синхронизация локальных книг завершена')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      setState(() => syncing = false);
    }
  }

  Future<void> _loadUser() async {
    final data = await getCachedUser();
    setState(() {
      user = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = user;
    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: const IconThemeData(color: Color.fromARGB(194, 60, 57, 103)),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color.fromRGBO(57, 60, 103, 1)),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Color.fromARGB(194, 60, 57, 103),
          textColor: Color.fromRGBO(57, 60, 103, 1),
        ),
      ),
      child: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              accountName: Text(
                u?['name'] ?? '...',
                style: const TextStyle(color: Color.fromRGBO(57, 60, 103, 1)),
              ),
              accountEmail: Text(
                u?['email'] ?? '',
                style: const TextStyle(color: Color.fromRGBO(57, 60, 103, 0.5)),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage:
                    u?['avatar'] != null && u!['avatar']!.isNotEmpty
                    ? NetworkImage(
                        '${url.replaceAll(RegExp(r"/$"), "")}${u['avatar']}',
                      )
                    : const AssetImage('assets/avatar.png') as ImageProvider,
              ),
            ),

            ListTile(
              leading: const Icon(Icons.account_circle_rounded),
              title: Text(tr(Keys.myProfile)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_emergency),
              title: Text(tr(Keys.friends)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: Text(tr(Keys.myBooks)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyBooksScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check),
              title: Text(tr(Keys.finishedBooks)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FinishedBooksScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text(tr(Keys.favouriteBooks)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoriteBooksScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.my_library_books),
              title: Text(tr(Keys.collections)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CollectionsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(tr(Keys.changeLanguage)),
              onTap: () async {
                final currentLocale = context.locale;
                final newLocale = currentLocale.languageCode == 'en'
                    ? const Locale('kk')
                    : const Locale('en');
                await context.setLocale(newLocale);
                setState(() {});
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                icon: syncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.sync),

                label: Text(
                  syncing ? tr(Keys.syncing) : tr(Keys.syncLocalBooks),
                ),
                onPressed: syncing ? null : _syncLocalBooks,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                tr(Keys.logOut),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                final apiClient = ApiClient();
                await apiClient.clearAuthData();
                final prefs = await SharedPreferences.getInstance();
                prefs.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
