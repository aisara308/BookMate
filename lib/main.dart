import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/start/redirect_page.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('kk')],
      path: 'assets/langs', // путь к JSON
      fallbackLocale: const Locale('en'),
      child: const BookMateApp(),
    ),
  );
}

class BookMateApp extends StatelessWidget {
  const BookMateApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: context.locale, 
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: const RedirectPage(),
    );
  }
}
