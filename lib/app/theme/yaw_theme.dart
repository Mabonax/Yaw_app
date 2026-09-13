import 'package:flutter/material.dart';

import 'yaw_tokens.dart';

class YawTheme {
  const YawTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: YawColors.aviationBlue,
      primary: YawColors.aviationBlue,
      secondary: YawColors.healthy,
      error: YawColors.critical,
      surface: YawColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: YawColors.background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: YawColors.surface,
        foregroundColor: YawColors.navy,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: YawColors.navy,
          fontWeight: FontWeight.w700,
          fontSize: 28,
        ),
        titleLarge: TextStyle(
          color: YawColors.navy,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          color: YawColors.navy,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        bodyLarge: TextStyle(color: YawColors.charcoal, fontSize: 16),
        bodyMedium: TextStyle(color: YawColors.charcoal, fontSize: 14),
        labelLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: YawColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: YawSpacing.lg,
          vertical: YawSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(YawRadius.md),
          borderSide: const BorderSide(color: YawColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(YawRadius.md),
          borderSide: const BorderSide(color: YawColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(YawRadius.md),
          borderSide: const BorderSide(
            color: YawColors.aviationBlue,
            width: 1.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(YawSizing.buttonHeight),
          backgroundColor: YawColors.aviationBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YawRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(YawSizing.buttonHeight),
          foregroundColor: YawColors.aviationBlue,
          side: const BorderSide(color: YawColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YawRadius.md),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: YawColors.aviationBlue,
        unselectedItemColor: YawColors.textMuted,
        type: BottomNavigationBarType.fixed,
        backgroundColor: YawColors.surface,
      ),
    );
  }
}
