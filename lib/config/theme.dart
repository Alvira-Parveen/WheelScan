import 'package:flutter/material.dart';

class WheelScanTheme {
  // Core Brand
  static const Color primary = Color(0xFF00D261);
  static const Color primaryDark = Color(0xFF00A34D);
  static const Color primaryDeep = Color(0xFF007A3A);
  static const Color primaryLight = Color(0xFFE8FBF0);
  static const Color primarySoft = Color(0xFFF0FFF5);

  // Accents
  static const Color accent = Color(0xFF4F7DF7);
  static const Color accentLight = Color(0xFFECF1FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF3EEFF);
  static const Color orange = Color(0xFFFF8C42);
  static const Color orangeLight = Color(0xFFFFF2E8);

  // Status
  static const Color danger = Color(0xFFFF4757);
  static const Color dangerLight = Color(0xFFFFF0F1);
  static const Color warning = Color(0xFFFFB020);
  static const Color warningLight = Color(0xFFFFF8EB);
  static const Color success = Color(0xFF00D261);
  static const Color successLight = Color(0xFFE8FBF0);

  // Neutrals
  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF0F3F7);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Dark Surface (for contrast cards)
  static const Color darkSurface = Color(0xFF1A1F2E);
  static const Color darkCard = Color(0xFF232A3B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D261), Color(0xFF00A34D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1F2E), Color(0xFF232A3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF00D261), Color(0xFF00A34D), Color(0xFF007A3A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [Color(0xFF00D261), Color(0xFF4F7DF7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.04),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.02),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(22),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.06),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: const Color(0xFF0F172A).withOpacity(0.02),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Text Styles
  static TextStyle get displayLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -1.0,
    height: 1.15,
  );

  static TextStyle get headingLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get headingMedium => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get headingSmall => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static TextStyle get caption => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textMuted,
    letterSpacing: 0.3,
  );

  static TextStyle get labelBold => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),
    );
  }
}