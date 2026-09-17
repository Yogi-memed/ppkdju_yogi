import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/latihan/contoh3_flutter.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/latihan_bottom_navigator.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/latihan_drawer.dart';
import 'package:ogi_ppkd_app_dev/shared/login_screen.dart';
import 'package:ogi_ppkd_app_dev/shared/preferencens_handler.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/Tugas/tugas3_flutter.dart';
import 'package:ogi_ppkd_app_dev/shared/splash_screen.dart';

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
      home: const LoginScreenDay15(),
    );
  }
}
