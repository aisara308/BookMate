import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';

class SyncBooksButton extends StatefulWidget {
  final VoidCallback onSyncComplete; // коллбек, чтобы обновить UI после синхронизации
  const SyncBooksButton({super.key, required this.onSyncComplete});

  @override
  State<SyncBooksButton> createState() => _SyncBooksButtonState();
}

class _SyncBooksButtonState extends State<SyncBooksButton> {
  bool syncing = false;

  Future<void> syncLocalBooks() async {
    setState(() => syncing = true);

    try {
      // 1️⃣ Получаем UID из SharedPreferences или другого хранилища
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка: UID не найден')),
        );
        return;
      }

      // 2️⃣ Получаем локальные книги
      final localRes = await http.get(Uri.parse('${url}books/local-scan'));
      if (localRes.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сканирования локальных книг: ${localRes.body}')),
        );
        return;
      }

      final localBooks = jsonDecode(localRes.body) as List<dynamic>;

      if (localBooks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Локальные книги не найдены')),
        );
        return;
      }

      // 3️⃣ Синхронизируем в базу
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
        const SnackBar(content: Text('Синхронизация завершена')),
      );

      widget.onSyncComplete(); // обновляем UI, например список книг
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    } finally {
      setState(() => syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: syncing ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Icon(Icons.sync),
      label: Text(syncing ? 'Синхронизация...' : 'Синхронизировать локальные книги'),
      onPressed: syncing ? null : syncLocalBooks,
    );
  }
}
