import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // AyuSync Nurse Brand Colors
  static const Color brandPrimary = Color(0xFF4F46E5); // Rich Royal Indigo
  static const Color brandSecondary = Color(0xFF0F172A); // Rich Slate Navy
  static const Color brandAccent = Color(0xFFE11D48); // Vibrant Rose
  
  static const Color bgMain = Color(0xFFF1F5F9); // Crisp Slate 100
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
      hintColor: textSecondary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandPrimary,
        primary: brandPrimary,
        secondary: brandAccent,
        surface: bgMain,
        error: colorUrgent,
      ),
      scaffoldBackgroundColor: bgMain,
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      cardTheme: CardTheme(
        color: bgCard,
        elevation: 8,
        shadowColor: const Color(0xFF0F172A).withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
          elevation: 4,
          shadowColor: brandPrimary.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
