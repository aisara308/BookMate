import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/api_client.dart';
import 'package:flutter_application_1/config.dart';
import 'package:flutter_application_1/utils/keys.dart';
import 'package:flutter_application_1/utils/menu_button.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List friends = [];
  List allFriends = [];
  bool loading = false;
  String? myUid;

  dynamic searchedUser;
  bool showMyFriends = true;
  final ApiClient api = ApiClient();

  Future<void> loadMyFriends() async {
    setState(() {
      loading = true;
    });

    try {
      final uid = await api.getUid();
      if (uid == null) throw Exception('UID not found');

      final responce = await api.get('$getFriends$uid');
      if (responce.statusCode == 200) {
        setState(() {
          friends = List.from(jsonDecode(responce.body));
          allFriends = List.from(friends);
        });
      } else {
        throw Exception(responce.body);
      }
    } catch (e) {
      debugPrint('loadMyFriends error: $e');
    } finally {
      loading = false;
    }
  }

  Future<void> searchUser(String uid) async {
    setState(() {
      loading = true;
      searchedUser = null;
    });

    try {
      final responce = await api.get('$getUserByUid$uid');

      if (responce.statusCode == 200) {
        setState(() {
          searchedUser = jsonDecode(responce.body);
        });
      }
    } catch (_) {
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> sendFriendRequest(String targetUid) async {
    final uid = await api.getUid();
    await api.post(sendRequest, {'userUid': uid, 'targetUid': targetUid});
    await loadMyFriends();
  }

  Future<void> removeFriendRequest(String targetUid) async {
    final uid = await api.getUid();
    await api.post(removeFriend, {'userUid': uid, 'targetUid': targetUid});
    await loadMyFriends();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    myUid = await api.getUid();
    await loadMyFriends();
  }

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
              'assets/bg6.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ☰ меню
                  const MenuButton(),
                  const SizedBox(height: 16),

                  /// 🔍 ПОИСК
                  TextField(
                    decoration: InputDecoration(
                      hintText: tr(Keys.searchFriendHint),
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) async {
                      if (value.isEmpty) {
                        setState(() {
                          friends = allFriends;
                          searchedUser = null;
                        });
                        return;
                      }

                      if (showMyFriends) {
                        setState(() {
                          friends = allFriends
                              .where(
                                (f) => f['name'].toLowerCase().contains(
                                  value.toLowerCase(),
                                ),
                              )
                              .toList();
                        });
                      } else {
                        await searchUser(value);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  /// 🔁 ПЕРЕКЛЮЧАТЕЛЬ
                  Row(
                    children: [
                      _tabButton(
                        title: tr(Keys.myFriendsTab),
                        selected: showMyFriends,
                        onTap: () {
                          setState(() => showMyFriends = true);
                        },
                      ),
                      const SizedBox(width: 8),
                      _tabButton(
                        title: tr(Keys.addFriendTab),
                        selected: !showMyFriends,
                        onTap: () {
                          setState(() => showMyFriends = false);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// 📜 СПИСОК
                  Expanded(
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : showMyFriends
                        ? ListView.builder(
                            itemCount: friends.length,
                            itemBuilder: (context, index) {
                              return _friendCard(friends[index]);
                            },
                          )
                        : searchedUser == null
                        ? Center(child: Text(tr(Keys.userNotFound)))
                        : searchedUser['uid'] == myUid
                        ? Center(child: Text(tr(Keys.cantAddYourself)))
                        : _friendCard(searchedUser),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧠 КНОПКА ПЕРЕКЛЮЧАТЕЛЯ
  Widget _tabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🧑‍🤝‍🧑 КАРТОЧКА ДРУГА
  Widget _friendCard(dynamic friend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(friend['name']),
        subtitle: Text(friend['uid']),
        trailing: showMyFriends
            ? _friendActionButtons(friend)
            : IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  sendFriendRequest(friend['uid']);
                },
              ),
      ),
    );
  }

  Widget _friendActionButtons(dynamic friend) {
    if (friend['status'] == 'pending') {
      if (friend['isSender'] == true) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () async {
                final uid = await api.getUid();
                await api.post(acceptRequest, {
                  'userUid': uid,
                  'targetUid': friend['uid'],
                });
                await loadMyFriends();
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                removeFriendRequest(friend['uid']);
              },
            ),
          ],
        );
      } else {
        return IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () {
            removeFriendRequest(friend['uid']);
          },
        );
      }
    }

    // accepted
    return IconButton(
      icon: const Icon(Icons.remove_circle_outline),
      onPressed: () {
        removeFriendRequest(friend['uid']);
      },
    );
  }
}
