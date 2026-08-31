import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6D245D);
  static const secondary = Color(0xFFA94A87);
  static const background = Color(0xFFFFF8FC);
  static const text = Color(0xFF241E23);
  static const emergency = Color(0xFFD92D20);
  static const safe = Color(0xFF14804A);
  static const warning = Color(0xFFF5A524);
}

ThemeData buildProtegeElaTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    error: AppColors.emergency,
    surface: Colors.white,
    background: AppColors.background,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Inter',
    visualDensity: VisualDensity.standard,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
      headlineMedium: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0),
      titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0),
      bodyLarge: TextStyle(letterSpacing: 0),
      bodyMedium: TextStyle(letterSpacing: 0),
    ).apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: AppColors.secondary.withOpacity(0.16),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
    focusColor: AppColors.warning.withOpacity(0.35),
  );
}
