import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme();

  ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
  );
}
