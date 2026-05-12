import 'package:flutter/material.dart';

/// App-wide theme configuration for Financial Tracker.
/// Supports both dark and light themes.
class AppTheme {
  AppTheme._();

  // ─── Brand Colors ───────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4A42DB);

  static const Color income = Color(0xFF00C897);
  static const Color expense = Color(0xFFFF6B6B);

  // ─── Dark Mode Colors ──────────────────────────────────────
  static const Color surface = Color(0xFF1E1E2C);
  static const Color surfaceVariant = Color(0xFF2A2A3C);
  static const Color background = Color(0xFF14141F);
  static const Color card = Color(0xFF23233A);
  static const Color cardAlt = Color(0xFF2D2D48);

  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFFA0A0B8);
  static const Color textHint = Color(0xFF6C6C80);

  static const Color divider = Color(0xFF2E2E42);
  static const Color error = Color(0xFFFF5252);

  // ─── Light Mode Colors ─────────────────────────────────────
  static const Color lightSurface = Color(0xFFF8F8FC);
  static const Color lightSurfaceVariant = Color(0xFFEEEEF5);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF2F2F8);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B6B80);
  static const Color lightTextHint = Color(0xFF9E9EB0);
  static const Color lightDivider = Color(0xFFE0E0EA);

  // ─── Predefined wallet colors ─────────────────────────────
  static const List<Color> walletColors = [
    Color(0xFF6C63FF),
    Color(0xFF00C897),
    Color(0xFFFF6B6B),
    Color(0xFFFFB74D),
    Color(0xFF4FC3F7),
    Color(0xFFE040FB),
    Color(0xFF69F0AE),
    Color(0xFFFF8A65),
  ];

  // ─── Dark ThemeData ─────────────────────────────────────────
  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      bg: background,
      surf: surface,
      surfVariant: surfaceVariant,
      cardColor: card,
      txtPrimary: textPrimary,
      txtSecondary: textSecondary,
      txtHint: textHint,
      div: divider,
    );
  }

  // ─── Light ThemeData ────────────────────────────────────────
  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      bg: lightBackground,
      surf: lightSurface,
      surfVariant: lightSurfaceVariant,
      cardColor: lightCard,
      txtPrimary: lightTextPrimary,
      txtSecondary: lightTextSecondary,
      txtHint: lightTextHint,
      div: lightDivider,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color bg,
    required Color surf,
    required Color surfVariant,
    required Color cardColor,
    required Color txtPrimary,
    required Color txtSecondary,
    required Color txtHint,
    required Color div,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: income,
        onSecondary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surf,
        onSurface: txtPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: txtPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: txtPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: txtHint),
        labelStyle: TextStyle(color: txtSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
            color: txtPrimary, fontSize: 28, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(
            color: txtPrimary, fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(
            color: txtPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(
            color: txtPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: txtPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: txtSecondary, fontSize: 14),
        bodySmall: TextStyle(color: txtHint, fontSize: 12),
        labelLarge: TextStyle(
            color: txtPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      dividerTheme: DividerThemeData(color: div, thickness: 1, space: 1),
      splashFactory: InkSparkle.splashFactory,
      splashColor: isDark
          ? primary.withValues(alpha: 0.08)
          : primary.withValues(alpha: 0.05),
      highlightColor: Colors.transparent,
    );
  }
}
