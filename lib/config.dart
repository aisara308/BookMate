// config.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/api_client.dart';
import 'package:flutter_application_1/utils/parseMongoDate.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ApiClient api = ApiClient();

final url = 'http://10.0.2.2:3000/';
final registration = '${url}users/registration';
final login = '${url}users/login';
final updateProfile = '${url}users/update';
final getUserByEmail = '${url}users/email/';
final getUserByUid = '${url}users/uid/';
final setAvatar = '${url}users/avatar/set';
final deleteAvatar = '${url}users/avatar';

final sendRequest = '${url}friends/request';
final acceptRequest = '${url}friends/accept';
final removeFriend = '${url}friends/remove';
final getFriends = '${url}friends/';

const _uidKey = 'uid';
const _nameKey = 'name';
const _emailKey = 'email';
const _birthDateKey = 'birthDate';
const _genderKey = 'gender';
const _avatarKey = 'avatar';

Future<void> getInfoAndCache() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString(_uidKey);

    if (uid == null) return;

    final responce = await api.get('$getUserByUid${prefs.getString(_uidKey)}');

    if (responce.statusCode == 200) {
      final data = jsonDecode(responce.body);

      await prefs.setString(_uidKey, data['uid']);
      await prefs.setString(_nameKey, data['name']);
      await prefs.setString(_emailKey, data['email']);
      await prefs.setString(_genderKey, data['gender'] ?? '');
      await prefs.setString(_avatarKey, data['avatar'] ?? '');

      final birthDate = parseMongoDate(data['birthDate']);
      if (birthDate != null) {
        await prefs.setString(_birthDateKey, birthDate.toIso8601String());
      }
    }
  } catch (e) {
    debugPrintStack();
    rethrow;
  }
}

Future<Map<String, String?>> getCachedUser() async {
  final prefs = await SharedPreferences.getInstance();

  return {
    'uid': prefs.getString(_uidKey),
    'name': prefs.getString(_nameKey),
    'email': prefs.getString(_emailKey),
    'birthDate': prefs.getString(_birthDateKey),
    'gender': prefs.getString(_genderKey),
    'avatar': prefs.getString(_avatarKey),
  };
}
