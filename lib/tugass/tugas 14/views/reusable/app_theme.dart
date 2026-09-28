import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryDark = Color(0xFF4527A0);

  static const Color background = Color(0xFFF6F4FC);
  static const Color card = Colors.white;

  static const Color textPrimary = Color(0xFF29243D);
  static const Color textSecondary = Color(0xFF777180);

  static const Color alive = Color(0xFF16A34A);
  static const Color dead = Color(0xFFDC2626);
  static const Color unknown = Color(0xFF9CA3AF);

  static ThemeData themeData() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}
