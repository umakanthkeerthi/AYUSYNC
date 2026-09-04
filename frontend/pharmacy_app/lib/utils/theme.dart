import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PharmacyTheme {
  // Premium Brand Colors (Deep Indigo / Violet)
  static const Color sidebar = Color(0xFF1E1B4B); // Deepest Indigo
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryHover = Color(0xFF4F46E5); // Indigo 600
  
  static const Color background = Color(0xFFF8FAFC); // Slate 50 - softer neutral
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  
  static const Color textDark = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  
  // Status Colors (Softer Backgrounds, more vibrant text)
  static const Color statOrange = Color(0xFFF97316);
  static const Color statOrangeBg = Color(0xFFFFF7ED);
  static const Color statBlue = Color(0xFF0EA5E9);
  static const Color statBlueBg = Color(0xFFF0F9FF);
  static const Color statPurple = Color(0xFF8B5CF6);
  static const Color statPurpleBg = Color(0xFFF5F3FF);
  static const Color statRed = Color(0xFFEF4444);
  static const Color statRedBg = Color(0xFFFEF2F2);
  static const Color statGreen = Color(0xFF10B981);
  static const Color statGreenBg = Color(0xFFECFDF5);

  // Professional Aesthetics
  static final BorderRadius cardRadius = BorderRadius.circular(20); // softer, larger radius
  static final BorderRadius buttonRadius = BorderRadius.circular(12);
  static final BorderRadius inputRadius = BorderRadius.circular(12);
  static final BorderRadius pillRadius = BorderRadius.circular(100);

  static final List<BoxShadow> premiumShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.04),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.02),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryHover,
        surface: surface,
        onSurface: textDark,
        error: statRed,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w800, letterSpacing: -1),
        displayMedium: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w700, letterSpacing: -0.2),
        titleMedium: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textDark, fontSize: 15, height: 1.6),
        bodyMedium: GoogleFonts.inter(color: textSecondary, fontSize: 14, height: 1.5),
        labelLarge: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      ).apply(bodyColor: textDark, displayColor: textDark),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: buttonRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: inputRadius, borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: inputRadius, borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: inputRadius, borderSide: const BorderSide(color: primary, width: 2)),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
    );
  }
}
