import 'package:flutter/material.dart';

import 'package:ogi_ppkd_app_dev/day_19/views/post_list_views.dart';
import 'package:ogi_ppkd_app_dev/db/services/preferencens_handler.dart';
import 'package:ogi_ppkd_app_dev/views/tugas%2014/views/character_list_view.dart';
import 'package:ogi_ppkd_app_dev/views/tugas%2014/views/reusable/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferenceHandler.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rick & Morty App',

      // Menggunakan tema yang sudah dibuat
      theme: AppTheme.themeData(),

      // Halaman utama aplikasi
      home: const CharacterListView(),
    );
  }
}
