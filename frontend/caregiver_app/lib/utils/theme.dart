import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AyuTheme {
  // Vibrant Premium Palette
  static const Color primary = Color(0xFFF27B42);
  static const Color primaryDark = Color(0xFFD9632D);
  static const Color primaryLight = Color(0xFFFFEAE0);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF99E5C), Color(0xFFF27B42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient alertGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status & Alerts
  static const Color green = Color(0xFF10B981);
  static const Color greenBg = Color(0xFFECFDF5);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberBg = Color(0xFFFFFBEB);
  
  // Neutral Spectrum
  static const Color bgApp = Color(0xFFF4F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textMain = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);

  // Soft Premium Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    )
  ];

  static const List<BoxShadow> floatingIconShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    )
  ];

  static const List<BoxShadow> primaryFloatingShadow = [
    BoxShadow(
      color: Color(0x4DF27B42),
      blurRadius: 12,
      offset: Offset(0, 6),
    )
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color(0x33F27B42),
      blurRadius: 16,
      offset: Offset(0, 4),
    )
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: bgApp,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: amber,
        surface: surface,
        onSurface: textMain,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.w800),
        titleLarge: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(color: textMain, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textMuted, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }
}
