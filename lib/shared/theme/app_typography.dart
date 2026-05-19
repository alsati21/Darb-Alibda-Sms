import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.24),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.4),
    );
  }
}
