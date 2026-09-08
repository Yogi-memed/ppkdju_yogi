import 'package:flutter/material.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/contoh3_flutter.dart';
import 'package:ogi_ppkd_app_dev/latihan_widget/tugas3_flutter.dart';




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
      home: const Tugas3Flutter(),
    );
  }
}
