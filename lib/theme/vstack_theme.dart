import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class VStackColors {
  static const bg = Color(0xFF06080F);
  static const surface = Color(0xFF0E1424);
  static const surfaceLight = Color(0xFF151D32);
  static const text = Color(0xFFEEF2FC);
  static const muted = Color(0xFF8A9BB8);
  static const accent = Color(0xFF3B9EFF);
  static const accent2 = Color(0xFF8B5CF6);
  static const border = Color(0x1AFFFFFF);
}

ThemeData buildVStackTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: VStackColors.bg,
    useMaterial3: true,
  );
  return base.copyWith(
    textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
      bodyColor: VStackColors.text,
      displayColor: VStackColors.text,
    ),
    colorScheme: const ColorScheme.dark(
      primary: VStackColors.accent,
      secondary: VStackColors.accent2,
      surface: VStackColors.surface,
    ),
  );
}
