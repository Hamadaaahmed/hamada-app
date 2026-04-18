import 'package:flutter/material.dart';

import 'ui.dart';

ThemeData buildAppTheme() {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: AppUiColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppUiColors.primary,
    secondary: AppUiColors.info,
    surface: AppUiColors.surface,
    onSurface: AppUiColors.text,
    outline: AppUiColors.border,
    onSurfaceVariant: AppUiColors.muted,
    surfaceTint: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: baseScheme,
    scaffoldBackgroundColor: AppUiColors.background,
    cardColor: AppUiColors.surface,
    dividerColor: AppUiColors.border,
    canvasColor: AppUiColors.background,
    shadowColor: const Color(0x12000000),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppUiColors.primary,
      foregroundColor: Colors.white,
      centerTitle: false,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 21,
        fontWeight: FontWeight.w900,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppUiColors.border),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppUiColors.text),
      bodyMedium: TextStyle(color: AppUiColors.text),
      titleLarge: TextStyle(color: AppUiColors.text),
      titleMedium: TextStyle(color: AppUiColors.text),
      titleSmall: TextStyle(color: AppUiColors.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: AppUiColors.muted),
      labelStyle: const TextStyle(color: AppUiColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppUiColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppUiColors.primary, width: 1.4),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppUiColors.border),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppUiColors.border),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppUiColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppUiColors.text,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppUiColors.border),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppUiColors.text,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      disabledColor: const Color(0xFFF9FAFB),
      selectedColor: AppUiColors.primary.withAlpha(20),
      secondarySelectedColor: AppUiColors.primary.withAlpha(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: AppUiColors.border),
      ),
      side: const BorderSide(color: AppUiColors.border),
      labelStyle: const TextStyle(
        color: AppUiColors.text,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      iconColor: AppUiColors.text,
      textColor: AppUiColors.text,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppUiColors.primary,
      unselectedItemColor: AppUiColors.muted,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800),
    ),
  );
}
