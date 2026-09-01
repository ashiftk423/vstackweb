import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class DemoThemes {
  static const ink = Color(0xFF0F172A);
  static const inkSecondary = Color(0xFF1E293B);
  static const inkMuted = Color(0xFF64748B);
  static ThemeData ecommerce() => _light(
        primary: const Color(0xFF2874F0),
        secondary: const Color(0xFFFF9F00),
        bg: const Color(0xFFF1F3F6),
        surface: Colors.white,
      );

  static ThemeData pos() => _light(
        primary: const Color(0xFF00A651),
        secondary: const Color(0xFF00897B),
        bg: const Color(0xFFF5F7FA),
        surface: Colors.white,
      );

  static ThemeData fintech() => _light(
        primary: const Color(0xFF5F259F),
        secondary: const Color(0xFF00BA8C),
        bg: const Color(0xFFF8F9FB),
        surface: Colors.white,
      );

  static ThemeData saas() => _light(
        primary: const Color(0xFF635BFF),
        secondary: const Color(0xFF0EA5E9),
        bg: Colors.white,
        surface: const Color(0xFFF8FAFC),
      );

  static ThemeData admin() => _light(
        primary: const Color(0xFF2563EB),
        secondary: const Color(0xFF64748B),
        bg: const Color(0xFFF1F5F9),
        surface: Colors.white,
      );

  static ThemeData delivery() => _light(
        primary: const Color(0xFFFC8019),
        secondary: const Color(0xFFE23744),
        bg: Colors.white,
        surface: const Color(0xFFFFF8F3),
      );

  static ThemeData motion() => _light(
        primary: const Color(0xFF3B82F6),
        secondary: const Color(0xFF8B5CF6),
        bg: const Color(0xFFF8FAFC),
        surface: Colors.white,
      );

  static ThemeData _light({
    required Color primary,
    required Color secondary,
    required Color bg,
    required Color surface,
  }) {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFF1E293B),
        displayColor: const Color(0xFF0F172A),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
