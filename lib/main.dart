import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/db/services/preferencens_handler.dart';
import 'package:ogi_ppkd_app_dev/tugas/tugas_5/tugas_5.dart';
import 'package:ogi_ppkd_app_dev/views/tugas_11/login_screen.dart';
import 'package:ogi_ppkd_app_dev/views/tugas_11/profile_screen.dart';
import 'package:ogi_ppkd_app_dev/views/tugas_11/splash_screen.dart';
import 'package:ogi_ppkd_app_dev/views/tugas_12_13/screens/home_screen.dart';
import 'package:ogi_ppkd_app_dev/views/tugas_12_13/services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceHandler.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const HomeScreen(),
    );
  }
}
