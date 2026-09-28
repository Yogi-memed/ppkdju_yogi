import 'package:flutter/material.dart';

import 'package:ogi_ppkd_app_dev/project_absensi/reusable/theme_controller.dart';
import 'package:ogi_ppkd_app_dev/project_absensi/services/storage_services.dart';
import 'package:ogi_ppkd_app_dev/project_absensi/views/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final savedTheme = await StorageServices.getTheme();

  ThemeController.isDarkMode.value = savedTheme;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkMode,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Absensi PPKD',

          theme: ThemeData(
            brightness: Brightness.light,
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
          ),

          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

          home: const LoginScreen(),
        );
      },
    );
  }
}
