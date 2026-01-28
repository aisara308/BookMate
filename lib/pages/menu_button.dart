import 'package:flutter/material.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/pages/start/login_screen.dart';
import 'package:flutter_application_1/pages/mybooks_screen.dart';
import 'package:flutter_application_1/pages/buyabook_screen.dart';
import 'package:flutter_application_1/pages/myprofile_screen.dart';
import 'package:flutter_application_1/pages/friends_screen.dart';
import 'package:flutter_application_1/pages/readlist_screen.dart';
import 'package:flutter_application_1/api_client.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUser();
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
                    ? NetworkImage('$url${u['avatar']}')
                    : const AssetImage('assets/avatar.png') as ImageProvider,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shop),
              title: const Text("Buy a book"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BuyABookScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_rounded),
              title: const Text("My profile"),
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
              title: Text("Friends"),
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
              leading: const Icon(Icons.timelapse),
              title: Text("Readlist"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReadlistScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: Text("My books"),
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
              title: Text("Finished books"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text("Favourite books"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.my_library_books),
              title: Text("Collections books"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Log out", style: TextStyle(color: Colors.red)),
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
