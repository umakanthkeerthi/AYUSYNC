import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // AyuSync Lab Brand Colors
  static const Color brandSidebar = Color(0xFF052E2A); // Very dark teal
  static const Color brandActive = Color(0xFF0F4B45); // Active sidebar
  static const Color brandBg = Color(0xFFF9FAFB); // Main background
  
  static const Color textDark = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color bgCard = Color(0xFFFFFFFF);

  // Status/Urgency Colors
  static const Color statOrange = Color(0xFFF59E0B);
  static const Color statBlue = Color(0xFF3B82F6);
  static const Color statPurple = Color(0xFF8B5CF6);
  static const Color statRed = Color(0xFFEF4444);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandSidebar,
        primary: brandActive,
        surface: brandBg,
        error: statRed,
      ),
      scaffoldBackgroundColor: brandBg,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),
      cardTheme: CardTheme(
        color: bgCard,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
          backgroundColor: brandActive,
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
