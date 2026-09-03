import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/latihan_screen.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/tugas_s.dart';

void main() {
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
      home: const LatihanScreen(),
    );
  }
}
