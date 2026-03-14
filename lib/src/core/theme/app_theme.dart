import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF1A4D2E),
      secondary: Color(0xFFD4A017),
      surface: Color(0xFFF8F6F0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8F6F0),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
      ),
    );
  }
}
