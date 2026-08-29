import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // AyuSync Nurse Brand Colors
  static const Color brandPrimary = Color(0xFF00A884); // Healthcare Green/Teal
  static const Color brandSecondary = Color(0xFF131924); // Deep Navy Sidebar
  static const Color brandAccent = Color(0xFF6366F1); // Soft Blue/Purple
  
  static const Color bgMain = Color(0xFFF4F7FE);
  static const Color bgCard = Color(0xFFFFFFFF);
  
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  // Status/Urgency Colors
  static const Color colorUrgent = Color(0xFFEF4444); // Red
  static const Color colorFollowup = Color(0xFFF97316); // Orange
  static const Color colorOnTrack = Color(0xFF10B981); // Green
  static const Color colorTotal = Color(0xFF3B82F6); // Blue

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandPrimary,
        primary: brandPrimary,
        secondary: brandAccent,
        surface: bgMain,
        error: colorUrgent,
      ),
      scaffoldBackgroundColor: bgMain,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // --radius-lg is 1rem
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        space: 1,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          side: const BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
