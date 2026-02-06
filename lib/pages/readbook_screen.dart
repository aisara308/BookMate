import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/keys.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

import '../config.dart'; // BASE_URL

class ReadbookScreen extends StatefulWidget {
  final String fileUrl;
  const ReadbookScreen({super.key, required this.fileUrl});

  @override
  State<ReadbookScreen> createState() => _ReadbookScreenState();
}

class _ReadbookScreenState extends State<ReadbookScreen> {
  late EpubController _controller;
  String? _startCfi;

  String get _prefsKey => p.basename(widget.fileUrl);

  @override
  void initState() {
    super.initState();
    _controller = EpubController();

    _loadProgressFromCache();
    _syncProgressFromCacheToServer();
  }

  /* ============================
      LOAD FROM CACHE
     ============================ */
  Future<void> _loadProgressFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final startCfi = prefs.getString('${_prefsKey}_startCfi');

    if (mounted) {
      setState(() {
        _startCfi = startCfi;
      });
    }
  }

  /* ============================
      SAVE TO CACHE
     ============================ */
  Future<void> _saveProgressToCache(EpubLocation location) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('${_prefsKey}_startCfi', location.startCfi);
    await prefs.setString('${_prefsKey}_endCfi', location.endCfi);
    await prefs.setDouble('${_prefsKey}_progress', location.progress);

    debugPrint('💾 Cached progress: ${location.progress}');
  }

  /* ============================
      SYNC CACHE → SERVER
     ============================ */
  Future<void> _syncProgressFromCacheToServer() async {
    final prefs = await SharedPreferences.getInstance();

    final progressRaw = prefs.getDouble('${_prefsKey}_progress');
    final startCfi = prefs.getString('${_prefsKey}_startCfi');
    final uid = prefs.getString('uid');
    if (progressRaw == null) return;

    final progressPercent = (progressRaw * 100).round().clamp(0, 100);
    debugPrint('🚀 Sending progress: $progressPercent');
    final normalizedPath = normalizeFilePath(widget.fileUrl);
    try {
      final response = await http.patch(
        Uri.parse(setBookProgress),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': uid,
          'filePath': normalizedPath,
          'progress': progressPercent,
          'lastCfi': startCfi,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('☁️ Progress synced: $progressPercent%');
      } else {
        debugPrint('❌ Sync failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('🔥 Sync error: $e');
    }
  }

  DateTime? _lastSyncTime;

  Future<void> _syncProgressIfNeeded() async {
    final now = DateTime.now();

    if (_lastSyncTime != null &&
        now.difference(_lastSyncTime!).inSeconds < 10) {
      return;
    }

    _lastSyncTime = now;
    await _syncProgressFromCacheToServer();
  }

  String normalizeFilePath(String url) {
    if (url.startsWith('http')) {
      final uri = Uri.parse(url);
      return uri.path; // /assets/books/117640.epub
    }
    return url;
  }

  /* ============================
      UI
     ============================ */
  @override
  Widget build(BuildContext context) {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return Scaffold(body: Center(child: Text(tr(Keys.epubNotSupported))));
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr(Keys.readBookTitle))),
      body: SafeArea(
        child: EpubViewer(
          epubController: _controller,
          epubSource: EpubSource.fromUrl(widget.fileUrl),
          initialCfi: _startCfi,
          displaySettings: EpubDisplaySettings(
            flow: EpubFlow.paginated,
            snap: true,
          ),
          onRelocated: (location) {
            _saveProgressToCache(location);
            _syncProgressIfNeeded();
          },
          onEpubLoaded: () {
            debugPrint('📖 EPUB loaded');
          },
        ),
      ),
    );
  }

  /* ============================
      DISPOSE
     ============================ */
  @override
  void dispose() {
    _syncProgressFromCacheToServer();
    super.dispose();
  }
}
