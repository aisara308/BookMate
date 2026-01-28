import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'dart:io';

class ReadbookScreen extends StatefulWidget {
  const ReadbookScreen({super.key});

  @override
  State<ReadbookScreen> createState() => _ReadbookScreenState();
}

class _ReadbookScreenState extends State<ReadbookScreen> {
  final epubController = EpubController();

  @override
  Widget build(BuildContext context) {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return const Scaffold(
        body: Center(
          child: Text(
            'EPUB оқу тек Android / iOS жүйесінде қолжетімді',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: EpubViewer(
          epubController: epubController,
          epubSource: EpubSource.fromUrl(
            'https://github.com/IDPF/epub3-samples/releases/download/20230704/accessible_epub_3.epub',
          ),
          displaySettings: EpubDisplaySettings(
            flow: EpubFlow.paginated,
            snap: true,
          ),
          onChaptersLoaded: (chapters) {},
          onEpubLoaded: () async {
            // Handle epub loaded
          },
          onRelocated: (value) {
            // Handle page change
          },
          onTextSelected: (epubTextSelection) {
            // Handle text selection
          },
        ),
      ),
    );
  }
}
