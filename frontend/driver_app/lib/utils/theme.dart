import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverTheme {
  // Uber Dark Theme Palette
  static const Color primary = Color(0xFF276EF1); // Uber Blue
  static const Color background = Color(0xFF000000); // Pure Black
  static const Color surface = Color(0xFF1C1C1E); // Dark Gray Surface
  static const Color border = Color(0xFF333333); // Subtle border
  
  static const Color textMain = Color(0xFFFFFFFF); // Pure White
  static const Color textMuted = Color(0xFFA6A6A6); // Light Gray
  
  static const Color red = Color(0xFFE11900); // Uber Error/SOS Red
  static const Color redBg = Color(0xFF3A0A05); // Dark Red BG
  static const Color green = Color(0xFF05A357); // Uber Success Green

  static const List<BoxShadow> floatingIconShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    )
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: red,
        surface: surface,
        onSurface: textMain,
        error: red,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.w800),
        titleLarge: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(color: textMain, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textMuted, fontSize: 14),
      ).apply(bodyColor: textMain, displayColor: textMain),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
