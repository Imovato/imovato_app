import 'package:flutter/material.dart';

// Cor de marca (seu botão rosa/avermelhado)
const kBrandSeed = Color(0xFFD10B58);

final ColorScheme lightScheme = ColorScheme.light(
  primary: kBrandSeed,
  brightness: Brightness.light,
);

final ColorScheme darkScheme = ColorScheme.fromSeed(
  seedColor: kBrandSeed,
  brightness: Brightness.dark,
);
