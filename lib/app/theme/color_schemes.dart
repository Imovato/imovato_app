import 'package:flutter/material.dart';

const Color kBrandPrimary = Color(0xFFD20B59);
const Color kBrandOnPrimary = Color(0xFFFFFFFF);
const Color kBrandPrimaryContainer = Color(0xFFFFD9E4);
const Color kBrandOnPrimaryContainer = Color(0xFF3E0018);

const Color kBrandSecondary = Color(0xFF192335);
const Color kBrandOnSecondary = Color(0xFFFFFFFF);
const Color kBrandSecondaryContainer = Color(0xFFD7DAE5);
const Color kBrandOnSecondaryContainer = Color(0xFF10151F);

const Color kBrandTertiary = Color(0xFF7C5CFF);
const Color kBrandSurface = Color(0xFFFFFBFE);
const Color kBrandSurfaceVariant = Color(0xFFEFE3E7);
const Color kBrandOutline = Color(0xFF79747E);

const Color kBrandSuccess = Color(0xFF2E7D32);
const Color kBrandWarning = Color(0xFFF9A825);
const Color kBrandError = Color(0xFFB3261E);
const Color kBrandInfo = Color(0xFF0B6BD2);

final ColorScheme lightScheme = ColorScheme.fromSeed(
  seedColor: kBrandPrimary,
  brightness: Brightness.light,
  primary: kBrandPrimary,
  onPrimary: kBrandOnPrimary,
  primaryContainer: kBrandPrimaryContainer,
  onPrimaryContainer: kBrandOnPrimaryContainer,
  secondary: kBrandSecondary,
  onSecondary: kBrandOnSecondary,
  secondaryContainer: kBrandSecondaryContainer,
  onSecondaryContainer: kBrandOnSecondaryContainer,
  tertiary: kBrandTertiary,
  surface: kBrandSurface,
  surfaceContainerHighest: kBrandSurfaceVariant,
  onSurface: kBrandSecondary,
  outline: kBrandOutline,
  error: kBrandError,
  onError: kBrandOnPrimary,
  tertiaryContainer: kBrandPrimaryContainer,
);

final ColorScheme darkScheme = ColorScheme.fromSeed(
  seedColor: kBrandPrimary,
  brightness: Brightness.dark,
  primary: const Color(0xFFF08BB0),
  onPrimary: const Color(0xFF3E0018),
  primaryContainer: const Color(0xFF7A0037),
  onPrimaryContainer: const Color(0xFFFFD9E4),
  secondary: const Color(0xFFD7DAE5),
  onSecondary: const Color(0xFF10151F),
  secondaryContainer: const Color(0xFF394150),
  onSecondaryContainer: const Color(0xFFEAF0F8),
  tertiary: const Color(0xFFB8AEFF),
  surface: const Color(0xFF111318),
  surfaceContainerHighest: const Color(0xFF262A33),
  onSurface: const Color(0xFFF5F7FA),
  outline: const Color(0xFF8C93A3),
  error: const Color(0xFFFFB4AB),
  onError: const Color(0xFF690005),
  tertiaryContainer: const Color(0xFF3B2E7A),
);
