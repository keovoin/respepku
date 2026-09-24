import 'package:flutter/material.dart';

/// Sastra Fitmeal design tokens — warm orange accent, cream background.
class C {
  static const primary = Color(0xFFFF7A00);
  static const primaryDark = Color(0xFFE06300);
  static const primarySoft = Color(0xFFFFF1E2);
  static const primaryLine = Color(0xFFFFD9B3);
  static const ink = Color(0xFF2A211A);
  static const muted = Color(0xFF8C8279);
  static const line = Color(0xFFF0E8DF);
  static const bg = Color(0xFFFBF8F5);
  static const card = Colors.white;
  static const green = Color(0xFF2F9E63);
  static const greenSoft = Color(0xFFE7F5EC);
  static const amber = Color(0xFFF5A623);
  static const amberSoft = Color(0xFFFDF3DF);
  static const teal = Color(0xFF2E9CA6);
  static const tealSoft = Color(0xFFE4F4F6);
  static const blue = Color(0xFF3E7CB1);
  static const red = Color(0xFFE05252);
  static const redSoft = Color(0xFFFDEBEB);
}

ThemeData appTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: C.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: C.primary, surface: C.bg),
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: C.ink,
      titleTextStyle: TextStyle(color: C.ink, fontSize: 18, fontWeight: FontWeight.w800),
    ),
    dividerTheme: const DividerThemeData(color: C.line, thickness: 1),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
