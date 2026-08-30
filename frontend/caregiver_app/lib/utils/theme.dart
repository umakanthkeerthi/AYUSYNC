import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AyuTheme {
  // Brand Colors (matching Patient App AppTheme)
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF2DD4BF);
  static const Color primaryDark = Color(0xFF0F766E);
  
  static const Color bgApp = Color(0xFFF8F9FA); // backgroundLight
  static const Color surface = Colors.white; // surfaceWhite
  
  static const Color textMain = Color(0xFF1E293B); // textDark
  static const Color textMuted = Color(0xFF64748B); // textMuted

  // Additional Caregiver specific colors
  static const Color green = Color(0xFF10B981);
  static const Color greenBg = Color(0xFFECFDF5);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberBg = Color(0xFFFFFBEB);
  static const Color border = Color(0xFFE2E8F0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient alertGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
      color: Color(0x4D0D9488),
      blurRadius: 12,
      offset: Offset(0, 6),
    )
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color(0x330D9488),
      blurRadius: 16,
      offset: Offset(0, 4),
    )
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        background: bgApp,
        surface: surface,
      ),
      scaffoldBackgroundColor: bgApp,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textMain,
        displayColor: textMain,
      ).copyWith(
        displayLarge: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.w800),
        titleLarge: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.outfit(color: textMain, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textMain),
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
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
