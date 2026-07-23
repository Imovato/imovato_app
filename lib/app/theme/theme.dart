import 'package:flutter/material.dart';
import 'color_schemes.dart';

const double _radiusMd = 12;
const double _radiusLg = 16;
const double _radiusXl = 28;

TextTheme _buildTextTheme(ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
  ).textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 48,
          height: 1.17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineLarge: const TextStyle(
          fontSize: 30,
          height: 1.27,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: const TextStyle(
          fontSize: 22,
          height: 1.27,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: const TextStyle(
          fontSize: 17,
          height: 1.41,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.43,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: const TextStyle(
          fontSize: 13,
          height: 1.23,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      );
}

ThemeData buildLightTheme() {
  final scheme = lightScheme;
  final textTheme = _buildTextTheme(scheme);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFFBFAFB),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusLg),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radiusMd),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radiusMd),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radiusMd),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      labelStyle: textTheme.labelLarge?.copyWith(color: scheme.primary),
      hintStyle: textTheme.bodyLarge?.copyWith(color: scheme.outline),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusXl),
        ),
        textStyle: textTheme.labelLarge?.copyWith(color: scheme.onPrimary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusXl),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      side: BorderSide(color: scheme.surfaceContainerHighest),
      selectedColor: scheme.primaryContainer,
      labelStyle: textTheme.bodyMedium,
      secondaryLabelStyle: textTheme.bodyMedium,
      backgroundColor: scheme.surfaceContainerHighest,
      checkmarkColor: scheme.onPrimaryContainer,
      showCheckmark: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? scheme.primary : scheme.outline,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: isSelected ? scheme.primary : scheme.outline,
        );
      }),
    ),
  );
}

ThemeData buildDarkTheme() {
  final scheme = darkScheme;
  final textTheme = _buildTextTheme(scheme);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF111318),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radiusLg),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radiusMd),
        borderSide: BorderSide(color: scheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radiusMd),
        borderSide: BorderSide(color: scheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radiusMd),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      labelStyle: textTheme.labelLarge?.copyWith(color: scheme.primary),
      hintStyle: textTheme.bodyLarge?.copyWith(color: scheme.outline),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusXl),
        ),
        textStyle: textTheme.labelLarge?.copyWith(color: scheme.onPrimary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusXl),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      side: BorderSide(color: scheme.surfaceContainerHighest),
      selectedColor: scheme.primaryContainer,
      labelStyle: textTheme.bodyMedium,
      secondaryLabelStyle: textTheme.bodyMedium,
      backgroundColor: scheme.surfaceContainerHighest,
      checkmarkColor: scheme.onPrimaryContainer,
      showCheckmark: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? scheme.primary : scheme.outline,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: isSelected ? scheme.primary : scheme.outline,
        );
      }),
    ),
  );
}
