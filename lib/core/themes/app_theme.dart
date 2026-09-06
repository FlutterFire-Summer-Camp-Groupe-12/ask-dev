import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme();

  ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      );
}