import 'package:flutter/material.dart';

ThemeData buildBrutalTheme() {
  const black = Color(0xFF111111);
  const white = Color(0xFFF6F2E9);
  const yellow = Color(0xFFFFD400);
  const red = Color(0xFFE63946);

  OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: color, width: 3),
  );

  return ThemeData(
    colorScheme: const ColorScheme.light(
      primary: black,
      secondary: yellow,
      surface: white,
      error: red,
      onPrimary: white,
      onSurface: black,
    ),
    scaffoldBackgroundColor: white,
    appBarTheme: const AppBarTheme(
      backgroundColor: yellow,
      foregroundColor: black,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    ),
    cardTheme: const CardThemeData(
      color: white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: black, width: 3),
      ),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      enabledBorder: inputBorder(black),
      focusedBorder: inputBorder(yellow),
      errorBorder: inputBorder(red),
      focusedErrorBorder: inputBorder(red),
      border: inputBorder(black),
      hintStyle: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.w700,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: yellow,
        foregroundColor: black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: black, width: 3),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: yellow,
      foregroundColor: black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: black, width: 3),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
      ),
      bodyLarge: TextStyle(fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontWeight: FontWeight.w500),
    ),
  );
}
