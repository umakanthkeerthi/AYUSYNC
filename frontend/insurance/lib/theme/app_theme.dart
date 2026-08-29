import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color brandSidebar = Color(0xFF131940); // Deep navy from mockup
  static const Color brandActive = Color(0xFF3346d3); // Vibrant blue/purple from mockup
  static const Color brandBg = Color(0xFFF7F8FA); // Light gray background
  
  // Status Colors
  static const Color statPending = Color(0xFF1E293B); // Dark gray/black
  static const Color statApproved = Color(0xFF10B981); // Green
  static const Color statRejected = Color(0xFFEF4444); // Red
  static const Color statReview = Color(0xFFF59E0B); // Orange
  
  // Text & Border Colors
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color bgCard = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: brandActive,
      scaffoldBackgroundColor: brandBg,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgCard,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
    );
  }
}
