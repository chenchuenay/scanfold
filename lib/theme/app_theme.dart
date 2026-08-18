import 'package:flutter/material.dart';

abstract final class ScanFoldColors {
  static const background = Color(0xFF07090D);
  static const surface = Color(0xFF0E141D);
  static const card = Color(0xFF151E2B);
  static const border = Color(0xFF263445);
  static const mint = Color(0xFF5DE2B3);
  static const amber = Color(0xFFFFB454);
  static const text = Color(0xFFF6F8FB);
  static const secondary = Color(0xFFB6C0CE);
  static const muted = Color(0xFF778394);
  static const error = Color(0xFFFF6B7A);
}

abstract final class ScanFoldTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ScanFoldColors.background,
    colorScheme: const ColorScheme.dark(
      primary: ScanFoldColors.mint,
      secondary: ScanFoldColors.amber,
      surface: ScanFoldColors.surface,
      error: ScanFoldColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ScanFoldColors.background,
      foregroundColor: ScanFoldColors.text,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: ScanFoldColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: ScanFoldColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ScanFoldColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ScanFoldColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ScanFoldColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ScanFoldColors.mint),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ScanFoldColors.card,
      contentTextStyle: const TextStyle(color: ScanFoldColors.text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
